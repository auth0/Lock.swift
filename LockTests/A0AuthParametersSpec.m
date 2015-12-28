//  A0AuthParametersSpec.m
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

#import <Quick/Quick.h>
#import <Nimble/Nimble.h>
#import <UIKit/UIKit.h>
#import "A0AuthParameters.h"

QuickSpecBegin(A0AuthParametersSpec)

describe(@"A0AuthParameters", ^{

    __block A0AuthParameters *params;

    describe(@"initialization", ^{

        sharedExamples(@"valid parameter with scope", ^(QCKDSLSharedExampleContext context) {

            __block A0AuthParameters *authParams;

            beforeEach(^{
                authParams = context()[@"params"];
            });

            it(@"should have scopes", ^{
                expect(authParams.scopes).to(equal(context()[@"scopes"]));
            });

        });

        sharedExamples(@"offline access parameter", ^(QCKDSLSharedExampleContext context) {

            __block A0AuthParameters *authParams;

            beforeEach(^{
                authParams = context()[@"params"];
            });

            itBehavesLike(@"valid parameter with scope", context);

            it(@"should have offline scope", ^{
                expect(authParams.scopes).to(contain(A0ScopeOfflineAccess));
            });

            it(@"should have device name", ^{
                expect(authParams.device).to(equal([[UIDevice currentDevice] name]));
            });

        });

        itBehavesLike(@"offline access parameter", ^{
            return @{
                     @"params": [[A0AuthParameters alloc] init],
                     @"scopes": @[A0ScopeOpenId, A0ScopeOfflineAccess],
                     };
        });

        itBehavesLike(@"offline access parameter", ^{
            return @{
                     @"params": [[A0AuthParameters alloc] initWithDictionary:@{}],
                     @"scopes": @[A0ScopeOpenId, A0ScopeOfflineAccess],
                     };
        });

        itBehavesLike(@"offline access parameter", ^{
            return @{
                     @"params": [A0AuthParameters newDefaultParams],
                     @"scopes": @[A0ScopeOpenId, A0ScopeOfflineAccess],
                     };
        });

        itBehavesLike(@"valid parameter with scope", ^{
            return @{
                     @"params": [[A0AuthParameters alloc] initWithScopes:@[A0ScopeProfile]],
                     @"scopes": @[A0ScopeProfile],
                     };
        });

        itBehavesLike(@"valid parameter with scope", ^{
            return @{
                     @"params": [A0AuthParameters newWithScopes:@[A0ScopeProfile]],
                     @"scopes": @[A0ScopeProfile],
                     };
        });

        itBehavesLike(@"valid parameter with scope", ^{
            return @{
                     @"params": [[A0AuthParameters alloc] initWithDictionary:@{
                                                                               A0ParameterScope: @[@"openid profile", @"offline_access"],
                                                                               }],
                     @"scopes": @[A0ScopeProfile, A0ScopeOfflineAccess],
                     };
        });

        itBehavesLike(@"offline access parameter", ^{
            return @{
                     @"params": [A0AuthParameters newWithDictionary:@{
                                                                      A0ParameterScope: @[@"offline_access", @"openid profile"],
                                                                      }],
                     @"scopes": @[A0ScopeOfflineAccess, A0ScopeProfile],
                     };
        });

        it(@"should remove device parameter when `offline_access` is not present in scope", ^{
            params = [A0AuthParameters newDefaultParams];
            params.scopes = @[A0ScopeOpenId];
            expect(params.device).to(beNil());
        });

        context(@"extra parameters", ^{

            beforeEach(^{
                params = [[A0AuthParameters alloc] initWithDictionary:@{
                                                                        @"key": @"value"
                                                                        }];
            });

            it(@"should have extra values", ^{
                expect(params[@"key"]).to(equal(@"value"));
            });
        });

        context(@"Connection scopes", ^{

            beforeEach(^{
                params = [[A0AuthParameters alloc] init];
                params.connectionScopes = @{
                                            @"facebook": @[@"email", @"friends"],
                                            };
            });

            it(@"should have extra values", ^{
                expect(params[A0ParameterConnectionScopes]).to(equal(@{
                                                                       @"facebook": @[@"email", @"friends"],
                                                                       }));
            });

        });
    });

    describe(@"add values", ^{

        beforeEach(^{
            params = [A0AuthParameters newDefaultParams];
        });

        it(@"should add value to extra parameters", ^{
            params[@"key"] = @"value";
            expect(params[@"key"]).to(equal(@"value"));
        });

        it(@"should not allow replace scope", ^{
            expectAction(^{
                params[@"scope"] = @"scope";
            }).to(raiseException());
        });

        it(@"should not allow replace connection scopes", ^{
            expectAction(^{
                params[@"connection_scopes"] = @"scope";
            }).to(raiseException());
        });

    });

    describe(@"NSCopying", ^{

        beforeEach(^{
            params = [A0AuthParameters newDefaultParams];
        });

        it(@"should make a copy", ^{
            expect(params.copy).toNot(equal(params));
        });

        it(@"should be a deep copy", ^{
            A0AuthParameters *copy = params.copy;
            params[@"key"] = @"new value";
            expect(copy[@"key"]).to(beNil());
        });

    });

    describe(@"as API dictionary", ^{

        __block NSDictionary *dict;

        beforeEach(^{
            params = [A0AuthParameters newDefaultParams];
            params.scopes = @[A0ScopeProfile, A0ScopeOfflineAccess];
            params.connectionScopes =@{
                                       @"facebook": @[@"email", @"friends"],
                                       @"google": @[],
                                       @"linkedin": @[@"public_profile"],
                                       };
            params[A0ParameterConnection] = @"facebook";
            params.state = @"TEST";
            params.device = @"Specta Test";
            params[@"foo"] = @"bar";
            dict = params.asAPIPayload;
        });

        it(@"should coalesce scopes in a NSString", ^{
            expect(dict[A0ParameterScope]).to(equal(@"openid profile offline_access"));
        });

        it(@"should include specified scopes for connection", ^{
            NSDictionary *payload = [params asAPIPayload];
            expect(payload.allKeys).to(contain(@"connection_scope"));
            expect(payload[@"connection_scope"]).to(equal(@"email,friends"));
        });

        it(@"should have state", ^{
            expect(dict[A0ParameterState]).to(equal(@"TEST"));
        });

        it(@"should have device", ^{
            expect(dict[A0ParameterDevice]).to(equal(@"Specta Test"));
        });

        it(@"should have custom parameter", ^{
            expect(dict[@"foo"]).to(equal(@"bar"));
        });

    });
});

QuickSpecEnd
