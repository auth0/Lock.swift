//  NSDictionary+A0QueryParameters.m
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

#import "NSDictionary+A0QueryParameters.h"

@interface A0QueryParameter : NSObject

@property (copy, nonatomic) NSString *key;
@property (copy, nonatomic) NSString *value;

- (instancetype)initWithQueryString:(NSString *)queryString;
- (NSString *)stringValue;

@end

@implementation NSDictionary (A0QueryParameters)

+ (NSDictionary *)fromQueryString:(NSString *)queryString {
    if (queryString.length == 0) {
        return @{};
    }
    NSMutableDictionary *dict = [@{} mutableCopy];
    NSArray *parts = [queryString componentsSeparatedByString:@"&"];
    [parts enumerateObjectsUsingBlock:^(NSString *part, NSUInteger idx, BOOL *stop) {
        A0QueryParameter *param = [[A0QueryParameter alloc] initWithQueryString:part];
        if (param.value) {
            dict[param.key] = [param.value stringByRemovingPercentEncoding];
        }
    }];
    return [NSDictionary dictionaryWithDictionary:dict];
}

- (NSString *)queryString {
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:self.count];
    [self enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
        A0QueryParameter *parameter = [[A0QueryParameter alloc] init];
        parameter.key = key;
        parameter.value = obj;
        [array addObject:parameter.stringValue];
    }];
    return [array componentsJoinedByString:@"&"];
}

@end

@implementation A0QueryParameter

- (instancetype)initWithQueryString:(NSString *)queryString {
    self = [super init];
    if (self) {
        NSArray *parts = [queryString componentsSeparatedByString:@"="];
        NSAssert(parts.count > 1, @"Must have 2 parts");
        _key = parts[0];
        if (parts.count > 1) {
            _value = parts[1];
        }
    }
    return self;
}

- (NSString *)stringValue {
    return [NSString stringWithFormat:@"%@=%@", self.key, self.value];
}

@end