//
//  A0Strategy.m
//  Pods
//
//  Created by Hernan Zalazar on 7/6/14.
//
//

#import "A0Strategy.h"

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
