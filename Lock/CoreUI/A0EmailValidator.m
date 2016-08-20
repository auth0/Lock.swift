// A0EmailValidator.m
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

#import "A0EmailValidator.h"
#import "A0Errors.h"

NSString * const A0EmailValidatorIdentifer = @"A0EmailValidatorIdentifer";

@interface A0EmailValidator ()
@property (copy, nonatomic) A0EmailValidatorSourceBlock emailSource;
@property (strong, nonatomic) NSPredicate *emailPredicate;
@end

@implementation A0EmailValidator

@synthesize identifier = _identifier;

- (instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return [self initWithSource:^NSString * _Nullable {
        return nil;
    }];
}

- (instancetype)initWithSource:(A0EmailValidatorSourceBlock)source {
    self = [super init];
    if (self) {
        _emailSource = [source copy];
        NSString *emailRegex = @"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?";
        _emailPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
        _identifier = A0EmailValidatorIdentifer;
    }
    return self;
}

- (instancetype)initWithField:(UITextField *)field {
    return [self initWithSource:^NSString * _Nullable{
        return field.text;
    }];
}

- (NSError *)validate {
    NSString *trimmedEmail = [self.emailSource() stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    BOOL valid = [self.emailPredicate evaluateWithObject:trimmedEmail];
    return valid ? nil : [A0Errors invalidEmail];
}

@end
