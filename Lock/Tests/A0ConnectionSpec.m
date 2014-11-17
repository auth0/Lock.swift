//  A0ConnectionSpec.m
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

#import "Specta.h"
#import "A0Connection.h"


SpecBegin(A0Connection)

describe(@"A0Connection", ^{

    __block A0Connection *connection;

    __block NSDictionary *JSON = @{
                                   @"name": @"facebook",
                                   @"extra_key": @"extra_value",
                                   };

    sharedExamplesFor(@"valid connection", ^(NSDictionary *data) {

        beforeEach(^{
            connection = [[A0Connection alloc] initWithJSONDictionary:data];
        });

        specify(@"valid name", ^{
            expect(connection.name).to.equal(data[@"name"]);
        });

        specify(@"valid values", ^{
            expect(connection.values).to.equal(data);
        });

    });

    sharedExamplesFor(@"invalid connection", ^(NSDictionary *data) {

        it(@"should raise exception on init", ^{
            expect(^{
                connection = [[A0Connection alloc] initWithJSONDictionary:data];
            }).to.raise(NSInternalInconsistencyException);
        });

    });

    itBehavesLike(@"valid connection", JSON);
    itBehavesLike(@"invalid connection", nil);
    itBehavesLike(@"invalid connection", @{});
    itBehavesLike(@"invalid connection", @{@"key": @"value"});
    
});

SpecEnd
