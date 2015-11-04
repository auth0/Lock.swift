// A0PasswordStrengthErrorBuilder.m
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

#import "A0PasswordStrengthErrorBuilder.h"

@implementation A0PasswordStrengthErrorBuilder

- (NSDictionary *)allErrors {
    NSString *path = [[NSBundle bundleForClass:self.class] pathForResource:@"PasswordStrengthError" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    return [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
}

- (NSDictionary *)errorWithFailingRules:(NSArray *)rules {
    NSMutableDictionary *error = [[self allErrors] mutableCopy];
    NSMutableDictionary *description = [error[@"description"] mutableCopy];
    NSMutableArray *array = [@[] mutableCopy];
    [description[@"rules"] enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableDictionary *dict = [item mutableCopy];
        NSString *code = item[@"code"];
        dict[@"verified"] = @(![rules containsObject:code]);
        [array addObject:dict];
    }];
    description[@"rules"] = array;
    error[@"description"] = description;
    return error;
}

@end
