// A0CredentialsValidator.m
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

#import "A0CredentialsValidator.h"
#import "NSError+A0APIError.h"
#import "A0Errors.h"
#import "Constants.h"

NSString * const A0CredentialsValidatorErrorsKey = @"A0CredentialsValidatorErrorsKey";

@interface A0CredentialsValidator ()
@property (strong, nonatomic) NSArray *validators;
@end

@implementation A0CredentialsValidator

@synthesize identifier = _identifier;

- (instancetype)initWithValidators:(NSArray *)validators {
    NSAssert(validators.count > 0, @"Must have at least 1 validator");
    self = [super init];
    if (self) {
        _validators = [validators copy];
    }
    return self;
}

- (NSError *)validate {
    NSMutableDictionary *errors = [@{} mutableCopy];
    [self.validators enumerateObjectsUsingBlock:^(id<A0FieldValidator> validator, NSUInteger idx, BOOL *stop) {
        NSError *error = [validator validate];
        if (error) {
            errors[validator.identifier] = error;
        }
    }];

    if (errors.count == 0) {
        return nil;
    }

    NSError *error;
    if (errors.count == 1) {
        error = errors.allValues.firstObject;
    } else if (self.flattenErrors) {
        error = self.flattenErrors(errors);
    } else  {
        error = [NSError errorWithCode:A0ErrorCodeInvalidCredentials
                              userInfo:@{
                                         NSLocalizedDescriptionKey: A0LocalizedString(@"Invalid credentials"),
                                         NSLocalizedFailureReasonErrorKey: A0LocalizedString(@"The credentials you entered are invalid. Please try again"),
                                         A0CredentialsValidatorErrorsKey: errors,
                                         }];
    }
    return error;
}

@end
