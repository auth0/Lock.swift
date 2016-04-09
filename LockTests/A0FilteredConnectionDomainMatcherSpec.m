//  A0FilteredConnectionDomainMatcherSpec.m
//
// Copyright (c) 2014 Auth0 (http://auth0.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#define QUICK_DISABLE_SHORT_SYNTAX 1

#import <Quick/Quick.h>
#import <Nimble/Nimble.h>
#import "A0FilteredConnectionDomainMatcher.h"
#import "A0Strategy.h"
#import "A0Connection.h"

QuickSpecBegin(A0FilteredConnectionDomainMatcherSpec)

describe(@"A0FilteredConnectionDomainMatcher", ^{

    __block A0FilteredConnectionDomainMatcher *matcher;

    describe(NSStringFromSelector(@selector(initWithStrategies:filter:)), ^{

        __block A0Strategy *strategy;
        __block A0Strategy *filterStrategy;

        beforeEach(^{
            strategy = [[A0Strategy alloc] initWithJSONDictionary:@{
                                                                    @"name": A0StrategyNameADFS,
                                                                    @"connections": @[
                                                                                        @{
                                                                                            @"name": @"myADFS",
                                                                                            @"domain": @"adfs.com",
                                                                                        },
                                                                                    ]
                                                                    }];
            filterStrategy = [[A0Strategy alloc] initWithJSONDictionary:@{
                                                                        @"name": A0StrategyNameActiveDirectory,
                                                                        @"connections": @[
                                                                                @{
                                                                                    @"name": @"myAD",
                                                                                    @"domain": @"ad.com",
                                                                                    },
                                                                                ]
                                                                        }];
        });

        it(@"should instantiate with at least one strategy", ^{
            matcher = [[A0FilteredConnectionDomainMatcher alloc] initWithStrategies:@[strategy] filter:@[A0StrategyNameActiveDirectory]];
            expect(matcher).toNot(beNil());
        });

        it(@"should pick connection with domain", ^{
            matcher = [[A0FilteredConnectionDomainMatcher alloc] initWithStrategies:@[strategy] filter:@[A0StrategyNameActiveDirectory]];
            expect([[matcher valueForKeyPath:@"connections"] allKeys]).to(equal(@[@"myADFS"]));
            expect([[matcher valueForKeyPath:@"domains"] allKeys]).to(equal(@[@"myADFS"]));
        });

        it(@"should pick connections from unfiltered strategies", ^{
            matcher = [[A0FilteredConnectionDomainMatcher alloc] initWithStrategies:@[strategy, filterStrategy] filter:@[A0StrategyNameActiveDirectory]];
            expect([[matcher valueForKeyPath:@"connections"] allKeys]).to(equal(@[@"myADFS"]));
            expect([[matcher valueForKeyPath:@"domains"] allKeys]).to(equal(@[@"myADFS"]));
        });

        it(@"should not pick connection without domain", ^{
            A0Strategy *noDomain = [[A0Strategy alloc] initWithName:@"MyStrategy" connections:@[] type:A0StrategyTypeEnterprise];
            matcher = [[A0FilteredConnectionDomainMatcher alloc] initWithStrategies:@[noDomain] filter:@[A0StrategyNameActiveDirectory]];
            expect([matcher valueForKeyPath:@"connections"]).to(beEmpty());
            expect([matcher valueForKeyPath:@"domains"]).to(beEmpty());
        });

        it(@"should pick connections from unfiltered strategies", ^{
            matcher = [[A0FilteredConnectionDomainMatcher alloc] initWithStrategies:@[strategy, filterStrategy] filter:@[]];
            expect([[matcher valueForKeyPath:@"connections"] allKeys]).to(contain(@"myADFS", @"myAD"));
            expect([[matcher valueForKeyPath:@"domains"] allKeys]).to(contain(@"myADFS", @"myAD"));
        });
    });
});

QuickSpecEnd
