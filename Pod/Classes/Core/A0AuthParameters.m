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

NSArray *ScopeArrayFromNSString(NSString *scope) {
    NSString *trimmedScope = [scope stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (trimmedScope.length == 0) {
        return @[];
    }
    return [trimmedScope componentsSeparatedByString:@" "];
}

NSString *ScopeValueFromNSArray(NSArray *scopes) {
    NSArray *array = scopes;
    if (array.count == 0) {
        array = @[A0ScopeOfflineAccess, A0ScopeOpenId];
    }
    return [array componentsJoinedByString:@" "];
}

@implementation A0AuthParameters

- (instancetype)init {
    return [self initWithScopes:@[A0ScopeOpenId, A0ScopeOfflineAccess]];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [self init];
    if (self) {
        NSArray *scopes = ScopeArrayFromNSString(dictionary[A0APIScope]);
        if (scopes.count > 0) {
            _scopes = scopes;
        }
        if ([scopes containsObject:A0ScopeOfflineAccess]) {
            NSString *deviceName = dictionary[A0APIDevice];
            _device = deviceName ?: [[UIDevice currentDevice] name];
        }
        NSMutableDictionary *params = [dictionary mutableCopy];
        [params removeObjectsForKeys:@[A0APIScope, A0APIDevice]];
        _extraParams = [NSDictionary dictionaryWithDictionary:params];
    }
    return self;
}

- (instancetype)initWithScopes:(NSArray *)scopes {
    self = [super init];
    if (self) {
        _scopes = [scopes copy];
        if ([scopes containsObject:A0ScopeOfflineAccess]) {
            _device = [[UIDevice currentDevice] name];
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

- (NSDictionary *)dictionary {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:self.extraParams];
    params[A0APIScope] = ScopeValueFromNSArray(self.scopes);
    if (self.device && [self.scopes containsObject:A0ScopeOfflineAccess]) {
        params[A0APIDevice] = self.device;
    }
    return [NSDictionary dictionaryWithDictionary:params];
}

- (void)addValuesFromDictionary:(NSDictionary *)dictionary {
    NSArray *scopes = ScopeArrayFromNSString(dictionary[A0APIScope]);
    if (scopes.count > 0) {
        self.scopes = scopes;
    }
    if ([scopes containsObject:A0ScopeOfflineAccess]) {
        NSString *deviceName = dictionary[A0APIDevice];
        self.device = deviceName ?: [[UIDevice currentDevice] name];
    }
    NSMutableDictionary *params = [dictionary mutableCopy];
    [params removeObjectsForKeys:@[A0APIScope, A0APIDevice]];
    NSMutableDictionary *extraParams = self.extraParams.mutableCopy;
    [extraParams addEntriesFromDictionary:params];
    self.extraParams = [NSDictionary dictionaryWithDictionary:extraParams];

}

- (void)addValuesFromParameters:(A0AuthParameters *)parameters {
    if (parameters.scopes) {
        self.scopes = parameters.scopes;
    }
    if (parameters.device) {
        self.device = parameters.device;
    }
    if (parameters.extraParams.count > 0) {
        NSMutableDictionary *params = self.extraParams.mutableCopy;
        [params addEntriesFromDictionary:parameters.extraParams];
        self.extraParams = [NSDictionary dictionaryWithDictionary:params];
    }
}
@end
