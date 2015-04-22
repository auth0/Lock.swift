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
        [given([firstValidator identifier]) willReturn:@"first"];
        [given([secondValidator identifier]) willReturn:@"second"];
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
            [MKTVerify(firstValidator) validate];
            [MKTVerify(secondValidator) validate];
        });

        it(@"should return no error", ^{
            expect([validator validate]).to.beNil();
        });

    });

    context(@"one failed validation", ^{

        __block NSError *validatorError;

        beforeEach(^{
            validatorError = mock(NSError.class);
            [given([firstValidator validate]) willReturn:validatorError];
            [given([secondValidator validate]) willReturn:nil];
        });

        it(@"should call all validators", ^{
            [validator validate];
            [MKTVerify(firstValidator) validate];
            [MKTVerify(secondValidator) validate];
        });

        it(@"should return error", ^{
            expect([validator validate]).notTo.beNil();
        });

        it(@"should be error returned by first validator", ^{
            [given([firstValidator validate]) willReturn:validatorError];
            [given([secondValidator validate]) willReturn:nil];
            expect([validator validate]).to.beIdenticalTo(validatorError);
        });

        it(@"should be error returned by second validator", ^{
            [given([firstValidator validate]) willReturn:nil];
            [given([secondValidator validate]) willReturn:validatorError];
            expect([validator validate]).to.beIdenticalTo(validatorError);
        });

    });

    context(@"2+ validation errors", ^{

        __block NSError *firstError;
        __block NSError *secondError;

        beforeEach(^{
            validator.flattenErrors = nil;
            firstError = mock(NSError.class);
            secondError = mock(NSError.class);
            [given([firstValidator validate]) willReturn:firstError];
            [given([secondValidator validate]) willReturn:secondError];
        });

        it(@"should call all validators", ^{
            [validator validate];
            [MKTVerify(firstValidator) validate];
            [MKTVerify(secondValidator) validate];
        });

        it(@"should return error", ^{
            expect([validator validate]).notTo.beNil();
        });

        it(@"should return invalid credentials code", ^{
            expect([[validator validate] code]).to.equal(@(A0ErrorCodeInvalidCredentials));
        });

        it(@"should have errors embedded", ^{
            NSDictionary *errors = [[validator validate] userInfo][A0CredentialsValidatorErrorsKey];
            expect(errors).to.haveCountOf(2);
            expect(errors[@"first"]).to.equal(firstError);
            expect(errors[@"second"]).to.equal(secondError);
        });

        it(@"should call flattenErrors block", ^{
            NSError *flattenedError = mock(NSError.class);
            validator.flattenErrors = ^(NSDictionary *errors) {
                return flattenedError;
            };
            expect([validator validate]).to.equal(flattenedError);
        });

    });
});

SpecEnd
