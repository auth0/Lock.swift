// A0UserAPIClient.h
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
#import "A0APIRouter.h"

@class A0UserProfile;

NS_ASSUME_NONNULL_BEGIN

typedef void(^A0UserAPIClientUserProfileSuccess)(A0UserProfile* __nonnull profile);
typedef void(^A0UserAPIClientError)(NSError* __nonnull error);

/**
 `A0UserAPIClient` is a class with convenience methods for Auth0 REST API that needs to be authenticated with a user's accessToken or JWT token.
 */
@interface A0UserAPIClient : NSObject

- (instancetype)initWithRouter:(id<A0APIRouter>)router accessToken:(NSString *)accessToken;
- (instancetype)initWithRouter:(id<A0APIRouter>)router idToken:(NSString *)idToken;

///----------------------------------------
/// @name User Profile
///----------------------------------------

/**
 *  Obtains the user's profile information
 *
 *  @param success     block called on successful request with user's profile
 *  @param failure     block called on failure with the reason as a parameter
 */
- (void)fetchUserProfileSuccess:(A0UserAPIClientUserProfileSuccess)success
                        failure:(A0UserAPIClientError)failure;

@end

@interface A0UserAPIClient (Deprecated)

/**
 *  Initialise a new User API Client
 *
 *  @param clientId    account client identifier
 *  @param tenant      account tenant name
 *  @param accessToken user's access token
 *
 *  @deprecated 1.12.0
 *  @return a A0UserAPIClient instance
 */
- (instancetype)initWithClientId:(NSString *)clientId tenant:(NSString *)tenant accessToken:(NSString *)accessToken DEPRECATED_ATTRIBUTE;
/**
 *  Initialise a new User API Client
 *
 *  @param clientId    account client identifier
 *  @param tenant      account tenant name
 *  @param idToken     user's id token
 *
 *  @deprecated 1.12.0
 *  @return a A0UserAPIClient instance
 */
- (instancetype)initWithClientId:(NSString *)clientId tenant:(NSString *)tenant idToken:(NSString *)idToken DEPRECATED_ATTRIBUTE;

/**
 *  Creates a new client with an access token
 *
 *  @param accessToken user's access token
 *
 *  @deprecated 1.12.0
 *  @return a new instance
 */
+ (A0UserAPIClient *)clientWithAccessToken:(NSString *)accessToken DEPRECATED_ATTRIBUTE;

/**
 *  Creates a new client with a id token
 *
 *  @param idToken user's id token
 *
 *  @deprecated 1.12.0
 *  @return a new instance
 */
+ (A0UserAPIClient *)clientWithIdToken:(NSString *)idToken DEPRECATED_ATTRIBUTE;

/**
 *  Registers a RSA Public Key for the user. The key will be used to validate signed JWTs when authenticating.
 *
 *  @param pubKey           public key data to upload
 *  @param device           name of the device
 *  @param userId           id of the user
 *  @param success block    called on successful request
 *  @param failure block    called on failure with the reason as a parameter
 */
- (void)registerPublicKey:(NSData *)pubKey
                   device:(NSString *)deviceName
                     user:(NSString *)userId
                  success:(void(^)())success
                  failure:(A0UserAPIClientError)failure DEPRECATED_ATTRIBUTE;

/**
 *  Removes a RSA public key associated to the user and a specific device.
 *
 *  @param deviceName name of the device
 *  @param userId     id of the user
 *  @param success    called on successful request
 *  @param failure    called on failure with the reason as a parameter
 */
- (void)removePublicKeyOfDevice:(NSString *)deviceName
                           user:(NSString *)userId
                        success:(void(^)())success
                        failure:(A0UserAPIClientError)failure DEPRECATED_ATTRIBUTE;

@end

NS_ASSUME_NONNULL_END