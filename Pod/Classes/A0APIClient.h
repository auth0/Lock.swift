//
//  A0APIClient.h
//  Pods
//
//  Created by Hernan Zalazar on 7/4/14.
//
//

#import <Foundation/Foundation.h>

typedef void(^A0APIClientSuccess)(id payload);
typedef void(^A0APIClientError)(NSError *error);

@interface A0APIClient : NSObject

- (instancetype)initWithClientId:(NSString *)clientId;

- (void)fetchAppInfoWithSuccess:(A0APIClientSuccess)success failure:(A0APIClientError)failure;

+ (instancetype)sharedClient;

@end
