// A0SocialAuthenticator.m
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

#import "A0SocialAuthenticator.h"
#import "A0Strategy.h"
#import "A0Application.h"

@interface A0SocialAuthenticator ()

@property (strong, nonatomic) NSMutableDictionary *registeredAuthenticators;
@property (strong, nonatomic) NSMutableDictionary *authenticators;

@end

@implementation A0SocialAuthenticator

+ (A0SocialAuthenticator *)sharedInstance {
    static A0SocialAuthenticator *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[A0SocialAuthenticator alloc] init];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        _registeredAuthenticators = [@{} mutableCopy];
    }
    return self;
}

- (void)registerSocialAuthenticatorProviders:(NSArray *)socialAuthenticatorProviders {
    [socialAuthenticatorProviders enumerateObjectsUsingBlock:^(id<A0SocialAuthenticationProvider> provider, NSUInteger idx, BOOL *stop) {
        [self registerSocialAuthenticatorProvider:provider];
    }];
}

- (void)registerSocialAuthenticatorProvider:(id<A0SocialAuthenticationProvider>)socialProviderAuth {
    self.registeredAuthenticators[socialProviderAuth.identifier] = socialProviderAuth;
}

- (void)configureForApplication:(A0Application *)application {
    self.authenticators = [@{} mutableCopy];
    [application.availableSocialStrategies enumerateObjectsUsingBlock:^(A0Strategy *strategy, NSUInteger idx, BOOL *stop) {
        if (self.registeredAuthenticators[strategy.name]) {
            self.authenticators[strategy.name] = self.registeredAuthenticators[strategy.name];
        }
    }];
}

- (void)authenticateForStrategy:(A0Strategy *)strategy
                    withSuccess:(void (^)(A0SocialCredentials *))success
                        failure:(void (^)(NSError *))failure {
    id<A0SocialAuthenticationProvider> authenticator = self.authenticators[strategy.name];
    [authenticator authenticateWithSuccess:success failure:failure];
}

- (BOOL)handleURL:(NSURL *)url sourceApplication:(NSString *)application {
    __block BOOL handled = NO;
    [self.authenticators enumerateKeysAndObjectsUsingBlock:^(NSString *key, id<A0SocialAuthenticationProvider> authenticator, BOOL *stop) {
        handled = [authenticator handleURL:url sourceApplication:application];
        *stop = handled;
    }];
    return handled;
}
@end
