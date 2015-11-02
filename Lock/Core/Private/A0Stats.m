// A0Stats.m
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

#import "A0Stats.h"

NSString * const A0ClientInfoHeaderName = @"Auth0-Client";
NSString * const A0ClientInfoQueryParamName = @"auth0Client";

@implementation A0Stats

+ (BOOL)shouldSendAuth0ClientHeader {
#ifndef A0CurrentLockVersion
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    return [bundle.bundleIdentifier isEqualToString:@"com.auth0.Lock"];
#else
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSNumber *optOut = info[@"Auth0SendSDKInfo"];
    return optOut ? optOut.boolValue : YES;
#endif
}

+ (NSString *)stringForAuth0ClientHeader {
    static NSString *base64;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#ifdef A0CurrentLockVersion
        NSString *version = A0CurrentLockVersion;
#else
        NSBundle *bundle = [NSBundle bundleForClass:self.class];
        NSString *version = [bundle infoDictionary][@"CFBundleShortVersionString"] ?: @"0.0.0";
#endif

        NSDictionary *value = @{
                                @"name": @"Lock.iOS-OSX",
                                @"version": version,
                                };
        NSData *data = [NSJSONSerialization dataWithJSONObject:value options:0 error:nil];
        base64 = [data base64EncodedStringWithOptions:0];
        base64 = [base64 stringByReplacingOccurrencesOfString:@"=" withString:@""];
        base64 = [base64 stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
        base64 = [base64 stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
    });
    return base64;
}

@end
