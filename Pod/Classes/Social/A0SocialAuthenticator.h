//
//  A0SocialAuthenticator.h
//  Pods
//
//  Created by Hernan Zalazar on 7/28/14.
//
//

#import <Foundation/Foundation.h>
#import "A0SocialProviderAuth.h"

@class A0Application, A0Strategy;

@interface A0SocialAuthenticator : NSObject

+ (A0SocialAuthenticator *)sharedInstance;

- (void)registerSocialAuthenticatorProviders:(NSArray *)socialAuthenticatorProviders;
- (void)registerSocialAuthenticatorProvider:(id<A0SocialAuthenticationProvider>)socialAuthenticatorProvider;
- (void)configureForApplication:(A0Application *)application;
- (void)authenticateForStrategy:(A0Strategy *)strategy withSuccess:(void(^)(A0SocialCredentials *socialCredentials))success failure:(void(^)(NSError *error))failure;
- (BOOL)handleURL:(NSURL *)url sourceApplication:(NSString *)application;

@end
