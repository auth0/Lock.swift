// A0LockSpec.m
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

#import "A0Lock.h"
#import "A0LockNotification.h"

#define kClientId @"1234567890"
#define kDomain @"samples.auth0.com"
#define kEUDomain @"samples.eu.auth0.com"
#define kConfigurationDomain @"myconfig.mydomain.com"

@interface A0Lock (Testing)
- (instancetype)initWithBundleInfo:(NSDictionary *)info;
@end


SpecBegin(A0Lock)

describe(@"A0Lock", ^{

    describe(@"initialization", ^{

        sharedExamplesFor(@"valid Lock", ^(NSDictionary *data) {

            __block A0Lock *lock;

            beforeEach(^{
                lock = data[@"lock"];
            });

            specify(@"domain URL", ^{
                expect([[lock domainURL] absoluteString]).to.equal(data[@"domain"]);
            });

            specify(@"configuration URL", ^{
                expect([[lock configurationURL] absoluteString]).to.equal(data[@"configurationDomain"]);
            });

            specify(@"client Id", ^{
                expect([lock clientId]).to.equal(data[@"clientId"]);
            });

        });

        itShouldBehaveLike(@"valid Lock", @{
                                            @"lock": [A0Lock newLockWithClientId:kClientId domain:kDomain],
                                            @"domain": @"https://samples.auth0.com",
                                            @"configurationDomain": [NSString stringWithFormat:@"https://cdn.auth0.com/client/%@.js", kClientId],
                                            @"clientId": kClientId,
                                            });

        itShouldBehaveLike(@"valid Lock", @{
                                            @"lock": [A0Lock newLockWithClientId:kClientId domain:kEUDomain],
                                            @"domain": @"https://samples.eu.auth0.com",
                                            @"configurationDomain": [NSString stringWithFormat:@"https://cdn.eu.auth0.com/client/%@.js", kClientId],
                                            @"clientId": kClientId,
                                            });

        itShouldBehaveLike(@"valid Lock", @{
                                            @"lock": [A0Lock newLockWithClientId:kClientId domain:@"https://overmind.auth0.com"],
                                            @"domain": @"https://overmind.auth0.com",
                                            @"configurationDomain": [NSString stringWithFormat:@"https://cdn.auth0.com/client/%@.js", kClientId],
                                            @"clientId": kClientId,
                                            });

        itShouldBehaveLike(@"valid Lock", @{
                                            @"lock": [A0Lock newLockWithClientId:kClientId domain:@"https://overmind.eu.auth0.com"],
                                            @"domain": @"https://overmind.eu.auth0.com",
                                            @"configurationDomain": [NSString stringWithFormat:@"https://cdn.eu.auth0.com/client/%@.js", kClientId],
                                            @"clientId": kClientId,
                                            });

        itShouldBehaveLike(@"valid Lock", @{
                                            @"lock": [A0Lock newLockWithClientId:kClientId domain:kDomain configurationDomain:kConfigurationDomain],
                                            @"domain": @"https://samples.auth0.com",
                                            @"configurationDomain": [NSString stringWithFormat:@"https://%@/client/%@.js", kConfigurationDomain, kClientId],
                                            @"clientId": kClientId,
                                            });
        itShouldBehaveLike(@"valid Lock", @{
                                            @"lock": [A0Lock newLockWithClientId:kClientId domain:kDomain configurationDomain:@"https://somewhere.far.beyond"],
                                            @"domain": @"https://samples.auth0.com",
                                            @"configurationDomain": [NSString stringWithFormat:@"https://somewhere.far.beyond/client/%@.js", kClientId],
                                            @"clientId": kClientId,
                                            });


        itShouldBehaveLike(@"valid Lock", @{
                                            @"lock": [A0Lock newLockWithClientId:kClientId domain:kDomain configurationDomain:@"https://somewhere.far.beyond"],
                                            @"domain": @"https://samples.auth0.com",
                                            @"configurationDomain": [NSString stringWithFormat:@"https://somewhere.far.beyond/client/%@.js", kClientId],
                                            @"clientId": kClientId,
                                            });

        itShouldBehaveLike(@"valid Lock", @{
                                            @"lock": [[A0Lock alloc] initWithBundleInfo:@{
                                                                                          @"Auth0ClientId": kClientId,
                                                                                          @"Auth0Tenant": @"samples",
                                                                                          }],
                                            @"domain": @"https://samples.auth0.com",
                                            @"configurationDomain": [NSString stringWithFormat:@"https://cdn.auth0.com/client/%@.js", kClientId],
                                            @"clientId": kClientId,
                                            });

        itShouldBehaveLike(@"valid Lock", @{
                                            @"lock": [[A0Lock alloc] initWithBundleInfo:@{
                                                                                          @"Auth0ClientId": kClientId,
                                                                                          @"Auth0Domain": kDomain,
                                                                                          }],
                                            @"domain": @"https://samples.auth0.com",
                                            @"configurationDomain": [NSString stringWithFormat:@"https://cdn.auth0.com/client/%@.js", kClientId],
                                            @"clientId": kClientId,
                                            });

        itShouldBehaveLike(@"valid Lock", @{
                                            @"lock": [[A0Lock alloc] initWithBundleInfo:@{
                                                                                          @"Auth0ClientId": kClientId,
                                                                                          @"Auth0Domain": kEUDomain,
                                                                                          }],
                                            @"domain": @"https://samples.eu.auth0.com",
                                            @"configurationDomain": [NSString stringWithFormat:@"https://cdn.eu.auth0.com/client/%@.js", kClientId],
                                            @"clientId": kClientId,
                                            });

        itShouldBehaveLike(@"valid Lock", @{
                                            @"lock": [[A0Lock alloc] initWithBundleInfo:@{
                                                                                          @"Auth0ClientId": kClientId,
                                                                                          @"Auth0Domain": kEUDomain,
                                                                                          @"Auth0ConfigurationDomain": kConfigurationDomain
                                                                                          }],
                                            @"domain": @"https://samples.eu.auth0.com",
                                            @"configurationDomain": [NSString stringWithFormat:@"https://%@/client/%@.js", kConfigurationDomain, kClientId],
                                            @"clientId": kClientId,
                                            });


        it(@"should fail to create", ^{
            expect(^{
                NSAssert([[A0Lock alloc] initWithBundleInfo:@{}], @"Non nil");
            }).to.raise(NSInternalInconsistencyException);
        });

    });

    describe(@"Universal Links", ^{

        __block A0Lock *lock;
        __block NSUserActivity *activity;
        void(^restorationHandler)(NSArray *) = ^(NSArray *array){};

        beforeEach(^{
            lock = [A0Lock newLockWithClientId:kClientId domain:kDomain];
            activity = mock(NSUserActivity.class);
        });

        it(@"should accept url from configured auth0 subdomain", ^{
            [given(activity.webpageURL) willReturn:[NSURL URLWithString:@"https://auth0.com"]];
            expect([lock continueUserActivity:activity restorationHandler:restorationHandler]).to.beFalsy();
        });

        it(@"should not accept nil url", ^{
            [given(activity.webpageURL) willReturn:nil];
            expect([lock continueUserActivity:activity restorationHandler:restorationHandler]).to.beFalsy();
        });

        it(@"should not accept url without ios prefix", ^{
            [given(activity.webpageURL) willReturn:[NSURL URLWithString:@"https://samples.auth0.com/callback"]];
            expect([lock continueUserActivity:activity restorationHandler:restorationHandler]).to.beFalsy();
        });

        it(@"should not accept url of another application", ^{
            [given(activity.webpageURL) willReturn:[NSURL URLWithString:@"https://samples.auth0.com/ios/com.auth0.MyAwesomeApp"]];
            expect([lock continueUserActivity:activity restorationHandler:restorationHandler]).to.beFalsy();
        });

        it(@"should handle valid url", ^{
            [given(activity.webpageURL) willReturn:[NSURL URLWithString:[@"https://samples.auth0.com/ios/" stringByAppendingString:[[NSBundle mainBundle] bundleIdentifier]]]];
            expect([lock continueUserActivity:activity restorationHandler:restorationHandler]).to.beTruthy();
        });

        it(@"should post notification with url", ^{
            NSURL *url = [NSURL URLWithString:[@"https://samples.auth0.com/ios/" stringByAppendingString:[[NSBundle mainBundle] bundleIdentifier]]];
            [given(activity.webpageURL) willReturn:url];
            NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];

            waitUntil(^(DoneCallback done) {
                NSObject *observer = [defaultCenter addObserverForName:A0LockNotificationUniversalLinkReceived
                                                                object:nil
                                                                 queue:nil
                                                            usingBlock:^(NSNotification * _Nonnull notif) {
                                                                expect(notif.userInfo[A0LockNotificationUniversalLinkParameterKey]).to.equal(url);
                                                                [[NSNotificationCenter defaultCenter] removeObserver:observer];
                                                                done();
                                                            }];
                [lock continueUserActivity:activity restorationHandler:restorationHandler];
            });
        });

    });
});

SpecEnd
