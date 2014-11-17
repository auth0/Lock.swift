//  A0WebAuthenticationSpec.m
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

#import "Specta.h"
#import "A0WebAuthentication.h"
#import "A0Application.h"
#import "A0Strategy.h"
#import "NSDictionary+A0QueryParameters.h"
#import "A0Errors.h"
#import "A0Connection.h"

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

#define kAppIdentifier @"1321As2sdj2FF"
#define kConnectionName @"connectionName"
#define kIdToken @"id token"
#define kTokenType @"token type"
#define kAccessToken @"access token"
#define kRefreshToken @"refresh token"

#define kValidURL @"a01321As2sdj2FF://connectionname.auth0.com/authorize"

NSURL *ValidURLWithQueryParameters(NSDictionary *params) {
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:[NSURL URLWithString:kValidURL] resolvingAgainstBaseURL:NO];
    components.query = params.queryString;
    return components.URL;
}

NSURL *ValidURLWithFragment(NSDictionary *params) {
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:[NSURL URLWithString:kValidURL] resolvingAgainstBaseURL:NO];
    components.fragment = params.queryString;
    return components.URL;
}

SpecBegin(A0WebAuthentication)

describe(@"A0WebAuthentication", ^{

    __block A0WebAuthentication *authentication;
    __block A0Application *application;
    __block A0Strategy *strategy;
    __block A0Connection *connection;

    beforeEach(^{
        application = mock(A0Application.class);
        strategy = mock(A0Strategy.class);
        connection = mock(A0Connection.class);
        [given(application.identifier) willReturn:kAppIdentifier];
        [given(strategy.connections) willReturn:@[connection]];
        [given(strategy.name) willReturn:kConnectionName];
        [given(connection.name) willReturn:kConnectionName];
    });

    describe(@"initialization", ^{

        context(@"valid application & strategy", ^{

            beforeEach(^{
                authentication = [[A0WebAuthentication alloc] initWithApplication:application strategy:strategy];
            });

            it(@"should return initialised instance", ^{
                expect(authentication).toNot.beNil();
            });

            it(@"should have the callback with correct scheme", ^{
                expect(authentication.callbackURL.scheme).to.equal([@"a0" stringByAppendingString:kAppIdentifier].lowercaseString);
            });

            it(@"should have the callback with correct host", ^{
                expect(authentication.callbackURL.host).to.equal([kConnectionName stringByAppendingString:@".auth0.com"].lowercaseString);
            });

        });

        sharedExamplesFor(@"init failure", ^(NSDictionary *data) {

            it(@"should fail initialise", ^{
                expect(^{
                    authentication = [[A0WebAuthentication alloc] initWithApplication:data[@"app"] strategy:data[@"strategy"]];
                }).to.raise(NSInternalInconsistencyException);
            });

        });

        itShouldBehaveLike(@"init failure", @{});
        itShouldBehaveLike(@"init failure", ^{
            return @{@"app": application};
        });
        itShouldBehaveLike(@"init failure", ^{
            return @{@"strategy": strategy};
        });
        itShouldBehaveLike(@"init failure", ^{
            [given(application.identifier) willReturn:nil];
            return @{@"app": application, @"strategy": strategy};
        });
        itShouldBehaveLike(@"init failure", ^{
            [given(strategy.connections) willReturn:nil];
            return @{@"app": application, @"strategy": strategy};
        });

    });

    describe(@"URL validation", ^{

        beforeEach(^{
            authentication = [[A0WebAuthentication alloc] initWithApplication:application strategy:strategy];
        });

        sharedExamplesFor(@"invalid url", ^(NSDictionary *data) {

            it(@"should fail validation", ^{
                expect([authentication validateURL:data[@"url"]]).to.beFalsy();
            });

        });

        itShouldBehaveLike(@"invalid url", @{});
        itShouldBehaveLike(@"invalid url", @{@"url": [NSURL URLWithString:@"http://pepe.com"]});
        itShouldBehaveLike(@"invalid url", @{@"url": [NSURL URLWithString:@"a0anotherclientid://connectionname.auth0.com"]});
        itShouldBehaveLike(@"invalid url", @{@"url": [NSURL URLWithString:@"a01321As2sdj2FF://facebook.auth0.com"]});

        it(@"should deem valid the URL", ^{
            NSURL *url = [NSURL URLWithString:kValidURL];
            expect([authentication validateURL:url]).to.beTruthy();
        });
    });


    describe(@"token parsing from URL", ^{

        sharedExamplesFor(@"valid URL with token info", ^(NSDictionary *data) {

            __block NSError *error;

            it(@"should parse from query parameters", ^{
                expect([authentication tokenFromURL:data[@"url"] error:&error]).toNot.beNil();
                expect(error).to.beNil();
            });
        });

        itShouldBehaveLike(@"valid URL with token info", ^{
            return @{
                     @"url": ValidURLWithQueryParameters(@{
                                                           @"id_token": kIdToken,
                                                           @"token_type": kTokenType,
                                                           }),
                     };
        });

        itShouldBehaveLike(@"valid URL with token info", ^{
            return @{
                     @"url": ValidURLWithQueryParameters(@{
                                                           @"id_token": kIdToken,
                                                           @"token_type": kTokenType,
                                                           @"access_token": kAccessToken,
                                                           }),
                     };
        });

        itShouldBehaveLike(@"valid URL with token info", ^{
            return @{
                     @"url": ValidURLWithQueryParameters(@{
                                                           @"id_token": kIdToken,
                                                           @"token_type": kTokenType,
                                                           @"access_token": kAccessToken,
                                                           @"refresh_token": kRefreshToken,
                                                           }),
                     };
        });

        itShouldBehaveLike(@"valid URL with token info", ^{
            return @{
                     @"url": ValidURLWithFragment(@{
                                                           @"id_token": kIdToken,
                                                           @"token_type": kTokenType,
                                                           }),
                     };
        });

        itShouldBehaveLike(@"valid URL with token info", ^{
            return @{
                     @"url": ValidURLWithFragment(@{
                                                           @"id_token": kIdToken,
                                                           @"token_type": kTokenType,
                                                           @"access_token": kAccessToken,
                                                           }),
                     };
        });

        itShouldBehaveLike(@"valid URL with token info", ^{
            return @{
                     @"url": ValidURLWithFragment(@{
                                                           @"id_token": kIdToken,
                                                           @"token_type": kTokenType,
                                                           @"access_token": kAccessToken,
                                                           @"refresh_token": kRefreshToken,
                                                           }),
                     };
        });

        context(@"access denied error in URL", ^{

            __block NSError *error;
            __block A0Token *token;

            beforeEach(^{
                token = [authentication tokenFromURL:ValidURLWithQueryParameters(@{
                                                                                   @"error": @"access_denied"
                                                                                   })
                                               error:&error];
            });

            it(@"should have no token", ^{
                expect(token).to.beNil();
            });

            it(@"should have an error", ^{
                expect(error).toNot.beNil();
                expect(error.code).to.equal(A0ErrorCodeAuth0NotAuthorized);
            });
        });

        context(@"no id_token in URL", ^{

            __block NSError *error;
            __block A0Token *token;

            beforeEach(^{
                token = [authentication tokenFromURL:ValidURLWithQueryParameters(@{})
                                               error:&error];
            });

            it(@"should have no token", ^{
                expect(token).to.beNil();
            });

            it(@"should have an error", ^{
                expect(error).toNot.beNil();
                expect(error.code).to.equal(A0ErrorCodeAuth0NotAuthorized);
            });
        });

        context(@"random error in URL", ^{

            __block NSError *error;
            __block A0Token *token;

            beforeEach(^{
                token = [authentication tokenFromURL:ValidURLWithQueryParameters(@{
                                                                                   @"error": @"invalid_scope"
                                                                                   })
                                               error:&error];
            });

            it(@"should have no token", ^{
                expect(token).to.beNil();
            });

            it(@"should have an error", ^{
                expect(error).toNot.beNil();
                expect(error.code).to.equal(A0ErrorCodeAuth0InvalidConfiguration);
            });
        });

    });
});

SpecEnd
