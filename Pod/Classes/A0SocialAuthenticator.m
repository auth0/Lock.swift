//
//  A0SocialAuthenticator.m
//  Pods
//
//  Created by Hernan Zalazar on 7/28/14.
//
//

#import "A0SocialAuthenticator.h"
#import "A0FacebookAuthentication.h"
#import "A0Strategy.h"
#import "A0Application.h"

@interface A0SocialAuthenticator ()

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

- (void)configureForApplication:(A0Application *)application {
    self.authenticators = [@{} mutableCopy];
    [application.availableSocialStrategies enumerateObjectsUsingBlock:^(A0Strategy *strategy, NSUInteger idx, BOOL *stop) {
        if ([strategy.name isEqualToString:@"facebook"]) {
            self.authenticators[@"facebook"] = [[A0FacebookAuthentication alloc] init];
        }
    }];
}

- (void)authenticateForStrategy:(A0Strategy *)strategy
                    withSuccess:(void (^)(NSString *))success
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
