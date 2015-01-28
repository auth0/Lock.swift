// A0APIClientSpec.m
//
// Copyright (c) 2015 Auth0 (http://auth0.com)
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
#import "A0APIClient.h"

#import <OHHTTPStubs/OHHTTPStubs.h>
#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

#define AS_NSURL(urlString) [NSURL URLWithString:urlString]

#define kValidClientExample @"valid API client"
#define kAPIClientArgument @"APIClient"
#define kClientIdArgument @"ClientId"
#define kTenantArgument @"Tenant"

static NSString * const CLIENT_ID = @"1234567890";
static NSString * const TENANT = @"samples";
static NSString * const ENDPOINT = @"https://samples.auth0.com";

SpecBegin(A0APIClient)

describe(@"A0APIClient", ^{

    __block A0APIClient *client;

    describe(@"Initialisation", ^{

        __block id<A0APIRouter> router;

        beforeEach(^{
            router = mockProtocol(@protocol(A0APIRouter));
            [given([router clientId]) willReturn:CLIENT_ID];
            [given([router tenant]) willReturn:TENANT];
            [given([router endpointURL]) willReturn:AS_NSURL(ENDPOINT)];
        });

        sharedExamplesFor(kValidClientExample, ^(NSDictionary *data) {

            __block A0APIClient *client;

            beforeEach(^{
                client = data[kAPIClientArgument];
            });

            specify(@"valid clientId", ^{
                expect(client.clientId).to.equal(data[kClientIdArgument]);
            });

            specify(@"valid tenant", ^{
                expect(client.tenant).to.equal(data[kTenantArgument]);
            });

            specify(@"valid endpoint URL", ^{
                expect(client.baseURL).to.equal(AS_NSURL(ENDPOINT));
            });
        });

        itShouldBehaveLike(kValidClientExample, @{
                                                  kAPIClientArgument: [[A0APIClient alloc] initWithClientId:CLIENT_ID andTenant:TENANT],
                                                  kClientIdArgument: CLIENT_ID,
                                                  kTenantArgument: TENANT,
                                                  });

        itBehavesLike(kValidClientExample, ^{
            return @{
                     kAPIClientArgument: [[A0APIClient alloc] initWithAPIRouter:router],
                     kClientIdArgument: CLIENT_ID,
                     kTenantArgument: TENANT,
                     };
        });
    });
});

SpecEnd
