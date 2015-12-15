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

#define QUICK_DISABLE_SHORT_SYNTAX 1

#import <Quick/Quick.h>
#import <Nimble/Nimble.h>

#import "A0Lock.h"
#import "A0LockNotification.h"
#import "A0CredentialProvider.h"
#import "A0MainBundleCredentialProvider.h"

#define kClientId @"1234567890"
#define kDomain @"samples.auth0.com"
#define kEUDomain @"samples.eu.auth0.com"
#define kAUDomain @"samples.au.auth0.com"
#define kConfigurationDomain @"myconfig.mydomain.com"

@interface A0Lock (Testing)
- (instancetype)initWithCredentialProvider:(id<A0CredentialProvider>)credentialProvider;
@end

@interface A0MainBundleCredentialProvider (Testing)
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
@end

QuickSpecBegin(A0LockSpec)

describe(@"A0Lock", ^{

    describe(@"initialization", ^{

        sharedExamples(@"valid Lock", ^(QCKDSLSharedExampleContext context) {

            __block A0Lock *lock;

            beforeEach(^{
                lock = context()[@"lock"];
            });

            it(@"domain URL", ^{
                expect([[lock domainURL] absoluteString]).to(equal(context()[@"domain"]));
            });

            it(@"configuration URL", ^{
                expect([[lock configurationURL] absoluteString]).to(equal(context()[@"configurationDomain"]));
            });

            it(@"client Id", ^{
                expect([lock clientId]).to(equal(context()[@"clientId"]));
            });

        });

        itBehavesLike(@"valid Lock", ^{
            return @{
                     @"lock": [A0Lock newLockWithClientId:kClientId domain:kDomain],
                     @"domain": @"https://samples.auth0.com",
                     @"configurationDomain": [NSString stringWithFormat:@"https://cdn.auth0.com/client/%@.js", kClientId],
                     @"clientId": kClientId,
                     };
        });

        itBehavesLike(@"valid Lock", ^{
            return @{
                     @"lock": [A0Lock newLockWithClientId:kClientId domain:kEUDomain],
                     @"domain": @"https://samples.eu.auth0.com",
                     @"configurationDomain": [NSString stringWithFormat:@"https://cdn.eu.auth0.com/client/%@.js", kClientId],
                     @"clientId": kClientId,
                     };
        });

        itBehavesLike(@"valid Lock", ^{
            return @{
                     @"lock": [A0Lock newLockWithClientId:kClientId domain:kAUDomain],
                     @"domain": @"https://samples.au.auth0.com",
                     @"configurationDomain": [NSString stringWithFormat:@"https://cdn.au.auth0.com/client/%@.js", kClientId],
                     @"clientId": kClientId,
                     };
        });

        itBehavesLike(@"valid Lock", ^{
            return @{
                     @"lock": [A0Lock newLockWithClientId:kClientId domain:@"https://overmind.auth0.com"],
                     @"domain": @"https://overmind.auth0.com",
                     @"configurationDomain": [NSString stringWithFormat:@"https://cdn.auth0.com/client/%@.js", kClientId],
                     @"clientId": kClientId,
                     };
        });

        itBehavesLike(@"valid Lock", ^{
            return @{
                                            @"lock": [A0Lock newLockWithClientId:kClientId domain:@"https://overmind.eu.auth0.com"],
                                            @"domain": @"https://overmind.eu.auth0.com",
                                            @"configurationDomain": [NSString stringWithFormat:@"https://cdn.eu.auth0.com/client/%@.js", kClientId],
                                            @"clientId": kClientId,
                                            };
        });

        itBehavesLike(@"valid Lock", ^{
            return @{
                     @"lock": [A0Lock newLockWithClientId:kClientId domain:kDomain configurationDomain:kConfigurationDomain],
                     @"domain": @"https://samples.auth0.com",
                     @"configurationDomain": [NSString stringWithFormat:@"https://%@/client/%@.js", kConfigurationDomain, kClientId],
                     @"clientId": kClientId,
                     };
        });

        itBehavesLike(@"valid Lock", ^{
            return @{
                     @"lock": [A0Lock newLockWithClientId:kClientId domain:kDomain configurationDomain:@"https://somewhere.far.beyond"],
                     @"domain": @"https://samples.auth0.com",
                     @"configurationDomain": [NSString stringWithFormat:@"https://somewhere.far.beyond/client/%@.js", kClientId],
                     @"clientId": kClientId,
                     };
        });


        itBehavesLike(@"valid Lock", ^{
            return @{
                                            @"lock": [A0Lock newLockWithClientId:kClientId domain:kDomain configurationDomain:@"https://somewhere.far.beyond"],
                                            @"domain": @"https://samples.auth0.com",
                                            @"configurationDomain": [NSString stringWithFormat:@"https://somewhere.far.beyond/client/%@.js", kClientId],
                                            @"clientId": kClientId,
                                            };
        });

        itBehavesLike(@"valid Lock", ^{
            return @{
                     @"lock": [[A0Lock alloc] initWithCredentialProvider:[[A0MainBundleCredentialProvider alloc] initWithDictionary:@{
                                                                                                                                      @"Auth0ClientId": kClientId,
                                                                                                                                      @"Auth0Tenant": @"samples",
                                                                                                                                      }]],
                     @"domain": @"https://samples.auth0.com",
                     @"configurationDomain": [NSString stringWithFormat:@"https://cdn.auth0.com/client/%@.js", kClientId],
                     @"clientId": kClientId,
                     };
        });

        itBehavesLike(@"valid Lock", ^{
            return @{
                     @"lock": [[A0Lock alloc] initWithCredentialProvider:[[A0MainBundleCredentialProvider alloc] initWithDictionary:@{
                                                                                                                                      @"Auth0ClientId": kClientId,
                                                                                                                                      @"Auth0Domain": kDomain,
                                                                                                                                      }]],
                     @"domain": @"https://samples.auth0.com",
                     @"configurationDomain": [NSString stringWithFormat:@"https://cdn.auth0.com/client/%@.js", kClientId],
                     @"clientId": kClientId,
                     };
        });

        itBehavesLike(@"valid Lock", ^{
            return @{
                     @"lock": [[A0Lock alloc] initWithCredentialProvider:[[A0MainBundleCredentialProvider alloc] initWithDictionary:@{
                                                                                                                                      @"Auth0ClientId": kClientId,
                                                                                                                                      @"Auth0Domain": kEUDomain,
                                                                                                                                      }]],
                     @"domain": @"https://samples.eu.auth0.com",
                     @"configurationDomain": [NSString stringWithFormat:@"https://cdn.eu.auth0.com/client/%@.js", kClientId],
                     @"clientId": kClientId,
                     };
        });

        itBehavesLike(@"valid Lock", ^{
            return @{
                     @"lock": [[A0Lock alloc] initWithCredentialProvider:[[A0MainBundleCredentialProvider alloc] initWithDictionary:@{
                                                                                                                                      @"Auth0ClientId": kClientId,
                                                                                                                                      @"Auth0Domain": kEUDomain,
                                                                                                                                      @"Auth0ConfigurationDomain": kConfigurationDomain
                                                                                                                                      }]],
                     @"domain": @"https://samples.eu.auth0.com",
                     @"configurationDomain": [NSString stringWithFormat:@"https://%@/client/%@.js", kConfigurationDomain, kClientId],
                     @"clientId": kClientId,
                     };
        });

    });

    describe(@"Universal Links", ^{

        __block A0Lock *lock;
        __block NSUserActivity *activity;
        __block id observer;
        void(^restorationHandler)(NSArray *) = ^(NSArray *array){};

        beforeEach(^{
            lock = [A0Lock newLockWithClientId:kClientId domain:kDomain];
            activity = [[NSUserActivity alloc] initWithActivityType:@"Mock"];
        });

        afterEach(^{
            [[NSNotificationCenter defaultCenter] removeObserver:observer];
        });

        it(@"should accept url from configured auth0 subdomain", ^{
            activity.webpageURL = [NSURL URLWithString:@"https://auth0.com"];
            expect(@([lock continueUserActivity:activity restorationHandler:restorationHandler])).to(beFalsy());
        });

        it(@"should not accept nil url", ^{
            activity.webpageURL = nil;
            expect(@([lock continueUserActivity:activity restorationHandler:restorationHandler])).to(beFalsy());
        });

        it(@"should not accept url without ios prefix", ^{
            activity.webpageURL = [NSURL URLWithString:@"https://samples.auth0.com/callback"];
            expect(@([lock continueUserActivity:activity restorationHandler:restorationHandler])).to(beFalsy());
        });

        it(@"should not accept url of another application", ^{
            activity.webpageURL = [NSURL URLWithString:@"https://samples.auth0.com/ios/com.auth0.MyAwesomeApp"];
            expect(@([lock continueUserActivity:activity restorationHandler:restorationHandler])).to(beFalsy());
        });

        it(@"should handle valid url", ^{
            activity.webpageURL = [NSURL URLWithString:[@"https://samples.auth0.com/ios/" stringByAppendingString:[[NSBundle mainBundle] bundleIdentifier]]];
            expect(@([lock continueUserActivity:activity restorationHandler:restorationHandler])).to(beTruthy());
        });

        it(@"should post notification with url", ^{
            NSURL *url = [NSURL URLWithString:[@"https://samples.auth0.com/ios/" stringByAppendingString:[[NSBundle mainBundle] bundleIdentifier]]];
            activity.webpageURL = url;
            NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];

            waitUntil(^(void (^done)()) {
                observer = [defaultCenter addObserverForName:A0LockNotificationUniversalLinkReceived
                                                                object:nil
                                                                 queue:nil
                                                            usingBlock:^(NSNotification * _Nonnull notif) {
                                                                expect(notif.userInfo[A0LockNotificationUniversalLinkParameterKey]).to(equal(url));
                                                                done();
                                                            }];
                [lock continueUserActivity:activity restorationHandler:restorationHandler];
            });
        });

    });
});

QuickSpecEnd
