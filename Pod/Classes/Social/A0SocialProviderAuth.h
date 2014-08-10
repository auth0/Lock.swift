//
//  A0SocialAuthenticationProvider.h
//  Pods
//
//  Created by Hernan Zalazar on 7/28/14.
//
//

#import <Foundation/Foundation.h>
#import "A0SocialCredentials.h"

@protocol A0SocialAuthenticationProvider <NSObject>

@required
- (NSString *)identifier;
- (void)authenticateWithSuccess:(void(^)(A0SocialCredentials *socialCredentials))success failure:(void(^)(NSError *))failure;

@optional
- (BOOL)handleURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication;

@end
