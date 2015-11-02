// A0PasswordlessLockViewModelSpec.m
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
#import "A0PasswordlessLockViewModel.h"
#import "A0LockNotification.h"

#define kEmailForSuccess @"mail@mail.com"
#define kEmailForFailure @"failed@mail.com"
#define kNumberForSuccess @"+1123123123"
#define kNumberForFailure @"+549123123123"

SpecBegin(A0PasswordlessLockViewModel)

__block A0Lock *lock;
__block A0APIClient *client;
__block A0AuthParameters *parameters;

__block A0PasswordlessLockViewModel *model;

beforeEach(^{
    lock = mock(A0Lock.class);
    client = mock(A0APIClient.class);
    parameters = [A0AuthParameters newDefaultParams];
    [given([lock apiClient]) willReturn:client];
});

describe(@"initialisation", ^{

    it(@"should build for Magic Link", ^{
        model = [[A0PasswordlessLockViewModel alloc] initWithLock:lock authenticationParameters:parameters strategy:A0PasswordlessLockStrategyEmailMagicLink];
        expect(model).toNot.beNil();
    });

    it(@"should build for code only", ^{
        model = [[A0PasswordlessLockViewModel alloc] initWithLock:lock authenticationParameters:parameters strategy:A0PasswordlessLockStrategyEmailCode];
        expect(model).toNot.beNil();
    });

});

describe(@"email", ^{

    beforeEach(^{
        model = [[A0PasswordlessLockViewModel alloc] initWithLock:lock authenticationParameters:parameters strategy:A0PasswordlessLockStrategyEmailMagicLink];
    });

    it(@"should tell an email is invalid", ^{
        model.identifier = @"no idea what i should input";
        expect(model.identifierError).toNot.beNil();
    });

    it(@"should check if there is a valid email", ^{
        model.identifier = @"random string";
        expect(model.hasIdentifier).to.beFalsy();
    });

    it(@"should not have any email first", ^{
        expect(model.hasIdentifier).to.beFalsy();
    });

});

describe(@"start", ^{

    sharedExamplesFor(@"passwordless started", ^(NSDictionary *data) {
        __block A0PasswordlessLockViewModel *model;
        beforeEach(^{
            id (^allGood)(NSInvocation *) = ^id(NSInvocation *invocation) {
                NSArray *arguments = [invocation mkt_arguments];
                void(^callback)() = arguments[arguments.count - 2];
                callback();
                return mock(NSURLSessionDataTask.class);
            };
            id (^noGood)(NSInvocation *) = ^id(NSInvocation *invocation) {
                NSArray *arguments = [invocation mkt_arguments];
                void(^callback)() = arguments[arguments.count - 1];
                callback(mock(NSError.class));
                return mock(NSURLSessionDataTask.class);
            };
            [given([client startPasswordlessWithEmail:kEmailForSuccess success:anything() failure:anything()]) willDo:allGood];
            [given([client startPasswordlessWithEmail:kEmailForFailure success:anything() failure:anything()]) willDo:noGood];
            [given([client startPasswordlessWithMagicLinkInEmail:kEmailForSuccess parameters:anything() success:anything() failure:anything()]) willDo:allGood];
            [given([client startPasswordlessWithMagicLinkInEmail:kEmailForFailure parameters:anything() success:anything() failure:anything()]) willDo:noGood];
            [given([client startPasswordlessWithPhoneNumber:kNumberForSuccess success:anything() failure:anything()]) willDo:allGood];
            [given([client startPasswordlessWithPhoneNumber:kNumberForFailure success:anything() failure:anything()]) willDo:noGood];
            [given([client startPasswordlessWithMagicLinkInSMS:kNumberForSuccess parameters:anything() success:anything() failure:anything()]) willDo:allGood];
            [given([client startPasswordlessWithMagicLinkInSMS:kNumberForFailure parameters:anything() success:anything() failure:anything()]) willDo:noGood];

            model = data[@"model"];
        });

        it(@"should request code or magic link", ^{
            waitUntil(^(DoneCallback done) {
                model.identifier = [data[@"mode"] isEqualToString:@"email"] ? kEmailForSuccess : kNumberForSuccess;
                [model requestVerificationCodeWithCallback:^(NSError * _Nullable error) {
                    expect(error).to.beNil();
                    done();
                }];
            });
        });

        it(@"should report error", ^{
            waitUntil(^(DoneCallback done) {
                model.identifier = [data[@"mode"] isEqualToString:@"email"] ? kEmailForFailure : kNumberForFailure;
                [model requestVerificationCodeWithCallback:^(NSError * _Nullable error) {
                    expect(error).toNot.beNil();
                    done();
                }];
            });
        });

    });

    itShouldBehaveLike(@"passwordless started", ^id{
        return @{
                 @"mode": @"email",
                 @"model": [[A0PasswordlessLockViewModel alloc] initWithLock:lock authenticationParameters:parameters strategy:A0PasswordlessLockStrategyEmailCode]
                 };
    });

    itShouldBehaveLike(@"passwordless started", ^id{
        return @{
                 @"mode": @"email",
                 @"model": [[A0PasswordlessLockViewModel alloc] initWithLock:lock authenticationParameters:parameters strategy:A0PasswordlessLockStrategyEmailMagicLink]
                 };
    });

    itShouldBehaveLike(@"passwordless started", ^id{
        return @{
                 @"mode": @"sms",
                 @"model": [[A0PasswordlessLockViewModel alloc] initWithLock:lock authenticationParameters:parameters strategy:A0PasswordlessLockStrategySMSCode]
                 };
    });

    itShouldBehaveLike(@"passwordless started", ^id{
        return @{
                 @"mode": @"sms",
                 @"model": [[A0PasswordlessLockViewModel alloc] initWithLock:lock authenticationParameters:parameters strategy:A0PasswordlessLockStrategySMSMagicLink]
                 };
    });

});

