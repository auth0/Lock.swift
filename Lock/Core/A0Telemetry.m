// A0Telemetry.m
//
// Copyright (c) 2016 Auth0 (http://auth0.com)
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

#import "A0Telemetry.h"

@interface A0Telemetry ()
@property (strong, nonatomic) NSMutableDictionary *values;
@end

@implementation A0Telemetry

- (instancetype)init {
    NSString *name = [A0Telemetry libraryName];
    NSString *version = [A0Telemetry libraryVersion];
    return [self initWithName:name version:version extra:nil];
}

- (instancetype)initWithName:(NSString *)name version:(NSString *)version extra:(NSDictionary *)extra {
    self = [super init];
    if (self) {
        _values = [@{
                    @"name": name,
                    @"version": version,
                    } mutableCopy];
        if (extra) {
            [_values addEntriesFromDictionary:extra];
        }
    }
    return self;
}

- (NSString *)base64Value {
    NSData *data = [NSJSONSerialization dataWithJSONObject:self.values options:0 error:nil];
    NSString *base64 = [data base64EncodedStringWithOptions:0];
    base64 = [base64 stringByReplacingOccurrencesOfString:@"=" withString:@""];
    base64 = [base64 stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    base64 = [base64 stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
    return base64;
}

+ (BOOL)telemetryEnabled {
#ifndef A0CurrentLockVersion
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    return [bundle.bundleIdentifier isEqualToString:@"com.auth0.Lock"];
#else
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSNumber *optOut = info[@"Auth0SendSDKInfo"];
    return optOut ? optOut.boolValue : YES;
#endif
}

+ (NSString *)libraryVersion {
#ifdef A0CurrentLockVersion
    NSString *version = A0CurrentLockVersion;
#else
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSString *version = [bundle infoDictionary][@"CFBundleShortVersionString"] ?: @"0.0.0";
#endif
    return version;
}

+ (NSString *)libraryName {
    return [@"Lock." stringByAppendingString:[self platform]];
}

+ (NSString *)platform {
#if TARGET_OS_IOS
    return @"iOS";
#elif TARGET_OS_TV
    return @"tvOS";
#elif TARGET_OS_WATCH
    return @"watchOS";
#elif TARGET_OS_SIMULATOR
    return @"AppleSimulator";
#elif TARGET_OS_MAC
    return @"OSX";
#else
    return @"unknown";
#endif
}

@end
