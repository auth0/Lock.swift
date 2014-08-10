//
//  A0APIClient.h
//  Pods
//
//  Created by Hernan Zalazar on 7/4/14.
//
//

#import <Foundation/Foundation.h>

@class A0Application, A0Strategy, A0SocialCredentials, A0UserProfile;

typedef void(^A0APIClientFetchAppInfoSuccess)(id payload);
typedef void(^A0APIClientAuthenticationSuccess)(A0UserProfile *profile);
typedef void(^A0APIClientError)(NSError *error);

@interface A0APIClient : NSObject

- (void)configureForApplication:(A0Application *)application;

- (instancetype)initWithClientId:(NSString *)clientId;

- (void)fetchAppInfoWithSuccess:(A0APIClientFetchAppInfoSuccess)success failure:(A0APIClientError)failure;

- (void)loginWithUsername:(NSString *)username password:(NSString *)password success:(A0APIClientAuthenticationSuccess)success failure:(A0APIClientError)failure;

- (void)signUpWithUsername:(NSString *)username password:(NSString *)password success:(A0APIClientAuthenticationSuccess)success failure:(A0APIClientError)failure;

- (void)changePassword:(NSString *)newPassword forUsername:(NSString *)username success:(A0APIClientAuthenticationSuccess)success failure:(A0APIClientError)failure;

- (void)authenticateWithSocialStrategy:(A0Strategy *)strategy socialCredentials:(A0SocialCredentials *)socialCredentials success:(A0APIClientAuthenticationSuccess)success failure:(A0APIClientError)failure;

+ (instancetype)sharedClient;

@end
