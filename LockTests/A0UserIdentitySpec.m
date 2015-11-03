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

#define QUICK_DISABLE_SHORT_SYNTAX 1

#import <Quick/Quick.h>
#import <Nimble/Nimble.h>
#import "A0UserIdentity.h"

#define kAccessToken @"ACCESS_TOKEN"
#define kConnectionName @"CONNECTION"
#define kProvider @"PROVIDER"
#define kUserId @"USER"
#define kAccessTokenSecret @"secret"
#define kIdentityId @"PROVIDER|USER"

QuickSpecBegin(A0UserIdentitySpec)

describe(@"A0UserIdentity", ^{

    __block A0UserIdentity *identity;

    __block NSDictionary *jsonDict = @{
                                       @"access_token": kAccessToken,
                                       @"connection": kConnectionName,
                                       @"isSocial": @YES,
                                       @"provider": kProvider,
                                       @"user_id": kUserId,
                                       };

    sharedExamples(@"valid basic identity", ^(QCKDSLSharedExampleContext context) {

        beforeEach(^{
            identity = context()[@"identity"];
        });

        it(@"valid connection", ^{
            expect(identity.connection).to(equal(kConnectionName));
        });

        it(@"valid isSocial", ^{
            expect(@(identity.isSocial)).to(beTruthy());
        });

        it(@"valid provider", ^{
            expect(identity.provider).to(equal(kProvider));
        });

        it(@"valid userId", ^{
            expect(identity.userId).to(equal(kUserId));
        });

        it(@"valid identity id", ^{
            expect(identity.identityId).to(equal(kIdentityId));
        });
    });

    sharedExamples(@"valid identity with access token", ^(QCKDSLSharedExampleContext context) {

        beforeEach(^{
            identity = context()[@"identity"];
        });

        it(@"valid access token", ^{
            expect(identity.accessToken).to(equal(kAccessToken));
        });

        itBehavesLike(@"valid basic identity", context);

    });

    describe(@"creating from JSON", ^{

        itBehavesLike(@"valid identity with access token", ^{ return @{@"identity": [[A0UserIdentity alloc] initWithJSONDictionary:jsonDict]}; });

        context(@"identity with access token secret", ^{

            beforeEach(^{
                jsonDict = @{
                             @"access_token": kAccessToken,
                             @"connection": kConnectionName,
                             @"isSocial": @YES,
                             @"provider": kProvider,
                             @"user_id": kUserId,
                             @"access_token_secret": kAccessTokenSecret
                             };
                identity = [[A0UserIdentity alloc] initWithJSONDictionary:jsonDict];
            });

            itBehavesLike(@"valid identity with access token", ^{
                return @{@"identity": identity};
            });

            it(@"valid access token secret", ^{
                expect(identity.accessTokenSecret).to(equal(kAccessTokenSecret));
            });

        });
    });
});

QuickSpecEnd
