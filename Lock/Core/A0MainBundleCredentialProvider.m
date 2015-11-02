// A0MainBundleCredentialProvider.m
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

#import "A0MainBundleCredentialProvider.h"

static NSString * const ClientIdKey = @"Auth0ClientId";
static NSString * const TenantKey = @"Auth0Tenant";
static NSString * const DomainKey = @"Auth0Domain";
static NSString * const ConfigurationDomainKey = @"Auth0ConfigurationDomain";

@interface A0MainBundleCredentialProvider ()
@property (strong, nonatomic) NSDictionary *values;
@end

@implementation A0MainBundleCredentialProvider

- (instancetype)init {
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSMutableDictionary *values = [NSMutableDictionary dictionary];
    [@[ClientIdKey, TenantKey, DomainKey, ConfigurationDomainKey] enumerateObjectsUsingBlock:^(NSString * _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *value = info[key];
        if (value) {
            values[key] = value;
        }
    }];
    return [self initWithDictionary:[NSDictionary dictionaryWithDictionary:values]];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _values = [NSDictionary dictionaryWithDictionary:dictionary];
    }
    return self;
}

- (NSString *)clientId {
    return self.values[ClientIdKey];
}

- (NSString *)domain {
    return self.values[DomainKey] ?: [NSString stringWithFormat:@"https://%@.auth0.com", self.values[TenantKey]];
}

- (NSString *)configurationDomain {
    return self.values[ConfigurationDomainKey];
}

- (NSString *)description {
    return [self.values description];
}
@end
