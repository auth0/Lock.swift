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

/**
 *  `/passwordless/start` path
 *
 *  @return a path
 */
- (NSString *)startPasswordless;

@end
