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
#import "Constants.h"
#import "A0FailureAuthenticator.h"

#if TARGET_OS_IOS && __has_include(<Lock/A0WebViewAuthenticator.h>)
#define HAS_WEBVIEW_SUPPORT 1
#import <Lock/A0WebViewAuthenticator.h>
#endif

@interface A0IdentityProviderAuthenticator ()

@property (weak, nonatomic) A0Lock *lock;
@property (strong, nonatomic) NSMutableDictionary *authenticators;
@property (assign, nonatomic) BOOL useWebAsDefault;

@end

@implementation A0IdentityProviderAuthenticator

- (instancetype)initWithLock:(A0Lock *)lock {
    self = [super init];
    if (self) {
        _authenticators = [@{} mutableCopy];
        _lock = lock;
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
    authenticationProvider.clientProvider = self.lock;
    self.authenticators[authenticationProvider.identifier] = authenticationProvider;
}

- (void)authenticateWithConnectionName:(NSString * __nonnull)connectionName
                            parameters:(nullable A0AuthParameters *)parameters
                               success:(A0IdPAuthenticationBlock __nonnull)success
                               failure:(A0IdPAuthenticationErrorBlock __nonnull)failure {
    A0AuthParameters *params = [parameters copy];
    id<A0AuthenticationProvider> idp = [self providerForConnectionName:connectionName];
    [idp authenticateWithParameters:params success:success failure:failure];
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

    [[self defaultProviderForConnectionName:@"auth0"] clearSessions];
}

- (void)applicationLaunchedWithOptions:(NSDictionary *)launchOptions {
    [self.authenticators enumerateKeysAndObjectsUsingBlock:^(NSString *key, id<A0AuthenticationProvider> authenticator, BOOL *stop) {
        [authenticator applicationLaunchedWithOptions:launchOptions];
    }];
}

- (id<A0AuthenticationProvider>)defaultProviderForConnectionName:(NSString *)connectionName {
#ifdef HAS_WEBVIEW_SUPPORT
    return [[A0WebViewAuthenticator alloc] initWithConnectionName:connectionName lock:self.lock];
#else
    return [[A0FailureAuthenticator alloc] initWithConnectionName:connectionName];
#endif
}

- (id<A0AuthenticationProvider>)providerForConnectionName:(NSString *)connectionName {
    id<A0AuthenticationProvider> provider = self.authenticators[connectionName];
    if (!provider) {
        provider = [self defaultProviderForConnectionName:connectionName];
    }
    A0LogDebug(@"Provider %@ for connection %@", NSStringFromClass([provider class]), connectionName);
    return provider;
}

@end

@implementation A0IdentityProviderAuthenticator (Deprecated)

- (id)init {
    return [self initWithLock:[A0Lock sharedLock]];
}

+ (A0IdentityProviderAuthenticator *)sharedInstance {
    static A0IdentityProviderAuthenticator *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[A0IdentityProviderAuthenticator alloc] init];
    });
    return instance;
}

- (void)configureForApplication:(A0Application *)application {}

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
