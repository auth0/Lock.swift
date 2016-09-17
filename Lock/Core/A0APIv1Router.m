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
#import "Constants.h"

@interface A0APIv1Router ()
@property (copy, nonatomic) NSString *clientId;
@property (copy, nonatomic) NSString *tenant;
@property (strong, nonatomic) NSURL *endpointURL;
@property (strong, nonatomic) NSURL *configurationURL;
@end

@implementation A0APIv1Router

- (instancetype)init {
    [NSException raise:NSInternalInconsistencyException format:@"Please use %@ initializer", NSStringFromSelector(@selector(initWithClientId:domainURL:configurationURL:))];
    return [super init];
}

- (instancetype)initWithClientId:(NSString *)clientId domainURL:(NSURL *)domainURL configurationURL:(NSURL *)configurationURL {
    NSAssert(clientId.length > 0, @"Must supply a valid client id");
    NSAssert(domainURL != nil, @"Must supply a non-nil domain URL");
    NSAssert(configurationURL != nil, @"Must supply a non-nil configuration URL");
    self = [super init];
    if (self) {
        _endpointURL = domainURL;
        _configurationURL = configurationURL;
        A0LogInfo(@"Base URL of API is %@", self.endpointURL);
        A0LogInfo(@"Configuration URL is %@", self.configurationURL);
        _clientId = clientId;
        NSString *host = _endpointURL.host;
        _tenant = [host hasSuffix:@".auth0.com"] ? [[host componentsSeparatedByString:@"."] firstObject] : host;
    }
    return self;
}

- (NSString *)loginPath {
    return @"oauth/ro";
}

- (NSString *)signUpPath {
    return @"dbconnections/signup";
}

- (NSString *)changePasswordPath {
    return @"dbconnections/change_password";
}

- (NSString *)socialLoginPath {
    return @"oauth/access_token";
}

- (NSString *)userInfoPath {
    return @"userinfo";
}

- (NSString *)tokenInfoPath {
    return @"tokeninfo";
}

- (NSString *)delegationPath {
    return @"delegation";
}

- (NSString *)unlinkPath {
    return @"unlink";
}

- (NSString *)usersPath {
    return @"api/users";
}

- (NSString *)userPublicKeyPathForUser:(NSString *)userId {
    return [[NSString stringWithFormat:@"api/users/%@/publickey", userId] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];;
}

- (NSString *)startPasswordless {
    return @"passwordless/start";
}
@end
