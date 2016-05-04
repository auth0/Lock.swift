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

#define QUICK_DISABLE_SHORT_SYNTAX 1

#import <Quick/Quick.h>
#import <Nimble/Nimble.h>
#import <OCMockito/OCMockito.h>
#import "A0UserProfile.h"

#define kUserId @"USER_ID"
#define kName @"John Doe"
#define kNickname @"J"
#define kEmail @"mail@mail.com"
#define kPictureURL @"http://server.com/image"
#define kCreatedAt @"2014-08-28T15:44:24.288Z"

QuickSpecBegin(A0UserProfileSpec)

describe(@"A0UserProfile", ^{

    NSDictionary *jsonDict = @{
                               @"user_id": kUserId,
                               @"name": kName,
                               @"nickname": kNickname,
                               @"email": kEmail,
                               @"picture": kPictureURL,
                               @"created_at": kCreatedAt,
                               };

    sharedExamples(@"valid basic profile", ^(QCKDSLSharedExampleContext context) {

        __block A0UserProfile *profile;

        beforeEach(^{
            profile = context()[@"profile"];
        });

        it(@"valid user id", ^{
            expect(profile.userId).to(equal(kUserId));
        });

    });

    sharedExamples(@"valid complete profile", ^(QCKDSLSharedExampleContext context) {

        __block A0UserProfile *profile;

        beforeEach(^{
            profile = context()[@"profile"];
        });

        itBehavesLike(@"valid basic profile", context);

        it(@"valid name", ^{
            expect(profile.name).to(equal(kName));
        });

        it(@"valid nickname", ^{
            expect(profile.nickname).to(equal(kNickname));
        });

        it(@"valid email", ^{
            expect(profile.email).to(equal(kEmail));
        });

        it(@"valid picture url", ^{
            expect(profile.picture.absoluteString).to(equal(kPictureURL));
        });

        it(@"valid created date", ^{
            expect(profile.createdAt).toNot(beNil());
        });
    });

    context(@"Create object from JSON", ^{

        __block A0UserProfile *profile;

        itBehavesLike(@"valid complete profile", ^{ return @{ @"profile": [[A0UserProfile alloc] initWithDictionary:jsonDict] }; });

        it(@"should fail when no user id is present", ^{
            expectAction(^{
                NSMutableDictionary *dict = [jsonDict mutableCopy];
                [dict removeObjectForKey:@"user_id"];
                profile = [[A0UserProfile alloc] initWithDictionary:dict];
            }).to(raiseException());
        });

        it(@"should fail when no user id is empty", ^{
            expectAction(^{
                NSMutableDictionary *dict = [jsonDict mutableCopy];
                dict[@"user_id"] = @"";
                profile = [[A0UserProfile alloc] initWithDictionary:dict];
            }).to(raiseException());
        });

        itBehavesLike(@"valid basic profile", ^{ return @{ @"profile": [[A0UserProfile alloc] initWithDictionary:@{ @"user_id": kUserId }] }; });
    });

    describe(@"NSCoding", ^{

        __block A0UserProfile *profile;
        __block NSCoder *coder;

        beforeEach(^{
            coder = mock(NSCoder.class);
        });

        context(@"saving A0UserProfile", ^{

            beforeEach(^{
                profile = [[A0UserProfile alloc] initWithDictionary:jsonDict];
                [profile encodeWithCoder:coder];
            });

            it(@"store key for user id", ^{
                [verify(coder) encodeObject:profile.userId forKey:@"userId"];
            });

            it(@"store key for email", ^{
                [verify(coder) encodeObject:profile.email forKey:@"email"];
            });

            it(@"store key for name", ^{
                [verify(coder) encodeObject:profile.name forKey:@"name"];
            });

            it(@"store key for nickname", ^{
                [verify(coder) encodeObject:profile.nickname forKey:@"nickname"];
            });

            it(@"store key for picture", ^{
                [verify(coder) encodeObject:profile.picture forKey:@"picture"];
            });

            it(@"store key for createdAt", ^{
                [verify(coder) encodeObject:profile.createdAt forKey:@"createdAt"];
            });

            it(@"store key for extraInfo", ^{
                [verify(coder) encodeObject:profile.extraInfo forKey:@"extraInfo"];
            });

        });

        context(@"restore A0UserProfile", ^{

            beforeEach(^{
                profile = [[A0UserProfile alloc] initWithDictionary:jsonDict];
                [given([coder decodeObjectOfClass:NSString.class forKey:@"userId"]) willReturn:profile.userId];
                [given([coder decodeObjectOfClass:NSString.class forKey:@"email"]) willReturn:profile.email];
                [given([coder decodeObjectOfClass:NSString.class forKey:@"name"]) willReturn:profile.name];
                [given([coder decodeObjectOfClass:NSString.class forKey:@"nickname"]) willReturn:profile.nickname];
                [given([coder decodeObjectOfClass:NSDate.class forKey:@"createdAt"]) willReturn:profile.createdAt];
                [given([coder decodeObjectOfClass:NSURL.class forKey:@"picture"]) willReturn:profile.picture];
                [given([coder decodeObjectOfClass:NSDictionary.class forKey:@"extraInfo"]) willReturn:@{}];
                profile = [[A0UserProfile alloc] initWithCoder:coder];
            });

            itBehavesLike(@"valid complete profile", ^{ return @{ @"profile": [[A0UserProfile alloc] initWithDictionary:jsonDict] }; });

            it(@"valid extraInfo", ^{
                expect(profile.extraInfo).to(equal(@{}));
            });
        });
    });
});

QuickSpecEnd
