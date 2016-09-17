//  A0WebAuthentication.m
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

#import "A0WebAuthentication.h"
#import "A0Application.h"
#import "A0Strategy.h"
#import "A0Token.h"
#import "A0Errors.h"
#import "NSDictionary+A0QueryParameters.h"
#import "A0Connection.h"
#import "A0AuthParameters.h"
#import "NSError+A0APIError.h"
#import "Constants.h"
#import "A0Lock.h"

#define kCallbackURLString @"a0%@://%@.auth0.com/authorize"

@interface A0WebAuthentication ()
@property (strong, nonatomic) NSURL *callbackURL;
@property (strong, nonatomic) NSString *connectionName;
@property (strong, nonatomic) NSURL *domainURL;
@property (copy, nonatomic) NSString *clientId;
@end

@implementation A0WebAuthentication

- (instancetype)initWithClientId:(NSString *)clientId domainURL:(NSURL *)domainURL connectionName:(NSString *)connectionName {
    self = [super init];
    if (self) {
        NSString *callbackURLString = [NSString stringWithFormat:kCallbackURLString, clientId, connectionName].lowercaseString;
        _callbackURL = [NSURL URLWithString:callbackURLString];
        _connectionName = connectionName;
        _domainURL = domainURL;
        _clientId = clientId;
    }
    return self;
}

- (BOOL)validateURL:(NSURL *)url {
    return [url.scheme.lowercaseString isEqualToString:self.callbackURL.scheme] && [url.host.lowercaseString isEqualToString:self.callbackURL.host];
}

- (A0Token *)tokenFromURL:(NSURL *)url error:(NSError *__autoreleasing *)error {
    NSString *queryString = url.query ?: url.fragment;
    NSDictionary *params = [NSDictionary fromQueryString:queryString];
    A0LogDebug(@"Received params %@ from URL %@", params, url);
    NSString *errorMessage = params[@"error"];
    A0Token *token;
    if (errorMessage) {
        A0LogError(@"URL contained error message %@", errorMessage);
        if (error != NULL) {
            NSString *localizedDescription = [NSString stringWithFormat:@"Failed to authenticate user with connection %@", self.connectionName];
            *error = [NSError errorWithCode:A0ErrorCodeAuthenticationFailed
                                description:A0LocalizedString(localizedDescription)
                                    payload:params];
        }
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
            if (error != NULL) {
                *error = [A0Errors auth0InvalidConfigurationForConnectionName:self.connectionName];
            }

        }
    }
    return token;
}

- (NSString *)authorizationCodeFromURL:(NSURL *)url error:(NSError * _Nullable __autoreleasing *)error {
    NSString *queryString = url.query ?: url.fragment;
    NSDictionary *params = [NSDictionary fromQueryString:queryString];
    A0LogDebug(@"Received params %@ from URL %@", params, url);
    NSString *errorMessage = params[@"error"];
    NSString *code;
    if (errorMessage) {
        A0LogError(@"URL contained error message %@", errorMessage);
        if (error != NULL) {
            NSString *localizedDescription = [NSString stringWithFormat:@"Failed to authenticate user with connection %@", self.connectionName];
            *error = [NSError errorWithCode:A0ErrorCodeAuthenticationFailed
                                description:A0LocalizedString(localizedDescription)
                                    payload:params];
        }
    } else {
        code = params[@"code"];
    }
    return code;
}

- (NSURL *)authorizeURLWithParameters:(NSDictionary *)parameters usePKCE:(BOOL)usePKCE {
    NSString *responseType = usePKCE ? @"code" : @"token";
    A0LogVerbose(@"Using response_type %@", responseType);
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:self.domainURL.absoluteURL resolvingAgainstBaseURL:NO];
    components.path = @"/authorize";
    NSMutableDictionary *dictionary = parameters ? [parameters mutableCopy] : [[[A0AuthParameters newDefaultParams] asAPIPayload] mutableCopy];
    [dictionary addEntriesFromDictionary:@{
                                           @"response_type": responseType,
                                           @"client_id": self.clientId,
                                           @"redirect_uri": self.callbackURL.absoluteString,
                                           @"connection": self.connectionName,
                                           }];
    if (self.telemetryInfo) {
        dictionary[A0ClientInfoQueryParamName] = self.telemetryInfo;
    }
    components.query = dictionary.queryString;
    return components.URL;
}

@end
