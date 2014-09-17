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
#import "NSDictionary+A0QueryParameters.h"

#define kCallbackURLString @"a0%@://authorize/%@"

@interface A0WebAuthentication ()

@property (strong, nonatomic) NSString *connectionName;
@property (strong, nonatomic) NSURL *authorizeURL;
@property (strong, nonatomic) NSString *redirectURI;
@property (copy, nonatomic) void(^successBlock)(A0IdentityProviderCredentials *);
@property (copy, nonatomic) void(^failureBlock)(NSError *);

@end

@implementation A0WebAuthentication

+ (instancetype)newWebAuthenticationForStrategy:(A0Strategy *)strategy
                                  ofApplication:(A0Application *)application {
    A0WebAuthentication *auth = [[A0WebAuthentication alloc] init];
    auth.connectionName = strategy.name;
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:application.authorizeURL resolvingAgainstBaseURL:NO];
    NSString *connectionName = strategy.connection[@"name"];
    NSString *redirectURI = [NSString stringWithFormat:kCallbackURLString, application.identifier, connectionName].lowercaseString;
    NSDictionary *parameters = @{
                                 @"scope": @"openid",
                                 @"response_type": @"token",
                                 @"connection": connectionName,
                                 @"client_id": application.identifier,
                                 @"redirect_uri": redirectURI,
                                 };
    components.query = parameters.queryString;
    auth.connectionName = connectionName;
    auth.authorizeURL = components.URL;
    auth.redirectURI = redirectURI;
    return auth;
}

- (NSString *)identifier {
    return self.connectionName;
}

- (void)clearSessions {
    [self clearBlocks];
}

- (BOOL)handleURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication {
    Auth0LogVerbose(@"Received url %@ from source application %@", url, sourceApplication);
    BOOL handled = [url.absoluteString.lowercaseString hasPrefix:self.redirectURI];
    if (handled) {
        NSString *queryString = url.query ?: url.fragment;
        NSDictionary *params = [NSDictionary fromQueryString:queryString];
        Auth0LogDebug(@"Received params %@ from URL %@", params, url);
        NSString *error = params[@"error"];
        if (error) {
            if (self.failureBlock) {
                self.failureBlock(nil);
            }
        } else {
            NSString *accessToken = params[@"access_token"];
            if (accessToken) {
                NSMutableDictionary *extraInfo = [params mutableCopy];
                [extraInfo removeObjectForKey:@"access_token"];
                A0IdentityProviderCredentials *credentials = [[A0IdentityProviderCredentials alloc] initWithAccessToken:accessToken extraInfo:params];
                if (self.successBlock) {
                    self.successBlock(credentials);
                }
            } else {
                if (self.failureBlock) {
                    self.failureBlock(nil);
                }
            }
        }
        [self clearBlocks];
    }
    return handled;
}

- (void)authenticateWithSuccess:(void(^)(A0IdentityProviderCredentials *socialCredentials))success
                        failure:(void(^)(NSError *))failure {
    self.successBlock = success;
    self.failureBlock = failure;
    Auth0LogDebug(@"Opening web authentication wit URL %@", self.authorizeURL);
    [[UIApplication sharedApplication] openURL:self.authorizeURL];
}

#pragma mark - Utility methods

- (void)clearBlocks {
    self.successBlock = nil;
    self.failureBlock = nil;
}

@end
