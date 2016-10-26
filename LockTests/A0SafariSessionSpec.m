// A0SafariSessionSpec.m
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

#define QUICK_DISABLE_SHORT_SYNTAX 1

#import <Quick/Quick.h>
#import <Nimble/Nimble.h>
#import <OCMockito/OCMockito.h>
#import <OCHamcrest/OCHamcrest.h>

#import "A0SafariSession.h"
#import "A0Lock.h"
#import "A0APIClient.h"
#import "A0Token.h"
#import "A0UserProfile.h"
#import "A0AuthParameters.h"
#import <SafariServices/SafariServices.h>

@interface A0SafariSession (Testing)
- (instancetype)initWithLock:(A0Lock *)lock connectionName:(NSString *)connectionName callbackURL:(NSURL *)callbackURL usePKCE:(BOOL)usePKCE;
- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller;

+ (NSURL *)callbackURLForOSVersion:(double)osVersion withLock:(A0Lock *)lock;
@end

@interface A0MockAPI : A0APIClient
@end

@implementation A0MockAPI

- (NSURLSessionDataTask *)fetchUserProfileWithIdToken:(NSString *)idToken success:(A0APIClientUserProfileSuccess)success failure:(A0APIClientError)failure {
    dispatch_async(dispatch_get_main_queue(), ^{
        success([[A0UserProfile alloc] init]);
    });
    return nil;
}

@end

QuickSpecBegin(A0SafariSessionSpec)

