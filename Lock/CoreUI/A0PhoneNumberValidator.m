// A0PhoneNumberValidator.m
//
// Copyright (c) 2015 Auth0 (http://auth0.com)
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

#import "A0PhoneNumberValidator.h"
#import "A0Errors.h"

NSString * const A0PhoneNumberValidatorIdentifer = @"A0PhoneNumberValidatorIdentifer";

@interface A0PhoneNumberValidator ()
@property (copy, nonatomic) A0PhoneNumberValidatorSourceBlock source;
@end

@implementation A0PhoneNumberValidator

@synthesize identifier = _identifier;

- (instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return [self initWithSource:^NSString * _Nullable {
        return nil;
    }];
}

- (instancetype)initWithSource:(A0PhoneNumberValidatorSourceBlock)source {
    self = [super init];
    if (self) {
        _source = [source copy];
        _identifier = A0PhoneNumberValidatorIdentifer;
    }
    return self;
}

- (NSError *)validate {
    NSString *trimmedText = [self.source() stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    BOOL valid = trimmedText.length > 0;
    return valid ? nil : [A0Errors invalidPhoneNumber];
}

@end
