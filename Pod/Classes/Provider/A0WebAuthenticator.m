//  A0WebAuthenticator.m
//
// Copyright (c) 2014 Auth0 (http://auth0.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "A0WebAuthenticator.h"
#import "A0Application.h"
#import "A0Strategy.h"
#import "NSDictionary+A0QueryParameters.h"
#import "A0UserProfile.h"
#import "A0Token.h"
#import "A0APIClient.h"
#import "A0Errors.h"
#import "A0WebAuthentication.h"
#import "A0AuthParameters.h"

@interface A0WebAuthenticator ()

@property (strong, nonatomic) A0AuthParameters *parameters;
@property (strong, nonatomic) A0Strategy *strategy;
@property (strong, nonatomic) NSURLComponents *components;
@property (strong, nonatomic) A0WebAuthentication *authentication;
@property (copy, nonatomic) void(^successBlock)(A0UserProfile *, A0Token *);
@property (copy, nonatomic) void(^failureBlock)(NSError *);

@end

@implementation A0WebAuthenticator

- (id)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (instancetype)initWithStrategy:(A0Strategy *)strategy
                     application:(A0Application *)application {
    self = [self init];
    if (self) {
        _authentication = [[A0WebAuthentication alloc] initWithApplication:application strategy:strategy];
        NSURLComponents *components = [[NSURLComponents alloc] initWithURL:application.authorizeURL resolvingAgainstBaseURL:NO];
        NSString *connectionName = [strategy.connections.firstObject name];
        A0AuthParameters *parameters = [A0AuthParameters newWithDictionary:@{
                                                                             @"response_type": @"token",
                                                                             @"connection": connectionName,
                                                                             @"client_id": application.identifier,
                                                                             @"redirect_uri": _authentication.callbackURL.absoluteString,
                                                                             }];
        _parameters = parameters;
        _strategy = strategy;
        _components = components;
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applicationActiveNotification:(NSNotification *)notification {
    if (self.failureBlock) {
        self.failureBlock([A0Errors auth0CancelledForStrategy:self.strategy.name]);
    }
    [self clearBlocks];
}

+ (instancetype)newWebAuthenticationForStrategy:(A0Strategy *)strategy
                                  ofApplication:(A0Application *)application {
    return [[A0WebAuthenticator alloc] initWithStrategy:strategy
                                             application:application];
}

- (NSString *)identifier {
    return self.strategy.name;
}

- (void)clearSessions {
    [self clearBlocks];
}

- (BOOL)handleURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication {
    Auth0LogVerbose(@"Received url %@ from source application %@", url, sourceApplication);
    BOOL handled = [self.authentication validateURL:url];
    if (handled) {
        NSError *error;
        A0Token *token = [self.authentication tokenFromURL:url error:&error];
        if (token) {
            void(^success)(A0UserProfile *, A0Token *) = self.successBlock;
            [[A0APIClient sharedClient] fetchUserProfileWithIdToken:token.idToken success:^(A0UserProfile *profile) {
                if (success) {
                    success(profile, token);
                }
            } failure:self.failureBlock];
        } else {
            if (self.failureBlock) {
                self.failureBlock(error);
            }
        }
        [self clearBlocks];
    }
    return handled;
}

- (void)authenticateWithParameters:(A0AuthParameters *)parameters
                           success:(void (^)(A0UserProfile *, A0Token *))success
                           failure:(void (^)(NSError *))failure {
    if ([self hasAuth0Scheme]) {
        self.successBlock = success;
        self.failureBlock = failure;
        A0AuthParameters *defaultParameters = self.parameters.copy;
        [defaultParameters addValuesFromParameters:parameters];
        NSDictionary *payload = [defaultParameters asAPIPayload];
        self.components.query = payload.queryString;
        NSURL *authorizeURL = self.components.URL;
        Auth0LogDebug(@"Opening web authentication wit URL %@", authorizeURL);
        [[UIApplication sharedApplication] openURL:authorizeURL];
    } else {
        Auth0LogError(@"Scheme %@ not configured in CFBundleURLTypes", self.authentication.callbackURL.scheme);
        failure([A0Errors urlSchemeNotRegistered]);
    }
}

#pragma mark - Utility methods

- (BOOL)hasAuth0Scheme {
    __block BOOL hasScheme = NO;
    NSDictionary *bundleInfo = [[NSBundle mainBundle] infoDictionary];
    NSArray *urlTypes = bundleInfo[@"CFBundleURLTypes"];
    [urlTypes enumerateObjectsUsingBlock:^(NSDictionary *urlType, NSUInteger idx, BOOL *stop) {
        NSArray *schemes = urlType[@"CFBundleURLSchemes"];
        for (NSString *scheme in schemes) {
            hasScheme = [scheme.lowercaseString isEqualToString:self.authentication.callbackURL.scheme];
            *stop = hasScheme;
        }
    }];
    return hasScheme;
}

- (void)clearBlocks {
    self.successBlock = nil;
    self.failureBlock = nil;
}

@end
