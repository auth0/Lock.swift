// A0APIClient.h
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

#import <Foundation/Foundation.h>

@class A0Application, A0Strategy, A0SocialCredentials, A0UserProfile;

typedef void(^A0APIClientFetchAppInfoSuccess)(id payload);
typedef void(^A0APIClientAuthenticationSuccess)(A0UserProfile *profile);
typedef void(^A0APIClientError)(NSError *error);

@interface A0APIClient : NSObject

- (void)configureForApplication:(A0Application *)application;

- (instancetype)initWithClientId:(NSString *)clientId;

- (void)fetchAppInfoWithSuccess:(A0APIClientFetchAppInfoSuccess)success failure:(A0APIClientError)failure;

- (void)loginWithUsername:(NSString *)username password:(NSString *)password success:(A0APIClientAuthenticationSuccess)success failure:(A0APIClientError)failure;

- (void)signUpWithUsername:(NSString *)username password:(NSString *)password success:(A0APIClientAuthenticationSuccess)success failure:(A0APIClientError)failure;

- (void)changePassword:(NSString *)newPassword forUsername:(NSString *)username success:(A0APIClientAuthenticationSuccess)success failure:(A0APIClientError)failure;

- (void)authenticateWithSocialStrategy:(A0Strategy *)strategy socialCredentials:(A0SocialCredentials *)socialCredentials success:(A0APIClientAuthenticationSuccess)success failure:(A0APIClientError)failure;

+ (instancetype)sharedClient;

@end
