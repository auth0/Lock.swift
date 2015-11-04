//  A0SimpleConnectionDomainMatcherSpec.m
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
#import "A0SimpleConnectionDomainMatcher.h"
#import "A0Strategy.h"
#import "A0Connection.h"

SpecBegin(A0SimpleConnectionDomainMatcherSpec)

describe(@"A0SimpleConnectionDomainMatcherSpec", ^{

    __block A0SimpleConnectionDomainMatcher *matcher;

    __block A0Strategy *strategy;
    __block A0Connection *connection;

    beforeEach(^{
        strategy = mock(A0Strategy.class);
        connection = mock(A0Connection.class);
        [given(strategy.connections) willReturn:@[connection]];
        [given(connection.name) willReturn:@"MyAD"];
    });

    describe(NSStringFromSelector(@selector(initWithStrategies:)), ^{

        it(@"should instantiate with at least one strategy", ^{
            matcher = [[A0SimpleConnectionDomainMatcher alloc] initWithStrategies:@[strategy]];
            expect(matcher).toNot.beNil();
        });

        it(@"should pick connection with domain", ^{
            [given([connection objectForKeyedSubscript:@"domain"]) willReturn:@"mydomain.com"];
            matcher = [[A0SimpleConnectionDomainMatcher alloc] initWithStrategies:@[strategy]];
            expect([matcher valueForKeyPath:@"connections"]).toNot.beEmpty();
            expect([matcher valueForKeyPath:@"domains"]).toNot.beEmpty();
        });

        it(@"should not pick connection without domain", ^{
            [given(connection.values) willReturn:@{}];
            matcher = [[A0SimpleConnectionDomainMatcher alloc] initWithStrategies:@[strategy]];
            expect([matcher valueForKeyPath:@"connections"]).to.beEmpty();
            expect([matcher valueForKeyPath:@"domains"]).to.beEmpty();
        });

        it(@"should not pick connection with domain as null", ^{
            [given(connection.values) willReturn:@{@"domain": [NSNull null]}];
            matcher = [[A0SimpleConnectionDomainMatcher alloc] initWithStrategies:@[strategy]];
            expect([matcher valueForKeyPath:@"connections"]).to.beEmpty();
            expect([matcher valueForKeyPath:@"domains"]).to.beEmpty();
        });

    });

    describe(NSStringFromSelector(@selector(connectionForEmail:)), ^{

        beforeEach(^{
            [given([connection objectForKeyedSubscript:@"domain"]) willReturn:@"mydomain.com"];
        });

        it(@"should return nil for empty strategy list", ^{
            matcher = [[A0SimpleConnectionDomainMatcher alloc] initWithStrategies:@[]];
            expect([matcher connectionForEmail:@"p@p.xom"]).to.beNil();
        });

        it(@"should match connection with main domain", ^{
            matcher = [[A0SimpleConnectionDomainMatcher alloc] initWithStrategies:@[strategy]];
            expect([matcher connectionForEmail:@"pepe@mydomain.com"]).to.equal(connection);
        });

        it(@"should return nil for empty email", ^{
            matcher = [[A0SimpleConnectionDomainMatcher alloc] initWithStrategies:@[strategy]];
            expect([matcher connectionForEmail:@""]).to.beNil();
        });

        it(@"should return nil for nil email", ^{
            matcher = [[A0SimpleConnectionDomainMatcher alloc] initWithStrategies:@[strategy]];
            expect([matcher connectionForEmail:@""]).to.beNil();
        });

        it(@"should match connection with alias domain", ^{
            [given([connection objectForKeyedSubscript:@"domain_aliases"]) willReturn:@[@"anotherdomain.com"]];
            matcher = [[A0SimpleConnectionDomainMatcher alloc] initWithStrategies:@[strategy]];
            expect([matcher connectionForEmail:@"pepe@anotherdomain.com"]).to.equal(connection);
        });

    });
});

SpecEnd
