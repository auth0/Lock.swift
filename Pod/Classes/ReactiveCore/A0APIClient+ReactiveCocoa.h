// A0APIClient+ReactiveCocoa.h
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

#import "A0APIClient.h"

@class RACSignal;

@interface A0APIClient (ReactiveCocoa)

///----------------------------------------
/// @name Configuration for Auth0 App
///----------------------------------------

/**
 *  Fetches Auth0 application info from Auth0 and configure itself.
 */
- (RACSignal *)fetchAppInfo;

///----------------------------------------
/// @name Database Authentication
///----------------------------------------

/**
 *  Perform login of a user with username & password. The selected strategy is obtained from the application configured on the client.
 *  By default it will use the first database connection name found in `application` property. If it's nil a *connection_name* must be set in parameters.
 *  On success it will send a `RACTuple` with the following values `(A0UserProfile, A0Token)`.
 *
 *  @param username     username or email of the user to login
 *  @param password     password of the user to login
 *  @param parameters   optional parameters for Auth0 API. It can be nil
 *
 *  @see A0AuthParameters
 *  @see RACTuple
 */
- (RACSignal *)loginWithUsername:(NSString *)username
                        password:(NSString *)password
                      parameters:(A0AuthParameters *)parameters;

/**
 *  Perform signup for a new user in the application database. It can login the user after a succesful signup.
 *  By default it will use the first database connection name found in `application` property. If it's nil a *connection_name* must be set in parameters.
 *  On success it will send a `RACTuple` with the following values `(A0UserProfile, A0Token)`. If loginOnSuccess is `NO` it will contain nil values.
 *
 *  @param username       username or email of the new user
 *  @param password       password of the new user
 *  @param loginOnSuccess if after the signup the user should be automatically logged in
 *  @param parameters     optional parameters for Auth0 API. It can be nil
 */
- (RACSignal *)signUpWithUsername:(NSString *)username
                         password:(NSString *)password
                   loginOnSuccess:(BOOL)loginOnSuccess
                       parameters:(A0AuthParameters *)parameters;

/**
 *  Change the password for a user.
 *  By default it will use the first database connection name found in `application` property. If it's nil a *connection_name* must be set in parameters.
 *
 *  @param newPassword new password for the user
 *  @param username    username to change its password. It can be an email or a username
 *  @param parameters  optional parameters for Auth0 API. It can be nil
 */
- (RACSignal *)changePassword:(NSString *)newPassword
                  forUsername:(NSString *)username
                   parameters:(A0AuthParameters *)parameters;

/**
 *  Authenticates with a Database Connection using a signed JWT token.
 *  In order to use this method, a valid PublicKey must be registered for a user.
 *  On success it will send a `RACTuple` with the following values `(A0UserProfile, A0Token)`.
 *
 *  @param idToken    signed JWT token
 *  @param deviceName name of the device that signed the JWT. Must be URL safe and non nil.
 *  @param parameters optional parameters for Auth0 API. It can be nil
 */
- (RACSignal *)loginWithIdToken:(NSString *)idToken
                     deviceName:(NSString *)deviceName
                     parameters:(A0AuthParameters *)parameters;

///----------------------------------------
/// @name SMS Authentication
///----------------------------------------

/**
 *  Perform login of a user with phone number & SMS code using `SMS` connection.
 *  If app info is available and it doesn't have a SMS connection, it will fail.
 *  On success it will send a `RACTuple` with the following values `(A0UserProfile, A0Token)`.
 *
 *  @param phoneNumber  phone number where the user received the code and previously registered with.
 *  @param passcode     passcode received by SMS.
 *  @param parameters   optional parameters for Auth0 API. It can be nil
 *
 *  @see A0AuthParameters
 */
- (RACSignal *)loginWithPhoneNumber:(NSString *)phoneNumber
                           passcode:(NSString *)passcode
                         parameters:(A0AuthParameters *)parameters;

///----------------------------------------
/// @name Social Authentication
///----------------------------------------

/**
 *  Authenticate a user using credentials from a social identity provider like Facebook or Twitter
 *  On success it will send a `RACTuple` with the following values `(A0UserProfile, A0Token)`.
 *
 *  @param strategyName         name of the connection in Auth0 to authenticate with the social credentials. For example 'facebook', 'linkedin', etc.
 *  @param socialCredentials    credentials obtained from the identity provider. e.g. Facebook accessToken
 *  @param parameters           optional parameters for Auth0 API. It can be nil
 */
- (RACSignal *)authenticateWithSocialConnectionName:(NSString *)connectionName
                                        credentials:(A0IdentityProviderCredentials *)socialCredentials
                                         parameters:(A0AuthParameters *)parameters;

///----------------------------------------
/// @name Refresh Tokens
///----------------------------------------

/**
 *  Ask Auth0 API to return a new `id_token` for the user using their `refresh_token`
 *
 *  @param refreshToken user's refresh token
 *  @param parameters   optional parameters for Auth0 API. It can be nil
 */
- (RACSignal *)fetchNewIdTokenWithRefreshToken:(NSString *)refreshToken
                                    parameters:(A0AuthParameters *)parameters;

/**
 *  Ask Auth0 API to return a new `id_token` for the user using a currently valid `id_token`
 *
 *  @param idToken          user's JWT token
 *  @param parameters       optional parameters for Auth0 API. It can be nil
 */
- (RACSignal *)fetchNewIdTokenWithIdToken:(NSString *)idToken
                               parameters:(A0AuthParameters *)parameters;

///----------------------------------------
/// @name Delegation API
///----------------------------------------

/**
 *  Performs delegated authentication against Auth0 API and returns a new token to call for example another API.
 *  On success it will send a `NSDictionary` with delegated credentials.
 *
 *  @param parameters delegation API parameters. Must not be nil
 */
- (RACSignal *)fetchDelegationTokenWithParameters:(A0AuthParameters *)parameters;

///----------------------------------------
/// @name User Profile
///----------------------------------------

/**
 *  Obtains the user's profile information from Auth0
 *
 *  @param idToken user's id_token
 */
- (RACSignal *)fetchUserProfileWithIdToken:(NSString *)idToken;

///----------------------------------------
/// @name Link Account
///----------------------------------------

/**
 *  Unlink a specific account
 *
 *  @param userId      id of the account to unlink with the format `provider|identity_user_id`, e.g: `facebook|123456678`. You can use `A0UserIdentity`'s `identityId` method.
 *  @param accessToken Auth0 acces token for the user
 */
- (RACSignal *)unlinkAccountWithUserId:(NSString *)userId
                           accessToken:(NSString *)accessToken;

@end
