//
//  A0Application.m
//  Pods
//
//  Created by Hernan Zalazar on 7/4/14.
//
//

#import "A0Application.h"

#import "A0Strategy.h"
@implementation A0Application

- (instancetype)initWithJSONDictionary:(NSDictionary *)JSONDict {
    self = [super init];
    if (self) {
        NSAssert(JSONDict, @"Must supply non empty JSON dictionary");
        NSString *identifier = JSONDict[@"id"];
        NSString *tenant = JSONDict[@"tenant"];
        NSString *authorize = JSONDict[@"authorize"];
        NSString *callback = JSONDict[@"callback"];
        NSArray *array = JSONDict[@"strategies"];
        NSMutableArray *strategies = [@[] mutableCopy];
        [array enumerateObjectsUsingBlock:^(NSDictionary *strategyDict, NSUInteger idx, BOOL *stop) {
            [strategies addObject:[[A0Strategy alloc] initWithJSONDictionary:strategyDict]];
        }];
        NSAssert(identifier.length > 0, @"Must have a valid name");
        NSAssert(tenant.length > 0, @"Must have a valid tenant");
        NSAssert(authorize.length > 0, @"Must have a valid auhorize URL");
        NSAssert(callback, @"Must have a valid callback URL");
        NSAssert(strategies.count > 0, @"Must have at least 1 strategy");
        _identifier = identifier;
        _tenant = tenant;
        _authorizeURL = [NSURL URLWithString:authorize];
        _callbackURL = [NSURL URLWithString:callback];
        _strategies = [NSArray arrayWithArray:strategies];
    }
    return self;
}

- (BOOL)hasDatabaseConnection {
    NSInteger index = [self.strategies indexOfObjectPassingTest:^BOOL(A0Strategy *strategy, NSUInteger idx, BOOL *stop) {
        BOOL isAuth0Strategy = [strategy.name isEqualToString:@"auth0"];
        *stop = isAuth0Strategy;
        return isAuth0Strategy;
    }];
    return index != NSNotFound;
}

- (A0Strategy *)databaseStrategy {
    NSInteger index = [self.strategies indexOfObjectPassingTest:^BOOL(A0Strategy *strategy, NSUInteger idx, BOOL *stop) {
        BOOL isAuth0Strategy = [strategy.name isEqualToString:@"auth0"];
        *stop = isAuth0Strategy;
        return isAuth0Strategy;
    }];
    A0Strategy *strategy;
    if (index != NSNotFound) {
        strategy = self.strategies[index];
    }
    return strategy;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<A0Application id = '%@'; tenant = '%@' strategies = %@>", self.identifier, self.tenant, self.strategies];
}
@end