describe(@"A0SafariSession", ^{
    __block A0Lock *lock;
    __block A0APIClient *client;
    __block A0SafariSession *session;

    beforeEach(^{
        lock = mock(A0Lock.class);
        client = mock(A0APIClient.class);
        [given([lock apiClient]) willReturn:client];
        [given([lock domainURL]) willReturn:[NSURL URLWithString:@"https://samples.auth0.com"]];
        [given([lock clientId]) willReturn:@"CLIENTID"];
    });

    it(@"should create a new instance", ^{
        NSURL *callbackURL = [NSURL URLWithString:@"https://samples.auth0.com"];
        session = [[A0SafariSession alloc] initWithLock:lock connectionName:@"facebook" callbackURL:callbackURL usePKCE:NO];
        expect(session).toNot(beNil());
        expect(session.connectionName).to(equal(@"facebook"));
        expect(session.callbackURL).to(equal(callbackURL));
    });

    context(@"callback url", ^{
        it(@"should build with custom scheme", ^{
            expect([A0SafariSession callbackURLForOSVersion:NSFoundationVersionNumber_iOS_8_3 withLock:lock]).to(equal([NSURL URLWithString:@"com.auth0.app.legacy.Lock://samples.auth0.com/ios/com.auth0.app.legacy.Lock/callback"]));
        });

        it(@"should build with universal links", ^{
            expect([A0SafariSession callbackURLForOSVersion:(NSFoundationVersionNumber_iOS_8_3 + 1) withLock:lock]).to(equal([NSURL URLWithString:@"https://samples.auth0.com/ios/com.auth0.app.legacy.Lock/callback"]));
        });

        it(@"should pick the current OS version", ^{
            session = [[A0SafariSession alloc] initWithLock:lock connectionName:@"facebook" usePKCE:NO];
            if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_8_3) {
                expect(session.callbackURL.scheme).to(equal(@"https"));
            } else {
                expect(session.callbackURL.scheme).to(equal([[NSBundle mainBundle] bundleIdentifier]));
            }
        });
    });

    context(@"authorize url with connection", ^{

        __block NSURL *url;

        beforeEach(^{
            session = [[A0SafariSession alloc] initWithLock:lock connectionName:@"facebook" usePKCE:NO];
            url = [session authorizeURLWithParameters:nil];
        });

        it(@"should be based in domainURL", ^{
            expect(url.host).to(equal(@"samples.auth0.com"));
            expect(url.scheme).to(equal(@"https"));
        });

        it(@"should include default parameters in query string", ^{
            NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:YES];
            NSArray<NSURLQueryItem *> *items = components.queryItems;
            expect(items).to(contain([NSURLQueryItem queryItemWithName:@"client_id" value:@"CLIENTID"]));
            expect(items).to(contain([NSURLQueryItem queryItemWithName:@"response_type" value:@"token"]));
            expect(items).to(contain([NSURLQueryItem queryItemWithName:@"connection" value:@"facebook"]));
            expect(items).to(contain([NSURLQueryItem queryItemWithName:@"redirect_uri" value:session.callbackURL.absoluteString]));
        });

        it(@"should include extra parameters in query string", ^{
            url = [session authorizeURLWithParameters:@{
                                                        @"scope": @"openid",
                                                        @"nonce": @"some random value",
                                                        }];
            NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:YES];
            NSArray<NSURLQueryItem *> *items = components.queryItems;
            expect(items).to(contain([NSURLQueryItem queryItemWithName:@"scope" value:@"openid"]));
            expect(items).to(contain([NSURLQueryItem queryItemWithName:@"nonce" value:@"some random value"]));
        });

        it(@"should always use the connection from initializer", ^{
            url = [session authorizeURLWithParameters:@{
                                                        @"connection": @"twitter",
                                                        }];
            NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:YES];
            NSArray<NSURLQueryItem *> *items = components.queryItems;
            expect(items).to(contain([NSURLQueryItem queryItemWithName:@"connection" value:@"facebook"]));
        });

    });

    context(@"authorize url with no connection", ^{

        __block NSURL *url;

        beforeEach(^{
            session = [[A0SafariSession alloc] initWithLock:lock connectionName:nil usePKCE:NO];
            url = [session authorizeURLWithParameters:nil];
        });

        it(@"should be based in domainURL", ^{
            expect(url.host).to(equal(@"samples.auth0.com"));
            expect(url.scheme).to(equal(@"https"));
        });

        it(@"should include default parameters in query string", ^{
            NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:YES];
            NSArray<NSURLQueryItem *> *items = components.queryItems;
            expect(items).to(contain([NSURLQueryItem queryItemWithName:@"client_id" value:@"CLIENTID"]));
            expect(items).to(contain([NSURLQueryItem queryItemWithName:@"response_type" value:@"token"]));
            expect(items).toNot(contain([NSURLQueryItem queryItemWithName:@"connection" value:@"facebook"]));
            expect(items).to(contain([NSURLQueryItem queryItemWithName:@"redirect_uri" value:session.callbackURL.absoluteString]));
        });

        it(@"should include extra parameters in query string", ^{
            url = [session authorizeURLWithParameters:@{
                                                        @"scope": @"openid",
                                                        @"nonce": @"some random value",
                                                        }];
            NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:YES];
            NSArray<NSURLQueryItem *> *items = components.queryItems;
            expect(items).to(contain([NSURLQueryItem queryItemWithName:@"scope" value:@"openid"]));
            expect(items).to(contain([NSURLQueryItem queryItemWithName:@"nonce" value:@"some random value"]));
        });

    });

    context(@"authentication block", ^{

        __block A0IdPAuthenticationBlock successBlock;
        __block A0IdPAuthenticationErrorBlock failureBlock;
        __block A0Token *token;

        beforeEach(^{
            token = mock(A0Token.class);
            [given(token.idToken) willReturn:@"IDTOKEN"];
            successBlock = ^(A0UserProfile *profile, A0Token *token) {
            };
            failureBlock = ^(NSError *error) {
            };
            session = [[A0SafariSession alloc] initWithLock:lock connectionName:@"facebook" usePKCE:NO];
        });

        it(@"should report error", ^{
            waitUntil(^(void(^done)()) {
                A0SafariSessionAuthentication block = [session authenticationBlockWithSuccess:^(A0UserProfile * _Nonnull profile, A0Token * _Nonnull token) {
                    failWithMessage(@"should have failed");
                    done();
                } failure:^(NSError * _Nonnull error) {
                    failureBlock(error);
                    done();
                }];
                block([NSError errorWithDomain:@"com.auth0" code:0 userInfo:nil], nil);
            });
        });

        it(@"should fetch profile", ^{
            [given([client fetchUserProfileWithIdToken:@"IDTOKEN" success:anything() failure:anything()]) willDo:^id(NSInvocation *invocation) {
                NSArray *arguments = [invocation mkt_arguments];
                A0APIClientUserProfileSuccess block = arguments[1];
                block(mock(A0UserProfile.class));
                return nil;
            }];
            waitUntil(^(void(^done)()) {
                A0SafariSessionAuthentication block = [session authenticationBlockWithSuccess:^(A0UserProfile * _Nonnull profile, A0Token * _Nonnull token) {
                    successBlock(profile, token);
                    [MKTVerify(client) fetchUserProfileWithIdToken:@"IDTOKEN" success:anything() failure:anything()];
                    done();
                } failure:^(NSError * _Nonnull error) {
                    failWithMessage(@"should not have failed");
                    done();
                }];
                block(nil, token);
            });
        });
    });
});

QuickSpecEnd
