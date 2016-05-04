//  A0TokenSpec.m
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
#import <OCMockito/OCMockito.h>
#import "A0Token.h"

#define kAccessToken @"ACCESS TOKEN"
#define kIdToken @"ID TOKEN"
#define kTokenType @"BEARER"
#define kRefreshToken @"REFRESH TOKEN"

QuickSpecBegin(A0TokenSpec)

describe(@"A0Token", ^{

    NSDictionary *jsonDict = @{
                               @"access_token": kAccessToken,
                               @"id_token": kIdToken,
                               @"token_type": kTokenType,
                               @"refresh_token": kRefreshToken,
                               };

    sharedExamples(@"invalid token", ^(QCKDSLSharedExampleContext context) {
        beforeEach(^{
            expectAction(^{
                A0Token *token = [[A0Token alloc] initWithDictionary:context()];
                expect(token).to(beNil());
            }).to(raiseException());
        });
    });

    sharedExamples(@"valid basic token", ^(QCKDSLSharedExampleContext context) {

        __block A0Token *token;

        beforeEach(^{
            token = context()[@"token"];
        });

        it(@"valid id token", ^{
            expect(token.idToken).to(equal(kIdToken));
        });

        it(@"valid token type", ^{
            expect(token.tokenType).to(equal(kTokenType));
        });

    });

    sharedExamples(@"valid complete token", ^(QCKDSLSharedExampleContext context) {

        __block A0Token *token;

        beforeEach(^{
            token = context()[@"token"];
        });

        itBehavesLike(@"valid basic token", context);

        it(@"valid access token", ^{
            expect(token.accessToken).to(equal(kAccessToken));
        });

    });

    sharedExamples(@"valid basic with offline token", ^(QCKDSLSharedExampleContext context) {

        __block A0Token *token;

        beforeEach(^{
            token = context()[@"token"];
        });

        itBehavesLike(@"valid basic token", context);

        it(@"valid refresh token", ^{
            expect(token.refreshToken).to(equal(kRefreshToken));
        });
        
    });

    sharedExamples(@"valid complete with offline token", ^(QCKDSLSharedExampleContext context) {

        __block A0Token *token;

        beforeEach(^{
            token = context()[@"token"];
        });

        itBehavesLike(@"valid complete token", context);

        it(@"valid refresh token", ^{
            expect(token.refreshToken).to(equal(kRefreshToken));
        });
        
    });

    context(@"creating from JSON", ^{

        itBehavesLike(@"valid complete token", ^{ return @{ @"token": [[A0Token alloc] initWithDictionary:jsonDict] }; });

        itBehavesLike(@"valid basic token", ^{
            NSMutableDictionary *dict = [jsonDict mutableCopy];
            [dict removeObjectForKey:@"access_token"];
            return @{ @"token": [[A0Token alloc] initWithDictionary:dict] };
        });

        itBehavesLike(@"valid basic with offline token", ^{
            NSMutableDictionary *dict = [jsonDict mutableCopy];
            [dict removeObjectForKey:@"access_token"];
            dict[@"refresh_token"] = kRefreshToken;
            return @{ @"token": [[A0Token alloc] initWithDictionary:dict] };
        });

        itBehavesLike(@"valid complete with offline token", ^{
            NSMutableDictionary *dict = [jsonDict mutableCopy];
            dict[@"refresh_token"] = kRefreshToken;
            return @{ @"token": [[A0Token alloc] initWithDictionary:dict] };
        });

        itBehavesLike(@"invalid token", ^{ return @{}; });
        itBehavesLike(@"invalid token", ^{ return @{ @"access_token": kAccessToken }; });
        itBehavesLike(@"invalid token", ^{ return @{ @"refresh_token": kRefreshToken }; });
        itBehavesLike(@"invalid token", ^{ return @{ @"access_token": kAccessToken, @"token_type": kTokenType }; });
        itBehavesLike(@"invalid token", ^{ return @{ @"access_token": kAccessToken, @"id_token": kIdToken }; });
        itBehavesLike(@"invalid token", ^{ return @{ @"access_token": kAccessToken, @"refresh_token": kRefreshToken }; });
        itBehavesLike(@"invalid token", ^{ return @{ @"access_token": kAccessToken, @"token_type": kTokenType, @"refresh_token": kRefreshToken }; });
        itBehavesLike(@"invalid token", ^{ return @{ @"access_token": kAccessToken, @"id_token": kIdToken, @"refresh_token": kRefreshToken }; });

    });

    describe(@"NSCoding", ^{

        __block A0Token *token;
        __block NSCoder *coder;

        beforeEach(^{
            coder = mock(NSCoder.class);
        });

        context(@"saving A0UserProfile", ^{

            beforeEach(^{
                token = [[A0Token alloc] initWithDictionary:jsonDict];
                [token encodeWithCoder:coder];
            });

            it(@"store key for access token", ^{
                [verify(coder) encodeObject:token.accessToken forKey:@"accessToken"];
            });

            it(@"store key for refresh_token", ^{
                [verify(coder) encodeObject:token.refreshToken forKey:@"refreshToken"];
            });

            it(@"store key for token type", ^{
                [verify(coder) encodeObject:token.tokenType forKey:@"tokenType"];
            });

            it(@"store key for id token", ^{
                [verify(coder) encodeObject:token.idToken forKey:@"idToken"];
            });

        });

        context(@"restore A0UserProfile", ^{

            beforeEach(^{
                token = [[A0Token alloc] initWithDictionary:jsonDict];
                [given([coder decodeObjectOfClass:NSString.class forKey:@"idToken"]) willReturn:token.idToken];
                [given([coder decodeObjectOfClass:NSString.class forKey:@"refreshToken"]) willReturn:token.refreshToken];
                [given([coder decodeObjectOfClass:NSString.class forKey:@"accessToken"]) willReturn:token.accessToken];
                [given([coder decodeObjectOfClass:NSString.class forKey:@"tokenType"]) willReturn:token.tokenType];
                token = [[A0Token alloc] initWithCoder:coder];
            });

            itBehavesLike(@"valid complete token", ^{ return @{ @"token": [[A0Token alloc] initWithDictionary:jsonDict] }; });
        });
    });

});

QuickSpecEnd
