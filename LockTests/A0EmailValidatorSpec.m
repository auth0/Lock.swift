// A0EmailValidatorSpec.m
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

#import <Quick/Quick.h>
#import <Nimble/Nimble.h>

#import "A0EmailValidator.h"
#import "A0Errors.h"

QuickSpecBegin(A0EmailValidatorSpec)

describe(@"A0EmailValidator", ^{

    __block A0EmailValidator *validator;
    __block UITextField *field;

    beforeEach(^{
        field = [[UITextField alloc] init];
        validator = [[A0EmailValidator alloc] initWithField:field];
    });

    sharedExamples(@"valid email", ^(QCKDSLSharedExampleContext context) {

        beforeEach(^{
            field.text = context()[@"mail"];
        });

        it(@"no error", ^{
            expect([validator validate]).to(beNil());
        });

    });

    itBehavesLike(@"valid email", ^{ return @{@"mail": @"mail@mail.com"}; });
    itBehavesLike(@"valid email", ^{ return @{@"mail": @"mail+filter1@auth0.com"}; });
    itBehavesLike(@"valid email", ^{ return @{@"mail": @"mail+filter1@auth0.co.uk"}; });
    itBehavesLike(@"valid email", ^{ return @{@"mail": @"mail+filter1@auth0.blog"}; });
    itBehavesLike(@"valid email", ^{ return @{@"mail": @"mail+filter1@auth0.com.ar"}; });
    itBehavesLike(@"valid email", ^{ return @{@"mail": @" mail@auth0.com.ar"}; });
    itBehavesLike(@"valid email", ^{ return @{@"mail": @"filter1@auth0.com.ar  "}; });
    itBehavesLike(@"valid email", ^{ return @{@"mail": @" mail@auth0.com.ar  "}; });

    sharedExamples(@"invalid email", ^(QCKDSLSharedExampleContext context) {

        beforeEach(^{
            field.text = context()[@"mail"];
        });

        it(@"an error", ^{
            expect([validator validate]).notTo(beNil());
        });

        it(@"email error code", ^{
            expect(@([[validator validate] code])).to(equal(@(A0ErrorCodeInvalidEmail)));
        });

    });

    itBehavesLike(@"invalid email", ^{ return @{}; });
    itBehavesLike(@"invalid email", ^{ return @{@"mail": @""}; });
    itBehavesLike(@"invalid email", ^{ return @{@"mail": @" "}; });
    itBehavesLike(@"invalid email", ^{ return @{@"mail": @"mail"}; });
    itBehavesLike(@"invalid email", ^{ return @{@"mail": @"mail.com"}; });
    itBehavesLike(@"invalid email", ^{ return @{@"mail": @"mail@mail"}; });
    itBehavesLike(@"invalid email", ^{ return @{@"mail": @"@mail.com"}; });
});

QuickSpecEnd
