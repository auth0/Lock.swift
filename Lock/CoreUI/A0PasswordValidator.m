// A0PasswordValidator.m
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

#import "A0PasswordValidator.h"
#import "A0Errors.h"

NSString * const A0PasswordValidatorIdentifer = @"A0PasswordValidatorIdentifer";

@interface A0PasswordValidator ()

@property (weak, nonatomic) UITextField *field;

@end

@implementation A0PasswordValidator

@synthesize identifier = _identifier;

- (instancetype)initWithField:(UITextField *)field {
    NSAssert(field != nil, @"Must provide a UITextField instance");
    self = [super init];
    if (self) {
        _identifier = A0PasswordValidatorIdentifer;
        _field = field;
    }
    return self;
}

- (NSError *)validate {
    BOOL valid = self.field.text.length > 0;
    return valid ? nil : [A0Errors invalidPassword];
}

@end
