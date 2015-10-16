// A0EmailLockViewModelSpec.m
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
#import "Lock.h"
#import "A0EmailLockViewModel.h"

SpecBegin(A0EmailLockViewModel)

__block A0Lock *lock;
__block A0APIClient *client;
__block A0AuthParameters *parameters;

__block A0EmailLockViewModel *model;

beforeEach(^{
    lock = mock(A0Lock.class);
    client = mock(A0APIClient.class);
    parameters = [A0AuthParameters newDefaultParams];
    [given([lock apiClient]) willReturn:client];
});

describe(@"initialisation", ^{

    it(@"should build for Magic Link", ^{
        model = [[A0EmailLockViewModel alloc] initForMagicLinkWithLock:lock authenticationParameters:parameters];
        expect(model).toNot.beNil();
    });

    it(@"should build for code only", ^{
        model = [[A0EmailLockViewModel alloc] initWithLock:lock authenticationParameters:parameters];
        expect(model).toNot.beNil();
    });

});

describe(@"email", ^{

    beforeEach(^{
        model = [[A0EmailLockViewModel alloc] initForMagicLinkWithLock:lock authenticationParameters:parameters];
    });

    it(@"should tell an email is invalid", ^{
        model.email = @"no idea what i should input";
        expect(model.emailError).toNot.beNil();
    });

    it(@"should check if there is a valid email", ^{
        model.email = @"random string";
        expect(model.hasEmail).to.beFalsy();
    });

    it(@"should not have any email first", ^{
        expect(model.hasEmail).to.beFalsy();
    });

});


describe(@"send email with code", ^{

    beforeEach(^{
        model = [[A0EmailLockViewModel alloc] initWithLock:lock authenticationParameters:parameters];
    });

    it(@"should request to send email", ^{
        [given([client startPasswordlessWithEmail:anything() success:anything() failure:anything()]) willDo:^id(NSInvocation *invocation) {
            NSArray *arguments = [invocation mkt_arguments];
            void(^callback)() = arguments[1];
            callback();
            return mock(NSURLSessionDataTask.class);
        }];
        waitUntil(^(DoneCallback done) {
            [model requestVerificationCodeWithCallback:^(NSError * _Nullable error) {
                expect(error).to.beNil();
                done();
            }];
        });
    });

    it(@"should report error", ^{
        [given([client startPasswordlessWithEmail:anything() success:anything() failure:anything()]) willDo:^id(NSInvocation *invocation) {
            NSArray *arguments = [invocation mkt_arguments];
            void(^callback)() = arguments[2];
            callback(mock(NSError.class));
            return mock(NSURLSessionDataTask.class);
        }];
        waitUntil(^(DoneCallback done) {
            [model requestVerificationCodeWithCallback:^(NSError * _Nullable error) {
                expect(error).toNot.beNil();
                done();
            }];
        });
    });

});

describe(@"send magic link", ^{

    beforeEach(^{
        model = [[A0EmailLockViewModel alloc] initForMagicLinkWithLock:lock authenticationParameters:parameters];
    });

    it(@"should request to send email", ^{
        [given([client startPasswordlessWithMagicLinkInEmail:anything() parameters:anything() success:anything() failure:anything()]) willDo:^id(NSInvocation *invocation) {
            NSArray *arguments = [invocation mkt_arguments];
            void(^callback)() = arguments[2];
            callback();
            return mock(NSURLSessionDataTask.class);
        }];
        waitUntil(^(DoneCallback done) {
            [model requestVerificationCodeWithCallback:^(NSError * _Nullable error) {
                expect(error).to.beNil();
                done();
            }];
        });
    });

    it(@"should report error", ^{
        [given([client startPasswordlessWithMagicLinkInEmail:anything() parameters:anything() success:anything() failure:anything()]) willDo:^id(NSInvocation *invocation) {
            NSArray *arguments = [invocation mkt_arguments];
            void(^callback)() = arguments[3];
            callback(mock(NSError.class));
            return mock(NSURLSessionDataTask.class);
        }];
        waitUntil(^(DoneCallback done) {
            [model requestVerificationCodeWithCallback:^(NSError * _Nullable error) {
                expect(error).toNot.beNil();
                done();
            }];
        });
    });
    
});

describe(@"code authentication", ^{

    sharedExamplesFor(@"authentication", ^(NSDictionary *data) {

        beforeEach(^{
            [given([client loginWithEmail:anything() passcode:@"valid" parameters:anything() success:anything() failure:anything()]) willDo:^id(NSInvocation *invocation) {
                NSArray *arguments = [invocation mkt_arguments];
                A0APIClientAuthenticationSuccess callback = arguments[3];
                callback(mock(A0UserProfile.class), mock(A0Token.class));
                return mock(NSURLSessionDataTask.class);
            }];
            [given([client loginWithEmail:anything() passcode:@"invalid" parameters:anything() success:anything() failure:anything()]) willDo:^id(NSInvocation *invocation) {
                NSArray *arguments = [invocation mkt_arguments];
                A0APIClientError callback = arguments[4];
                callback(mock(NSError.class));
                return mock(NSURLSessionDataTask.class);
            }];

        });

        it(@"should authenticate user", ^{
            A0EmailLockViewModel *model = data[@"model"];
            model.onAuthenticationBlock = ^(A0UserProfile *profile, A0Token *token) {
            };
            waitUntil(^(DoneCallback done) {
                [model authenticateWithVerificationCode:@"valid" callback:^(NSError * _Nullable error) {
                    expect(error).to.beNil();
                    done();
                }];
            });
        });

        it(@"should report failure", ^{
            A0EmailLockViewModel *model = data[@"model"];
            model.onAuthenticationBlock = ^(A0UserProfile *profile, A0Token *token) {
            };
            waitUntil(^(DoneCallback done) {
                [model authenticateWithVerificationCode:@"invalid" callback:^(NSError * _Nullable error) {
                    expect(error).toNot.beNil();
                    done();
                }];
            });
        });

        it(@"should return token and profile", ^{
            A0EmailLockViewModel *model = data[@"model"];
            waitUntil(^(DoneCallback done) {
                model.onAuthenticationBlock = ^(A0UserProfile *profile, A0Token *token) {
                    expect(profile).toNot.beNil();
                    expect(token).toNot.beNil();
                    done();
                };
                [model authenticateWithVerificationCode:@"valid" callback:^(NSError * _Nullable error) {}];
            });
        });
    });

    itShouldBehaveLike(@"authentication", ^id{
        return @{
                 @"model": [[A0EmailLockViewModel alloc] initForMagicLinkWithLock:lock authenticationParameters:parameters]
                 };
    });

    itShouldBehaveLike(@"authentication", ^id{
        return @{
                 @"model": [[A0EmailLockViewModel alloc] initWithLock:lock authenticationParameters:parameters]
                 };
    });

});

SpecEnd