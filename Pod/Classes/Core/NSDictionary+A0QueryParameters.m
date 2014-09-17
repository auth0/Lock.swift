//
//  NSDictionary+A0QueryParameters.m
//  Pods
//
//  Created by Hernan Zalazar on 9/17/14.
//
//

#import "NSDictionary+A0QueryParameters.h"

@interface A0QueryParameter : NSObject

@property (copy, nonatomic) NSString *key;
@property (copy, nonatomic) NSString *value;

- (instancetype)initWithQueryString:(NSString *)queryString;
- (NSString *)stringValue;

@end

@implementation NSDictionary (A0QueryParameters)

+ (NSDictionary *)fromQueryString:(NSString *)queryString {
    NSMutableDictionary *dict = [@{} mutableCopy];
    NSArray *parts = [queryString componentsSeparatedByString:@"&"];
    [parts enumerateObjectsUsingBlock:^(NSString *part, NSUInteger idx, BOOL *stop) {
        A0QueryParameter *param = [[A0QueryParameter alloc] initWithQueryString:part];
        if (param.value) {
            dict[param.key] = param.value;
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