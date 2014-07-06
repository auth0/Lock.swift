//
//  A0Strategy.h
//  Pods
//
//  Created by Hernan Zalazar on 7/6/14.
//
//

#import <Foundation/Foundation.h>

@interface A0Strategy : NSObject

@property (strong, nonatomic, readonly) NSString *name;
@property (strong, nonatomic, readonly) NSDictionary *connection;

- (instancetype)initWithJSONDictionary:(NSDictionary *)JSONDictionary;

@end
