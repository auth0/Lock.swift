// A0UsernameValidator.m
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

#import "A0UsernameValidator.h"
#import "A0Errors.h"

NSString * const A0UsernameValidatorIdentifier = @"A0UsernameValidatorIdentifier";

@interface A0UsernameValidator ()
@property (weak, nonatomic) UITextField *field;
@property (strong, nonatomic) NSCharacterSet *trimSet;
@property (strong, nonatomic) NSCharacterSet *invalidSet;
@property (assign, nonatomic) NSInteger minimum;
@property (assign, nonatomic) NSInteger maximum;
@end

@implementation A0UsernameValidator

@synthesize identifier = _identifier;

- (instancetype)initWithField:(UITextField *)field invalidSet:(NSCharacterSet *)invalidSet minimum:(NSInteger)minimum maximum:(NSInteger)maximum {
    NSAssert(field != nil, @"Must provide a UITextField instance");
    self = [super init];
    if (self) {
        _identifier = A0UsernameValidatorIdentifier;
        _field = field;
        _trimSet = [NSCharacterSet whitespaceCharacterSet];
        _invalidSet = invalidSet;
        _minimum = minimum;
        _maximum = maximum;
    }
    return self;
}

- (instancetype)initWithField:(UITextField *)field {
    NSAssert(field != nil, @"Must provide a UITextField instance");
    self = [super init];
    if (self) {
        _identifier = A0UsernameValidatorIdentifier;
        _field = field;
        _trimSet = [NSCharacterSet whitespaceCharacterSet];
        NSMutableCharacterSet *set = [[NSCharacterSet alphanumericCharacterSet] mutableCopy];
        [set addCharactersInString:@"_"];
        _invalidSet = [set invertedSet];
        _minimum = 1;
        _maximum = 15;
    }
    return self;
}

- (NSError *)validate {
    NSString *trimmedText = [self.field.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSInteger length = trimmedText.length;
    BOOL valid = length >= self.minimum && length <= self.maximum && [self text:trimmedText hasNoCharacterFromSet:self.invalidSet];
    return valid ? nil : [A0Errors invalidUsername];
}

- (BOOL)text:(NSString *)text hasNoCharacterFromSet:(NSCharacterSet *)set {
    return set == nil || [text rangeOfCharacterFromSet:set].location == NSNotFound;
}

+ (instancetype)databaseValidatorForField:(UITextField *)field withMinimum:(NSInteger)minimum andMaximum:(NSInteger)maximum {
    NSMutableCharacterSet *set = [[NSCharacterSet alphanumericCharacterSet] mutableCopy];
    [set addCharactersInString:@"_"];
    NSCharacterSet *invalidSet = [set invertedSet];
    return [[A0UsernameValidator alloc] initWithField:field invalidSet:invalidSet minimum:minimum maximum:maximum];
}

+ (instancetype)nonEmtpyValidatorForField:(UITextField *)field {
    return [[A0UsernameValidator alloc] initWithField:field invalidSet:nil minimum:1 maximum:NSIntegerMax];
}
@end
