// A0APIClientSpec.m
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

#import "Specta.h"
#import "A0APIClient.h"

#import <OHHTTPStubs/OHHTTPStubs.h>
#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

#import "A0APIRouter.h"
#import "A0Application.h"
#import "A0Connection.h"
#import "Tests-Swift.h"
#import "A0Token.h"
#import "A0Strategy.h"
#import "A0AuthParameters.h"
#import "A0AnnotatedRequestSerializer.h"
#import "A0IdentityProviderCredentials.h"

#define AS_NSURL(urlString) [NSURL URLWithString:urlString]

#define kValidClientExample @"valid API client"
#define kAPIClientArgument @"APIClient"
#define kClientIdArgument @"ClientId"
#define kTenantArgument @"Tenant"

static NSString * const CLIENT_ID = @"rU5HShUyQlEqbVWjZSTCBBLMUFAbJAS3";
static NSString * const TENANT = @"samples";
static NSString * const ENDPOINT = @"https://samples.auth0.com";
static NSString * const DB_CONNECTION = @"DatabaseConnection";
static NSString * const EMAIL = @"mail@mail.com";
static NSString * const PASSWORD = @"password";
static NSString * const JWT = @"HEADER.PAYLOAD.SIGNATURE";
static NSString * const DEVICE = @"MyiPhone";
static NSString * const SOCIAL_TOKEN = @"SOCIAL TOKEN";
static NSString * const REFRESH_TOKEN = @"RefreshToken";

@interface A0APIClient (TestingOnly)

@property (readonly, nonatomic) AFHTTPRequestOperationManager *manager;

- (void)configureForApplication:(A0Application *)application;

@end

SpecBegin(A0APIClient)

