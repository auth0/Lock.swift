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

@interface A0APIClient (TestingOnly)

@property (readonly, nonatomic) AFHTTPRequestOperationManager *manager;

- (void)configureForApplication:(A0Application *)application;

@end

SpecBegin(A0APIClient)

describe(@"A0APIClient", ^{

    __block A0APIClient *client;

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

    before(^{
        client = [[A0APIClient alloc] initWithClientId:CLIENT_ID andTenant:TENANT];
        [OHHTTPStubs onStubActivation:^(NSURLRequest *request, id<OHHTTPStubsDescriptor> stub) {
            NSLog(@"%@ stubbed by %@", request.URL, stub.name);
        }];

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
        __block A0HTTPStubFilter *filter;

        before(^{
            filter = [[A0HTTPStubFilter alloc] init];
            client.manager.requestSerializer = [A0AnnotatedRequestSerializer serializer];
            [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return YES;
            } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                NSError *error = [NSError errorWithDomain:@"com.auth0" code:-99999999 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"%@ You shall not pass!", request.URL]}];
                return [OHHTTPStubsResponse responseWithError:error];
            }].name = @"YOU SHALL NOT PASS!";
        });

        it(@"should fail when no connection is specified", ^{
            waitUntil(^(DoneCallback done) {
                [client loginWithUsername:@"username" password:@"password" parameters:nil success:^(A0UserProfile *profile, A0Token *tokenInfo) {
                    expect(tokenInfo).to.beNil;
                    done();
                } failure:^(NSError *error) {
                    expect(error).notTo.beNil;
                    expect(error.localizedFailureReason).to.equal(@"Can't find connection name to use for authentication");
                    done();
                }];
            });
        });

        fcontext(@"with application info", ^{

            __block A0Application *application;

            before(^{
                application = mock(A0Application.class);
                connection = mock(A0Connection.class);
                A0Strategy *strategy = mock(A0Strategy.class);
                [given(application.identifier) willReturn:CLIENT_ID];
                [given(application.databaseStrategy) willReturn:strategy];
                [given(strategy.connections) willReturn:@[connection]];
                [given(connection.name) willReturn:DB_CONNECTION];
                [client configureForApplication:application];
                filter.application = application;
            });

            it(@"should login with email/password", ^{
                [OHHTTPStubs stubRequestsPassingTest:[filter filterForResourceOwnerWithUsername:EMAIL password:PASSWORD]
                                    withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                                        return [OHHTTPStubsResponse responseNamed:@"POST-oauth-ro" inBundle:nil];
                                    }].name = @"OAuth RO Endpoint Success";
                [OHHTTPStubs stubRequestsPassingTest:[filter filterForTokenInfoWithJWT:JWT]
                                    withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                                        return [OHHTTPStubsResponse responseNamed:@"POST-tokeninfo" inBundle:nil];
                                    }].name = @"JWT token info Success";
                [client configureForApplication:application];
                waitUntil(^(DoneCallback done) {
                    [client loginWithUsername:EMAIL password:PASSWORD parameters:nil success:^(A0UserProfile *profile, A0Token *tokenInfo) {
                        expect(tokenInfo).toNot.beNil;
                        expect(tokenInfo.idToken).toNot.beNil;
                        done();
                    } failure:^(NSError *error) {
                        expect(error.localizedDescription).to.beNil();
                        done();
                    }];
                });
            });

            it(@"should login with email/password with parameters", ^{
                [OHHTTPStubs stubRequestsPassingTest:[filter filterForResourceOwnerWithUsername:EMAIL password:PASSWORD]
                                    withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                                        return [OHHTTPStubsResponse responseNamed:@"POST-oauth-ro" inBundle:nil];
                                    }].name = @"OAuth RO Endpoint Success";
                [OHHTTPStubs stubRequestsPassingTest:[filter filterForTokenInfoWithJWT:JWT]
                                    withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                                        return [OHHTTPStubsResponse responseNamed:@"POST-tokeninfo" inBundle:nil];
                                    }].name = @"JWT token info Success";
                [client configureForApplication:application];
                waitUntil(^(DoneCallback done) {
                    A0AuthParameters *parameters = [A0AuthParameters newWithDictionary:@{@"param": @"value"}];
                    [client loginWithUsername:EMAIL password:PASSWORD parameters:parameters success:^(A0UserProfile *profile, A0Token *tokenInfo) {
                        expect(tokenInfo).toNot.beNil;
                        expect(tokenInfo.idToken).toNot.beNil;
                        done();
                    } failure:^(NSError *error) {
                        expect(error.localizedDescription).to.beNil();
                        done();
                    }];
                });
            });

            it(@"should login with email/password with overriding default parameters", ^{
                [OHHTTPStubs stubRequestsPassingTest:[filter filterForResourceOwnerWithParameters:@{@"username": EMAIL, @"scope": @"openid"}]
                                    withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                                        return [OHHTTPStubsResponse responseNamed:@"POST-oauth-ro" inBundle:nil];
                                    }].name = @"OAuth RO Endpoint Success";
                [OHHTTPStubs stubRequestsPassingTest:[filter filterForTokenInfoWithJWT:JWT]
                                    withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                                        return [OHHTTPStubsResponse responseNamed:@"POST-tokeninfo" inBundle:nil];
                                    }].name = @"JWT token info Success";
                [client configureForApplication:application];
                waitUntil(^(DoneCallback done) {
                    A0AuthParameters *parameters = [A0AuthParameters newWithScopes:@[@"openid"]];
                    [client loginWithUsername:EMAIL password:PASSWORD parameters:parameters success:^(A0UserProfile *profile, A0Token *tokenInfo) {
                        expect(tokenInfo).toNot.beNil;
                        expect(tokenInfo.idToken).toNot.beNil;
                        done();
                    } failure:^(NSError *error) {
                        expect(error.localizedDescription).to.beNil();
                        done();
                    }];
                });
            });

        });
    });
});

SpecEnd
