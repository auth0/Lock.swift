// A0UsernameValidatorSpec.m
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
#import <OCHamcrest/OCHamcrest.h>

#import "A0UsernameValidator.h"
#import "A0Errors.h"

#define kValidatorKey @"validator"

typedef NSDictionary *(^SampleBlock)();

SampleBlock NonEmptyValidationForUsername(NSString *username) {
    return ^{
        UITextField *field = [[UITextField alloc] init];
        field.text = username;
        return @{
                 kValidatorKey: [A0UsernameValidator nonEmtpyValidatorForField:field],
                 };
    };
};

SampleBlock BoundedValidationForUsername(NSString *username, NSInteger min, NSInteger max) {
    return ^{
        UITextField *field = [[UITextField alloc] init];
        field.text = username;
        return @{
                 kValidatorKey: [A0UsernameValidator databaseValidatorForField:field withMinimum:min andMaximum:max],
                 };
    };
};

QuickSpecBegin(A0UsernameValidatorSpec)

describe(@"A0UsernameValidator", ^{

    sharedExamples(@"valid username", ^(QCKDSLSharedExampleContext context) {

        A0UsernameValidator *validator = context()[kValidatorKey];

        it(@"should return no error", ^{
            expect([validator validate]).to(beNil());
        });

    });

    sharedExamples(@"invalid username", ^(QCKDSLSharedExampleContext context) {

        A0UsernameValidator *validator = context()[kValidatorKey];

        it(@"should have an error", ^{
            expect([validator validate]).notTo(beNil());
        });

        it(@"should return invalid username error code", ^{
            expect(@([[validator validate] code])).to(equal(@(A0ErrorCodeInvalidUsername)));
        });

    });

    itBehavesLike(@"valid username", NonEmptyValidationForUsername(@"jdoe"));
    itBehavesLike(@"valid username", NonEmptyValidationForUsername(@"j_doe"));
    itBehavesLike(@"valid username", NonEmptyValidationForUsername(@"j"));
    itBehavesLike(@"valid username", NonEmptyValidationForUsername(@"john_doe_longer"));
    itBehavesLike(@"valid username", NonEmptyValidationForUsername(@"john doe"));
    itBehavesLike(@"valid username", NonEmptyValidationForUsername(@"john.doe"));
    itBehavesLike(@"valid username", NonEmptyValidationForUsername(@"john/doe"));
    itBehavesLike(@"valid username", NonEmptyValidationForUsername(@"john_doe_longer_than_allowed"));

    itBehavesLike(@"invalid username", NonEmptyValidationForUsername(nil));
    itBehavesLike(@"invalid username", NonEmptyValidationForUsername(@""));
    itBehavesLike(@"invalid username", NonEmptyValidationForUsername(@"  "));

    itBehavesLike(@"valid username", BoundedValidationForUsername(@"jdoe", 1, 15));
    itBehavesLike(@"valid username", BoundedValidationForUsername(@"j_doe", 1, 15));
    itBehavesLike(@"valid username", BoundedValidationForUsername(@"j", 1, 15));
    itBehavesLike(@"valid username", BoundedValidationForUsername(@"john_doe_longer", 1, 15));
    itBehavesLike(@"valid username", BoundedValidationForUsername(@"j", 1, 1));

    itBehavesLike(@"invalid username", BoundedValidationForUsername(nil, 1, 15));
    itBehavesLike(@"invalid username", BoundedValidationForUsername(@"", 1, 15));
    itBehavesLike(@"invalid username", BoundedValidationForUsername(@"  ", 1, 15));
    itBehavesLike(@"invalid username", BoundedValidationForUsername(@"john doe", 1, 15));
    itBehavesLike(@"invalid username", BoundedValidationForUsername(@"john.doe", 1, 15));
    itBehavesLike(@"invalid username", BoundedValidationForUsername(@"john/doe", 1, 15));
    itBehavesLike(@"invalid username", BoundedValidationForUsername(@"john_doe_longer_than_allowed", 1, 15));
    itBehavesLike(@"invalid username", BoundedValidationForUsername(@"j", 2, 15));

});

QuickSpecEnd
