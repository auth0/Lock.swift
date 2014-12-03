//  A0APIv1Router.m
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

#import "A0APIv1Router.h"

#define kAppBaseURLFormatString @"https://%@.auth0.com"
#define kCDNConfigurationURL @"https://cdn.auth0.com"

#define kClientIdKey @"Auth0ClientId"
#define kTenantKey @"Auth0Tenant"
#define kDomainKey @"Auth0Domain"
#define kConfigurationDomainKey @"Auth0ConfigurationDomain"

#define kLoginPath @"oauth/ro"
#define kSignUpPath @"dbconnections/signup"
#define kTokenInfoPath @"tokeninfo"
#define kChangePasswordPath @"dbconnections/change_password"
#define kSocialAuthPath @"oauth/access_token"
#define kDelegationAuthPath @"delegation"
#define kUnlinkAccountPath @"unlink"
#define kUserInfoPath @"userinfo"
#define kUsersPath @"api/users"
#define kPublicKeyUserPath @"api/users/%@/publickey"

@interface A0APIv1Router ()
@property (copy, nonatomic) NSString *clientId;
@property (copy, nonatomic) NSString *tenant;
@property (strong, nonatomic) NSURL *endpointURL;
@property (strong, nonatomic) NSURL *configurationURL;
@end

@implementation A0APIv1Router

- (void)configureWithBundleInfo:(NSDictionary *)bundleInfo {
    NSString *domain = bundleInfo[kDomainKey];
    NSString *configDomain = bundleInfo[kConfigurationDomainKey];
    NSString *clientId = bundleInfo[kClientIdKey];
    NSString *tenant = bundleInfo[kTenantKey];
    if (domain && configDomain) {
        [self configureForDomain:domain configurationDomain:configDomain clientId:clientId];
    } else if(domain) {
        [self configureForDomain:domain clientId:clientId];
    } else {
        [self configureForTenant:tenant clientId:clientId];
    }
}

- (void)configureForDomain:(NSString *)domain clientId:(NSString *)clientId {
    NSURL *domainURL = [NSURL URLWithString:domain];
    NSAssert(domainURL, @"You must supply a valid Auth0 domain.");
    NSString *configurationDomain = [domainURL.host hasSuffix:@".auth0.com"] ? kCDNConfigurationURL : domain;
    [self configureForDomain:domain configurationDomain:configurationDomain clientId:clientId];
}

- (void)configureForDomain:(NSString *)domain configurationDomain:(NSString *)configurationDomain clientId:(NSString *)clientId {
    NSURL *domainURL = [NSURL URLWithString:domain];
    NSURL *configurationURL = [NSURL URLWithString:configurationDomain];
    NSAssert(domainURL, @"You must supply a valid Auth0 domain.");
    NSAssert(configurationURL, @"You must supply a valid Auth0 config domain.");
    NSAssert(clientId, @"You must supply your Auth0 app's Client Id.");
    self.endpointURL = domainURL;
    NSString *clientPath = [[@"client" stringByAppendingPathComponent:clientId] stringByAppendingPathExtension:@"js"];
    self.configurationURL = [NSURL URLWithString:clientPath relativeToURL:configurationURL];
    Auth0LogInfo(@"Base URL of API is %@", self.endpointURL);
    Auth0LogInfo(@"Configuration URL is %@", self.configurationURL);
    self.clientId = clientId;
}

- (void)configureForTenant:(NSString *)tenant clientId:(NSString *)clientId {
    NSAssert(tenant, @"You must supply your Auth0 app's Tenant.");
    NSString *URLString = [NSString stringWithFormat:kAppBaseURLFormatString, tenant];
    [self configureForDomain:URLString configurationDomain:kCDNConfigurationURL clientId:clientId];
    self.tenant = tenant;
}

- (NSString *)loginPath {
    return kLoginPath;
}

- (NSString *)signUpPath {
    return kSignUpPath;
}

- (NSString *)changePasswordPath {
    return kChangePasswordPath;
}

- (NSString *)socialLoginPath {
    return kSocialAuthPath;
}

- (NSString *)userInfoPath {
    return kUserInfoPath;
}

- (NSString *)tokenInfoPath {
    return kTokenInfoPath;
}

- (NSString *)delegationPath {
    return kDelegationAuthPath;
}

- (NSString *)unlinkPath {
    return kUnlinkAccountPath;
}

- (NSString *)usersPath {
    return kUsersPath;
}

- (NSString *)userPublicKeyPathForUser:(NSString *)userId {
    return [[NSString stringWithFormat:kPublicKeyUserPath, userId] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];;
}

@end
