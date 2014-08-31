//  A0UserSessionStorageSpec.m
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
#import "A0UserSessionStorage.h"
#import "A0Token.h"

#import <UICKeyChainStore/UICKeyChainStore.h>

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

#define kAccessToken @"AccessToken"
#define kIdToken @"IdToken"
#define kTokenType @"TokenType"
#define kRefreshToken @"RefreshToken"

@interface A0UserSessionStorage (TestAPI)

@property (strong, nonatomic) UICKeyChainStore *store;

@end

SpecBegin(A0UserSessionStorage)

describe(@"A0UserSessionStorage", ^{

    __block A0UserSessionStorage *storage;
    __block UICKeyChainStore *store;

    beforeEach(^{
        storage = [[A0UserSessionStorage alloc] init];
        store = mock(UICKeyChainStore.class);
        storage.store = store;
    });

    describe(@"storing session", ^{

        sharedExamplesFor(@"complete token info", ^(NSDictionary *data) {

            beforeEach(^{
                store = data[@"store"];
            });

            it(@"should save access token", ^{
                [verifyCount(store, times(1)) setString:kAccessToken forKey:@"auth0-access-token"];
            });

            it(@"should save id token", ^{
                [verifyCount(store, times(1)) setString:kIdToken forKey:@"auth0-id-token"];
            });

            it(@"should save refresh token", ^{
                [verifyCount(store, times(1)) setString:kRefreshToken forKey:@"auth0-refresh-token"];
            });

            it(@"should save token type", ^{
                [verifyCount(store, times(1)) setString:kTokenType forKey:@"auth0-token-type"];
            });

            it(@"should synchronize changes with keychain", ^{
                [(UICKeyChainStore *)verify(store) synchronize];
            });
        });

        sharedExamplesFor(@"token info without refresh token", ^(NSDictionary *data) {

            beforeEach(^{
                store = data[@"store"];
            });

            it(@"should save access token", ^{
                [verifyCount(store, times(1)) setString:kAccessToken forKey:@"auth0-access-token"];
            });

            it(@"should save id token", ^{
                [verifyCount(store, times(1)) setString:kIdToken forKey:@"auth0-id-token"];
            });

            it(@"should not save refresh token", ^{
                [verifyCount(store, never()) setString:anything() forKey:@"auth0-refresh-token"];
            });

            it(@"should save token type", ^{
                [verifyCount(store, times(1)) setString:kTokenType forKey:@"auth0-token-type"];
            });

            it(@"should synchronize changes with keychain", ^{
                [(UICKeyChainStore *)verify(store) synchronize];
            });
        });

        sharedExamplesFor(@"basic token info", ^(NSDictionary *data) {

            beforeEach(^{
                store = data[@"store"];
            });

            it(@"should save access token", ^{
                [verifyCount(store, never()) setString:kAccessToken forKey:@"auth0-access-token"];
            });

            it(@"should save id token", ^{
                [verifyCount(store, times(1)) setString:kIdToken forKey:@"auth0-id-token"];
            });

            it(@"should not save refresh token", ^{
                [verifyCount(store, never()) setString:anything() forKey:@"auth0-refresh-token"];
            });

            it(@"should save token type", ^{
                [verifyCount(store, times(1)) setString:kTokenType forKey:@"auth0-token-type"];
            });

            it(@"should synchronize changes with keychain", ^{
                [(UICKeyChainStore *)verify(store) synchronize];
            });
        });

        itShouldBehaveLike(@"complete token info", ^{
            [storage storeToken:[[A0Token alloc] initWithAccessToken:kAccessToken
                                                            idToken:kIdToken
                                                          tokenType:kTokenType
                                                        refreshToken:kRefreshToken]];
            return @{ @"store": storage.store };
        });

        itShouldBehaveLike(@"token info without refresh token", ^{
            [storage storeToken:[[A0Token alloc] initWithAccessToken:kAccessToken
                                                             idToken:kIdToken
                                                           tokenType:kTokenType
                                                        refreshToken:nil]];
            return @{ @"store": storage.store };
        });

        itShouldBehaveLike(@"basic token info", ^{
            [storage storeToken:[[A0Token alloc] initWithAccessToken:nil
                                                             idToken:kIdToken
                                                           tokenType:kTokenType
                                                        refreshToken:nil]];
            return @{ @"store": storage.store };
        });

    });
});

SpecEnd
