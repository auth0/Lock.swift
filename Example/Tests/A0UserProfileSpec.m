//  A0UserProfileSpec.m
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
#import "A0UserProfile.h"

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

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

    describe(@"NSCoding", ^{

        __block NSCoder *coder;

        beforeEach(^{
            coder = mock(NSCoder.class);
        });

        context(@"saving A0UserProfile", ^{

            beforeEach(^{
                profile = [[A0UserProfile alloc] initWithDictionary:jsonDict];
                [profile encodeWithCoder:coder];
            });

            specify(@"store key for user id", ^{
                [verify(coder) encodeObject:profile.userId forKey:@"userId"];
            });

            specify(@"store key for email", ^{
                [verify(coder) encodeObject:profile.email forKey:@"email"];
            });

            specify(@"store key for name", ^{
                [verify(coder) encodeObject:profile.name forKey:@"name"];
            });

            specify(@"store key for nickname", ^{
                [verify(coder) encodeObject:profile.nickname forKey:@"nickname"];
            });

            specify(@"store key for picture", ^{
                [verify(coder) encodeObject:profile.picture forKey:@"picture"];
            });

            specify(@"store key for createdAt", ^{
                [verify(coder) encodeObject:profile.createdAt forKey:@"createdAt"];
            });

            specify(@"store key for extraInfo", ^{
                [verify(coder) encodeObject:profile.extraInfo forKey:@"extraInfo"];
            });

        });

        context(@"restore A0UserProfile", ^{

            beforeEach(^{
                profile = [[A0UserProfile alloc] initWithDictionary:jsonDict];
                [given([coder decodeObjectForKey:@"userId"]) willReturn:profile.userId];
                [given([coder decodeObjectForKey:@"email"]) willReturn:profile.email];
                [given([coder decodeObjectForKey:@"name"]) willReturn:profile.name];
                [given([coder decodeObjectForKey:@"nickname"]) willReturn:profile.nickname];
                [given([coder decodeObjectForKey:@"createdAt"]) willReturn:profile.createdAt];
                [given([coder decodeObjectForKey:@"picture"]) willReturn:profile.picture];
                [given([coder decodeObjectForKey:@"extraInfo"]) willReturn:@{}];
                profile = [[A0UserProfile alloc] initWithCoder:coder];
            });

            itShouldBehaveLike(@"valid complete profile", ^{ return @{ @"profile": profile }; });

            specify(@"valid extraInfo", ^{
                expect(profile.extraInfo).to.equal(@{});
            });
        });
    });
});

SpecEnd
