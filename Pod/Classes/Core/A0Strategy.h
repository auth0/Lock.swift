//
//  A0Strategy.h
//  Pods
//
//  Created by Hernan Zalazar on 7/6/14.
//
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString * const A0TwitterAuthenticationName;
FOUNDATION_EXPORT NSString * const A0FacebookAuthenticationName;

FOUNDATION_EXPORT NSString * const A0StrategySocialTokenParameter;
FOUNDATION_EXPORT NSString * const A0StrategySocialTokenSecretParameter;
FOUNDATION_EXPORT NSString * const A0StrategySocialUserIdParameter;

@interface A0Strategy : NSObject

@property (strong, nonatomic, readonly) NSString *name;
@property (strong, nonatomic, readonly) NSDictionary *connection;

- (instancetype)initWithJSONDictionary:(NSDictionary *)JSONDictionary;

@end
