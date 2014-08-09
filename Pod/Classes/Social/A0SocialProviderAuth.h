//
//  A0SocialProviderAuth.h
//  Pods
//
//  Created by Hernan Zalazar on 7/28/14.
//
//

#import <Foundation/Foundation.h>

@protocol A0SocialProviderAuth <NSObject>

@required
- (NSString *)identifier;
- (void)authenticateWithSuccess:(void(^)(NSString *accessToken))success failure:(void(^)(NSError *))failure;

@optional
- (BOOL)handleURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication;

@end
