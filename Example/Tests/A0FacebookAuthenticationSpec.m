//
//  A0FacebookAuthenticationSpec.m
//  Auth0Client
//
//  Created by Hernan Zalazar on 8/29/14.
//  Copyright 2014 Auth0. All rights reserved.
//

#import "Specta.h"
#import "A0FacebookAuthentication.h"

@interface A0FacebookAuthentication (TestAPI)
@property (strong, nonatomic) NSArray *permissions;
@end

SpecBegin(A0FacebookAuthentication)

describe(@"A0FacebookAuthentication", ^{

    __block A0FacebookAuthentication *facebook;

    describe(@"creating facebook authentication", ^{

        sharedExamplesFor(@"valid permissions", ^(NSDictionary *data) {

            __block NSArray *permissions;

            beforeEach(^{
                permissions = data[@"permissions"] ?: @[];
                facebook = [A0FacebookAuthentication newAuthenticationWithPermissions:permissions];
            });

            specify(@"has public_profile permissions", ^{
                expect(facebook.permissions).to.contain(@"public_profile");
            });

            specify(@"has the permissions supplied when created", ^{
                expect(facebook.permissions).to.beSupersetOf(permissions);
            });

        });

        itBehavesLike(@"valid permissions", @{ @"permissions": @[] });
        itBehavesLike(@"valid permissions", nil);
        itBehavesLike(@"valid permissions", @{ @"permissions": @[@"email"] });
        itBehavesLike(@"valid permissions", @{ @"permissions": @[@"public_profile", @"email"] });
        itBehavesLike(@"valid permissions", @{ @"permissions": @[@"user_likes"] });

    });
});

SpecEnd