describe(@"authentication", ^{

    sharedExamplesFor(@"authenticated", ^(NSDictionary *data) {

        __block A0PasswordlessLockViewModel *model;

        beforeEach(^{
            id (^allGood)(NSInvocation *) = ^id(NSInvocation *invocation) {
                NSArray *arguments = [invocation mkt_arguments];
                A0APIClientAuthenticationSuccess callback = arguments[3];
                callback(mock(A0UserProfile.class), mock(A0Token.class));
                return mock(NSURLSessionDataTask.class);
            };
            id (^noGood)(NSInvocation *) = ^id(NSInvocation *invocation) {
                NSArray *arguments = [invocation mkt_arguments];
                A0APIClientError callback = arguments[4];
                callback(mock(NSError.class));
                return mock(NSURLSessionDataTask.class);
            };
            [given([client loginWithEmail:kEmailForSuccess passcode:@"valid" parameters:anything() success:anything() failure:anything()]) willDo:allGood];
            [given([client loginWithEmail:kEmailForSuccess passcode:@"invalid" parameters:anything() success:anything() failure:anything()]) willDo:noGood];
            [given([client loginWithPhoneNumber:kNumberForSuccess passcode:@"valid" parameters:anything() success:anything() failure:anything()]) willDo:allGood];
            [given([client loginWithPhoneNumber:kNumberForSuccess passcode:@"invalid" parameters:anything() success:anything() failure:anything()]) willDo:noGood];

            model = data[@"model"];
            model.identifier = data[@"identifier"];
        });

        it(@"should authenticate user", ^{
            model.onAuthentication = ^(A0UserProfile *profile, A0Token *token) {
            };
            waitUntil(^(DoneCallback done) {
                [model authenticateWithVerificationCode:@"valid" callback:^(NSError * _Nullable error) {
                    expect(error).to.beNil();
                    done();
                }];
            });
        });

        it(@"should report failure", ^{
            model.onAuthentication = ^(A0UserProfile *profile, A0Token *token) {
            };
            waitUntil(^(DoneCallback done) {
                [model authenticateWithVerificationCode:@"invalid" callback:^(NSError * _Nullable error) {
                    expect(error).toNot.beNil();
                    done();
                }];
            });
        });

        it(@"should return token and profile", ^{
            waitUntil(^(DoneCallback done) {
                model.onAuthentication = ^(A0UserProfile *profile, A0Token *token) {
                    expect(profile).toNot.beNil();
                    expect(token).toNot.beNil();
                    done();
                };
                [model authenticateWithVerificationCode:@"valid" callback:^(NSError * _Nullable error) {}];
            });
        });
    });

    itShouldBehaveLike(@"authenticated", ^id{
        return @{
                 @"identifier": kEmailForSuccess,
                 @"model": [[A0PasswordlessLockViewModel alloc] initWithLock:lock authenticationParameters:parameters strategy:A0PasswordlessLockStrategyEmailCode]
                 };
    });

    itShouldBehaveLike(@"authenticated", ^id{
        return @{
                 @"identifier": kEmailForSuccess,
                 @"model": [[A0PasswordlessLockViewModel alloc] initWithLock:lock authenticationParameters:parameters strategy:A0PasswordlessLockStrategyEmailMagicLink]
                 };
    });

    itShouldBehaveLike(@"authenticated", ^id{
        return @{
                 @"identifier": kNumberForSuccess,
                 @"model": [[A0PasswordlessLockViewModel alloc] initWithLock:lock authenticationParameters:parameters strategy:A0PasswordlessLockStrategySMSCode]
                 };
    });

    itShouldBehaveLike(@"authenticated", ^id{
        return @{
                 @"identifier": kNumberForSuccess,
                 @"model": [[A0PasswordlessLockViewModel alloc] initWithLock:lock authenticationParameters:parameters strategy:A0PasswordlessLockStrategySMSMagicLink]
                 };
    });

});

