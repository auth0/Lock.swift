//
//  A0ApplicationSpec.m
//  Auth0Client
//
//  Created by Hernan Zalazar on 7/4/14.
//  Copyright 2014 Hernan Zalazar. All rights reserved.
//

#import "Specta.h"
#import <Auth0Client/A0Application.h>

#define kAppDataKey @"app"
#define kAppIdentifier @"A VALID IDENTIFIER"
#define kTenant @"TENANT"
#define kAuthorizeURL @"https://somewherefarneyond.com"
#define kCallbackURL @"https://callback.to"

SpecBegin(A0Application)

describe(@"A0Application", ^{


    sharedExamplesFor(@"valid application object", ^(NSDictionary *data) {
        __block A0Application *application;

        beforeEach(^{
            application = data[kAppDataKey];
        });

        specify(@"valid id", ^{
            expect(application.identifier).to.equal(kAppIdentifier);
        });

        specify(@"valid tenant", ^{
            expect(application.tenant).to.equal(kTenant);
        });

        specify(@"valid authorize URL", ^{
            expect(application.authorizeURL).to.equal([NSURL URLWithString:kAuthorizeURL]);
        });

        specify(@"valid callback URL", ^{
            expect(application.callbackURL).to.equal([NSURL URLWithString:kCallbackURL]);
        });
    });

    context(@"object creation from JSON", ^{

        NSString *JSONDictKey = @"JSONDict";
        NSDictionary *jsonDict = @{
                                   @"id": kAppIdentifier,
                                   @"tenant": kTenant,
                                   @"authorize": kAuthorizeURL,
                                   @"callback": kCallbackURL,
                                   };


        sharedExamplesFor(@"invalid JSON dictionary", ^(NSDictionary *data) {
            it(@"should fail on init method", ^{
                expect(^{
                    A0Application *app = [[A0Application alloc] initWithJSONDictionary:data[JSONDictKey]];
                    expect(app).to.beNil;
                }).to.raiseAny();
            });
        });

        itBehavesLike(@"valid application object", ^{
            return @{
                     kAppDataKey: [[A0Application alloc] initWithJSONDictionary:jsonDict],
                     };
        });

        itBehavesLike(@"invalid JSON dictionary", @{});

        itBehavesLike(@"invalid JSON dictionary", @{JSONDictKey: @{}});

        itBehavesLike(@"invalid JSON dictionary", ^{
            NSMutableDictionary *dict = [jsonDict mutableCopy];
            [dict removeObjectForKey:@"id"];
            return dict;
        });

        itBehavesLike(@"invalid JSON dictionary", ^{
            NSMutableDictionary *dict = [jsonDict mutableCopy];
            [dict removeObjectForKey:@"tenant"];
            return dict;
        });

        itBehavesLike(@"invalid JSON dictionary", ^{
            NSMutableDictionary *dict = [jsonDict mutableCopy];
            [dict removeObjectForKey:@"authorize"];
            return dict;
        });

        itBehavesLike(@"invalid JSON dictionary", ^{
            NSMutableDictionary *dict = [jsonDict mutableCopy];
            [dict removeObjectForKey:@"callback"];
            return dict;
        });

    });
});

SpecEnd
