//
//  A0UserProfileSpec.m
//  Auth0Client
//
//  Created by Hernan Zalazar on 8/28/14.
//  Copyright 2014 Auth0. All rights reserved.
//

#import "Specta.h"
#import "A0UserProfile.h"

#define kUserId @"USER_ID"
#define kName @"John Doe"
#define kNickname @"J"
#define kEmail @"mail@mail.com"
#define kPictureURL @"http://server.com/image"
#define kCreatedAt @"2014-08-28T15:44:24.288Z"

SpecBegin(A0UserProfile)

describe(@"A0UserProfile", ^{

    __block A0UserProfile *profile;

    NSDictionary *jsonDict = @{
                               @"user_id": kUserId,
                               @"name": kName,
                               @"nickname": kNickname,
                               @"email": kEmail,
                               @"picture": kPictureURL,
                               @"created_at": kCreatedAt,
                               };

    sharedExamplesFor(@"valid basic profile", ^(NSDictionary *data) {

        beforeEach(^{
            profile = data[@"profile"];
        });

        specify(@"valid user id", ^{
            expect(profile.userId).to.equal(kUserId);
        });

    });

    sharedExamplesFor(@"valid complete profile", ^(NSDictionary *data) {

        beforeEach(^{
            profile = data[@"profile"];
        });

        itShouldBehaveLike(@"valid basic profile", data);

        specify(@"valid name", ^{
            expect(profile.name).to.equal(kName);
        });

        specify(@"valid nickname", ^{
            expect(profile.nickname).to.equal(kNickname);
        });

        specify(@"valid email", ^{
            expect(profile.email).to.equal(kEmail);
        });

        specify(@"valid picture url", ^{
            expect(profile.picture.absoluteString).to.equal(kPictureURL);
        });

        specify(@"valid created date", ^{
            expect(profile.createdAt).toNot.beNil();
        });
    });

    context(@"Create object from JSON", ^{

        itShouldBehaveLike(@"valid complete profile", @{ @"profile": [[A0UserProfile alloc] initWithDictionary:jsonDict] });

        it(@"should fail when no user id is present", ^{
            expect(^{
                NSMutableDictionary *dict = [jsonDict mutableCopy];
                [dict removeObjectForKey:@"user_id"];
                profile = [[A0UserProfile alloc] initWithDictionary:dict];
            }).to.raiseWithReason(NSInternalInconsistencyException, @"Should have a non empty user id");
        });

        it(@"should fail when no user id is empty", ^{
            expect(^{
                NSMutableDictionary *dict = [jsonDict mutableCopy];
                dict[@"user_id"] = @"";
                profile = [[A0UserProfile alloc] initWithDictionary:dict];
            }).to.raiseWithReason(NSInternalInconsistencyException, @"Should have a non empty user id");
        });

        itShouldBehaveLike(@"valid basic profile", @{ @"profile": [[A0UserProfile alloc] initWithDictionary:@{ @"user_id": kUserId }] });
    });

});

SpecEnd
