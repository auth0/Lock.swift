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
#import "A0APIv1Router.h"
#import "A0APIClient.h"
#if TARGET_OS_IPHONE
#import "A0IdentityProviderAuthenticator.h"
#endif
#import "A0UserAPIClient.h"

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

@interface A0Lock ()
@property (strong, nonatomic) id<A0APIRouter> router;
@property (strong, nonatomic) A0APIClient *client;
#if TARGET_OS_IPHONE
@property (strong, nonatomic) A0IdentityProviderAuthenticator *authenticator;
#endif
@end

@implementation A0Lock

AUTH0_DYNAMIC_LOGGER_METHODS

- (instancetype)init {
    return [self initWithBundleInfo:[[NSBundle mainBundle] infoDictionary]];
}

- (instancetype)initWithBundleInfo:(NSDictionary *)info {
    NSString *tenant = info[kTenantKey];
    NSString *clientId = info[kClientIdKey];
    NSString *domain = info[kDomainKey];
    NSString *configurationDomain = info[kConfigurationDomainKey];
    A0LogVerbose(@"Loaded info from bundle %@", info);
    if (configurationDomain) {
        return [self initWithClientId:clientId domain:domain ?: [NSString stringWithFormat:@"https://%@.auth0.com", tenant] configurationDomain:configurationDomain];
    }
    return [self initWithClientId:clientId domain:domain ?: [NSString stringWithFormat:@"https://%@.auth0.com", tenant]];
}

- (instancetype)initWithClientId:(NSString *)clientId domain:(NSString *)domain {
    NSAssert(clientId.length > 0, @"Must supply a valid clientId");
    NSAssert(domain.length > 0, @"Must supply a valid domain");
    NSURL *domainURL = [NSURL URLWithAuth0Domain:domain];
    NSURL *configurationURL = [domainURL.host hasSuffix:@".eu.auth0.com"] ? [NSURL URLWithString:kEUCDNConfigurationURL] : [NSURL URLWithString:kCDNConfigurationURL];
    return [self initWithClientId:clientId domain:domain configurationDomain:configurationURL.absoluteString];
}

- (instancetype)initWithClientId:(NSString *)clientId domain:(NSString *)domain configurationDomain:(NSString *)configurationDomain {
    NSAssert(clientId.length > 0, @"Must supply a valid clientId");
    NSAssert(domain.length > 0, @"Must supply a valid domain");
    NSAssert(configurationDomain.length > 0, @"Must supply a valid configuration domain");
    self = [super init];
    if (self) {
        NSURL *domainURL = [NSURL URLWithAuth0Domain:domain];
        NSString *clientPath = [[@"client" stringByAppendingPathComponent:clientId] stringByAppendingPathExtension:@"js"];
        NSURL *configurationURL = [NSURL URLWithString:clientPath relativeToURL:[NSURL URLWithAuth0Domain:configurationDomain]];
        A0LogDebug(@"Auth0 Lock initialised with clientId: (%@) domainURL: (%@) configurationURL: (%@)", clientId, domainURL, configurationURL);
        _router = [[A0APIv1Router alloc] initWithClientId:clientId domainURL:domainURL configurationURL:configurationURL];
        _client = [[A0APIClient alloc] initWithAPIRouter:_router];
#if TARGET_OS_IPHONE
        _authenticator = [[A0IdentityProviderAuthenticator alloc] initWithLock:self];
#endif
    }

    return self;
}

- (A0APIClient *)apiClient {
    return self.client;
}

- (A0UserAPIClient *)newUserAPIClientWithIdToken:(NSString *)idToken {
    return [[A0UserAPIClient alloc] initWithRouter:self.router idToken:idToken];
}

- (NSString *)clientId {
    return [self.router clientId];
}

- (NSURL *)configurationURL {
    return [self.router configurationURL];
}

- (NSURL *)domainURL {
    return [self.router endpointURL];
}

#pragma mark - IdP methods iOS only

#if TARGET_OS_IPHONE

- (A0IdentityProviderAuthenticator *)identityProviderAuthenticator {
    return self.authenticator;
}

- (BOOL)handleURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication {
    return [self.authenticator handleURL:url sourceApplication:sourceApplication];
}

- (void)registerAuthenticators:(NSArray *)authenticators {
    [self.identityProviderAuthenticator registerAuthenticationProviders:authenticators];
}

- (void)clearSessions {
    [self.identityProviderAuthenticator clearSessions];
}

- (void)applicationLaunchedWithOptions:(NSDictionary *)launchOptions {
    [self.identityProviderAuthenticator applicationLaunchedWithOptions:launchOptions];
}

#endif

# pragma mark - Factory methods

+ (instancetype)newLock {
    return [[A0Lock alloc] init];
}

+ (instancetype)newLockWithClientId:(NSString *)clientId domain:(NSString *)domain {
    return [[A0Lock alloc] initWithClientId:clientId domain:domain];
}

+ (instancetype)newLockWithClientId:(NSString *)clientId domain:(NSString *)domain configurationDomain:(NSString *)configurationDomain {
    return [[A0Lock alloc] initWithClientId:clientId domain:domain configurationDomain:configurationDomain];
}

@end
