// A0BasicValidator.m
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

#import "A0BasicValidator.h"

@interface A0BasicValidator ()

@property (strong, nonatomic) NSPredicate *emailPredicate;
@property (assign, nonatomic) BOOL usesEmail;

@end

@implementation A0BasicValidator

- (instancetype)initWithUsesEmail:(BOOL)usesEmail {
    self = [super init];
    if (self) {
        NSString *emailRegex = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
        _emailPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
        _usesEmail = usesEmail;
    }
    return self;
}

- (BOOL)validateUsername:(NSString *)username {
    if (self.usesEmail) {
        return [self.emailPredicate evaluateWithObject:username];
    } else {
        return username.length > 0;
    }
}

- (BOOL)validatePassword:(NSString *)password {
    return password.length > 0;
}

@end
