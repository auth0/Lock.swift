// A0APIRouter.h
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

/**
 *  Class that handles base URL and paths of Auth0 APIs. 
 *  It can be configured in three ways:
 *  1. Tenant and Client Id
 *  2. Domain and Client Id
 *  3. Domain, Config Domain and Client Id.
 *
 *  Also it can obtain its configuration from NSBundle user information.
 */
@protocol A0APIRouter <NSObject>

/**
 *  Auth0's app client id
 */
@property (readonly, nonatomic) NSString *clientId;
/**
 *  Tenant name of the account. It can be nil if domain was supplied.
 */
@property (readonly, nonatomic) NSString *tenant;

/**
 *  Base URL of Auth0 API.
 */
@property (readonly, nonatomic) NSURL *endpointURL;

/**
 *  Base URL where App condiguration is stored.
 */
@property (readonly, nonatomic) NSURL *configurationURL;

/**
 *  Configure router with values stored in bundle of app.
 *  The valid keys are the following:

 *  ClientId: "Auth0ClientId"
 *  Tenant: "Auth0Tenant"
 *  Domain: "Auth0Domain"
 *  Config Domain: "Auth0ConfigurationDomain"
 *
 *  It can be any of these configurations:
 *  1. Domain + Domain Config + Client Id
 *  2. Domain + Client Id
 *  3. Tenant + Client Id
 *  The order also determines the precende, so if (1) and (2) are found in the dictionary, the option (1) will be used instead of (2).
 *  @param bundleInfo info in main bundle
 */
- (void)configureWithBundleInfo:(NSDictionary *)bundleInfo;

/**
 *  Configure router with domain and client id
 *
 *  @param domain   domain url
 *  @param clientId id of the client
 */
- (void)configureForDomain:(NSString *)domain clientId:(NSString *)clientId;
/**
 *  Configure router with domain and domain config besides a client id.
 *
 *  @param domain              domain url
 *  @param configurationDomain config domain url
 *  @param clientId            id of the client
 */
- (void)configureForDomain:(NSString *)domain configurationDomain:(NSString *)configurationDomain clientId:(NSString *)clientId;
/**
 *  Configure router with tenant and client id
 *
 *  @param tenant   name of the tenant of the account owner of the app.
 *  @param clientId id of the client
 */
- (void)configureForTenant:(NSString *)tenant clientId:(NSString *)clientId;

/**
 *  `oauth/ro` path
 *
 *  @return a path
 */
- (NSString *)loginPath;

/**
 *  `dbconnections/signup` path
 *
 *  @return a path
 */
- (NSString *)signUpPath;

/**
 *  `dbconnections/change_password` path
 *
 *  @return a path
 */
- (NSString *)changePasswordPath;

/**
 *  `oauth/access_token` path
 *
 *  @return a path
 */
- (NSString *)socialLoginPath;

/**
 *  `userinfo` path
 *
 *  @return a path
 */
- (NSString *)userInfoPath;

/**
 *  `tokeninfo` path
 *
 *  @return a path
 */
- (NSString *)tokenInfoPath;

/**
 *  `delegation` path
 *
 *  @return a path
 */
- (NSString *)delegationPath;

/**
 *  `unlink` path
 *
 *  @return a path
 */
- (NSString *)unlinkPath;

/**
 *  `/users` path
 *
 *  @return a path
 */
- (NSString *)usersPath;

/**
 *  `/users/<user_id>/publickey` path
 *
 *  @param userId id of the user owner of the pub key
 *
 *  @return a path
 */
- (NSString *)userPublicKeyPathForUser:(NSString *)userId;

@end
