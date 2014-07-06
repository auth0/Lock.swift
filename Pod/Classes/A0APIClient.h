//
//  A0APIClient.h
//  Pods
//
//  Created by Hernan Zalazar on 7/4/14.
//
//

#import <Foundation/Foundation.h>

@class A0Application;

typedef void(^A0APIClientSuccess)(id payload);
typedef void(^A0APIClientError)(NSError *error);

@interface A0APIClient : NSObject

- (void)configureForApplication:(A0Application *)application;

- (instancetype)initWithClientId:(NSString *)clientId;

- (void)fetchAppInfoWithSuccess:(A0APIClientSuccess)success failure:(A0APIClientError)failure;

- (void)loginWithUsername:(NSString *)username password:(NSString *)password success:(A0APIClientSuccess)success failure:(A0APIClientError)failure;

+ (instancetype)sharedClient;

@end
