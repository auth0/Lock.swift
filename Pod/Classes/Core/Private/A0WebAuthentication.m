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

#define kCallbackURLString @"a0%@://%@.auth0.com/authorize"

@interface A0WebAuthentication ()
@property (strong, nonatomic) NSURL *callbackURL;
@property (strong, nonatomic) NSString *strategyName;
@end

@implementation A0WebAuthentication

- (instancetype)initWithApplication:(A0Application *)application strategy:(A0Strategy *)strategy {
    self = [super init];
    if (self) {
        A0Connection *connection = strategy.connections.firstObject;
        NSAssert(application != nil && application.identifier, @"You must supply a valid A0Application");
        NSAssert(strategy != nil && connection.name != nil, @"You must supply a valid strategy with at least 1 connection");
        NSString *connectionName = connection.name;
        NSString *callbackURLString = [NSString stringWithFormat:kCallbackURLString, application.identifier, connectionName].lowercaseString;
        _callbackURL = [NSURL URLWithString:callbackURLString];
        _strategyName = strategy.name;
    }
    return self;
}

- (BOOL)validateURL:(NSURL *)url {
    return [url.scheme.lowercaseString isEqualToString:self.callbackURL.scheme] && [url.host.lowercaseString isEqualToString:self.callbackURL.host];
}

- (A0Token *)tokenFromURL:(NSURL *)url error:(NSError *__autoreleasing *)error {
    NSString *queryString = url.query ?: url.fragment;
    NSDictionary *params = [NSDictionary fromQueryString:queryString];
    Auth0LogDebug(@"Received params %@ from URL %@", params, url);
    NSString *errorMessage = params[@"error"];
    A0Token *token;
    if (errorMessage) {
        Auth0LogError(@"URL contained error message %@", errorMessage);
        *error = [errorMessage isEqualToString:@"access_denied"] ? [A0Errors auth0NotAuthorizedForStrategy:self.strategyName] : [A0Errors auth0InvalidConfigurationForStrategy:self.strategyName];
    } else {
        NSString *accessToken = params[@"access_token"];
        NSString *idToken = params[@"id_token"];
        NSString *tokenType = params[@"token_type"];
        NSString *refreshToken = params[@"refresh_token"];
        if (idToken) {
            token = [[A0Token alloc] initWithAccessToken:accessToken idToken:idToken tokenType:tokenType refreshToken:refreshToken];
            Auth0LogVerbose(@"Obtained token from URL: %@", token);
        } else {
            Auth0LogError(@"Failed to obtain id_token from URL %@", url);
            *error = [A0Errors auth0NotAuthorizedForStrategy:self.strategyName];
        }
    }
    return token;
}

@end
