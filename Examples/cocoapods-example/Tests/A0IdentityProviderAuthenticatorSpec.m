//  A0IdentityProviderAuthenticator.m
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

#import <Specta/Specta.h>
#import "A0IdentityProviderAuthenticator.h"
#import "A0Application.h"
#import "A0Strategy.h"
#import "A0Errors.h"
#import "A0WebAuthenticator.h"

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

#define kFBProviderId @"facebook"
#define kTwitterProviderId @"twitter"

@interface A0IdentityProviderAuthenticator (TestAPI)

@property (strong, nonatomic) NSMutableDictionary *registeredAuthenticators;
@property (strong, nonatomic) NSMutableDictionary *authenticators;

@end

SpecBegin(A0IdentityProviderAuthenticator)

describe(@"A0SocialAuthenticator", ^{

    __block A0IdentityProviderAuthenticator *authenticator;

    beforeEach(^{
        authenticator = [[A0IdentityProviderAuthenticator alloc] init];
    });

    describe(@"provider registration", ^{

        sharedExamplesFor(@"registered provider", ^(NSDictionary *data) {

            id<A0AuthenticationProvider> provider = data[@"provider"];

            it(@"should store the provider under it's identifier", ^{
                expect(authenticator.registeredAuthenticators[provider.identifier]).to.equal(provider);
            });
        });

        it(@"should fail with nil provider", ^{
            expect(^{
                [authenticator registerAuthenticationProvider:nil];
            }).to.raiseWithReason(NSInternalInconsistencyException, @"Must supply a non-nil profile");
        });

        it(@"should fail with provider with no identifier", ^{
            expect(^{
                [authenticator registerAuthenticationProvider:mockProtocol(@protocol(A0AuthenticationProvider))];
            }).to.raiseWithReason(NSInternalInconsistencyException, @"Provider must have a valid indentifier");
        });

        context(@"when registering a single provider", ^{

            __block id<A0AuthenticationProvider> facebookProvider;

            beforeEach(^{
                facebookProvider = mockProtocol(@protocol(A0AuthenticationProvider));
                [given([facebookProvider identifier]) willReturn:kFBProviderId];
                [authenticator registerAuthenticationProvider:facebookProvider];
            });

            itBehavesLike(@"registered provider", ^{ return @{ @"provider": facebookProvider }; });
        });

        context(@"when registering providers as array", ^{

            __block id<A0AuthenticationProvider> facebookProvider;
            __block id<A0AuthenticationProvider> twitterProvider;

            beforeEach(^{
                facebookProvider = mockProtocol(@protocol(A0AuthenticationProvider));
                [given([facebookProvider identifier]) willReturn:kFBProviderId];
                twitterProvider = mockProtocol(@protocol(A0AuthenticationProvider));
                [given([twitterProvider identifier]) willReturn:kTwitterProviderId];

                [authenticator registerAuthenticationProviders:@[facebookProvider, twitterProvider]];
            });
            
            itBehavesLike(@"registered provider", ^{ return @{ @"provider": facebookProvider }; });
            itBehavesLike(@"registered provider", ^{ return @{ @"provider": twitterProvider }; });
        });

    });

    describe(@"configuration with application info", ^{

        __block A0Application *application;
        __block A0Strategy *facebookStrategy;
        __block id<A0AuthenticationProvider> facebookProvider;
        __block id<A0AuthenticationProvider> twitterProvider;

        beforeEach(^{
            facebookProvider = mockProtocol(@protocol(A0AuthenticationProvider));
            [given([facebookProvider identifier]) willReturn:kFBProviderId];
            twitterProvider = mockProtocol(@protocol(A0AuthenticationProvider));
            [given([twitterProvider identifier]) willReturn:kTwitterProviderId];
            application = mock(A0Application.class);
            facebookStrategy = mock(A0Strategy.class);
            [given([facebookStrategy name]) willReturn:kFBProviderId];
            [authenticator registerAuthenticationProviders:@[facebookProvider, twitterProvider]];
        });

        context(@"has declared a registered provider", ^{

            beforeEach(^{
                [given([application availableSocialOrEnterpriseStrategies]) willReturn:@[facebookStrategy]];
                [authenticator configureForApplication:application];
            });

            it(@"should have application's strategy providers", ^{
                expect(authenticator.authenticators[facebookProvider.identifier]).to.equal(facebookProvider);
            });

            it(@"should not have undeclared provider", ^{
                expect(authenticator.authenticators[twitterProvider.identifier]).to.beNil();
            });

        });

    });

    describe(@"Authentication", ^{

        __block A0Strategy *strategy;
        __block id<A0AuthenticationProvider> provider;
        void(^successBlock)(A0UserProfile *, A0Token *) = ^(A0UserProfile *profile, A0Token *token) {};

        beforeEach(^{
            provider = mockProtocol(@protocol(A0AuthenticationProvider));
            [given([provider identifier]) willReturn:@"provider"];
            strategy = mock(A0Strategy.class);
            [given([strategy name]) willReturn:@"provider"];
            authenticator.authenticators = [@{ @"provider": provider } mutableCopy];
        });

        context(@"authenticate with known strategy", ^{

            void(^failureBlock)(NSError *) = ^(NSError *error) {};
            beforeEach(^{
                [authenticator authenticateForStrategy:strategy parameters:nil success:successBlock failure:failureBlock];
            });

            it(@"should call the correct provider", ^{
                [MKTVerify(provider) authenticateWithParameters:nil success:successBlock failure:failureBlock];
            });

            it(@"should tell it can authenticate", ^{
                expect([authenticator canAuthenticateStrategy:strategy]).to.beTruthy();
            });

        });

        context(@"authenticate with unknown strategy", ^{

            __block A0Strategy *unknown;
            __block NSError *failureError;
            void(^failureBlock)(NSError *) = ^(NSError *error) { failureError = error; };

            beforeEach(^{
                unknown = mock(A0Strategy.class);
                failureError = nil;
                [authenticator authenticateForStrategy:unknown parameters:nil success:successBlock failure:failureBlock];
            });

            it(@"should not call any provider", ^{
                [verifyCount(provider, never()) authenticateWithParameters:nil success:successBlock failure:failureBlock];
            });

            it(@"should call failure block", ^{
                expect(failureError).toNot.beNil();
            });

            specify(@"unkown strategy error", ^{
                expect(failureError.code).to.equal(@(A0ErrorCodeUknownProviderForStrategy));
            });

            it(@"should tell it can authenticate", ^{
                expect([authenticator canAuthenticateStrategy:unknown]).to.beFalsy();
            });

        });

    });

    describe(@"Handle URL", ^{

        __block id<A0AuthenticationProvider> facebook;
        __block id<A0AuthenticationProvider> twitter;
        NSURL *facebookURL = [NSURL URLWithString:@"fb12345678://handler"];
        NSURL *twitterURL = [NSURL URLWithString:@"twitter://handler"];

        beforeEach(^{
            facebook = mockProtocol(@protocol(A0AuthenticationProvider));
            twitter = mockProtocol(@protocol(A0AuthenticationProvider));
            [given([facebook handleURL:facebookURL sourceApplication:nil]) willReturnBool:YES];
            [given([twitter handleURL:twitterURL sourceApplication:nil]) willReturnBool:YES];
            authenticator.authenticators = [@{ @"facebook": facebook, @"twitter": twitter } mutableCopy];
        });

        context(@"url for facebook provider to handle", ^{

            __block BOOL handled;

            beforeEach(^{
                handled = [authenticator handleURL:facebookURL sourceApplication:nil];
            });

            it(@"should call facebook provider", ^{
                [verifyCount(facebook, times(1)) handleURL:facebookURL sourceApplication:nil];
            });

            it(@"should be handled", ^{
                expect(handled).to.beTruthy();
            });
        });

        context(@"url for twitter provider to handle", ^{

            __block BOOL handled;

            beforeEach(^{
                handled = [authenticator handleURL:twitterURL sourceApplication:nil];
            });

            it(@"should call facebook provider", ^{
                [verifyCount(twitter, times(1)) handleURL:twitterURL sourceApplication:nil];
            });

            it(@"should be handled", ^{
                expect(handled).to.beTruthy();
            });
        });

        context(@"unknown url to handle", ^{

            __block BOOL handled;
            NSURL *invalidURL = [NSURL URLWithString:@"ftp://pepe"];

            beforeEach(^{
                handled = [authenticator handleURL:invalidURL sourceApplication:nil];
            });

            it(@"should call all providers", ^{
                [verifyCount(twitter, times(1)) handleURL:invalidURL sourceApplication:nil];
                [verifyCount(facebook, times(1)) handleURL:invalidURL sourceApplication:nil];
            });

            it(@"should be handled", ^{
                expect(handled).to.beFalsy();
            });
        });

    });

    describe(@"Clear sessions", ^{

        __block id<A0AuthenticationProvider> facebook;
        __block id<A0AuthenticationProvider> twitter;

        beforeEach(^{
            facebook = mockProtocol(@protocol(A0AuthenticationProvider));
            twitter = mockProtocol(@protocol(A0AuthenticationProvider));
            authenticator.authenticators = [@{ @"facebook": facebook, @"twitter": twitter } mutableCopy];
        });

        context(@"url for facebook provider to handle", ^{

            beforeEach(^{
                [authenticator clearSessions];
            });

            it(@"should call facebook provider", ^{
                [verifyCount(facebook, times(1)) clearSessions];
            });

            it(@"should call twitter provider", ^{
                [verifyCount(twitter, times(1)) clearSessions];
            });
        });

    });

});

SpecEnd
