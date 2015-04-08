// A0APIv1RouterSpec.m
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
#import "A0APIv1Router.h"

#define kTenant @"overmind"
#define kClientId @"1234567890"
#define kDomainURL @"https://domain.somewhere.co"
#define kAuth0Domain @"https://overmind.auth0.com"
#define kConfigurationURL @"https://configuration.somewhere.co"

#define kClientIdKey @"Auth0ClientId"
#define kTenantKey @"Auth0Tenant"
#define kDomainKey @"Auth0Domain"
#define kConfigurationDomainKey @"Auth0ConfigurationDomain"

SpecBegin(A0APIv1Router)

describe(@"A0APIv1Router", ^{

    __block A0APIv1Router *router;

    beforeEach(^{
        router = [[A0APIv1Router alloc] init];
    });

    specify(@"default initializer", ^{
        router = [[A0APIv1Router alloc] init];
        expect(router).notTo.beNil();
    });

    context(@"configure with tenant and client id", ^{

        beforeEach(^{
            [router configureForTenant:kTenant clientId:kClientId];
        });

        it(@"should have correct endpoint URL", ^{
            expect(router.endpointURL.absoluteString).to.equal(@"https://overmind.auth0.com");
        });

        it(@"should have correct config URL", ^{
            expect(router.configurationURL.absoluteString).to.equal(@"https://cdn.auth0.com/client/1234567890.js");
        });

        it(@"should fail with nil tenant", ^{
            expect(^{
                [router configureForTenant:nil clientId:kClientId];
            }).to.raise(NSInternalInconsistencyException);
        });

        it(@"should fail with nil client id", ^{
            expect(^{
                [router configureForTenant:kTenant clientId:nil];
            }).to.raise(NSInternalInconsistencyException);
        });

    });

    context(@"configure with domain and config URL", ^{

        beforeEach(^{
            [router configureForDomain:kDomainURL configurationDomain:kConfigurationURL clientId:kClientId];
        });

        it(@"should have correct endpoint URL", ^{
            expect(router.endpointURL.absoluteString).to.equal(@"https://domain.somewhere.co");
        });

        it(@"should have correct config URL", ^{
            expect(router.configurationURL.absoluteString).to.equal(@"https://configuration.somewhere.co/client/1234567890.js");
        });

        it(@"should fail with nil domain", ^{
            expect(^{
                [router configureForDomain:nil configurationDomain:kConfigurationURL clientId:kClientId];
            }).to.raise(NSInternalInconsistencyException);
        });

        it(@"should fail with nil config", ^{
            expect(^{
                [router configureForDomain:kDomainURL configurationDomain:nil clientId:kClientId];
            }).to.raise(NSInternalInconsistencyException);
        });

        it(@"should fail with nil client id", ^{
            expect(^{
                [router configureForDomain:kDomainURL configurationDomain:kConfigurationURL clientId:nil];
            }).to.raise(NSInternalInconsistencyException);
        });
        
    });

    context(@"configure with auth0 domain only", ^{

        beforeEach(^{
            [router configureForDomain:kAuth0Domain clientId:kClientId];
        });

        it(@"should have correct endpoint URL", ^{
            expect(router.endpointURL.absoluteString).to.equal(@"https://overmind.auth0.com");
        });

        it(@"should have correct config URL", ^{
            expect(router.configurationURL.absoluteString).to.equal(@"https://cdn.auth0.com/client/1234567890.js");
        });

    });

    context(@"configure with auth0 domain without protocol", ^{

        beforeEach(^{
            [router configureForDomain:@"overmind.auth0.com" clientId:kClientId];
        });

        it(@"should have correct endpoint URL", ^{
            expect(router.endpointURL.absoluteString).to.equal(@"https://overmind.auth0.com");
        });

        it(@"should have correct config URL", ^{
            expect(router.configurationURL.absoluteString).to.equal(@"https://cdn.auth0.com/client/1234567890.js");
        });
        
    });

    context(@"configure with non auth0 domain only", ^{

        beforeEach(^{
            [router configureForDomain:kDomainURL clientId:kClientId];
        });

        it(@"should have correct endpoint URL", ^{
            expect(router.endpointURL.absoluteString).to.equal(@"https://domain.somewhere.co");
        });

        it(@"should have correct config URL", ^{
            expect(router.configurationURL.absoluteString).to.equal(@"https://domain.somewhere.co/client/1234567890.js");
        });

        it(@"should fail with nil domain", ^{
            expect(^{
                [router configureForDomain:nil clientId:kClientId];
            }).to.raise(NSInternalInconsistencyException);
        });

        it(@"should fail with nil client id", ^{
            expect(^{
                [router configureForDomain:kDomainURL clientId:nil];
            }).to.raise(NSInternalInconsistencyException);
        });
        
    });

    sharedExamplesFor(@"configured from bundle", ^(NSDictionary *data) {

        beforeEach(^{
            [router configureWithBundleInfo:data[@"info"]];
        });

        it(@"should have correct endpoint URL", ^{
            expect(router.endpointURL.absoluteString).to.equal(data[@"endpoint"]);
        });

        it(@"should have correct config URL", ^{
            expect(router.configurationURL.absoluteString).to.equal(data[@"config"]);
        });

    });


    itShouldBehaveLike(@"configured from bundle", @{
                                                    @"info": @{
                                                            kTenantKey: kTenant,
                                                            kClientIdKey: kClientId,
                                                            },
                                                    @"endpoint": @"https://overmind.auth0.com",
                                                    @"config": @"https://cdn.auth0.com/client/1234567890.js",
                                                    });
    itShouldBehaveLike(@"configured from bundle", @{
                                                    @"info": @{
                                                            kDomainKey: kDomainURL,
                                                            kClientIdKey: kClientId,
                                                            },
                                                    @"endpoint": @"https://domain.somewhere.co",
                                                    @"config": @"https://domain.somewhere.co/client/1234567890.js",
                                                    });
    itShouldBehaveLike(@"configured from bundle", @{
                                                    @"info": @{
                                                            kDomainKey: kAuth0Domain,
                                                            kClientIdKey: kClientId,
                                                            },
                                                    @"endpoint": @"https://overmind.auth0.com",
                                                    @"config": @"https://cdn.auth0.com/client/1234567890.js",
                                                    });
    itShouldBehaveLike(@"configured from bundle", @{
                                                    @"info": @{
                                                            kDomainKey: kDomainURL,
                                                            kConfigurationDomainKey: kConfigurationURL,
                                                            kClientIdKey: kClientId,
                                                            },
                                                    @"endpoint": @"https://domain.somewhere.co",
                                                    @"config": @"https://configuration.somewhere.co/client/1234567890.js",
                                                    });
    itShouldBehaveLike(@"configured from bundle", @{
                                                    @"info": @{
                                                            kTenantKey: kTenant,
                                                            kDomainKey: kDomainURL,
                                                            kConfigurationDomainKey: kConfigurationURL,
                                                            kClientIdKey: kClientId,
                                                            },
                                                    @"endpoint": @"https://domain.somewhere.co",
                                                    @"config": @"https://configuration.somewhere.co/client/1234567890.js",
                                                    });
    itShouldBehaveLike(@"configured from bundle", @{
                                                    @"info": @{
                                                            kTenantKey: kTenant,
                                                            kDomainKey: kDomainURL,
                                                            kClientIdKey: kClientId,
                                                            },
                                                    @"endpoint": @"https://domain.somewhere.co",
                                                    @"config": @"https://domain.somewhere.co/client/1234567890.js",
                                                    });
    itShouldBehaveLike(@"configured from bundle", @{
                                                    @"info": @{
                                                            kTenantKey: kTenant,
                                                            kDomainKey: kAuth0Domain,
                                                            kClientIdKey: kClientId,
                                                            },
                                                    @"endpoint": @"https://overmind.auth0.com",
                                                    @"config": @"https://cdn.auth0.com/client/1234567890.js",
                                                    });

});

SpecEnd
