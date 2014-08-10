//
//  A0Strategy.m
//  Pods
//
//  Created by Hernan Zalazar on 7/6/14.
//
//

#import "A0Strategy.h"

NSString * const A0TwitterAuthenticationName = @"twitter";
NSString * const A0FacebookAuthenticationName = @"facebook";

NSString * const A0StrategySocialTokenParameter = @"access_token";
NSString * const A0StrategySocialTokenSecretParameter = @"access_token_secret";
NSString * const A0StrategySocialUserIdParameter = @"user_id";

@implementation A0Strategy

- (instancetype)initWithJSONDictionary:(NSDictionary *)JSONDictionary {
    self = [super init];
    if (self) {
        _name = JSONDictionary[@"name"];
        _connection = [JSONDictionary[@"connections"] firstObject];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<A0Strategy name = '%@' connection = %@>", self.name, self.connection];
}

@end
