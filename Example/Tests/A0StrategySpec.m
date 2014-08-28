//
//  A0StrategySpec.m
//  Auth0Client
//
//  Created by Hernan Zalazar on 8/28/14.
//  Copyright 2014 Auth0. All rights reserved.
//

#import "Specta.h"
#import "A0Strategy.h"


#define kName @"facebook"

SpecBegin(A0Strategy)

describe(@"A0Strategy", ^{

    __block A0Strategy *strategy;

    context(@"creating from JSON", ^{

        beforeEach(^{
            strategy = [[A0Strategy alloc] initWithJSONDictionary:@{ @"name": kName }];
        });

        specify(@"valid name", ^{
            expect(strategy.name).to.equal(kName);
        });
    });
});

SpecEnd
