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
#import "A0DeviceNameProvider.h"

NSString * const A0ParameterScope = @"scope";
NSString * const A0ParameterDevice = @"device";
NSString * const A0ParameterProtocol = @"protocol";
NSString * const A0ParameterState = @"state";
NSString * const A0ParameterNonce = @"nonce";
NSString * const A0ParameterOfflineMode = @"offline_mode";
NSString * const A0ParameterConnectionScopes = @"connection_scopes";
NSString * const A0ParameterAccessToken = @"access_token";
NSString * const A0ParameterMainAccessToken = @"main_access_token";
NSString * const A0ParameterConnection = @"connection";

NSString * const A0ScopeOpenId = @"openid";
NSString * const A0ScopeOfflineAccess = @"offline_access";
NSString * const A0ScopeProfile = @"openid profile";

NSString * const A0ParameterAPIType = @"api_type";
NSString * const A0ParameterTarget = @"target";

NSString *ScopeValueFromNSArray(NSArray *scopes) {
    NSArray *array = scopes;
    if (array.count == 0) {
        array = @[A0ScopeOfflineAccess, A0ScopeOpenId];
    }
    return [array componentsJoinedByString:@" "];
}

NSDictionary *ConnectionScopeValuesFromNSDictionary(NSDictionary *scopes) {
    NSMutableDictionary *values = [@{} mutableCopy];
    [scopes enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSArray *scopeArray, BOOL *stop) {
        if (scopeArray.count > 0) {
            values[key] = [scopeArray componentsJoinedByString:@","];
        }
    }];
    return values;
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
        NSArray *scopes = dictionary[A0ParameterScope];
        if (scopes.count == 0) {
            _params[A0ParameterScope] = @[A0ScopeOpenId, A0ScopeOfflineAccess];
        } else {
            _params[A0ParameterScope] = scopes;
        }
        if ([_params[A0ParameterScope] containsObject:A0ScopeOfflineAccess]) {
            NSString *deviceName = dictionary[A0ParameterDevice];
            _params[A0ParameterDevice] = deviceName ?: [A0DeviceNameProvider deviceName];
        }
        NSMutableDictionary *params = [dictionary mutableCopy];
        [params removeObjectsForKeys:@[A0ParameterDevice, A0ParameterScope]];
        [_params addEntriesFromDictionary:params];
    }
    return self;
}

- (instancetype)initWithScopes:(NSArray *)scopes {
    self = [super init];
    if (self) {
        _params = [@{} mutableCopy];
        _params[A0ParameterScope] = [scopes copy];
        if ([scopes containsObject:A0ScopeOfflineAccess]) {
            _params[A0ParameterDevice] = [A0DeviceNameProvider deviceName];
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

- (NSDictionary *)asAPIPayload {
    NSMutableDictionary *params = self.params.mutableCopy;
    [params removeObjectsForKeys:@[A0ParameterScope, A0ParameterConnectionScopes]];
    NSMutableDictionary *payload = [NSMutableDictionary dictionaryWithDictionary:params];
    payload[A0ParameterScope] = ScopeValueFromNSArray(self.params[A0ParameterScope]);
    NSDictionary *connectionScopes = self.params[A0ParameterConnectionScopes];
    NSArray *connectionScope = connectionScopes[self.params[A0ParameterConnection]];
    if (connectionScope) {
        payload[@"connection_scope"] = [connectionScope componentsJoinedByString:@","];
    }
    return payload;
}

- (NSArray *)scopes {
    return self.params[A0ParameterScope];
}

- (NSString *)device {
    return self.params[A0ParameterDevice];
}

- (NSString *)protocol {
    return self.params[A0ParameterProtocol];
}

- (NSString *)state {
    return self.params[A0ParameterState];
}

- (NSString *)nonce {
    return self.params[A0ParameterNonce];
}

- (NSString *)offlineMode {
    return self.params[A0ParameterOfflineMode];
}

- (NSDictionary *)connectionScopes {
    return self.params[A0ParameterConnectionScopes];
}

- (NSString *)accessToken {
    return self.params[A0ParameterAccessToken];
}

- (void)setScopes:(NSArray *)scopes {
    NSAssert(scopes.count > 0, @"Must have at least one scope");
    self.params[A0ParameterScope] = [scopes copy];
    if ([scopes containsObject:A0ScopeOfflineAccess]) {
        self.params[A0ParameterDevice] = [A0DeviceNameProvider deviceName];
    } else {
        [self.params removeObjectForKey:A0ParameterDevice];
    }
}

- (void)setDevice:(NSString *)device {
    NSAssert([self.scopes containsObject:A0ScopeOfflineAccess], @"Must have offline access to set device name");
    self[A0ParameterDevice] = device;
}

- (void)setProtocol:(NSString *)protocol {
    self[A0ParameterProtocol] = protocol;
}

- (void)setState:(NSString *)state {
    self[A0ParameterState] = state;
}

- (void)setNonce:(NSString *)nonce {
    self[A0ParameterNonce] = nonce;
}

- (void)setConnectionScopes:(NSDictionary *)connectionScopes {
    if (connectionScopes.count > 0) {
        self.params[A0ParameterConnectionScopes] = connectionScopes.copy;
    } else {
        [self.params removeObjectForKey:A0ParameterConnectionScopes];
    }
}

- (void)setAccessToken:(NSString *)accessToken {
    self[A0ParameterAccessToken] = accessToken;
}

- (void)addValuesFromDictionary:(NSDictionary *)dictionary {
    NSArray *scopes = dictionary[A0ParameterScope];
    if (scopes.count > 0) {
        self.params[A0ParameterScope] = scopes;
    }
    if ([scopes containsObject:A0ScopeOfflineAccess]) {
        NSString *deviceName = dictionary[A0ParameterDevice];
        self.params[A0ParameterDevice] = deviceName ?: [A0DeviceNameProvider deviceName];
    }
    NSMutableDictionary *params = [dictionary mutableCopy];
    [params removeObjectsForKeys:@[A0ParameterScope, A0ParameterDevice]];
    [self.params addEntriesFromDictionary:params];

}

- (void)addValuesFromParameters:(A0AuthParameters *)parameters {
    [self.params addEntriesFromDictionary:parameters.params];
    if (!self.params[A0ParameterDevice] && [self.params[A0ParameterScope] containsObject:A0ScopeOfflineAccess]) {
        self.params[A0ParameterDevice] = [A0DeviceNameProvider deviceName];
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ values: %@>", NSStringFromClass(self.class), self.params];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    A0AuthParameters *parameters = [[A0AuthParameters alloc] init];
    parameters.params = [NSMutableDictionary dictionaryWithDictionary:self.params];
    return parameters;
}

#pragma mark - Custom Keyed Subscript

- (id)objectForKeyedSubscript:(NSString *)key {
    return self.params[key];
}

- (void)setObject:(id)obj forKeyedSubscript:(NSString *)key {
    NSAssert(![key isEqualToString:A0ParameterConnectionScopes] && ![key isEqualToString:A0ParameterScope], @"Set scope and connection_scopes using accessors");
    NSAssert(key != nil, @"Must supply a valid non-nil key");
    if (obj) {
        self.params[key] = obj;
    } else {
        [self.params removeObjectForKey:key];
    }
}

@end

#pragma mark - Deprecated methods

@implementation A0AuthParameters (Deprecated)

- (NSString *)valueForKey:(NSString *)key {
    return self[key];
}

- (void)setValue:(NSString *)value forKey:(NSString *)key {
    self[key] = value;
}

@end

