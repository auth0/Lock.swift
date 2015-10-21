// A0SafariSession.m
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

#import "A0SafariSession.h"
#import "A0Lock.h"
#import "A0Stats.h"
#import "NSDictionary+A0QueryParameters.h"
#import "A0APIClient.h"
#import "A0Token.h"

@interface A0SafariSession ()
@property (strong, nonatomic) A0APIClient *client;
@property (strong, nonatomic) NSURL *callbackURL;
@property (strong, nonatomic) NSURL *authorizeURL;
@property (strong, nonatomic) NSDictionary *defaultParameters;
@end

@implementation A0SafariSession

- (instancetype)initWithLock:(A0Lock *)lock connectionName:(NSString *)connectionName {
    NSURL *callbackURL = [A0SafariSession callbackURLForOSVersion:NSFoundationVersionNumber withLock:lock];
    return [self initWithLock:lock connectionName:connectionName callbackURL:callbackURL];
}

- (instancetype)initWithLock:(A0Lock *)lock connectionName:(NSString *)connectionName callbackURL:(NSURL *)callbackURL {
    self = [super init];
    if (self) {
        _connectionName = connectionName;
        _client = [lock apiClient];
        _callbackURL = callbackURL;
        NSURLComponents *components = [[NSURLComponents alloc] initWithURL:lock.domainURL.absoluteURL resolvingAgainstBaseURL:YES];
        components.path = @"/authorize";
        _authorizeURL = components.URL;
        NSMutableDictionary *defaults = [@{
                                           @"response_type": @"token",
                                           @"client_id": lock.clientId,
                                           @"redirect_uri": callbackURL.absoluteString,
                                           @"connection": connectionName,
                                           } mutableCopy];
        if ([A0Stats shouldSendAuth0ClientHeader]) {
            defaults[A0ClientInfoQueryParamName] = [A0Stats stringForAuth0ClientHeader];
        }
        _defaultParameters = [NSDictionary dictionaryWithDictionary:defaults];
    }
    return self;
}

- (NSURL *)authorizeURLWithParameters:(NSDictionary *)parameters {
    NSMutableDictionary *authenticationParameters = [NSMutableDictionary dictionaryWithDictionary:self.defaultParameters];
    [authenticationParameters addEntriesFromDictionary:parameters];
    NSURLComponents *components = [NSURLComponents componentsWithURL:self.authorizeURL resolvingAgainstBaseURL:YES];
    components.query = authenticationParameters.queryString;
    return components.URL;
}

- (A0SafariSessionAuthentication)authenticationBlockWithSuccess:(A0IdPAuthenticationBlock)success
                                                        failure:(A0IdPAuthenticationErrorBlock)failure {
    return ^(NSError *error, A0Token *token) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                failure(error);
                return;
            }
            [self.client fetchUserProfileWithIdToken:token.idToken success:^(A0UserProfile * _Nonnull profile) {
                success(profile, token);
            } failure:failure];
        });
    };
}

+ (NSURL *)callbackURLForOSVersion:(double)osVersion withLock:(A0Lock *)lock {
    BOOL magicLinkAvailable = floor(osVersion) > NSFoundationVersionNumber_iOS_8_3;
    NSURL *callbackURL = magicLinkAvailable ? [A0SafariSession universalLinkURLForLock:lock] : [A0SafariSession urlWithCustomSchemeForLock:lock];
    return callbackURL;
}

+ (NSURL *)urlWithCustomSchemeForLock:(A0Lock *)lock {
    NSURL *domainURL = lock.domainURL;
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:domainURL resolvingAgainstBaseURL:YES];
    components.scheme = [[NSBundle mainBundle] bundleIdentifier];
    components.path = [[@"/ios" stringByAppendingPathComponent:[[NSBundle mainBundle] bundleIdentifier]] stringByAppendingPathComponent:@"callback"];
    return components.URL;
}

+ (NSURL *)universalLinkURLForLock:(A0Lock *)lock {
    NSURL *domainURL = lock.domainURL;
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:domainURL resolvingAgainstBaseURL:YES];
    components.path = [[@"/ios" stringByAppendingPathComponent:[[NSBundle mainBundle] bundleIdentifier]] stringByAppendingPathComponent:@"callback"];
    return components.URL;
}

@end
