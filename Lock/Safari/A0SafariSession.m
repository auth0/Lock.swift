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
#import "NSDictionary+A0QueryParameters.h"
#import "A0APIClient.h"
#import "A0Token.h"
#import "A0Telemetry.h"
#import "A0PKCE.h"
#import "Constants.h"
#import "A0Errors.h"
#import "NSError+A0APIError.h"


@interface A0SafariSession ()
@property (strong, nonatomic) A0APIClient *client;
@property (strong, nonatomic) NSURL *callbackURL;
@property (strong, nonatomic) NSURL *authorizeURL;
@property (strong, nonatomic) NSDictionary *defaultParameters;
@property (strong, nonatomic) A0PKCE *pkce;
@end

@implementation A0SafariSession

- (instancetype)initWithLock:(A0Lock *)lock connectionName:(NSString *)connectionName usePKCE:(BOOL)usePKCE {
    return [self initWithLock:lock connectionName:connectionName useUniversalLink:YES usePKCE:usePKCE];
}

- (instancetype)initWithLock:(A0Lock *)lock connectionName:(NSString *)connectionName useUniversalLink:(BOOL)useUniversalLink usePKCE:(BOOL)usePKCE {
    NSURL *callbackURL = useUniversalLink ? [A0SafariSession callbackURLForOSVersion:NSFoundationVersionNumber withLock:lock] : [A0SafariSession urlWithCustomSchemeForLock:lock];
    return [self initWithLock:lock connectionName:connectionName callbackURL:callbackURL usePKCE:usePKCE];
}

- (instancetype)initWithLock:(A0Lock *)lock connectionName:(NSString *)connectionName callbackURL:(NSURL *)callbackURL usePKCE:(BOOL)usePKCE {
    self = [super init];
    if (self) {
        _connectionName = connectionName;
        _client = [lock apiClient];
        _callbackURL = callbackURL;
        _pkce = usePKCE ? [[A0PKCE alloc] init] : nil;
        NSURLComponents *components = [[NSURLComponents alloc] initWithURL:lock.domainURL.absoluteURL resolvingAgainstBaseURL:YES];
        components.path = @"/authorize";
        _authorizeURL = components.URL;
        NSMutableDictionary *defaults = [@{
                                           @"response_type": usePKCE ? @"code" : @"token",
                                           @"client_id": lock.clientId,
                                           @"redirect_uri": callbackURL.absoluteString,
                                           } mutableCopy];
        if (lock.telemetry) {
            defaults[A0ClientInfoQueryParamName] = lock.telemetry.base64Value;
        }
        if (_pkce) {
            [defaults addEntriesFromDictionary:[_pkce authorizationParameters]];
        }
        _defaultParameters = [NSDictionary dictionaryWithDictionary:defaults];
    }
    return self;
}

- (void)tokenFromURL:(NSURL *)url callback:(void (^)(NSError *, A0Token *))callback {
    NSString *queryString = url.query ?: url.fragment;
    NSDictionary *params = [NSDictionary fromQueryString:queryString];
    A0LogDebug(@"Received params %@ from URL %@", params, url);
    NSString *errorMessage = params[@"error"];
    if (errorMessage) {
        A0LogError(@"URL contained error message %@", errorMessage);
        NSString *localizedDescription = self.connectionName ? [NSString stringWithFormat:@"Failed to authenticate user with connection %@", self.connectionName] : @"Failed to authenticate user";
        NSError *error = [NSError errorWithCode:A0ErrorCodeAuthenticationFailed
                           description:A0LocalizedString(localizedDescription)
                               payload:params];
        callback(error, nil);
        return;
    }
    if (self.pkce) {
        NSString *code = params[@"code"];
        NSMutableDictionary *params = [[self.pkce tokenParametersWithAuthorizationCode:code] mutableCopy];
        [params addEntriesFromDictionary:@{
                                           @"redirect_uri": self.callbackURL.absoluteString,
                                           }];
        [self.client requestTokenWithParameters:params
                                       callback:callback];
    } else {
        NSError *error;
        A0Token *token = [self parseTokenFromURL:url error:&error];
        callback(error, token);
    }
}

- (NSURL *)authorizeURLWithParameters:(NSDictionary *)parameters {
    NSMutableDictionary *queryParameters = [NSMutableDictionary dictionaryWithDictionary:self.defaultParameters];
    [queryParameters addEntriesFromDictionary:parameters];
    if (self.connectionName) {
        queryParameters[@"connection"] = self.connectionName;
    }
    NSURLComponents *components = [NSURLComponents componentsWithURL:self.authorizeURL resolvingAgainstBaseURL:YES];
    components.query = queryParameters.queryString;
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

- (A0Token *)parseTokenFromURL:(NSURL *)url error:(NSError **)error {
    NSString *queryString = url.query ?: url.fragment;
    NSDictionary *params = [NSDictionary fromQueryString:queryString];
    A0LogDebug(@"Received params %@ from URL %@", params, url);
    NSString *errorMessage = params[@"error"];
    A0Token *token;
    NSError *cause;
    if (errorMessage) {
        A0LogError(@"URL contained error message %@", errorMessage);
        NSString *localizedDescription = [NSString stringWithFormat:@"Failed to authenticate user with connection %@", self.connectionName];
        cause = [NSError errorWithCode:A0ErrorCodeAuthenticationFailed
                           description:A0LocalizedString(localizedDescription)
                               payload:params];
    } else {
        NSString *accessToken = params[@"access_token"];
        NSString *idToken = params[@"id_token"];
        NSString *tokenType = params[@"token_type"];
        NSString *refreshToken = params[@"refresh_token"];
        if (idToken) {
            token = [[A0Token alloc] initWithAccessToken:accessToken idToken:idToken tokenType:tokenType refreshToken:refreshToken];
            A0LogVerbose(@"Obtained token from URL: %@", token);
        } else {
            A0LogError(@"Failed to obtain id_token from URL %@", url);
            cause = [A0Errors auth0InvalidConfigurationForConnectionName:self.connectionName];
        }
    }
    *error = cause;
    return token;
}

- (NSString *)titleForAuthenticationFailed {
    return self.connectionName ? [NSString stringWithFormat:@"Failed to authenticate user with connection %@", self.connectionName] : @"Failed to authenticate user";
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
