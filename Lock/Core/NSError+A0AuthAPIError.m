// NSError+A0AuthAPIError.m
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

#import "NSError+A0AuthAPIError.h"

NSString * const A0JSONResponseSerializerErrorDataKey = @"com.auth0.authentication.error";

@implementation NSError (A0AuthAPIError)

- (NSDictionary *)a0_payload {
    return self.userInfo[A0JSONResponseSerializerErrorDataKey];
}

- (NSString *)a0_error {
    return [self a0_payload][@"error"] ?: [self a0_payload][@"code"];
}

- (NSString *)a0_errorDescription {
    return [self a0_payload][@"error_description"];
}

- (BOOL)a0_mfaRequired {
    return [[self a0_error] isEqualToString:@"a0.mfa_required"];
}

@end
