//
//  A0AuthParametersSpec.m
//  Auth0Client
//
//  Created by Hernan Zalazar on 9/26/14.
//  Copyright 2014 Auth0. All rights reserved.
//

#import "Specta.h"
#import "A0AuthParameters.h"
#import <UIKit/UIKit.h>

SpecBegin(A0AuthParameters)

describe(@"A0AuthParameters", ^{

    __block A0AuthParameters *params;

    describe(@"initialization", ^{

        sharedExamplesFor(@"valid parameter with scope", ^(NSDictionary *data) {

            __block A0AuthParameters *authParams;

            beforeEach(^{
                authParams = data[@"params"];
            });

            it(@"should have scopes", ^{
                expect(authParams.scopes).to.equal(data[@"scopes"]);
            });

        });

        sharedExamplesFor(@"offline access parameter", ^(NSDictionary *data) {

            __block A0AuthParameters *authParams;

            beforeEach(^{
                authParams = data[@"params"];
            });

            itShouldBehaveLike(@"valid parameter with scope", data);

            it(@"should have offline scope", ^{
                expect(authParams.scopes).to.contain(A0ScopeOfflineAccess);
            });

            it(@"should have device name", ^{
                expect(authParams.device).to.equal([[UIDevice currentDevice] name]);
            });

        });

        itShouldBehaveLike(@"offline access parameter", ^{
            return @{
                     @"params": [[A0AuthParameters alloc] init],
                     @"scopes": @[A0ScopeOpenId, A0ScopeOfflineAccess],
                     };
        });

        itShouldBehaveLike(@"offline access parameter", ^{
            return @{
                     @"params": [A0AuthParameters newDefaultParams],
                     @"scopes": @[A0ScopeOpenId, A0ScopeOfflineAccess],
                     };
        });

        itShouldBehaveLike(@"valid parameter with scope", ^{
            return @{
                     @"params": [[A0AuthParameters alloc] initWithScopes:@[A0ScopeProfile]],
                     @"scopes": @[A0ScopeProfile],
                     };
        });

        itShouldBehaveLike(@"valid parameter with scope", ^{
            return @{
                     @"params": [A0AuthParameters newWithScopes:@[A0ScopeProfile]],
                     @"scopes": @[A0ScopeProfile],
                     };
        });

        itShouldBehaveLike(@"valid parameter with scope", ^{
            return @{
                     @"params": [[A0AuthParameters alloc] initWithDictionary:@{
                                                                               A0APIScope: @[@"openid", @"offline_access", @"profile"],
                                                                               }],
                     @"scopes": @[A0ScopeOpenId, A0ScopeOfflineAccess, A0ScopeProfile],
                     };
        });

        itShouldBehaveLike(@"offline access parameter", ^{
            return @{
                     @"params": [A0AuthParameters newWithDictionary:@{
                                                                      A0APIScope: @[@"openid", @"offline_access", @"profile"],
                                                                      }],
                     @"scopes": @[A0ScopeOpenId, A0ScopeOfflineAccess, A0ScopeProfile],
                     };
        });

        context(@"extra parameters", ^{

            beforeEach(^{
                params = [[A0AuthParameters alloc] initWithDictionary:@{
                                                                        @"key": @"value"
                                                                        }];
            });

            it(@"should have extra values", ^{
                expect([params valueForKey:@"key"]).to.equal(@"value");
            });
        });

    });

    describe(@"add values", ^{

        beforeEach(^{
            params = [A0AuthParameters newDefaultParams];
        });

        it(@"should add value to extra parameters", ^{
            [params setValue:@"value" forKey:@"key"];
            expect([params valueForKey:@"key"]).to.equal(@"value");
        });

        it(@"should replace scope", ^{
            [params setValue:@"scope" forKey:@"scope"];
            expect(params.scopes).to.equal(@[@"scope"]);
        });
    });
});

SpecEnd
