// A0ConfirmPasswordValidatorSpec.m
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
#import "A0ConfirmPasswordValidator.h"
#import "A0Errors.h"

QuickSpecBegin(A0ConfirmPasswordValidatorSpec)

describe(@"A0ConfirmPasswordValidator", ^{

    __block A0ConfirmPasswordValidator *validator;
    __block UITextField *field;
    __block UITextField *passwordField;

    beforeEach(^{
        field = [[UITextField alloc] init];
        passwordField = [[UITextField alloc] init];
        validator = [[A0ConfirmPasswordValidator alloc] initWithField:field passwordField:passwordField];
    });

    sharedExamples(@"valid confirm password", ^(QCKDSLSharedExampleContext context) {

        __block NSError *error;
        
        beforeEach(^{
            NSDictionary *data = context();
            field.text = data[@"confirm_password"];
            passwordField.text = data[@"password"];
            error = [validator validate];
        });

        it(@"no error", ^{
            expect(error).to(beNil());
        });
    });

    itBehavesLike(@"valid confirm password", ^{ return @{@"password": @"123456", @"confirm_password": @"123456"}; });

    sharedExamples(@"invalid confirm password", ^(QCKDSLSharedExampleContext context) {

        beforeEach(^{
            NSDictionary *data = context();
            field.text = data[@"confirm_password"];
            passwordField.text = data[@"password"];
        });

        it(@"an error", ^{
            expect([validator validate]).notTo(beNil());
        });

        it(@"invalid confirm password code", ^{
            expect(@([validator validate].code)).to(equal(@(A0ErrorCodeInvalidRepeatPassword)));
        });

    });

    itBehavesLike(@"invalid confirm password", ^{ return @{}; });
    itBehavesLike(@"invalid confirm password", ^{ return @{@"password":@"123456"}; });
    itBehavesLike(@"invalid confirm password", ^{ return @{@"confirm_password":@"123456"}; });
    itBehavesLike(@"invalid confirm password", ^{ return @{@"password":@"123456", @"confirm_password":@"123456A"}; });
    itBehavesLike(@"invalid confirm password", ^{ return @{@"password":@"123456", @"confirm_password":@"123456   "}; });
});

QuickSpecEnd
