// A0SafariAuthenticatorSpec.m
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

#import "A0LockTest.h"
#import "A0SafariAuthenticator.h"
#import "A0Token.h"
#import "A0UserProfile.h"
#import "A0SafariSession.h"
#import "A0Lock.h"
#import "A0APIClient.h"
#import "A0ModalPresenter.h"
#import "A0AuthParameters.h"
#import "A0LockNotification.h"
#import <SafariServices/SafariServices.h>

NSString * const ConnectionName = @"social-connection";

@interface A0SafariAuthenticator (Testing)
- (instancetype)initWithSession:(A0SafariSession *)session modalPresenter:(A0ModalPresenter *)presenter;
@end

SpecBegin(A0SafariAuthenticator)

__block A0SafariAuthenticator *authenticator;
__block A0SafariSession *session;
__block A0Lock *lock;
__block A0APIClient *client;
__block A0ModalPresenter *presenter;
__block A0IdPAuthenticationErrorBlock failureBlock;
__block A0IdPAuthenticationBlock authenticationBlock;

NSURL *authorizeURL = [NSURL URLWithString:@"https://auth0.com"];

beforeEach(^{
    session = mock(A0SafariSession.class);
    lock = mock(A0Lock.class);
    client = mock(A0APIClient.class);
    presenter = mock(A0ModalPresenter.class);
    failureBlock = ^(NSError *error) {
        expect(error).toNot.beNil();
    };
    authenticationBlock = ^(A0UserProfile *profile, A0Token *token) {
        expect(profile).toNot.beNil();
        expect(token).toNot.beNil();
    };

    [given(session.connectionName) willReturn:ConnectionName];
    [given([session authorizeURLWithParameters:anything()]) willReturn:authorizeURL];

    authenticator = [[A0SafariAuthenticator alloc] initWithSession:session modalPresenter:presenter];
});

specify(@"identifier is connection name", ^{
    expect([authenticator identifier]).to.equal(ConnectionName);
});

describe(@"safari controller", ^{

    beforeEach(^{
        A0AuthParameters *parameters = [A0AuthParameters newDefaultParams];
        [authenticator authenticateWithParameters:parameters success:authenticationBlock failure:failureBlock];
    });

    it(@"should present SFSafariViewController", ^{
        [MKTVerify(presenter) presentController:instanceOf(SFSafariViewController.class) completion:anything()];
    });

    it(@"should have itself as delegate", ^{
        HCArgumentCaptor *captor = [HCArgumentCaptor new];
        [MKTVerify(presenter) presentController:(id)captor completion:anything()];
        SFSafariViewController *controller = [captor value];
        expect(controller.delegate).to.equal(authenticator);
    });

    it(@"should open with authorizeURL", ^{
        [MKTVerify(session) authorizeURLWithParameters:[[A0AuthParameters newDefaultParams] asAPIPayload]];
    });

    it(@"should set authorization callback", ^{
        [MKTVerify(session) authenticationBlockWithSuccess:authenticationBlock failure:failureBlock];
    });
});

