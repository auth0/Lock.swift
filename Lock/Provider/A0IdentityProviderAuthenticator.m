// A0IdentityProviderAuthenticator.m
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

#import "A0IdentityProviderAuthenticator.h"
#import "A0Strategy.h"
#import "A0Application.h"
#import "A0Errors.h"
#import "A0Lock.h"
#import "A0AuthParameters.h"
#import "NSObject+A0APIClientProvider.h"

#if __has_include(<Lock/A0WebViewAuthenticator.h>)
#define HAS_WEBVIEW_SUPPORT 1
#import <Lock/A0WebViewAuthenticator.h>
#endif
#import "Constants.h"

@interface A0IdentityProviderAuthenticator ()

@property (weak, nonatomic) id<A0APIClientProvider> clientProvider;
@property (strong, nonatomic) NSMutableDictionary *authenticators;
@property (assign, nonatomic) BOOL useWebAsDefault;

@end

@implementation A0IdentityProviderAuthenticator

AUTH0_DYNAMIC_LOGGER_METHODS

- (instancetype)initWithLock:(A0Lock *)lock {
    return [self initWithClientProvider:lock];
}

- (id)initWithClientProvider:(id<A0APIClientProvider>)clientProvider {
    self = [super init];
    if (self) {
        _authenticators = [@{} mutableCopy];
        _clientProvider = clientProvider;
        _useWebAsDefault = NO;
    }
    return self;
}

- (void)registerAuthenticationProviders:(NSArray *)authenticationProviders {
    [authenticationProviders enumerateObjectsUsingBlock:^(id<A0AuthenticationProvider> provider, NSUInteger idx, BOOL *stop) {
        [self registerAuthenticationProvider:provider];
    }];
}

- (void)registerAuthenticationProvider:(A0BaseAuthenticator *)authenticationProvider {
    NSAssert(authenticationProvider != nil, @"Must supply a non-nil profile");
    NSAssert(authenticationProvider.identifier != nil, @"Provider must have a valid indentifier");
    authenticationProvider.clientProvider = self.clientProvider;
    self.authenticators[authenticationProvider.identifier] = authenticationProvider;
}

- (void)authenticateWithConnectionName:(NSString * __nonnull)connectionName
                            parameters:(nullable A0AuthParameters *)parameters
                               success:(A0IdPAuthenticationBlock __nonnull)success
                               failure:(A0IdPAuthenticationErrorBlock __nonnull)failure {
    id<A0AuthenticationProvider> idp = self.authenticators[connectionName];
    //TODO: Once all IdP authenticators are changed remove this parameter dance.
    A0AuthParameters *params = [parameters copy];
    params[A0ParameterConnection] = connectionName;
    if (idp) {
        [idp authenticateWithParameters:params success:success failure:failure];
    } else {
#ifdef HAS_WEBVIEW_SUPPORT
        A0LogDebug(@"Authenticating %@ with WebView authenticator", connectionName);
        A0WebViewAuthenticator *authenticator = [[A0WebViewAuthenticator alloc] initWithConnectionName:connectionName client:[self a0_apiClientFromProvider:self.clientProvider]];
        [authenticator authenticateWithParameters:parameters success:success failure:failure];
#else
        A0LogWarn(@"No known provider for connection %@", connectionName);
        if (failure) {
            failure([A0Errors unkownProviderForConnectionName:connectionName]);
        }
#endif
    }
}

- (BOOL)handleURL:(NSURL *)url sourceApplication:(NSString *)application {
    __block BOOL handled = NO;
    [self.authenticators enumerateKeysAndObjectsUsingBlock:^(NSString *key, id<A0AuthenticationProvider> authenticator, BOOL *stop) {
        if ([authenticator respondsToSelector:@selector(handleURL:sourceApplication:)]) {
            handled = [authenticator handleURL:url sourceApplication:application];
        }
        *stop = handled;
    }];
    return handled;
}

- (void)clearSessions {
    [self.authenticators enumerateKeysAndObjectsUsingBlock:^(NSString *key, id<A0AuthenticationProvider> authenticator, BOOL *stop) {
        [authenticator clearSessions];
    }];

}

- (void)applicationLaunchedWithOptions:(NSDictionary *)launchOptions {
    [self.authenticators enumerateKeysAndObjectsUsingBlock:^(NSString *key, id<A0AuthenticationProvider> authenticator, BOOL *stop) {
        [authenticator applicationLaunchedWithOptions:launchOptions];
    }];
}

@end

@implementation A0IdentityProviderAuthenticator (Deprecated)

- (id)init {
    return [self initWithClientProvider:nil];
}

+ (A0IdentityProviderAuthenticator *)sharedInstance {
    static A0IdentityProviderAuthenticator *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[A0IdentityProviderAuthenticator alloc] init];
    });
    return instance;
}

- (void)configureForApplication:(A0Application *)application {
    //NOOP
}

- (void)authenticateForStrategyName:(NSString *)strategyName
                         parameters:(A0AuthParameters *)parameters
                            success:(void (^)(A0UserProfile *, A0Token *))success
                            failure:(void (^)(NSError *))failure {
    [self authenticateWithConnectionName:strategyName parameters:parameters success:success failure:failure];
}

- (void)authenticateForStrategy:(A0Strategy *)strategy
                     parameters:(A0AuthParameters *)parameters
                        success:(void(^)(A0UserProfile *profile, A0Token *token))success
                        failure:(void(^)(NSError *error))failure {
    [self authenticateForStrategyName:strategy.name parameters:parameters success:success failure:failure];
}

- (BOOL)canAuthenticateStrategy:(A0Strategy *)strategy {
    id<A0AuthenticationProvider> authenticator = self.authenticators[strategy.name];
    return authenticator != nil;
}

@end
