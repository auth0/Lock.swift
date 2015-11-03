// A0LockConfigurationSpec.m
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

#import "A0LockConfiguration.h"
#import "A0Application.h"
#import "A0Connection.h"
#import "A0Strategy.h"

#define kLockConfig @"LockConfig"
#define kSocialConnectionNames @"SocialConnectionNames"
#define kEnterpriseConnectionNames @"EnterpriseConnectionNames"
#define kDefaultADConnectionName @"DefaultADConnectionName"
#define kDefaultDatabaseConnectionName @"DefaultDBConnectionName"
#define kFilteredEnterpriseAndSocialExample @"filtered social & enterprise connections"
#define kActiveDirectoryExample @"active directory strategy and default connection"
#define kDatabaseConnectionExample @"valid default active connection"

#define kCustomDatabaseConnectionName @"CustomDatabase"
#define kAuth0DatabaseConnectionName @"Username-Password-Authentication"

SpecBegin(A0LockConfiguration)

describe(@"A0LockConfiguration", ^{

    __block A0Application *application;

    describe(@"initialisation", ^{

        before(^{
            application = mock(A0Application.class);
        });

        it(@"should build with application and list of connection names", ^{
            expect([[A0LockConfiguration alloc] initWithApplication:application filter:@[@"facebook"]]).toNot.beNil();
        });

        it(@"should fail when application is nil", ^{
            expect(^{
                expect([[A0LockConfiguration alloc] initWithApplication:nil filter:@[@"facebook"]]).to.beNil();
            }).to.raiseWithReason(NSInternalInconsistencyException, @"Must supply a non-nil application");
        });

        it(@"should accept nil filter list", ^{
            expect([[A0LockConfiguration alloc] initWithApplication:application filter:nil]).toNot.beNil();
        });

    });


    describe(@"filter connections", ^{

        before(^{
            NSData *jsonData = [NSData dataWithContentsOfFile:[[NSBundle bundleForClass:self.class] pathForResource:@"AppInfo" ofType:@"json"]];
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
            application = [[A0Application alloc] initWithJSONDictionary:json];
        });

        sharedExamplesFor(kFilteredEnterpriseAndSocialExample, ^(NSDictionary *data) {

            __block A0LockConfiguration *config;

            before(^{
                config = data[kLockConfig];
            });

            it(@"should have social connections", ^{
                __block NSMutableArray *names = [@[] mutableCopy];
                [config.socialStrategies enumerateObjectsUsingBlock:^(A0Strategy *stragegy, NSUInteger idx, BOOL *stop) {
                    [names addObject:stragegy.name];
                }];
                NSArray *expected = [data[kSocialConnectionNames] mutableCopy];
                expect(names).to.beSupersetOf(expected);
                expect(names).to.haveCountOf(expected.count);
            });

            it(@"should have enterprise connections", ^{
                __block NSMutableArray *names = [@[] mutableCopy];
                [config.enterpriseStrategies enumerateObjectsUsingBlock:^(A0Strategy *stragegy, NSUInteger idx, BOOL *stop) {
                    [stragegy.connections enumerateObjectsUsingBlock:^(A0Connection *connection, NSUInteger idx, BOOL *stop) {
                        [names addObject:connection.name];
                    }];
                }];
                NSArray *expected = [data[kEnterpriseConnectionNames] mutableCopy];
                expect(names).to.beSupersetOf(expected);
                expect(names).to.haveCountOf(expected.count);
            });
        });

        itBehavesLike(kFilteredEnterpriseAndSocialExample, ^id{
            return @{
                     kLockConfig: [[A0LockConfiguration alloc] initWithApplication:application filter:@[]],
                     kSocialConnectionNames: @[@"google-oauth2", @"facebook", @"twitter", @"instagram"],
                     kEnterpriseConnectionNames: @[@"auth0.com", @"MyAD", @"mySeconAD"],
                     };
        });

        itBehavesLike(kFilteredEnterpriseAndSocialExample, ^id{
            return @{
                     kLockConfig: [[A0LockConfiguration alloc] initWithApplication:application filter:@[@"facebook", @"twitter", @"instagram"]],
                     kSocialConnectionNames: @[@"facebook", @"twitter", @"instagram"],
                     kEnterpriseConnectionNames: @[],
                     };
        });

        itBehavesLike(kFilteredEnterpriseAndSocialExample, ^id{
            return @{
                     kLockConfig: [[A0LockConfiguration alloc] initWithApplication:application filter:@[@"auth0.com", @"mySeconAD"]],
                     kSocialConnectionNames: @[],
                     kEnterpriseConnectionNames: @[@"auth0.com", @"mySeconAD"],
                     };
        });

        sharedExamplesFor(kActiveDirectoryExample, ^(NSDictionary *data) {

            __block A0LockConfiguration *config;

            before(^{
                config = data[kLockConfig];
            });

            itBehavesLike(kFilteredEnterpriseAndSocialExample, data);

            it(@"should return an active directory strategy", ^{
                expect(config.activeDirectoryStrategy).toNot.beNil();
                expect(config.activeDirectoryStrategy.name).to.equal(A0StrategyNameActiveDirectory);
            });

            it(@"should return the correct default AD connection", ^{
                expect(config.defaultActiveDirectoryConnection.name).to.equal(data[kDefaultADConnectionName]);
            });
        });

        itBehavesLike(kActiveDirectoryExample, ^id{
            return @{
                     kLockConfig: [[A0LockConfiguration alloc] initWithApplication:application filter:@[]],
                     kSocialConnectionNames: @[@"google-oauth2", @"facebook", @"twitter", @"instagram"],
                     kEnterpriseConnectionNames: @[@"auth0.com", @"MyAD", @"mySeconAD"],
                     kDefaultADConnectionName: @"MyAD",
                     };
        });

        itBehavesLike(kActiveDirectoryExample, ^id{
            return @{
                     kLockConfig: [[A0LockConfiguration alloc] initWithApplication:application filter:@[@"auth0.com", @"MyAD", @"mySeconAD"]],
                     kSocialConnectionNames: @[],
                     kEnterpriseConnectionNames: @[@"auth0.com", @"MyAD", @"mySeconAD"],
                     kDefaultADConnectionName: @"MyAD",
                     };
        });

        itBehavesLike(kActiveDirectoryExample, ^id{
            return @{
                     kLockConfig: [[A0LockConfiguration alloc] initWithApplication:application filter:@[@"auth0.com", @"mySeconAD"]],
                     kSocialConnectionNames: @[],
                     kEnterpriseConnectionNames: @[@"auth0.com", @"mySeconAD"],
                     kDefaultADConnectionName: @"mySeconAD",
                     };
        });


        it(@"should return nil default DB when no DB connection is present", ^{
            A0LockConfiguration *config = [[A0LockConfiguration alloc] initWithApplication:application filter:@[@"auth0.com", @"mySeconAD"]];
            expect(config.defaultDatabaseConnection).to.beNil();
        });

        sharedExamplesFor(kDatabaseConnectionExample, ^(NSDictionary *data) {

            __block A0LockConfiguration *config;

            before(^{
                config = data[kLockConfig];
            });

            it(@"should return a default DB connection", ^{
                expect(config.defaultDatabaseConnection.name).to.equal(data[kDefaultDatabaseConnectionName]);
            });
        });

        itShouldBehaveLike(kDatabaseConnectionExample, ^id{
            return @{
                     kLockConfig: [[A0LockConfiguration alloc] initWithApplication:application filter:@[]],
                     kDefaultDatabaseConnectionName: kAuth0DatabaseConnectionName,
                     };
        });

        itShouldBehaveLike(kDatabaseConnectionExample, ^id{
            return @{
                     kLockConfig: [[A0LockConfiguration alloc] initWithApplication:application filter:@[kAuth0DatabaseConnectionName, @"MyAD", @"mySeconAD"]],
                     kDefaultDatabaseConnectionName: kAuth0DatabaseConnectionName,
                     };
        });

        itShouldBehaveLike(kDatabaseConnectionExample, ^id{
            return @{
                     kLockConfig: [[A0LockConfiguration alloc] initWithApplication:application filter:@[kCustomDatabaseConnectionName, @"MyAD", @"mySeconAD"]],
                     kDefaultDatabaseConnectionName: kCustomDatabaseConnectionName,
                     };
        });

        itShouldBehaveLike(kDatabaseConnectionExample, ^id{
            A0LockConfiguration *configuration = [[A0LockConfiguration alloc] initWithApplication:application filter:@[]];
            configuration.defaultDatabaseConnectionName = kCustomDatabaseConnectionName;
            return @{
                     kLockConfig: configuration,
                     kDefaultDatabaseConnectionName: kCustomDatabaseConnectionName,
                     };
        });

        itShouldBehaveLike(kDatabaseConnectionExample, ^id{
            A0LockConfiguration *configuration = [[A0LockConfiguration alloc] initWithApplication:application
                                                                                           filter:@[
                                                                                                    kAuth0DatabaseConnectionName,
                                                                                                    kCustomDatabaseConnectionName
                                                                                                    ]];
            configuration.defaultDatabaseConnectionName = kCustomDatabaseConnectionName;
            return @{
                     kLockConfig: configuration,
                     kDefaultDatabaseConnectionName: kCustomDatabaseConnectionName,
                     };
        });

    });

    describe(@"disable Sign Up & Reset Password", ^{

        __block A0LockConfiguration *configuration;

        before(^{
            NSData *jsonData = [NSData dataWithContentsOfFile:[[NSBundle bundleForClass:self.class] pathForResource:@"AppInfo" ofType:@"json"]];
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
            application = [[A0Application alloc] initWithJSONDictionary:json];
            configuration = [[A0LockConfiguration alloc] initWithApplication:application filter:@[]];
        });

        context(@"when enabled in connection", ^{

            beforeEach(^{
                configuration.defaultDatabaseConnectionName = @"Username-PasswordAuthentication";
            });

            it(@"should disable Sign Up", ^{
                expect([configuration shouldDisableSignUp:YES]).to.beTruthy();
            });

            it(@"should not disable Sign Up", ^{
                expect([configuration shouldDisableSignUp:NO]).to.beFalsy();
            });

            it(@"should disable Reset Password", ^{
                expect([configuration shouldDisableResetPassword:YES]).to.beTruthy();
            });

            it(@"should not disable Reset Password", ^{
                expect([configuration shouldDisableResetPassword:NO]).to.beFalsy();
            });

        });

        context(@"when disabled in connection", ^{

            beforeEach(^{
                configuration.defaultDatabaseConnectionName = @"LoginOnly";
            });

            it(@"should disable Sign Up", ^{
                expect([configuration shouldDisableSignUp:YES]).to.beTruthy();
            });

            it(@"should not disable Sign Up", ^{
                expect([configuration shouldDisableSignUp:NO]).to.beTruthy();
            });

            it(@"should disable Reset Password", ^{
                expect([configuration shouldDisableResetPassword:YES]).to.beTruthy();
            });

            it(@"should not disable Reset Password", ^{
                expect([configuration shouldDisableResetPassword:NO]).to.beTruthy();
            });
            
        });

    });
});

SpecEnd
