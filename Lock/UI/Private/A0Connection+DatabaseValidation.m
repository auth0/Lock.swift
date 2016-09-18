// A0Connection+DatabaseValidation.m
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

#import "A0Connection+DatabaseValidation.h"

@implementation A0Connection (DatabaseValidation)

- (A0UsernameValidationInfo)usernameValidation {
    A0UsernameValidationInfo info;
    info.min = 1;
    info.max = 15;
    NSDictionary *validation = self.values[@"validation"][@"username"];
    info.min = MAX(1, [validation[@"min"] integerValue]);
    info.max = [validation[@"max"] integerValue] <= 0 ? 15 : [validation[@"max"] integerValue];
    if (info.min > info.max) {
        info.min = 1;
    }
    return info;
}

@end
