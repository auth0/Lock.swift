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

#import <Quick/Quick.h>
#import <Nimble/Nimble.h>
#import "A0CredentialsValidator.h"
#import "A0Errors.h"

@interface MockValidator : NSObject<A0FieldValidator>
@property (strong, nonatomic) NSError *error;
@property (strong, nonatomic) NSString *identifier;

- (instancetype)initWithIdentifier:(NSString *)identifier;
@end

@implementation MockValidator

- (instancetype)initWithIdentifier:(NSString *)identifier {
    self = [super init];
    if (self) {
        _identifier = identifier;
    }
    return self;
}

- (NSError *)validate {
    return self.error;
}

@end

QuickSpecBegin(A0CredentialsValidatorSpec)

describe(@"A0CredentialsValidator", ^{

    __block A0CredentialsValidator *validator;
    __block MockValidator *firstValidator;
    __block MockValidator *secondValidator;

    beforeEach(^{
        firstValidator = [[MockValidator alloc] initWithIdentifier:@"first"];
        secondValidator = [[MockValidator alloc] initWithIdentifier:@"second"];
        validator = [[A0CredentialsValidator alloc] initWithValidators:@[firstValidator, secondValidator]];
    });

    it(@"should fail with nil validator list", ^{
        expectAction(^{
            validator = [[A0CredentialsValidator alloc] initWithValidators:nil];
        }).to(raiseException());
    });

    it(@"should fail with empty validator list", ^{
        expectAction(^{
            validator = [[A0CredentialsValidator alloc] initWithValidators:@[]];
        }).to(raiseException());
    });

    context(@"successful validation", ^{

        it(@"should call all validators", ^{
            [validator validate];
        });

        it(@"should return no error", ^{
            expect([validator validate]).to(beNil());
        });

    });

    context(@"one failed validation", ^{

        __block NSError *validatorError;

        beforeEach(^{
            validatorError = [NSError errorWithDomain:@"com.auth0" code:-999999 userInfo:nil];
            firstValidator.error = validatorError;
        });

        it(@"should call all validators", ^{
            [validator validate];
        });

        it(@"should return error", ^{
            expect([validator validate]).notTo(beNil());
        });

        it(@"should be error returned by first validator", ^{
            expect([validator validate]).to(beIdenticalTo(validatorError));
        });

        it(@"should be error returned by second validator", ^{
            firstValidator.error = nil;
            secondValidator.error = validatorError;
            expect([validator validate]).to(beIdenticalTo(validatorError));
        });

    });

    context(@"2+ validation errors", ^{

        __block NSError *firstError;
        __block NSError *secondError;

        beforeEach(^{
            validator.flattenErrors = nil;
            firstError = [NSError errorWithDomain:@"com.auth0" code:-999999 userInfo:nil];
            secondError = [NSError errorWithDomain:@"com.auth0" code:-999999 userInfo:nil];
            firstValidator.error = firstError;
            secondValidator.error = secondError;
        });

        it(@"should call all validators", ^{
            [validator validate];
        });

        it(@"should return error", ^{
            expect([validator validate]).notTo(beNil());
        });

        it(@"should return invalid credentials code", ^{
            expect(@([[validator validate] code])).to(equal(@(A0ErrorCodeInvalidCredentials)));
        });

        it(@"should have errors embedded", ^{
            NSDictionary *errors = [[validator validate] userInfo][A0CredentialsValidatorErrorsKey];
            expect(errors).to(haveCount(@2));
            expect(errors[@"first"]).to(equal(firstError));
            expect(errors[@"second"]).to(equal(secondError));
        });

        it(@"should call flattenErrors block", ^{
            NSError *flattenedError = [NSError errorWithDomain:@"com.auth0" code:-999999 userInfo:nil];
            validator.flattenErrors = ^(NSDictionary *errors) {
                return flattenedError;
            };
            expect([validator validate]).to(equal(flattenedError));
        });

    });
});

QuickSpecEnd
