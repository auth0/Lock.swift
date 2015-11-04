//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#import <Lock/Lock.h>
#import <AFNetworking/AFNetworking.h>
#import "A0AnnotatedRequestSerializer.h"
#import "A0PKCE.h"

@interface A0APIClient (TestingOnly)

@property (strong, nonatomic) AFHTTPSessionManager *manager;

- (void)configureForApplication:(A0Application *)application;

@end