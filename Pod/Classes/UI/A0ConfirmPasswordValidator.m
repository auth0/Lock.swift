// A0ConfirmPasswordValidator.m
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

#import "A0ConfirmPasswordValidator.h"
#import "A0Errors.h"

NSString * const A0ConfirmPasswordValidatorIdentifer = @"A0ConfirmPasswordValidatorIdentifer";

@interface A0ConfirmPasswordValidator ()
@property (weak, nonatomic) UITextField *field;
@property (weak, nonatomic) UITextField *passwordField;
@end

@implementation A0ConfirmPasswordValidator

@synthesize identifier = _identifier;

- (instancetype)initWithField:(UITextField *)field passwordField:(UITextField *)passwordField {
    NSAssert(field != nil && passwordField != nil, @"Both confirm and password field shoulb be non-nil");
    self = [super init];
    if (self) {
        _identifier = @"Confirm Password";
        _field = field;
        _passwordField = passwordField;
    }
    return self;
}

- (NSError *)validate {
    BOOL valid = self.field.text.length > 0 && [self.field.text isEqualToString:self.passwordField.text];
    return valid ? nil : [A0Errors invalidRepeatPassword];
}
@end
