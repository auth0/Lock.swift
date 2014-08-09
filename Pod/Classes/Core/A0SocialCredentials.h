//
//  A0SocialCredentials.h
//  Pods
//
//  Created by Hernan Zalazar on 8/9/14.
//
//

#import <Foundation/Foundation.h>

@interface A0SocialCredentials : NSObject

@property (readonly, nonatomic) NSString *accessToken;

@property (readonly, nonatomic) NSDictionary *extraInfo;

- (instancetype)initWithAccessToken:(NSString *)accessToken extraInfo:(NSDictionary *)extraInfo;
- (instancetype)initWithAccessToken:(NSString *)accessToken;

@end
