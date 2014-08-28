//
//  A0SocialAuthenticatorSpec.m
//  Auth0Client
//
//  Created by Hernan Zalazar on 8/28/14.
//  Copyright 2014 Auth0. All rights reserved.
//

#import <Specta/Specta.h>
#import "A0SocialAuthenticator.h"
#import "A0Application.h"
#import "A0Strategy.h"

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

#define kFBProviderId @"facebook"
#define kTwitterProviderId @"twitter"

@interface A0SocialAuthenticator (TestAPI)

@property (strong, nonatomic) NSMutableDictionary *registeredAuthenticators;
@property (strong, nonatomic) NSMutableDictionary *authenticators;

@end

SpecBegin(A0SocialAuthenticator)

describe(@"A0SocialAuthenticator", ^{

    __block A0SocialAuthenticator *authenticator;

    beforeEach(^{
        authenticator = [[A0SocialAuthenticator alloc] init];
    });

    describe(@"provider registration", ^{

        sharedExamplesFor(@"registered provider", ^(NSDictionary *data) {

            id<A0SocialAuthenticationProvider> provider = data[@"provider"];

            it(@"should store the provider under it's identifier", ^{
                expect(authenticator.registeredAuthenticators[provider.identifier]).to.equal(provider);
            });
        });

        it(@"should fail with nil provider", ^{
            expect(^{
                [authenticator registerSocialAuthenticatorProvider:nil];
            }).to.raiseWithReason(NSInternalInconsistencyException, @"Must supply a non-nil profile");
        });

        it(@"should fail with provider with no identifier", ^{
            expect(^{
                [authenticator registerSocialAuthenticatorProvider:mockProtocol(@protocol(A0SocialAuthenticationProvider))];
            }).to.raiseWithReason(NSInternalInconsistencyException, @"Provider must have a valid indentifier");
        });

        context(@"when registering a single provider", ^{

            __block id<A0SocialAuthenticationProvider> facebookProvider;

            beforeEach(^{
                facebookProvider = mockProtocol(@protocol(A0SocialAuthenticationProvider));
                [given([facebookProvider identifier]) willReturn:kFBProviderId];
                [authenticator registerSocialAuthenticatorProvider:facebookProvider];
            });

            itBehavesLike(@"registered provider", ^{ return @{ @"provider": facebookProvider }; });
        });

        context(@"when registering providers as array", ^{

            __block id<A0SocialAuthenticationProvider> facebookProvider;
            __block id<A0SocialAuthenticationProvider> twitterProvider;

            beforeEach(^{
                facebookProvider = mockProtocol(@protocol(A0SocialAuthenticationProvider));
                [given([facebookProvider identifier]) willReturn:kFBProviderId];
                twitterProvider = mockProtocol(@protocol(A0SocialAuthenticationProvider));
                [given([twitterProvider identifier]) willReturn:kTwitterProviderId];

                [authenticator registerSocialAuthenticatorProviders:@[facebookProvider, twitterProvider]];
            });
            
            itBehavesLike(@"registered provider", ^{ return @{ @"provider": facebookProvider }; });
            itBehavesLike(@"registered provider", ^{ return @{ @"provider": twitterProvider }; });
        });

    });

    describe(@"configuration with application info", ^{

        __block A0Application *application;
        __block A0Strategy *facebookStrategy;
        __block id<A0SocialAuthenticationProvider> facebookProvider;
        __block id<A0SocialAuthenticationProvider> twitterProvider;

        beforeEach(^{
            facebookProvider = mockProtocol(@protocol(A0SocialAuthenticationProvider));
            [given([facebookProvider identifier]) willReturn:kFBProviderId];
            twitterProvider = mockProtocol(@protocol(A0SocialAuthenticationProvider));
            [given([twitterProvider identifier]) willReturn:kTwitterProviderId];
            application = mock(A0Application.class);
            facebookStrategy = mock(A0Strategy.class);
            [given([facebookStrategy name]) willReturn:kFBProviderId];
            [authenticator registerSocialAuthenticatorProviders:@[facebookProvider, twitterProvider]];
        });

        context(@"has declared a registered provider", ^{

            beforeEach(^{
                [given([application availableSocialStrategies]) willReturn:@[facebookStrategy]];
                [authenticator configureForApplication:application];
            });

            it(@"should have application's strategy providers", ^{
                expect(authenticator.authenticators[facebookProvider.identifier]).to.equal(facebookProvider);
            });

            it(@"should not have undeclared provider", ^{
                expect(authenticator.authenticators[twitterProvider.identifier]).to.beNil();
            });

        });

        context(@"has declared only an unknown provider", ^{

            beforeEach(^{
                [given([application availableSocialStrategies]) willReturn:@[mock(A0Strategy.class)]];
                [authenticator configureForApplication:application];
            });

            it(@"should have application's strategy providers", ^{
                expect(authenticator.authenticators).to.beEmpty();
            });

        });


    });
});

SpecEnd
