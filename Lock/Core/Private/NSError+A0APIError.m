// NSError+A0APIError.m
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

#import "NSError+A0APIError.h"

NSString * const A0JSONResponseSerializerErrorDataKey = @"A0JSONResponseSerializerErrorDataKey";
NSString * const A0ErrorDomain = @"com.auth0";

@implementation NSError (A0APIError)

- (NSDictionary *)a0_payload {
    return self.userInfo[A0JSONResponseSerializerErrorDataKey];
}

- (NSString *)a0_code {
    return [self a0_payload][@"code"];
}

- (NSString *)a0_error {
    return [self a0_payload][@"error"];
}

- (NSString *)a0_errorDescription {
    return [self a0_payload][@"error_description"];
}

- (NSError *)a0_errorWithPayload:(NSDictionary *)payload {
    NSMutableDictionary *userInfo = [self.userInfo mutableCopy];
    userInfo[A0JSONResponseSerializerErrorDataKey] = payload;
    return [NSError errorWithDomain:self.domain code:self.code userInfo:[NSDictionary dictionaryWithDictionary:userInfo]];
}

- (BOOL)a0_auth0ErrorWithCode:(A0ErrorCode)code {
    return [self.domain isEqualToString:A0ErrorDomain] && self.code == code;
}

- (BOOL)a0_cancelledSocialAuthenticationError {
    return self.code == A0ErrorCodeFacebookCancelled
    || self.code == A0ErrorCodeTwitterCancelled
    || self.code == A0ErrorCodeAuth0Cancelled
    || self.code == A0ErrorCodeGooglePlusCancelled;
}

+ (NSError *)errorWithCode:(NSInteger)code description:(NSString *)description payload:(NSDictionary *)payload {
    return [self errorWithCode:code
                      userInfo:@{
                                 NSLocalizedDescriptionKey: description,
                                 A0JSONResponseSerializerErrorDataKey: payload ?: @{},
                                 }];
}

+ (NSError *)errorWithCode:(NSInteger)code userInfo:(NSDictionary *)userInfo {
    NSError *error = [NSError errorWithDomain:A0ErrorDomain
                                         code:code
                                     userInfo:userInfo];
    return error;
}

+ (NSError *)errorWithCode:(NSInteger)code description:(NSString *)description failureReason:(NSString *)failureReason {
    return [self errorWithCode:code
                      userInfo:@{
                                 NSLocalizedDescriptionKey: description,
                                 NSLocalizedFailureReasonErrorKey: failureReason,
                                 }];
}

@end
