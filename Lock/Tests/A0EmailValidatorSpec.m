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

#import "Specta.h"
#import "A0EmailValidator.h"

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>
#import "A0Errors.h"

SpecBegin(A0EmailValidator)

describe(@"A0EmailValidator", ^{

    __block A0EmailValidator *validator;
    __block UITextField *field;

    beforeEach(^{
        field = mock(UITextField.class);
        validator = [[A0EmailValidator alloc] initWithField:field];
    });

    it(@"should fail init with nil field", ^{
        expect(^{
            validator = [[A0EmailValidator alloc] initWithField:nil];
        }).to.raise(NSInternalInconsistencyException);
    });

    sharedExamplesFor(@"valid email", ^(NSDictionary *data) {

        beforeEach(^{
            [given(field.text) willReturn:data[@"mail"]];
        });

        specify(@"should obtain value from field", ^{
            [validator validate];
            [MKTVerify(field) text];
        });

        specify(@"no error", ^{
            expect([validator validate]).to.beNil();
        });

    });

    itShouldBehaveLike(@"valid email", @{@"mail": @"mail@mail.com"});
    itShouldBehaveLike(@"valid email", @{@"mail": @"mail+filter1@auth0.com"});
    itShouldBehaveLike(@"valid email", @{@"mail": @"mail+filter1@auth0.com.ar"});
    itShouldBehaveLike(@"valid email", @{@"mail": @" mail@auth0.com.ar"});
    itShouldBehaveLike(@"valid email", @{@"mail": @"filter1@auth0.com.ar  "});
    itShouldBehaveLike(@"valid email", @{@"mail": @" mail@auth0.com.ar  "});

    sharedExamplesFor(@"invalid email", ^(NSDictionary *data) {

        beforeEach(^{
            [given(field.text) willReturn:data[@"mail"]];
        });

        specify(@"should obtain value from field", ^{
            [validator validate];
            [MKTVerify(field) text];
        });

        specify(@"an error", ^{
            expect([validator validate]).notTo.beNil();
        });

        specify(@"email error code", ^{
            expect([[validator validate] code]).to.equal(@(A0ErrorCodeInvalidEmail));
        });

    });

    itShouldBehaveLike(@"invalid email", @{});
    itShouldBehaveLike(@"invalid email", @{@"mail": @""});
    itShouldBehaveLike(@"invalid email", @{@"mail": @" "});
    itShouldBehaveLike(@"invalid email", @{@"mail": @"mail"});
    itShouldBehaveLike(@"invalid email", @{@"mail": @"mail.com"});
    itShouldBehaveLike(@"invalid email", @{@"mail": @"mail@mail"});
    itShouldBehaveLike(@"invalid email", @{@"mail": @"@mail.com"});
    itShouldBehaveLike(@"invalid email", @{@"mail": @"|mail@mail.com"});
    itShouldBehaveLike(@"invalid email", @{@"mail": @"mail@m.c"});
});

SpecEnd
