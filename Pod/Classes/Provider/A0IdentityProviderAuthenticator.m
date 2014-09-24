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
#import "A0WebAuthentication.h"

@interface A0IdentityProviderAuthenticator ()

@property (strong, nonatomic) NSMutableDictionary *registeredAuthenticators;
@property (strong, nonatomic) NSMutableDictionary *authenticators;

@end

@implementation A0IdentityProviderAuthenticator

+ (A0IdentityProviderAuthenticator *)sharedInstance {
    static A0IdentityProviderAuthenticator *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[A0IdentityProviderAuthenticator alloc] init];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        _registeredAuthenticators = [@{} mutableCopy];
        _useWebAsDefault = YES;
    }
    return self;
}

- (void)registerAuthenticatorProviders:(NSArray *)authenticatorProviders {
    [authenticatorProviders enumerateObjectsUsingBlock:^(id<A0AuthenticationProvider> provider, NSUInteger idx, BOOL *stop) {
        [self registerAuthenticatorProvider:provider];
    }];
}

- (void)registerAuthenticatorProvider:(id<A0AuthenticationProvider>)authenticatorProvider {
    NSAssert(authenticatorProvider != nil, @"Must supply a non-nil profile");
    NSAssert(authenticatorProvider.identifier != nil, @"Provider must have a valid indentifier");
    self.registeredAuthenticators[authenticatorProvider.identifier] = authenticatorProvider;
}

- (void)configureForApplication:(A0Application *)application {
    self.authenticators = [@{} mutableCopy];
    [application.availableSocialOrEnterpriseStrategies enumerateObjectsUsingBlock:^(A0Strategy *strategy, NSUInteger idx, BOOL *stop) {
        if (self.registeredAuthenticators[strategy.name]) {
            self.authenticators[strategy.name] = self.registeredAuthenticators[strategy.name];
        } else if (self.useWebAsDefault) {
            self.authenticators[strategy.name] = [A0WebAuthentication newWebAuthenticationForStrategy:strategy ofApplication:application];
        }
    }];
}

- (BOOL)canAuthenticateStrategy:(A0Strategy *)strategy {
    id<A0AuthenticationProvider> authenticator = self.authenticators[strategy.name];
    return authenticator != nil;
}

- (void)authenticateForStrategy:(A0Strategy *)strategy
                    withSuccess:(void(^)(A0UserProfile *profile, A0Token *token))success
                        failure:(void (^)(NSError *))failure {
    id<A0AuthenticationProvider> authenticator = self.authenticators[strategy.name];
    if (authenticator) {
        [authenticator authenticateWithSuccess:success failure:failure];
    } else {
        Auth0LogWarn(@"No known provider for strategy %@", strategy.name);
        if (failure) {
            failure([A0Errors unkownProviderForStrategy:strategy.name]);
        }
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

@end
