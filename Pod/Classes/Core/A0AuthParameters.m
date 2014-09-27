//  A0AuthParameters.m
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

#import "A0AuthParameters.h"

NSString * const A0APIScope = @"scope";
NSString * const A0APIDevice = @"device";

NSString * const A0ScopeOpenId = @"openid";
NSString * const A0ScopeOfflineAccess = @"offline_access";
NSString * const A0ScopeProfile = @"profile";

NSString * const A0DelegationAPIType = @"api_type";
NSString * const A0DelegationTarget = @"target";

NSString *ScopeValueFromNSArray(NSArray *scopes) {
    NSArray *array = scopes;
    if (array.count == 0) {
        array = @[A0ScopeOfflineAccess, A0ScopeOpenId];
    }
    return [array componentsJoinedByString:@" "];
}

@interface A0AuthParameters ()
@property (strong, nonatomic) NSMutableDictionary *params;
@end

@implementation A0AuthParameters

- (instancetype)init {
    return [self initWithScopes:@[A0ScopeOpenId, A0ScopeOfflineAccess]];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [self init];
    if (self) {
        _params = [@{} mutableCopy];
        NSArray *scopes = dictionary[A0APIScope];
        if (scopes.count == 0) {
            _params[A0APIScope] = @[A0ScopeOfflineAccess, A0ScopeOpenId];
        }
        if ([scopes containsObject:A0ScopeOfflineAccess]) {
            NSString *deviceName = dictionary[A0APIDevice];
            _params[A0APIDevice] = deviceName ?: [[UIDevice currentDevice] name];
        }
        NSMutableDictionary *params = [dictionary mutableCopy];
        [params removeObjectsForKeys:@[A0APIDevice]];
        [_params addEntriesFromDictionary:params];
    }
    return self;
}

- (instancetype)initWithScopes:(NSArray *)scopes {
    self = [super init];
    if (self) {
        _params = [@{} mutableCopy];
        _params[A0APIScope] = [scopes copy];
        if ([scopes containsObject:A0ScopeOfflineAccess]) {
            _params[A0APIDevice] = [[UIDevice currentDevice] name];
        }
    }
    return self;
}

+ (instancetype)newDefaultParams {
    return [[A0AuthParameters alloc] init];
}

+ (instancetype)newWithDictionary:(NSDictionary *)dictionary {
    return [[A0AuthParameters alloc] initWithDictionary:dictionary];
}

+ (instancetype)newWithScopes:(NSArray *)scopes {
    return [[A0AuthParameters alloc] initWithScopes:scopes];
}

- (NSDictionary *)extraParams {
    return [NSDictionary dictionaryWithDictionary:self.params];
}

- (NSDictionary *)dictionary {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:self.params];
    params[A0APIScope] = ScopeValueFromNSArray(self.params[A0APIScope]);
    return [NSDictionary dictionaryWithDictionary:params];
}

- (NSArray *)scopes {
    return self.params[A0APIScope];
}

- (NSString *)device {
    return self.params[A0APIDevice];
}

- (void)setScopes:(NSArray *)scopes {
    NSAssert(scopes.count > 0, @"Must have at least one scope");
    self.params[A0APIScope] = scopes;
    if ([scopes containsObject:A0ScopeOfflineAccess]) {
        self.params[A0APIDevice] = [[UIDevice currentDevice] name];
    } else {
        self.params[A0APIDevice] = nil;
    }
}

- (NSString *)valueForKey:(NSString *)key {
    return self.params[key];
}

- (void)setValue:(NSString *)value forKey:(NSString *)key {
    if ([key isEqualToString:A0APIScope]) {
        self.params[A0APIScope] = @[value];
    } else {
        self.params[key] = value;
    }
}

- (void)addValuesFromDictionary:(NSDictionary *)dictionary {
    NSArray *scopes = dictionary[A0APIScope];
    if (scopes.count > 0) {
        self.params[A0APIScope] = scopes;
    }
    if ([scopes containsObject:A0ScopeOfflineAccess]) {
        NSString *deviceName = dictionary[A0APIDevice];
        self.params[A0APIDevice] = deviceName ?: [[UIDevice currentDevice] name];
    }
    NSMutableDictionary *params = [dictionary mutableCopy];
    [params removeObjectsForKeys:@[A0APIScope, A0APIDevice]];
    [self.params addEntriesFromDictionary:params];

}

- (void)addValuesFromParameters:(A0AuthParameters *)parameters {
    [self.params addEntriesFromDictionary:parameters.params];
    if (!self.params[A0APIDevice] && [self.params[A0APIScope] containsObject:A0ScopeOfflineAccess]) {
        self.params[A0APIDevice] = [[UIDevice currentDevice] name];
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ values: %@>", NSStringFromClass(self.class), self.params];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    A0AuthParameters *parameters = [[A0AuthParameters alloc] init];
    parameters.params = self.params;
    return parameters;
}

@end
