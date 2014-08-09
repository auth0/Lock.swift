//
//  A0SocialAuthenticator.m
//  Pods
//
//  Created by Hernan Zalazar on 7/28/14.
//
//

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

- (void)registerSocialProviderAuth:(id<A0SocialProviderAuth>)socialProviderAuth {
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
    id<A0SocialProviderAuth> authenticator = self.authenticators[strategy.name];
    [authenticator authenticateWithSuccess:success failure:failure];
}

- (BOOL)handleURL:(NSURL *)url sourceApplication:(NSString *)application {
    __block BOOL handled = NO;
    [self.authenticators enumerateKeysAndObjectsUsingBlock:^(NSString *key, id<A0SocialProviderAuth> authenticator, BOOL *stop) {
        handled = [authenticator handleURL:url sourceApplication:application];
        *stop = handled;
    }];
    return handled;
}
@end