describe(@"A0APIClient", ^{

    describe(@"initialise", ^{

        __block id<A0APIRouter> router;

        beforeEach(^{
            router = mockProtocol(@protocol(A0APIRouter));
            [given([router clientId]) willReturn:CLIENT_ID];
            [given([router tenant]) willReturn:TENANT];
            [given([router endpointURL]) willReturn:AS_NSURL(ENDPOINT)];
        });

        sharedExamplesFor(kValidClientExample, ^(NSDictionary *data) {

            __block A0APIClient *client;

            beforeEach(^{
                client = data[kAPIClientArgument];
            });

            specify(@"valid clientId", ^{
                expect(client.clientId).to.equal(data[kClientIdArgument]);
            });

            specify(@"valid tenant", ^{
                expect(client.tenant).to.equal(data[kTenantArgument]);
            });

            specify(@"valid endpoint URL", ^{
                expect(client.baseURL).to.equal(AS_NSURL(ENDPOINT));
            });
        });

        itShouldBehaveLike(kValidClientExample, @{
                                                  kAPIClientArgument: [[A0APIClient alloc] initWithClientId:CLIENT_ID andTenant:TENANT],
                                                  kClientIdArgument: CLIENT_ID,
                                                  kTenantArgument: TENANT,
                                                  });

        itBehavesLike(kValidClientExample, ^{
            return @{
                     kAPIClientArgument: [[A0APIClient alloc] initWithAPIRouter:router],
                     kClientIdArgument: CLIENT_ID,
                     kTenantArgument: TENANT,
                     };
        });
    });

    A0HttpKeeper *keeper = [[A0HttpKeeper alloc] init];

    __block A0APIClient *client;
    __block A0Application *application;
    __block A0HTTPStubFilter *filter;

    before(^{
        client = [[A0APIClient alloc] initWithClientId:CLIENT_ID andTenant:TENANT];
        [OHHTTPStubs onStubActivation:^(NSURLRequest *request, id<OHHTTPStubsDescriptor> stub) {
            NSLog(@"%@ stubbed by %@", request.URL, stub.name);
        }];
        application = mock(A0Application.class);
        filter = [[A0HTTPStubFilter alloc] initWithApplication:application];
    });

    after(^{
        [OHHTTPStubs removeAllStubs];
    });

    describe(@"Auth0 application info", ^{

        it(@"should fetch app info", ^{
            [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return [request.URL.absoluteString isEqualToString:[client.router configurationURL].absoluteString];
            } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                return [OHHTTPStubsResponse responseNamed:@"GET-Application-Info" inBundle:nil];
            }].name = @"Auth0 App CDN";
            waitUntil(^(DoneCallback done) {
                [client fetchAppInfoWithSuccess:^(A0Application *application) {
                    expect(application).toNot.beNil();
                    expect(application.tenant).to.equal(TENANT);
                    expect(application.identifier).to.equal(CLIENT_ID);
                    expect(application.databaseStrategy).to.beNil();
                    expect(application.enterpriseStrategies).to.haveCountOf(0);
                    expect(application.socialStrategies).to.haveCountOf(4);
                    done();
                } failure:^(NSError *error){
                    expect(error).to.beNil();
                    done();
                }];
            });
        });

        it(@"should fail when app info is not found", ^{
            [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return [request.URL.absoluteString isEqualToString:[client.router configurationURL].absoluteString];
            } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                NSDictionary *json = @{@"error" : @"not_found"};
                return [OHHTTPStubsResponse responseWithJSONObject:json statusCode:404 headers:nil];
            }].name = @"No Auth0 App in CDN";
            waitUntil(^(DoneCallback done) {
                [client fetchAppInfoWithSuccess:^(A0Application *application) {
                    expect(application).to.beNil();
                    done();
                } failure:^(NSError *error){
                    expect(error).toNot.beNil();
                    done();
                }];
            });
        });

        it(@"should fail when is not jsonp", ^{
            [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return [request.URL.absoluteString isEqualToString:[client.router configurationURL].absoluteString];
            } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                NSData *data = [@"INVALID" dataUsingEncoding:NSUTF8StringEncoding];
                return [OHHTTPStubsResponse responseWithData:data statusCode:200 headers:nil];
            }].name = @"No Auth0 App in CDN";
            waitUntil(^(DoneCallback done) {
                [client fetchAppInfoWithSuccess:^(A0Application *application) {
                    expect(application).to.beNil();
                    done();
                } failure:^(NSError *error){
                    expect(error).toNot.beNil();
                    done();
                }];
            });
        });

    });

    describe(@"Database connection", ^{

        __block A0Connection *connection;

        before(^{
            client.manager.requestSerializer = [A0AnnotatedRequestSerializer serializer];
            [keeper failForAllRequests];
        });

        it(@"should fail login with user/pwd when no connection is specified", ^{
            waitUntil(^(DoneCallback done) {
                [client loginWithUsername:@"username" password:@"password" parameters:nil success:^(A0UserProfile *profile, A0Token *tokenInfo) {
                    expect(tokenInfo).to.beNil();
                    done();
                } failure:^(NSError *error) {
                    expect(error).notTo.beNil();
                    expect(error.localizedFailureReason).to.equal(@"Can't find connection name to use for authentication");
                    done();
                }];
            });
        });

        it(@"should fail login with jwt when no connection is specified", ^{
            waitUntil(^(DoneCallback done) {
                [client loginWithIdToken:@"token" deviceName:@"device" parameters:nil success:^(A0UserProfile *profile, A0Token *tokenInfo) {
                    expect(tokenInfo).to.beNil();
                    done();
                } failure:^(NSError *error) {
                    expect(error).notTo.beNil();
                    expect(error.localizedFailureReason).to.equal(@"Can't find connection name to use for authentication");
                    done();
                }];
            });
        });

        it(@"should fail signup when no connection is specified", ^{
            waitUntil(^(DoneCallback done) {
                [client signUpWithUsername:@"username" password:@"password" loginOnSuccess:YES parameters:nil success:^(A0UserProfile *profile, A0Token *tokenInfo) {
                    expect(tokenInfo).to.beNil();
                    done();
                } failure:^(NSError *error) {
                    expect(error).toNot.beNil();
                    expect(error.localizedFailureReason).to.equal(@"Can't find connection name to use for authentication");
                    done();
                }];
            });
        });

        it(@"should fail change password when no connection is specified", ^{
            waitUntil(^(DoneCallback done) {
                [client changePassword:@"password" forUsername:@"username" parameters:nil success:^() {
                    expect(false).to.beTruthy();
                    done();
                } failure:^(NSError *error) {
                    expect(error).toNot.beNil();
                    expect(error.localizedFailureReason).to.equal(@"Can't find connection name to use for authentication");
                    done();
                }];
            });
        });

        context(@"with application info", ^{

            before(^{
                connection = mock(A0Connection.class);
                A0Strategy *strategy = mock(A0Strategy.class);
                [given(application.identifier) willReturn:CLIENT_ID];
                [given(application.databaseStrategy) willReturn:strategy];
                [given(strategy.connections) willReturn:@[connection]];
                [given(connection.name) willReturn:DB_CONNECTION];
                [client configureForApplication:application];
            });

            describe(@"login email/password", ^{

                it(@"should login with email/password", ^{
                    [keeper returnSuccessfulLoginWithFilter:[filter filterForResourceOwnerWithUsername:EMAIL password:PASSWORD]];
                    [keeper returnProfileWithFilter:[filter filterForTokenInfoWithJWT:JWT]];
                    [client configureForApplication:application];
                    waitUntil(^(DoneCallback done) {
                        [client loginWithUsername:EMAIL password:PASSWORD parameters:nil success:^(A0UserProfile *profile, A0Token *tokenInfo) {
                            expect(tokenInfo).toNot.beNil();
                            expect(tokenInfo.idToken).toNot.beNil();
                            done();
                        } failure:^(NSError *error) {
                            expect(error.localizedDescription).to.beNil();
                            done();
                        }];
                    });
                });

                it(@"should login with email/password with parameters", ^{
                    [keeper returnSuccessfulLoginWithFilter:[filter filterForResourceOwnerWithUsername:EMAIL password:PASSWORD]];
                    [keeper returnProfileWithFilter:[filter filterForTokenInfoWithJWT:JWT]];
                    [client configureForApplication:application];
                    waitUntil(^(DoneCallback done) {
                        A0AuthParameters *parameters = [A0AuthParameters newWithDictionary:@{@"param": @"value"}];
                        [client loginWithUsername:EMAIL password:PASSWORD parameters:parameters success:^(A0UserProfile *profile, A0Token *tokenInfo) {
                            expect(tokenInfo).toNot.beNil();
                            expect(tokenInfo.idToken).toNot.beNil();
                            done();
                        } failure:^(NSError *error) {
                            expect(error.localizedDescription).to.beNil();
                            done();
                        }];
                    });
                });

                it(@"should login with email/password with overriding default parameters", ^{
                    [keeper returnSuccessfulLoginWithFilter:[filter filterForResourceOwnerWithParameters:@{@"username": EMAIL, @"scope": @"openid"}]];
                    [keeper returnProfileWithFilter:[filter filterForTokenInfoWithJWT:JWT]];
                    [client configureForApplication:application];
                    waitUntil(^(DoneCallback done) {
                        A0AuthParameters *parameters = [A0AuthParameters newWithScopes:@[@"openid"]];
                        [client loginWithUsername:EMAIL password:PASSWORD parameters:parameters success:^(A0UserProfile *profile, A0Token *tokenInfo) {
                            expect(tokenInfo).notTo.beNil();
                            expect(tokenInfo.idToken).toNot.beNil();
                            done();
                        } failure:^(NSError *error) {
                            expect(error.localizedDescription).to.beNil();
                            done();
                        }];
                    });
                });
            });

            describe(@"signup user/pwd", ^{

                it(@"should create and login user", ^{
                    [keeper returnSignUpWithFilter:[filter filterForSignUpWithParameters:@{
                                                                                           @"email": EMAIL,
                                                                                           @"password": PASSWORD,
                                                                                           @"client_id": CLIENT_ID,
                                                                                           @"connection": DB_CONNECTION,
                                                                                           @"tenant": TENANT
                                                                                           }]];
                    [keeper returnSuccessfulLoginWithFilter:[filter filterForResourceOwnerWithUsername:EMAIL password:PASSWORD]];
                    [keeper returnProfileWithFilter:[filter filterForTokenInfoWithJWT:JWT]];

                    waitUntil(^(DoneCallback done) {
                        [client signUpWithUsername:EMAIL password:PASSWORD loginOnSuccess:YES parameters:nil success:^(A0UserProfile *profile, A0Token *tokenInfo) {
                            expect(tokenInfo).notTo.beNil();
                            done();
                        } failure:^(NSError *error) {
                            expect(error).to.beNil();
                            done();
                        }];
                    });
                });

                it(@"should only create the user", ^{
                    [keeper returnSignUpWithFilter:[filter filterForSignUpWithParameters:@{
                                                                                           @"email": EMAIL,
                                                                                           @"password": PASSWORD,
                                                                                           @"client_id": CLIENT_ID,
                                                                                           @"connection": DB_CONNECTION,
                                                                                           }]];
                    waitUntil(^(DoneCallback done) {
                        [client signUpWithUsername:EMAIL password:PASSWORD loginOnSuccess:NO parameters:nil success:^(A0UserProfile *profile, A0Token *tokenInfo) {
                            expect(profile).to.beNil();
                            expect(tokenInfo).to.beNil();
                            done();
                        } failure:^(NSError *error) {
                            expect(error).to.beNil();
                            done();
                        }];
                    });
                });

                it(@"should only create the user with parameters", ^{
                    [keeper returnSignUpWithFilter:[filter filterForSignUpWithParameters:@{
                                                                                           @"email": EMAIL,
                                                                                           @"password": PASSWORD,
                                                                                           @"client_id": CLIENT_ID,
                                                                                           @"connection": DB_CONNECTION,
                                                                                           @"parameter": @"value"
                                                                                           }]];
                    waitUntil(^(DoneCallback done) {
                        A0AuthParameters *parameters = [A0AuthParameters newWithDictionary:@{@"parameter": @"value"}];
                        [client signUpWithUsername:EMAIL password:PASSWORD loginOnSuccess:NO parameters:parameters success:^(A0UserProfile *profile, A0Token *tokenInfo) {
                            expect(profile).to.beNil();
                            expect(tokenInfo).to.beNil();
                            done();
                        } failure:^(NSError *error) {
                            expect(error).to.beNil();
                            done();
                        }];
                    });
                });

                it(@"should call failure callback with error", ^{
                    [keeper failWithFilter:[filter filterForSignUpWithParameters:@{@"email": EMAIL}] message:@"signup_failed"];
                    waitUntil(^(DoneCallback done) {
                        [client signUpWithUsername:EMAIL password:PASSWORD loginOnSuccess:NO parameters:nil success:^(A0UserProfile *profile, A0Token *tokenInfo) {
                            expect(true).to.beFalsy();
                            done();
                        } failure:^(NSError *error) {
                            expect(error).toNot.beNil();
                            expect(error.localizedDescription).to.equal(@"signup_failed");
                            done();
                        }];
                    });
                });
            });

            describe(@"change password", ^{

                it(@"should change password", ^{
                    [keeper returnChangePasswordWithFilter:[filter filterForChangePasswordWithParameters:@{@"email": EMAIL, @"password": PASSWORD, @"connection": DB_CONNECTION}]];
                    waitUntil(^(DoneCallback done) {
                        [client changePassword:PASSWORD forUsername:EMAIL parameters:nil success:^{
                            done();
                        } failure:^(NSError *error) {
                            expect(error).to.beNil();
                            done();
                        }];
                    });
                });

                it(@"should call failure callback with error", ^{
                    [keeper failWithFilter:[filter filterForChangePasswordWithParameters:@{@"email": EMAIL, @"password": PASSWORD, @"connection": DB_CONNECTION}] message:@"change_password_failed"];
                    waitUntil(^(DoneCallback done) {
                        [client changePassword:PASSWORD forUsername:EMAIL parameters:nil success:^{
                            expect(true).to.beFalsy();
                            done();
                        } failure:^(NSError *error) {
                            expect(error).toNot.beNil();
                            expect(error.localizedDescription).to.equal(@"change_password_failed");
                            done();
                        }];
                    });
                });

            });

            describe(@"login with JWT", ^{

                it(@"should login with valid JWT", ^{
                    NSString *idToken = @"id_token";
                    [keeper returnSuccessfulLoginWithFilter:[filter filterForResourceOwnerWithParameters:@{
                                                                                                           @"id_token": idToken,
                                                                                                           @"device": DEVICE,
                                                                                                           @"grant_type": @"urn:ietf:params:oauth:grant-type:jwt-bearer",
                                                                                                           @"client_id" :CLIENT_ID,
                                                                                                           }]];
                    [keeper returnProfileWithFilter:[filter filterForTokenInfoWithJWT:JWT]];
                    waitUntil(^(DoneCallback done) {
                        [client loginWithIdToken:idToken deviceName:DEVICE parameters:nil success:^(A0UserProfile *profile, A0Token *tokenInfo) {
                            expect(tokenInfo).toNot.beNil();
                            done();
                        } failure:^(NSError *error) {
                            expect(error).to.beNil();
                            done();
                        }];
                    });
                });

                it(@"should call failure callback with error", ^{
                    NSString *idToken = @"id_token";
                    [keeper failWithFilter:[filter filterForResourceOwnerWithParameters:@{
                                                                                          @"id_token": idToken,
                                                                                          @"device": DEVICE,
                                                                                          @"grant_type": @"urn:ietf:params:oauth:grant-type:jwt-bearer",
                                                                                          @"client_id" :CLIENT_ID,
                                                                                          }]
                                   message:@"jwt_login_failed"];
                    waitUntil(^(DoneCallback done) {
                        [client loginWithIdToken:idToken deviceName:DEVICE parameters:nil success:^(A0UserProfile *profile, A0Token *tokenInfo) {
                            expect(tokenInfo).to.beNil();
                            done();
                        } failure:^(NSError *error) {
                            expect(error).notTo.beNil();
                            expect(error.localizedDescription).to.equal(@"jwt_login_failed");
                            done();
                        }];
                    });
                });
            });

            describe(@"login with SMS", ^{

                NSString *phone = @"4444444444";
                NSString *code = @"1234";

                it(@"should fail change password when no sms connection is enabled", ^{
                    waitUntil(^(DoneCallback done) {
                        [client loginWithPhoneNumber:@"444444444" passcode:@"1234" parameters:nil success:^(A0UserProfile *profile, A0Token *tokenInfo) {
                            expect(false).to.beTruthy();
                            done();
                        } failure:^(NSError *error) {
                            expect(error).toNot.beNil();
                            expect(error.localizedFailureReason).to.equal(@"Can't find connection name to use for authentication");
                            done();
                        }];
                    });
                });

                context(@"with sms conneciton enabled", ^{
                    __block A0Strategy *smsStrategy;
                    __block A0Connection * smsConnection;

                    before(^{
                        smsStrategy = mock(A0Strategy.class);
                        smsConnection = mock(A0Connection.class);
                        [given([application strategyByName:A0StrategyNameSMS]) willReturn:smsStrategy];
                        [given([smsStrategy connections]) willReturn:@[smsConnection]];
                        [given(smsConnection.name) willReturn:@"sms"];
                    });

                    it(@"should login with valid SMS and code", ^{
                        [keeper returnSuccessfulLoginWithFilter:[filter filterForResourceOwnerWithParameters:@{
                                                                                                               @"username": phone,
                                                                                                               @"password": code,
                                                                                                               @"connection": @"sms",
                                                                                                               @"grant_type": @"password",
                                                                                                               @"client_id" :CLIENT_ID,
                                                                                                               }]];
                        [keeper returnProfileWithFilter:[filter filterForTokenInfoWithJWT:JWT]];
                        waitUntil(^(DoneCallback done) {
                            [client loginWithPhoneNumber:phone passcode:code parameters:nil success:^(A0UserProfile *profile, A0Token *tokenInfo) {
                                expect(tokenInfo).toNot.beNil();
                                done();
                            } failure:^(NSError *error) {
                                expect(error).to.beNil();
                                done();
                            }];
                        });
                    });

                    it(@"should call failure callback with error", ^{
                        [keeper failWithFilter:[filter filterForResourceOwnerWithParameters:@{
                                                                                              @"username": phone,
                                                                                              @"password": code,
                                                                                              @"connection": @"sms",
                                                                                              @"grant_type": @"password",
                                                                                              @"client_id" :CLIENT_ID,
                                                                                              }]
                                       message:@"sms_login_failed"];
                        waitUntil(^(DoneCallback done) {
                            [client loginWithPhoneNumber:phone passcode:code parameters:nil success:^(A0UserProfile *profile, A0Token *tokenInfo) {
                                expect(tokenInfo).to.beNil();
                                done();
                            } failure:^(NSError *error) {
                                expect(error).notTo.beNil();
                                expect(error.localizedDescription).to.equal(@"sms_login_failed");
                                done();
                            }];
                        });
                    });
                });
            });
        });
    });

    describe(@"social authentication", ^{

        __block A0IdentityProviderCredentials *credentials;

        before(^{
            [keeper failForAllRequests];
            client.manager.requestSerializer = [A0AnnotatedRequestSerializer serializer];
        });

        it(@"should login with social credentials", ^{
            [keeper returnSuccessfulLoginWithFilter:[filter filterForSocialAuthenticationWithParameters:@{
                                                                                                          @"access_token": SOCIAL_TOKEN,
                                                                                                          @"connection": @"facebook",
                                                                                                          @"scope": @"openid offline_access"
                                                                                                          }]];
            [keeper returnProfileWithFilter:[filter filterForTokenInfoWithJWT:JWT]];
            credentials = [[A0IdentityProviderCredentials alloc] initWithAccessToken:SOCIAL_TOKEN];
            waitUntil(^(DoneCallback done) {
                [client authenticateWithSocialConnectionName:A0StrategyNameFacebook credentials:credentials parameters:nil success:^(A0UserProfile *profile, A0Token *tokenInfo) {
                    expect(tokenInfo).notTo.beNil();
                    done();
                } failure:^(NSError *error) {
                    expect(error).to.beNil();
                    done();
                }];
            });
        });

        it(@"should login with access token in parameters", ^{
            credentials = [[A0IdentityProviderCredentials alloc] initWithAccessToken:SOCIAL_TOKEN];
            A0AuthParameters *parameters = [A0AuthParameters newDefaultParams];
            NSString *accessToken = @"AnotherToken";
            [parameters setAccessToken:accessToken];
            [keeper returnSuccessfulLoginWithFilter:[filter filterForSocialAuthenticationWithParameters:@{
                                                                                                          @"access_token": SOCIAL_TOKEN,
                                                                                                          @"connection": @"facebook",
                                                                                                          @"scope": @"openid offline_access",
                                                                                                          @"main_access_token": accessToken,
                                                                                                          }]];
            [keeper returnProfileWithFilter:[filter filterForTokenInfoWithJWT:JWT]];
            waitUntil(^(DoneCallback done) {
                [client authenticateWithSocialConnectionName:A0StrategyNameFacebook credentials:credentials parameters:parameters success:^(A0UserProfile *profile, A0Token *tokenInfo) {
                    expect(tokenInfo).notTo.beNil();
                    done();
                } failure:^(NSError *error) {
                    expect(error).to.beNil();
                    done();
                }];
            });
        });

        it(@"should login with extra information", ^{
            credentials = [[A0IdentityProviderCredentials alloc] initWithAccessToken:SOCIAL_TOKEN
                                                                           extraInfo:@{
                                                                                       A0StrategySocialTokenSecretParameter: @"SECRET",
                                                                                       A0StrategySocialUserIdParameter: @"USERID",
                                                                                       }];
            [keeper returnSuccessfulLoginWithFilter:[filter filterForSocialAuthenticationWithParameters:@{
                                                                                                          @"access_token": SOCIAL_TOKEN,
                                                                                                          @"connection": @"twitter",
                                                                                                          @"scope": @"openid offline_access",
                                                                                                          @"access_token_secret": @"SECRET",
                                                                                                          @"user_id": @"USERID",
                                                                                                          }]];
            [keeper returnProfileWithFilter:[filter filterForTokenInfoWithJWT:JWT]];
            waitUntil(^(DoneCallback done) {
                [client authenticateWithSocialConnectionName:A0StrategyNameTwitter credentials:credentials parameters:nil success:^(A0UserProfile *profile, A0Token *tokenInfo) {
                    expect(tokenInfo).notTo.beNil();
                    done();
                } failure:^(NSError *error) {
                    expect(error).to.beNil();
                    done();
                }];
            });
        });

        it(@"should call callback on failure with error", ^{
            credentials = [[A0IdentityProviderCredentials alloc] initWithAccessToken:SOCIAL_TOKEN];
            [keeper failWithFilter:[filter filterForSocialAuthenticationWithParameters:@{@"access_token": SOCIAL_TOKEN}] message:@"invalid_social_login"];
            waitUntil(^(DoneCallback done) {
                [client authenticateWithSocialConnectionName:A0StrategyNameYahoo credentials:credentials parameters:nil success:^(A0UserProfile *profile, A0Token *tokenInfo) {
                    expect(tokenInfo).to.beNil();
                    done();
                } failure:^(NSError *error) {
                    expect(error).notTo.beNil();
                    expect(error.localizedDescription).to.equal(@"invalid_social_login");
                    done();
                }];
            });
        });
    });

    describe(@"Delegation", ^{

        before(^{
            [keeper failForAllRequests];
            client.manager.requestSerializer = [A0AnnotatedRequestSerializer serializer];
        });

        it(@"should return a new jwt with another jwt", ^{
            [keeper returnDelegationInfoWithFilter:[filter filterForDelegationWithParameters:@{
                                                                                               @"id_token": JWT,
                                                                                               @"grant_type": @"urn:ietf:params:oauth:grant-type:jwt-bearer",
                                                                                               @"client_id": CLIENT_ID,
                                                                                               @"scope": @"openid offline_access",
                                                                                               }]];
            waitUntil(^(DoneCallback done) {
                [client fetchNewIdTokenWithIdToken:JWT parameters:nil success:^(A0Token *token) {
                    expect(token).notTo.beNil();
                    done();
                } failure:^(NSError *error) {
                    expect(error).to.beNil();
                    done();
                }];
            });
        });

        it(@"should return a new jwt with refresh token", ^{
            [keeper returnDelegationInfoWithFilter:[filter filterForDelegationWithParameters:@{
                                                                                               @"refresh_token": REFRESH_TOKEN,
                                                                                               @"grant_type": @"urn:ietf:params:oauth:grant-type:jwt-bearer",
                                                                                               @"client_id": CLIENT_ID,
                                                                                               @"scope": @"openid offline_access",
                                                                                               }]];

            waitUntil(^(DoneCallback done) {
                [client fetchNewIdTokenWithRefreshToken:REFRESH_TOKEN parameters:nil success:^(A0Token *token) {
                    expect(token).notTo.beNil();
                    done();
                } failure:^(NSError *error) {
                    expect(error).to.beNil();
                    done();
                }];
            });
        });

        it(@"should return a new jwt with parameters", ^{
            [keeper returnDelegationInfoWithFilter:[filter filterForDelegationWithParameters:@{
                                                                                               @"id_token": JWT,
                                                                                               @"grant_type": @"urn:ietf:params:oauth:grant-type:jwt-bearer",
                                                                                               @"client_id": CLIENT_ID,
                                                                                               @"scope": @"openid offline_access",
                                                                                               @"key": @"value",
                                                                                               }]];
            A0AuthParameters *parameters = [A0AuthParameters newWithDictionary:@{@"key": @"value"}];
            waitUntil(^(DoneCallback done) {
                [client fetchNewIdTokenWithIdToken:JWT parameters:parameters success:^(A0Token *token) {
                    expect(token).notTo.beNil();
                    done();
                } failure:^(NSError *error) {
                    expect(error).to.beNil();
                    done();
                }];
            });
        });

        it(@"should return a delegation info with parameters", ^{
            [keeper returnDelegationInfoWithFilter:[filter filterForDelegationWithParameters:@{
                                                                                               @"grant_type": @"urn:ietf:params:oauth:grant-type:jwt-bearer",
                                                                                               @"client_id": CLIENT_ID,
                                                                                               @"scope": @"openid offline_access",
                                                                                               @"key": @"value",
                                                                                               }]];
            A0AuthParameters *parameters = [A0AuthParameters newWithDictionary:@{@"key": @"value"}];
            waitUntil(^(DoneCallback done) {
                [client fetchDelegationTokenWithParameters:parameters success:^(NSDictionary *info) {
                    expect(info).notTo.beNil();
                    done();
                } failure:^(NSError *error) {
                    expect(error).to.beNil();
                    done();
                }];
            });
        });

        it(@"should call failure callback with error when using jwt", ^{
            NSString *errorMessage = @"invalid_delegation";
            [keeper failWithFilter:[filter filterForDelegationWithParameters:@{
                                                                               @"id_token": JWT,
                                                                               }]
                           message:errorMessage];
            waitUntil(^(DoneCallback done) {
                [client fetchNewIdTokenWithIdToken:JWT parameters:nil success:^(A0Token *token) {
                    expect(token).to.beNil();
                    done();
                } failure:^(NSError *error) {
                    expect(error).notTo.beNil();
                    expect(error.localizedDescription).to.equal(errorMessage);
                    done();
                }];
            });
        });

        it(@"should return a new jwt with refreshToken and parameters", ^{
            [keeper returnDelegationInfoWithFilter:[filter filterForDelegationWithParameters:@{
                                                                                               @"refresh_token": REFRESH_TOKEN,
                                                                                               @"grant_type": @"urn:ietf:params:oauth:grant-type:jwt-bearer",
                                                                                               @"client_id": CLIENT_ID,
                                                                                               @"scope": @"openid offline_access",
                                                                                               @"key": @"value",
                                                                                               }]];
            A0AuthParameters *parameters = [A0AuthParameters newWithDictionary:@{@"key": @"value"}];
            waitUntil(^(DoneCallback done) {
                [client fetchNewIdTokenWithRefreshToken:REFRESH_TOKEN parameters:parameters success:^(A0Token *token) {
                    expect(token).notTo.beNil();
                    done();
                } failure:^(NSError *error) {
                    expect(error).to.beNil();
                    done();
                }];
            });
        });

        it(@"should call failure callback with error when using refresh token", ^{
            NSString *errorMessage = @"invalid_delegation";
            [keeper failWithFilter:[filter filterForDelegationWithParameters:@{
                                                                               @"refresh_token": REFRESH_TOKEN,
                                                                               }]
                           message:errorMessage];
            waitUntil(^(DoneCallback done) {
                [client fetchNewIdTokenWithRefreshToken:REFRESH_TOKEN parameters:nil success:^(A0Token *token) {
                    expect(token).to.beNil();
                    done();
                } failure:^(NSError *error) {
                    expect(error).notTo.beNil();
                    expect(error.localizedDescription).to.equal(errorMessage);
                    done();
                }];
            });
        });

        it(@"should call failure callback with error", ^{
            NSString *errorMessage = @"invalid_delegation";
            [keeper failWithFilter:[filter filterForDelegationWithParameters:@{
                                                                               @"key": @"value",
                                                                               }]
                           message:errorMessage];
            A0AuthParameters *parameters = [A0AuthParameters newWithDictionary:@{@"key": @"value"}];
            waitUntil(^(DoneCallback done) {
                [client fetchDelegationTokenWithParameters:parameters success:^(NSDictionary *info) {
                    expect(info).to.beNil();
                    done();
                } failure:^(NSError *error) {
                    expect(error).notTo.beNil();
                    expect(error.localizedDescription).to.equal(errorMessage);
                    done();
                }];
            });
        });

    });
});

SpecEnd
