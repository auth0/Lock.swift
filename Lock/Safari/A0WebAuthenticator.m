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

#import <UIKit/UIKit.h>

#import "A0WebAuthenticator.h"
#import <Lock/A0Application.h>
#import <Lock/A0Strategy.h>
#import <Lock/NSDictionary+A0QueryParameters.h>
#import <Lock/A0UserProfile.h>
#import <Lock/A0Token.h>
#import <Lock/A0APIClient.h>
#import <Lock/A0Errors.h>
#import <Lock/A0WebAuthentication.h>
#import <Lock/A0AuthParameters.h>
#import <Lock/NSObject+A0APIClientProvider.h>
#import "Constants.h"

@interface A0WebAuthenticator ()

@property (strong, nonatomic) A0AuthParameters *parameters;
@property (strong, nonatomic) NSString *connectionName;
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

- (instancetype)initWithAuthorizeURL:(NSURL *)authorizeURL clientId:(NSString *)clientId connectionName:(NSString *)connectionName {
    self = [self init];
    if (self) {
        _authentication = [[A0WebAuthentication alloc] initWithClientId:clientId domainURL:authorizeURL connectionName:connectionName];
        NSURLComponents *components = [[NSURLComponents alloc] initWithURL:authorizeURL resolvingAgainstBaseURL:NO];
        A0AuthParameters *parameters = [A0AuthParameters newWithDictionary:@{
                                                                             @"response_type": @"token",
                                                                             @"connection": connectionName,
                                                                             @"client_id": clientId,
                                                                             @"redirect_uri": _authentication.callbackURL.absoluteString,
                                                                             }];
        _connectionName = connectionName;
        _parameters = parameters;
        _components = components;
    }
    return self;
}

- (instancetype)initWithStrategy:(A0Strategy *)strategy
                     application:(A0Application *)application {
    return [self initWithAuthorizeURL:application.authorizeURL clientId:application.identifier connectionName:[strategy.connections.firstObject name]];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applicationActiveNotification:(NSNotification *)notification {
    if (self.failureBlock) {
        self.failureBlock([A0Errors auth0CancelledForConnectionName:self.connectionName]);
    }
    [self clearBlocks];
}

+ (instancetype)newWebAuthenticationForStrategy:(A0Strategy *)strategy
                                  ofApplication:(A0Application *)application {
    return [[A0WebAuthenticator alloc] initWithStrategy:strategy
                                             application:application];
}

- (NSString *)identifier {
    return self.connectionName;
}

- (void)clearSessions {
    [self clearBlocks];
}

- (BOOL)handleURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication {
    A0LogVerbose(@"Received url %@ from source application %@", url, sourceApplication);
    BOOL handled = [self.authentication validateURL:url];
    if (handled) {
        NSError *error;
        A0Token *token = [self.authentication tokenFromURL:url error:&error];
        if (token) {
            void(^success)(A0UserProfile *, A0Token *) = self.successBlock;
            A0APIClient *client = [self a0_apiClientFromProvider:self.clientProvider];
            [client fetchUserProfileWithIdToken:token.idToken success:^(A0UserProfile *profile) {
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
        A0LogDebug(@"Opening web authentication wit URL %@", authorizeURL);
        [[UIApplication sharedApplication] openURL:authorizeURL];
    } else {
        A0LogError(@"Scheme %@ not configured in CFBundleURLTypes", self.authentication.callbackURL.scheme);
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