describe(@"universal link", ^{

    sharedExamplesFor(@"authenticated with link", ^(NSDictionary *data) {
        __block A0PasswordlessLockViewModel *model;

        beforeEach(^{
            id (^allGood)(NSInvocation *) = ^id(NSInvocation *invocation) {
                NSArray *arguments = [invocation mkt_arguments];
                A0APIClientAuthenticationSuccess callback = arguments[3];
                callback(mock(A0UserProfile.class), mock(A0Token.class));
                return mock(NSURLSessionDataTask.class);
            };
            [given([client loginWithEmail:kEmailForSuccess passcode:@"valid" parameters:anything() success:anything() failure:anything()]) willDo:allGood];
            [given([client loginWithPhoneNumber:kNumberForSuccess passcode:@"valid" parameters:anything() success:anything() failure:anything()]) willDo:allGood];

            model = data[@"model"];
            model.identifier = data[@"identifier"];
        });

        it(@"should call magic link block on complete", ^{
            waitUntil(^(DoneCallback done) {
                model.onAuthentication = ^(A0UserProfile *profile, A0Token *token) {};
                model.onMagicLink = ^(NSError *error, BOOL completed) {
                    done();
                };
                [[NSNotificationCenter defaultCenter] postNotificationName:A0LockNotificationUniversalLinkReceived
                                                                    object:nil
                                                                  userInfo:@{
                                                                             A0LockNotificationUniversalLinkParameterKey: [NSURL URLWithString:[[@"https://samples.auth0.com/ios/appname/" stringByAppendingString:data[@"mode"]] stringByAppendingString:@"?code=valid"]]
                                                                             }];
            });
        });

        it(@"should return token and profile", ^{
            waitUntil(^(DoneCallback done) {
                model.onMagicLink = ^(NSError *error, BOOL completed) {};
                model.onAuthentication = ^(A0UserProfile *profile, A0Token *token) {
                    expect(profile).toNot.beNil();
                    expect(token).toNot.beNil();
                    done();
                };
                [[NSNotificationCenter defaultCenter] postNotificationName:A0LockNotificationUniversalLinkReceived
                                                                    object:nil
                                                                  userInfo:@{
                                                                             A0LockNotificationUniversalLinkParameterKey: [NSURL URLWithString:[[@"https://samples.auth0.com/ios/appname/" stringByAppendingString:data[@"mode"]] stringByAppendingString:@"?code=valid"]]
                                                                             }];
            });
        });

    });

    itShouldBehaveLike(@"authenticated with link", ^id{
        return @{
                 @"mode": @"email",
                 @"identifier": kEmailForSuccess,
                 @"model": [[A0PasswordlessLockViewModel alloc] initWithLock:lock authenticationParameters:parameters strategy:A0PasswordlessLockStrategyEmailMagicLink]
                 };
    });

    itShouldBehaveLike(@"authenticated with link", ^id{
        return @{
                 @"mode": @"sms",
                 @"identifier": kNumberForSuccess,
                 @"model": [[A0PasswordlessLockViewModel alloc] initWithLock:lock authenticationParameters:parameters strategy:A0PasswordlessLockStrategySMSMagicLink]
                 };
    });

});
SpecEnd