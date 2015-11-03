// A0APIv1RouterSpec.m
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

#import <Quick/Quick.h>
#import <Nimble/Nimble.h>
#import "A0APIv1Router.h"

QuickSpecBegin(A0APIv1RouterSpec)

describe(@"A0APIv1Router", ^{

    __block A0APIv1Router *router;

    beforeEach(^{
        router = [[A0APIv1Router alloc] initWithClientId:@"1234567890"
                                               domainURL:[NSURL URLWithString:@"https://samples.auth0.com"]
                                        configurationURL:[NSURL URLWithString:@"https://cdn.auth0.com/client/1234567890.js"]];
    });

    it(@"client identifier", ^{
        expect(router.clientId).to(equal(@"1234567890"));
    });

    it(@"domain URL", ^{
        expect(router.endpointURL.absoluteString).to(equal(@"https://samples.auth0.com"));
    });

    it(@"configuration URL", ^{
        expect(router.configurationURL.absoluteString).to(equal(@"https://cdn.auth0.com/client/1234567890.js"));
    });

    it(@"tenant", ^{
        expect(router.tenant).to(equal(@"samples"));
    });

    it(@"should fail with invalid client id", ^{
        expectAction(^{
            router = [[A0APIv1Router alloc] initWithClientId:nil domainURL:[NSURL URLWithString:@"https://samples.auth0.com"] configurationURL:[NSURL URLWithString:@"https://cdn.auth0.com/client/1234567890.js"]];
        }).to(raiseException());
    });

    it(@"should fail with invalid domain URL", ^{
        expectAction(^{
            router = [[A0APIv1Router alloc] initWithClientId:@"1234567890" domainURL:nil configurationURL:[NSURL URLWithString:@"https://cdn.auth0.com/client/1234567890.js"]];
        }).to(raiseException());
    });


    it(@"should fail with invalid configuration URL", ^{
        expectAction(^{
            router = [[A0APIv1Router alloc] initWithClientId:@"1234567890" domainURL:[NSURL URLWithString:@"https://samples.auth0.com"] configurationURL:nil];
        }).to(raiseException());
    });

});

QuickSpecEnd
