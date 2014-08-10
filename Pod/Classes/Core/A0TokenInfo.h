//
//  A0TokenInfo.h
//  Pods
//
//  Created by Hernan Zalazar on 8/10/14.
//
//

#import <Foundation/Foundation.h>

@interface A0TokenInfo : NSObject

@property (readonly, nonatomic) NSString *accessToken;
@property (readonly, nonatomic) NSString *idToken;
@property (readonly, nonatomic) NSString *tokenType;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
