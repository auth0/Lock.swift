// A0CredentialsValidatorSpec.m
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
#import "A0CredentialsValidator.h"
#import "A0Errors.h"

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

SpecBegin(A0CredentialsValidator)

describe(@"A0CredentialsValidator", ^{

    __block A0CredentialsValidator *validator;
    __block id<A0FieldValidator> firstValidator;
    __block id<A0FieldValidator> secondValidator;

    beforeEach(^{
        firstValidator = mockProtocol(@protocol(A0FieldValidator));
        secondValidator = mockProtocol(@protocol(A0FieldValidator));
        validator = [[A0CredentialsValidator alloc] initWithValidators:@[firstValidator, secondValidator]];
    });

    it(@"should fail with nil validator list", ^{
        expect(^{
            validator = [[A0CredentialsValidator alloc] initWithValidators:nil];
        }).to.raise(NSInternalInconsistencyException);
    });

    it(@"should fail with empty validator list", ^{
        expect(^{
            validator = [[A0CredentialsValidator alloc] initWithValidators:@[]];
        }).to.raise(NSInternalInconsistencyException);
    });

    context(@"successful validation", ^{

        beforeEach(^{
            [given([firstValidator validate]) willReturn:nil];
            [given([secondValidator validate]) willReturn:nil];
        });

        it(@"should call all validators", ^{
            [validator validate];
            MKTVerify([firstValidator validate]);
            MKTVerify([secondValidator validate]);
        });

        it(@"should return no error", ^{
            expect([validator validate]).to.beNil();
        });
    });
});

SpecEnd