describe(@"authentication", ^{

    __block NSURL *successURL;
    __block NSURL *failureURL;

    beforeEach(^{
        [given([session authenticationBlockWithSuccess:anything() failure:anything()]) willDo:^id(NSInvocation *invocation) {
            NSArray *arguments = [invocation mkt_arguments];
            A0IdPAuthenticationBlock success = arguments.firstObject;
            A0IdPAuthenticationErrorBlock failed = arguments.lastObject;
            return ^(NSError *error, A0Token *token){
                if (error) {
                    failed(error);
                } else {
                    success(mock(A0UserProfile.class), token);
                }
            };
        }];
    });

    context(@"custom scheme", ^{

        NSURL *customSchemeURL = [NSURL URLWithString:@"a0MyClientId://samples.auth0.com/ios/callback"];

        beforeEach(^{
            NSURLComponents *components = [NSURLComponents componentsWithURL:customSchemeURL resolvingAgainstBaseURL:YES];
            components.query = @"id_token=IDTOKEN&token_type=bearer&access_token=ACCESSTOKEN";
            successURL = components.URL;
            components.query = @"error=FAILED";
            failureURL = components.URL;

            [given(session.callbackURL) willReturn:customSchemeURL];
        });

        it(@"should accept URL", ^{
            expect([authenticator handleURL:customSchemeURL sourceApplication:nil]).to.beTruthy();
        });

        it(@"should provide token and profile", ^{
            waitUntil(^(DoneCallback done) {
                [authenticator authenticateWithParameters:[A0AuthParameters newDefaultParams]
                                                  success:^(A0UserProfile *profile, A0Token *token) {
                                                      authenticationBlock(profile, token);
                                                      done();
                                                  }
                                                  failure:^(NSError *error) {
                                                      failure(@"should not have failed");
                                                      done();
                                                  }];
                [authenticator handleURL:successURL sourceApplication:nil];
            });
        });

        it(@"should propagate errors", ^{
            waitUntil(^(DoneCallback done) {
                [authenticator authenticateWithParameters:[A0AuthParameters newDefaultParams]
                                                  success:^(A0UserProfile *profile, A0Token *token) {
                                                      failure(@"should have failed");
                                                      done();
                                                  }
                                                  failure:^(NSError *error) {
                                                      failureBlock(error);
                                                      done();
                                                  }];
                [authenticator handleURL:failureURL sourceApplication:nil];
            });
        });

        it(@"should propagate no token error", ^{
            waitUntil(^(DoneCallback done) {
                [authenticator authenticateWithParameters:[A0AuthParameters newDefaultParams]
                                                  success:^(A0UserProfile *profile, A0Token *token) {
                                                      failure(@"should have failed");
                                                      done();
                                                  }
                                                  failure:^(NSError *error) {
                                                      failureBlock(error);
                                                      done();
                                                  }];
                [authenticator handleURL:customSchemeURL sourceApplication:nil];
            });
        });

    });

    context(@"universal link", ^{

        NSURL *universalLinkURL = [NSURL URLWithString:@"https://samples.auth0.com/com.auth0.Lock/ios/callback"];

        beforeEach(^{
            NSURLComponents *components = [NSURLComponents componentsWithURL:universalLinkURL resolvingAgainstBaseURL:YES];
            components.query = @"id_token=IDTOKEN&token_type=bearer&access_token=ACCESSTOKEN";
            successURL = components.URL;
            components.query = @"error=FAILED";
            failureURL = components.URL;

            [given(session.callbackURL) willReturn:universalLinkURL];
        });

        it(@"should provide token and profile", ^{
            waitUntil(^(DoneCallback done) {
                [authenticator authenticateWithParameters:[A0AuthParameters newDefaultParams]
                                                  success:^(A0UserProfile *profile, A0Token *token) {
                                                      authenticationBlock(profile, token);
                                                      done();
                                                  }
                                                  failure:^(NSError *error) {
                                                      failure(@"should not have failed");
                                                      done();
                                                  }];
                [[NSNotificationCenter defaultCenter] postNotificationName:A0LockNotificationUniversalLinkReceived object:nil userInfo:@{A0LockNotificationUniversalLinkParameterKey: successURL}];
            });
        });

        it(@"should propagate errors", ^{
            waitUntil(^(DoneCallback done) {
                [authenticator authenticateWithParameters:[A0AuthParameters newDefaultParams]
                                                  success:^(A0UserProfile *profile, A0Token *token) {
                                                      failure(@"should have failed");
                                                      done();
                                                  }
                                                  failure:^(NSError *error) {
                                                      failureBlock(error);
                                                      done();
                                                  }];
                [[NSNotificationCenter defaultCenter] postNotificationName:A0LockNotificationUniversalLinkReceived object:nil userInfo:@{A0LockNotificationUniversalLinkParameterKey: failureURL}];
            });
        });

        it(@"should propagate no token error", ^{
            waitUntil(^(DoneCallback done) {
                [authenticator authenticateWithParameters:[A0AuthParameters newDefaultParams]
                                                  success:^(A0UserProfile *profile, A0Token *token) {
                                                      failure(@"should have failed");
                                                      done();
                                                  }
                                                  failure:^(NSError *error) {
                                                      failureBlock(error);
                                                      done();
                                                  }];
                [[NSNotificationCenter defaultCenter] postNotificationName:A0LockNotificationUniversalLinkReceived object:nil userInfo:@{A0LockNotificationUniversalLinkParameterKey: universalLinkURL}];
            });
        });

    });

});


SpecEnd
