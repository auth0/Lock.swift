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

typedef NS_OPTIONS(NSInteger, A0APIClientScope) {
    A0APIClientScopeOpenId = 1 << 0,
    A0APIClientScopeProfile = 1 << 1,
    A0APIClientScopeOfflineAccess = 1 << 2
};

FOUNDATION_EXTERN NSString * const A0APIClientDelegationAPIType;
FOUNDATION_EXTERN NSString * const A0APIClientDelegationTarget;

@class A0Application, A0Strategy, A0SocialCredentials, A0UserProfile, A0Token;

typedef void(^A0APIClientFetchAppInfoSuccess)(id payload);
typedef void(^A0APIClientAuthenticationSuccess)(A0UserProfile *profile, A0Token *tokenInfo);
typedef void(^A0APIClientDelegationSuccess)(A0Token *tokenInfo);
typedef void(^A0APIClientError)(NSError *error);

@interface A0APIClient : NSObject

@property (assign, nonatomic) A0APIClientScope defaultScope;

- (instancetype)initWithClientId:(NSString *)clientId andDomainName:(NSString *)domainName;

+ (instancetype)sharedClient;

#pragma mark - Client configuration

- (void)configureForApplication:(A0Application *)application;


- (void)fetchAppInfoWithSuccess:(A0APIClientFetchAppInfoSuccess)success
                        failure:(A0APIClientError)failure;

- (void)logout;

#pragma mark - Database Authentication

- (void)loginWithUsername:(NSString *)username
                 password:(NSString *)password
                  success:(A0APIClientAuthenticationSuccess)success
                  failure:(A0APIClientError)failure;

- (void)signUpWithUsername:(NSString *)username
                  password:(NSString *)password
                   success:(A0APIClientAuthenticationSuccess)success
                   failure:(A0APIClientError)failure;

- (void)changePassword:(NSString *)newPassword
           forUsername:(NSString *)username
               success:(void(^)())success
               failure:(A0APIClientError)failure;

#pragma mark - Social Authentication

- (void)authenticateWithSocialStrategy:(A0Strategy *)strategy
                     socialCredentials:(A0SocialCredentials *)socialCredentials
                               success:(A0APIClientAuthenticationSuccess)success
                               failure:(A0APIClientError)failure;


#pragma mark - Delegation Authentication

- (void)delegationWithRefreshToken:(NSString *)refreshToken
                           options:(NSDictionary *)options
                           success:(A0APIClientDelegationSuccess)success
                           failure:(A0APIClientError)failure;

- (void)delegationWithIdToken:(NSString *)idToken
                           options:(NSDictionary *)options
                           success:(A0APIClientDelegationSuccess)success
                           failure:(A0APIClientError)failure;

@end
