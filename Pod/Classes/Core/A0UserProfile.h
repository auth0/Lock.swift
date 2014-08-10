//
//  A0UserProfile.h
//  Pods
//
//  Created by Hernan Zalazar on 8/10/14.
//
//

#import <Foundation/Foundation.h>

@class A0TokenInfo;

@interface A0UserProfile : NSObject

@property (readonly, nonatomic) NSString *userId;
@property (readonly, nonatomic) NSString *name;
@property (readonly, nonatomic) NSString *nickname;
@property (readonly, nonatomic) NSString *email;
@property (readonly, nonatomic) NSURL *picture;
@property (readonly, nonatomic) NSDate *createdAt;
@property (readonly, nonatomic) A0TokenInfo *tokenInfo;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
