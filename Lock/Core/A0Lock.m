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
#import "A0LockNotification.h"
#import "A0MainBundleCredentialProvider.h"
#import "A0FileCredentialProvider.h"
#import "Constants.h"
#import "A0Telemetry.h"

NSString * const A0ClientInfoHeaderName = @"Auth0-Client";
NSString * const A0ClientInfoQueryParamName = @"auth0Client";

static NSString * const Auth0FileName = @"Auth0";
static NSString * const Auth0FileExtension = @"plist";

@interface NSURL (A0Lock)

+ (instancetype)URLWithAuth0Domain:(NSString *)domain;

@end

@implementation NSURL (A0Lock)

+ (instancetype)URLWithAuth0Domain:(NSString *)domain {
    NSURL *url = [domain hasPrefix:@"http"] ? [NSURL URLWithString:domain] : [NSURL URLWithString:[@"https://" stringByAppendingString:domain]];
    return url;
}

@end

static NSURL *Auth0CDNRegionURLFromDomainURL(NSURL *domainURL) {
    NSString *cdn = @"cdn";

    if ([domainURL.host hasSuffix:@".auth0.com"]) {
        NSString *part = [[domainURL.host componentsSeparatedByString:@".auth0.com"] firstObject];
        NSArray<NSString *> *values = [part componentsSeparatedByString:@"."];
        if (values.count > 1 && values.lastObject.length > 0) {
            cdn = [[cdn stringByAppendingString:@"."] stringByAppendingString:values.lastObject];
        }
    }
    NSURLComponents *components = [[NSURLComponents alloc] init];
    components.scheme = @"https";
    components.host = [cdn stringByAppendingString:@".auth0.com"];
    return components.URL;
}

@interface A0Lock ()

@property (strong, nonatomic) id<A0APIRouter> router;
@property (strong, nonatomic) A0APIClient *client;
#if TARGET_OS_IPHONE
@property (strong, nonatomic) A0IdentityProviderAuthenticator *authenticator;
#endif

@end

@implementation A0Lock

- (instancetype)init {
    NSString *path = [[NSBundle mainBundle] pathForResource:Auth0FileName ofType:Auth0FileExtension];
    id<A0CredentialProvider> credentialProvider;
    if (path) {
        A0LogInfo(@"Using Auth0 credentials from file %@", path);
        credentialProvider = [[A0FileCredentialProvider alloc] initWithFilePath:path];
    } else {
        A0LogInfo(@"Using Auth0 credentials from main bundle");
        credentialProvider = [[A0MainBundleCredentialProvider alloc] init];
    }
    return [self initWithCredentialProvider:credentialProvider];
}

- (instancetype)initWithCredentialProvider:(id<A0CredentialProvider>)credentialProvider {
    NSString *clientId = [credentialProvider clientId];
    NSString *domain = [credentialProvider domain];
    NSString *configurationDomain = [credentialProvider configurationDomain];
    A0LogVerbose(@"Building lock with credentials %@", credentialProvider);
    if (configurationDomain) {
        return [self initWithClientId:clientId domain:domain configurationDomain:configurationDomain];
    }
    return [self initWithClientId:clientId domain:domain];
}

- (instancetype)initWithClientId:(NSString *)clientId domain:(NSString *)domain {
    NSAssert(clientId.length > 0, @"Must supply a valid clientId");
    NSAssert(domain.length > 0, @"Must supply a valid domain");
    NSURL *domainURL = [NSURL URLWithAuth0Domain:domain];
    NSURL *configurationURL = Auth0CDNRegionURLFromDomainURL(domainURL);
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
        _telemetry = [A0Telemetry telemetryEnabled] ? [[A0Telemetry alloc] init] : nil;
        _client.telemetryInfo = _telemetry.base64Value;
        _usePKCE = NO;
    }
    return self;
}

+ (instancetype)sharedLock {
    static A0Lock *SharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SharedInstance = [A0Lock newLock];
    });
    return SharedInstance;
}

- (void)setTelemetry:(A0Telemetry *)telemetry {
    [self willChangeValueForKey:NSStringFromSelector(@selector(telemetry))];
    _telemetry = telemetry;
    [self didChangeValueForKey:NSStringFromSelector(@selector(telemetry))];
    self.client.telemetryInfo = telemetry.base64Value;
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
    return [self.identityProviderAuthenticator handleURL:url sourceApplication:sourceApplication];
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

- (BOOL)continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler {
    NSURL *url = userActivity.webpageURL;
    if (!url) {
        A0LogWarn(@"Received an user activity with no URL");
        return NO;
    }

    NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:YES];

    if (![components.host isEqualToString:self.domainURL.host]) {
        A0LogWarn(@"URL %@ is not inside configured Auth0 subdomain %@", url, self.domainURL.host);
        return NO;
    }

    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSString *prefix = [NSString stringWithFormat:@"/ios/%@", bundleIdentifier];

    if (![components.path.lowercaseString hasPrefix:prefix.lowercaseString]) {
        A0LogWarn(@"URL %@ is not for this application with bundleId %@", url, bundleIdentifier);
        return NO;
    }

    A0LogDebug(@"Received Universal Link %@", url);
    [[NSNotificationCenter defaultCenter] postNotificationName:A0LockNotificationUniversalLinkReceived
                                                        object:nil
                                                      userInfo:@{
                                                                 A0LockNotificationUniversalLinkParameterKey: url
                                                                 }];
    return YES;
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
