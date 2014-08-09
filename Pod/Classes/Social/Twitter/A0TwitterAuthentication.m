//
//  A0TwitterAuthentication.m
//  Pods
//
//  Created by Hernan Zalazar on 8/9/14.
//
//

#import "A0TwitterAuthentication.h"

static NSString * const A0TwitterAuthenticationName = @"twitter";

@implementation A0TwitterAuthentication

+ (A0TwitterAuthentication *)newTwitterAuthentication {
    return [[A0TwitterAuthentication alloc] init];
}

#pragma mark - A0SocialProviderAuth

- (NSString *)identifier {
    return A0TwitterAuthenticationName;
}

- (BOOL)handleURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication {
    return NO;
}

- (void)authenticateWithSuccess:(void(^)(A0SocialCredentials *socialCredentials))success failure:(void(^)(NSError *))failure {
}

@end
