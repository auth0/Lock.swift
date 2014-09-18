//  A0WebAuthentication.m
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

#import "A0WebAuthentication.h"
#import "A0Application.h"
#import "A0Strategy.h"
#import "NSDictionary+A0QueryParameters.h"
#import "A0UserProfile.h"
#import "A0Token.h"
#import "A0APIClient.h"
#import "A0Errors.h"

#define kCallbackURLString @"a0%@://%@.auth.com/authorize"

@interface A0WebAuthentication ()

@property (strong, nonatomic) A0Strategy *strategy;
@property (strong, nonatomic) NSURL *authorizeURL;
@property (strong, nonatomic) NSString *redirectURI;
@property (copy, nonatomic) void(^successBlock)(A0UserProfile *, A0Token *);
@property (copy, nonatomic) void(^failureBlock)(NSError *);

@end

@implementation A0WebAuthentication

- (id)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applicationActiveNotification:(NSNotification *)notification {
    if (self.failureBlock) {
        self.failureBlock([A0Errors auth0Cancelled]);
    }
    [self clearBlocks];
}

+ (instancetype)newWebAuthenticationForStrategy:(A0Strategy *)strategy
                                  ofApplication:(A0Application *)application {
    A0WebAuthentication *auth = [[A0WebAuthentication alloc] init];
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:application.authorizeURL resolvingAgainstBaseURL:NO];
    NSString *connectionName = strategy.connection[@"name"];
    NSString *redirectURI = [NSString stringWithFormat:kCallbackURLString, application.identifier, connectionName].lowercaseString;
    NSDictionary *parameters = @{
                                 @"scope": [[A0APIClient sharedClient] defaultScopeValue],
                                 @"response_type": @"token",
                                 @"connection": connectionName,
                                 @"client_id": application.identifier,
                                 @"redirect_uri": redirectURI,
                                 };
    if ([[[A0APIClient sharedClient] defaultScopes] containsObject:A0APIClientScopeOfflineAccess]) {
        NSMutableDictionary *dict = [parameters mutableCopy];
        dict[@"device"] = [[UIDevice currentDevice] name];
        parameters = dict;
    }
    components.query = parameters.queryString;
    auth.strategy = strategy;
    auth.authorizeURL = components.URL;
    auth.redirectURI = redirectURI;
    return auth;
}

- (NSString *)identifier {
    return self.strategy.name;
}

- (void)clearSessions {
    [self clearBlocks];
}

- (BOOL)handleURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication {
    Auth0LogVerbose(@"Received url %@ from source application %@", url, sourceApplication);
    BOOL handled = [url.absoluteString.lowercaseString hasPrefix:self.redirectURI];
    if (handled) {
        NSString *queryString = url.query ?: url.fragment;
        NSDictionary *params = [NSDictionary fromQueryString:queryString];
        Auth0LogDebug(@"Received params %@ from URL %@", params, url);
        NSString *errorMessage = params[@"error"];
        if (errorMessage) {
            NSError *error = [errorMessage isEqualToString:@"access_denied"] ? [A0Errors auth0NotAuthorized] : [A0Errors auth0InvalidConfigurationForStrategy:self.strategy.name];
            if (self.failureBlock) {
                self.failureBlock(error);
            }
        } else {
            NSString *accessToken = params[@"access_token"];
            NSString *idToken = params[@"id_token"];
            NSString *tokenType = params[@"token_type"];
            NSString *refreshToken = params[@"refresh_token"];
            if (idToken) {
                A0Token *token = [[A0Token alloc] initWithAccessToken:accessToken idToken:idToken tokenType:tokenType refreshToken:refreshToken];
                void(^success)(A0UserProfile *, A0Token *) = self.successBlock;
                [[A0APIClient sharedClient] fetchUserProfileWithIdToken:idToken success:^(A0UserProfile *profile) {
                    if (success) {
                        success(profile, token);
                    }
                } failure:self.failureBlock];
            } else {
                Auth0LogError(@"Failed to obtain id_token from URL %@", url);
                if (self.failureBlock) {
                    self.failureBlock([A0Errors auth0NotAuthorized]);
                }
            }
        }
        [self clearBlocks];
    }
    return handled;
}

- (void)authenticateWithSuccess:(void(^)(A0UserProfile *, A0Token *))success
                        failure:(void(^)(NSError *))failure {
    self.successBlock = success;
    self.failureBlock = failure;
    Auth0LogDebug(@"Opening web authentication wit URL %@", self.authorizeURL);
    [[UIApplication sharedApplication] openURL:self.authorizeURL];
}

#pragma mark - Utility methods

- (void)clearBlocks {
    self.successBlock = nil;
    self.failureBlock = nil;
}

@end
