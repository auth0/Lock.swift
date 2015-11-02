//  A0StrategySpec.m
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

#import "A0LockTest.h"
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

    context(@"types", ^{

        specify(@"database type", ^{
            strategy = [[A0Strategy alloc] initWithJSONDictionary:@{ @"name": @"auth0" }];
            expect(strategy.type).to.equal(A0StrategyTypeDatabase);
        });

        specify(@"enterprise type", ^{
            strategy = [[A0Strategy alloc] initWithJSONDictionary:@{ @"name": @"ad" }];
            expect(strategy.type).to.equal(A0StrategyTypeEnterprise);
        });

        specify(@"social type", ^{
            strategy = [[A0Strategy alloc] initWithJSONDictionary:@{ @"name": @"twitter" }];
            expect(strategy.type).to.equal(A0StrategyTypeSocial);
        });

        specify(@"unkown type", ^{
            strategy = [[A0Strategy alloc] initWithJSONDictionary:@{ @"name": @"no known name" }];
            expect(strategy.type).to.equal(A0StrategyTypeSocial);
        });

    });
});

SpecEnd
