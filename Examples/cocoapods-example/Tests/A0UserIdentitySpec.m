//  A0UserIdentitySpec.m
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
#import "A0UserIdentity.h"

#define kAccessToken @"ACCESS_TOKEN"
#define kConnectionName @"CONNECTION"
#define kProvider @"PROVIDER"
#define kUserId @"USER"

SpecBegin(A0UserIdentity)

describe(@"A0UserIdentity", ^{

    __block A0UserIdentity *identity;

    NSDictionary *jsonDict = @{
                               @"access_token": kAccessToken,
                               @"connection": kConnectionName,
                               @"isSocial": @YES,
                               @"provider": kProvider,
                               @"user_id": kUserId,
                               };

    sharedExamplesFor(@"valid basic identity", ^(NSDictionary *data) {

        beforeEach(^{
            identity = data[@"identity"];
        });

        specify(@"valid connection", ^{
            expect(identity.connection).to.equal(kConnectionName);
        });

        specify(@"valid isSocial", ^{
            expect(identity.isSocial).to.beTruthy();
        });

        specify(@"valid provider", ^{
            expect(identity.provider).to.equal(kProvider);
        });

        specify(@"valid userId", ^{
            expect(identity.userId).to.equal(kUserId);
        });
    });

    sharedExamplesFor(@"valid identity with access token", ^(NSDictionary *data) {

        beforeEach(^{
            identity = data[@"identity"];
        });

        specify(@"valid access token", ^{
            expect(identity.accessToken).to.equal(kAccessToken);
        });

        itShouldBehaveLike(@"valid basic identity", data);

    });

    describe(@"creating from JSON", ^{

        itBehavesLike(@"valid identity with access token", @{@"identity": [[A0UserIdentity alloc] initWithJSONDictionary:jsonDict]});

    });
});

SpecEnd
