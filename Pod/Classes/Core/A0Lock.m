// A0Lock.m
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

#import "A0Lock.h"

#define kCDNConfigurationURL @"https://cdn.auth0.com"
#define kEUCDNConfigurationURL @"https://cdn.eu.auth0.com"

#define kClientIdKey @"Auth0ClientId"
#define kTenantKey @"Auth0Tenant"
#define kDomainKey @"Auth0Domain"
#define kConfigurationDomainKey @"Auth0ConfigurationDomain"

@interface NSURL (A0Lock)

+ (instancetype)URLWithAuth0Domain:(NSString *)domain;

@end

@implementation NSURL (A0Lock)

+ (instancetype)URLWithAuth0Domain:(NSString *)domain {
    NSURL *url = [domain hasPrefix:@"http"] ? [NSURL URLWithString:domain] : [NSURL URLWithString:[@"https://" stringByAppendingString:domain]];
    return url;
}

@end

@implementation A0Lock

- (instancetype)init {
    return [self initWithBundleInfo:[[NSBundle mainBundle] infoDictionary]];
}

- (instancetype)initWithBundleInfo:(NSDictionary *)info {
    NSString *tenant = info[kTenantKey];
    NSString *clientId = info[kClientIdKey];
    NSString *domain = info[kDomainKey];
    NSString *configurationDomain = info[kConfigurationDomainKey];
    if (configurationDomain) {
        return [self initWithClientId:clientId domain:domain ?: [NSString stringWithFormat:@"https://%@.auth0.com", tenant] configurationDomain:configurationDomain];
    }
    return [self initWithClientId:clientId domain:domain ?: [NSString stringWithFormat:@"https://%@.auth0.com", tenant]];
}

- (instancetype)initWithClientId:(NSString *)clientId domain:(NSString *)domain {
    NSURL *domainURL = [NSURL URLWithAuth0Domain:domain];
    NSURL *configurationURL = [domainURL.host hasSuffix:@".eu.auth0.com"] ? [NSURL URLWithString:kEUCDNConfigurationURL] : [NSURL URLWithString:kCDNConfigurationURL];
    return [self initWithClientId:clientId domain:domain configurationDomain:configurationURL.absoluteString];
}

- (instancetype)initWithClientId:(NSString *)clientId domain:(NSString *)domain configurationDomain:(NSString *)configurationDomain {
    self = [super init];
    if (self) {
        _clientId = clientId;
        _domainURL = [NSURL URLWithAuth0Domain:domain];
        NSString *clientPath = [[@"client" stringByAppendingPathComponent:clientId] stringByAppendingPathExtension:@"js"];
        NSURL *configurationURL = [NSURL URLWithAuth0Domain:configurationDomain];
        _configurationURL = [NSURL URLWithString:clientPath relativeToURL:configurationURL];
    }

    return self;
}

+ (instancetype)newLockWithClientId:(NSString *)clientId domain:(NSString *)domain {
    return [[A0Lock alloc] initWithClientId:clientId domain:domain];
}

+ (instancetype)newLockWithClientId:(NSString *)clientId domain:(NSString *)domain configurationDomain:(NSString *)configurationDomain {
    return [[A0Lock alloc] initWithClientId:clientId domain:domain configurationDomain:configurationDomain];
}

@end
