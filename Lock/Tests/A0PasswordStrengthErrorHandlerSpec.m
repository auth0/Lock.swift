// A0PasswordStrengthErrorHandlerSpec.m
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

#import "A0LockTest.h"
#import "A0PasswordStrengthErrorHandler.h"
#import "A0PasswordStrengthErrorBuilder.h"

static NSString *LenghtError = @"At least 10 characters in length.";
static NSString *IdenticalCharacterError = @"No more than 2 identical characters in a row (e.g., \"aaa\" not allowed).";
static NSString *CharacterSetError = @"Contain at least 3 of the following 4 types of characters:";
static NSString *CharacterSetAllError = @"Should contain:";
static NSString *LowerCaseSet = @"lower case letters (a-z)";
static NSString *UpperCaseSet = @"upper case letters (A-Z)";
static NSString *NumberSet = @"numbers (i.e. 0-9)";
static NSString *SpecialCharacterSet = @"special characters (e.g. !@#$%^&*)";

SpecBegin(A0PasswordStrengthErrorHandler)

__block A0PasswordStrengthErrorHandler *handler;

A0PasswordStrengthErrorBuilder *builder = [[A0PasswordStrengthErrorBuilder alloc] init];

beforeEach(^{
    handler = [[A0PasswordStrengthErrorHandler alloc] init];
});

it(@"should return message for any password error", ^{
    NSError *error = createError([builder allErrors]);
    NSString *message = [handler localizedMessageFromError:error];
    expect(message).toNot.beNil();
    expect(message).to.startWith(@"Password failed to meet the requirements: ");
    expect(message).to.contain(LenghtError);
    expect(message).to.contain(IdenticalCharacterError);
    expect(message).to.contain(CharacterSetError);
});

it(@"should return message for length error", ^{
    NSError *error = createError([builder errorWithFailingRules:@[@"lengthAtLeast"]]);
    expect([handler localizedMessageFromError:error]).to.contain(LenghtError);
});

it(@"should return message for identical characters error", ^{
    NSError *error = createError([builder errorWithFailingRules:@[@"identicalChars"]]);
    expect([handler localizedMessageFromError:error]).to.contain(IdenticalCharacterError);
});

it(@"should return message for contains at least character set error", ^{
    NSError *error = createError([builder errorWithFailingRules:@[@"containsAtLeast"]]);
    NSString *message = [handler localizedMessageFromError:error];
    expect(message).to.contain(CharacterSetError);
    expect(message).to.contain(LowerCaseSet);
    expect(message).to.contain(UpperCaseSet);
    expect(message).to.contain(NumberSet);
    expect(message).to.contain(SpecialCharacterSet);
});

it(@"should return message for character should contain set error", ^{
    NSError *error = createError([builder errorWithFailingRules:@[@"shouldContain"]]);
    NSString *message = [handler localizedMessageFromError:error];
    expect(message).to.contain(CharacterSetAllError);
    expect(message).to.contain(LowerCaseSet);
    expect(message).to.contain(UpperCaseSet);
    expect(message).to.contain(NumberSet);
    expect(message).to.contain(SpecialCharacterSet);
});

SpecEnd