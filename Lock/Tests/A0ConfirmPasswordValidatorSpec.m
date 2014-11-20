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

#import "Specta.h"
#import "A0ConfirmPasswordValidator.h"
#import "A0Errors.h"

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>


SpecBegin(A0ConfirmPasswordValidator)

describe(@"A0ConfirmPasswordValidator", ^{

    __block A0ConfirmPasswordValidator *validator;
    __block UITextField *field;
    __block UITextField *passwordField;

    beforeEach(^{
        field = mock(UITextField.class);
        passwordField = mock(UITextField.class);
        validator = [[A0ConfirmPasswordValidator alloc] initWithField:field passwordField:passwordField];
    });

    it(@"should fail with nil field", ^{
        expect(^{
            validator = [[A0ConfirmPasswordValidator alloc] initWithField:nil passwordField:passwordField];
        }).to.raise(NSInternalInconsistencyException);
    });

    it(@"should fail with nil password field", ^{
        expect(^{
            validator = [[A0ConfirmPasswordValidator alloc] initWithField:field passwordField:nil];
        }).to.raise(NSInternalInconsistencyException);
    });

    it(@"should fail with nil fields", ^{
        expect(^{
            validator = [[A0ConfirmPasswordValidator alloc] initWithField:nil passwordField:nil];
        }).to.raise(NSInternalInconsistencyException);
    });

    sharedExamplesFor(@"valid confirm password", ^(NSDictionary *data) {

        __block NSError *error;
        
        beforeEach(^{
            [given(field.text) willReturn:data[@"confirm_password"]];
            [given(passwordField.text) willReturn:data[@"password"]];
            error = [validator validate];
        });

        specify(@"value from fields", ^{
            [verifyCount(field, atLeastOnce()) text];
            [verifyCount(passwordField, atLeastOnce()) text];
        });

        specify(@"no error", ^{
            expect(error).to.beNil();
        });
    });

    itShouldBehaveLike(@"valid confirm password", @{@"password": @"123456", @"confirm_password": @"123456"});

    sharedExamplesFor(@"invalid confirm password", ^(NSDictionary *data) {

        beforeEach(^{
            [given(field.text) willReturn:data[@"confirm_password"]];
            [given(passwordField.text) willReturn:data[@"password"]];
        });

        specify(@"an error", ^{
            expect([validator validate]).notTo.beNil();
        });

        specify(@"invalid confirm password code", ^{
            expect([validator validate].code).to.equal(@(A0ErrorCodeInvalidRepeatPassword));
        });

    });

    itShouldBehaveLike(@"invalid confirm password", @{});
    itShouldBehaveLike(@"invalid confirm password", @{@"password":@"123456"});
    itShouldBehaveLike(@"invalid confirm password", @{@"confirm_password":@"123456"});
    itShouldBehaveLike(@"invalid confirm password", @{@"password":@"123456", @"confirm_password":@"123456A"});
    itShouldBehaveLike(@"invalid confirm password", @{@"password":@"123456", @"confirm_password":@"123456   "});
});

SpecEnd
