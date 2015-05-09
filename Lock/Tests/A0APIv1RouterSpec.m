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

#import "Specta.h"
#import "A0APIv1Router.h"

SpecBegin(A0APIv1Router)

describe(@"A0APIv1Router", ^{

    __block A0APIv1Router *router;

    specify(@"default initializer should fail", ^{
        expect(^{
            router = [[A0APIv1Router alloc] init];
        }).to.raise(NSInternalInconsistencyException);
    });

    beforeEach(^{
        router = [[A0APIv1Router alloc] initWithClientId:@"1234567890"
                                               domainURL:[NSURL URLWithString:@"https://samples.auth0.com"]
                                        configurationURL:[NSURL URLWithString:@"https://cdn.auth0.com/client/1234567890.js"]];
    });

    specify(@"client identifier", ^{
        expect(router.clientId).to.equal(@"1234567890");
    });

    specify(@"domain URL", ^{
        expect(router.endpointURL.absoluteString).equal(@"https://samples.auth0.com");
    });

    specify(@"configuration URL", ^{
        expect(router.configurationURL.absoluteString).equal(@"https://cdn.auth0.com/client/1234567890.js");
    });

    specify(@"tenant", ^{
        expect(router.tenant).to.equal(@"samples");
    });

    specify(@"should fail with invalid client id", ^{
        expect(^{
            router = [[A0APIv1Router alloc] initWithClientId:nil domainURL:[NSURL URLWithString:@"https://samples.auth0.com"] configurationURL:[NSURL URLWithString:@"https://cdn.auth0.com/client/1234567890.js"]];
        }).to.raise(NSInternalInconsistencyException);
    });

    specify(@"should fail with invalid domain URL", ^{
        expect(^{
            router = [[A0APIv1Router alloc] initWithClientId:@"1234567890" domainURL:nil configurationURL:[NSURL URLWithString:@"https://cdn.auth0.com/client/1234567890.js"]];
        }).to.raise(NSInternalInconsistencyException);
    });


    specify(@"should fail with invalid configuration URL", ^{
        expect(^{
            router = [[A0APIv1Router alloc] initWithClientId:@"1234567890" domainURL:[NSURL URLWithString:@"https://samples.auth0.com"] configurationURL:nil];
        }).to.raise(NSInternalInconsistencyException);
    });

});

SpecEnd
