//
//  A0UserIdentitySpec.m
//  Auth0Client
//
//  Created by Hernan Zalazar on 9/4/14.
//  Copyright 2014 Auth0. All rights reserved.
//

#import "Specta.h"
#import "A0UserIdentity.h"

#define kAccessToken @"ACCESS_TOKEN"
#define kConnectionName @"CONNECTION"
#define kProvider @"PROVIDER"
#define kUserId @"USER"

SpecBegin(A0UserIdentity)

describe(@"A0UserIdentity", ^{

    __block A0UserIdentity *identity;

    NSDictionary *jsonDict = @{
                               @"access_token": kAccessToken,
                               @"connection": kConnectionName,
                               @"isSocial": @YES,
                               @"provider": kProvider,
                               @"user_id": kUserId,
                               };

    sharedExamplesFor(@"valid basic identity", ^(NSDictionary *data) {

        beforeEach(^{
            identity = data[@"identity"];
        });

        specify(@"valid connection", ^{
            expect(identity.connection).to.equal(kConnectionName);
        });

        specify(@"valid isSocial", ^{
            expect(identity.isSocial).to.beTruthy();
        });

        specify(@"valid provider", ^{
            expect(identity.provider).to.equal(kProvider);
        });

        specify(@"valid userId", ^{
            expect(identity.userId).to.equal(kUserId);
        });
    });

    sharedExamplesFor(@"valid identity with access token", ^(NSDictionary *data) {

        beforeEach(^{
            identity = data[@"identity"];
        });

        specify(@"valid access token", ^{
            expect(identity.accessToken).to.equal(kAccessToken);
        });

        itShouldBehaveLike(@"valid basic identity", data);

    });

    describe(@"creating from JSON", ^{

        itBehavesLike(@"valid identity with access token", @{@"identity": [[A0UserIdentity alloc] initWithJSONDictionary:jsonDict]});

    });
});

SpecEnd
