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

@class A0Application, A0Strategy, A0IdentityProviderCredentials, A0UserProfile, A0Token, A0AuthParameters;

typedef void(^A0APIClientFetchAppInfoSuccess)(A0Application* application);
typedef void(^A0APIClientAuthenticationSuccess)(A0UserProfile *profile, A0Token *tokenInfo);
typedef void(^A0APIClientUserProfileSuccess)(A0UserProfile *profile);
typedef void(^A0APIClientError)(NSError *error);

typedef void(^A0APIClientNewIdTokenSuccess)(A0Token *token);
typedef void(^A0APIClientNewDelegationTokenSuccess)(NSDictionary *delegationToken);

typedef void(^A0APIClientDelegationSuccess)(A0Token *tokenInfo);

/**
 `A0APIClient` is a class with convenience methods for Auth0 REST API.
 */
@interface A0APIClient : NSObject

///----------------------------------------
/// @name Initialization
///----------------------------------------

/**
 Initialise the Client with Auth0's app client ID and tenant name
 @param clientId app's client ID.
 @param tenant app's tenant name
 @return a new `A0APIClient` instance
 */
- (instancetype)initWithClientId:(NSString *)clientId andTenant:(NSString *)tenant;

/**
 Returns a shared instance of `A0APIClient`. This instance is initialised with clientId and tenant from Info plist file entries. These entries are `Auth0ClientId` and `Auth0Tenant`.
 @return a shared `A0APIClient` instance.
 */
+ (instancetype)sharedClient;

/**
 Logout from Auth0 API
 */
- (void)logout;

///----------------------------------------
/// @name Configuration for Auth0 App
///----------------------------------------

/**
 *  Auth0 application information after a call to fetchAppInfoWithSuccess:failure:. Default is nil.
 */
@property (readonly, nonatomic) A0Application *application;

/**
 Fetches Auth0 application info from Auth0 and configure itself.
 @param success block called on successful fetch of app info. Application information will be passed as a block parameter.
 @param failure block called when fetch of App information fails and reason of failure will be in error parameter
 */
- (void)fetchAppInfoWithSuccess:(A0APIClientFetchAppInfoSuccess)success
                        failure:(A0APIClientError)failure;

///----------------------------------------
/// @name Database Authentication
///----------------------------------------

/**
 *  Perform login of a user with username & password. The selected strategy is obtained from the application configured on the client.
 *  By default it will use the first database connection name found in `application` property. If it's nil a *connection_name* must be set in parameters.
 *
 *  @param username     username or email of the user to login
 *  @param password     password of the user to login
 *  @param parameters   optional parameters for Auth0 API. It can be nil
 *  @param success      block called on successful login with it's token info and profile
 *  @param failure      block called on failure with the reason as a parameter
 *  
 *  @see A0AuthParameters
 */
- (void)loginWithUsername:(NSString *)username
                 password:(NSString *)password
               parameters:(A0AuthParameters *)parameters
                  success:(A0APIClientAuthenticationSuccess)success
                  failure:(A0APIClientError)failure;

/**
 *  Perform signup for a new user in the application database. It can login the user after a succesful signup.
 *  By default it will use the first database connection name found in `application` property. If it's nil a *connection_name* must be set in parameters.
 *
 *  @param username       username or email of the new user
 *  @param password       password of the new user
 *  @param loginOnSuccess if after the signup the user should be automatically logged in
 *  @param parameters     optional parameters for Auth0 API. It can be nil
 *  @param success        block called on successful signup or login. If the user is not logged in both parameters are nil.
 *  @param failure        block called on failure with the reason as a parameter
 */
- (void)signUpWithUsername:(NSString *)username
                  password:(NSString *)password
            loginOnSuccess:(BOOL)loginOnSuccess
                parameters:(A0AuthParameters *)parameters
                   success:(A0APIClientAuthenticationSuccess)success
                   failure:(A0APIClientError)failure;

/**
 *  Change the password for a user.
 *  By default it will use the first database connection name found in `application` property. If it's nil a *connection_name* must be set in parameters.
 *
 *  @param newPassword new password for the user
 *  @param username    username to change its password. It can be an email or a username
 *  @param parameters  optional parameters for Auth0 API. It can be nil
 *  @param success     block called on success
 *  @param failure     block called on failure with the reason as a parameter
 */
- (void)changePassword:(NSString *)newPassword
           forUsername:(NSString *)username
            parameters:(A0AuthParameters *)parameters
               success:(void(^)())success
               failure:(A0APIClientError)failure;


/**
 *  Authenticates with a Database Connection using a signed JWT token.
 *  In order to use this method, a valid PublicKey must be registered for a user.
 *
 *  @param idToken    signed JWT token
 *  @param deviceName name of the device that signed the JWT. Must be URL safe and non nil.
 *  @param parameters optional parameters for Auth0 API. It can be nil
 *  @param success    block called on successful login with it's token info and profile
 *  @param failure    block called on failure with the reason as a parameter
 */
- (void)loginWithIdToken:(NSString *)idToken
              deviceName:(NSString *)deviceName
              parameters:(A0AuthParameters *)parameters
                 success:(A0APIClientAuthenticationSuccess)success
                 failure:(A0APIClientError)failure;

///----------------------------------------
/// @name Social Authentication
///----------------------------------------

/**
 *  Authenticate a user using credentials from a social identity provider like Facebook or Twitter
 *
 *  @param strategyName         name of the connection in Auth0 to authenticate with the social credentials. For example 'facebook', 'linkedin', etc.
 *  @param socialCredentials    credentials obtained from the identity provider. e.g. Facebook accessToken
 *  @param parameters           optional parameters for Auth0 API. It can be nil
 *  @param success              block called on successful authentication with user's token and profile
 *  @param failure              block called on failure with the reason as a parameter
 */
- (void)authenticateWithSocialConnectionName:(NSString *)connectionName
                                 credentials:(A0IdentityProviderCredentials *)socialCredentials
                                  parameters:(A0AuthParameters *)parameters
                                     success:(A0APIClientAuthenticationSuccess)success
                                     failure:(A0APIClientError)failure;


///----------------------------------------
/// @name Refresh Tokens
///----------------------------------------

/**
 *  Ask Auth0 API to return a new `id_token` for the user using their `refresh_token`
 *
 *  @param refreshToken user's refresh token
 *  @param parameters   optional parameters for Auth0 API. It can be nil
 *  @param success      block called on successful request with new token information.
 *  @param failure      block called on failure with the reason as a parameter
 */
- (void)fetchNewIdTokenWithRefreshToken:(NSString *)refreshToken
                             parameters:(A0AuthParameters *)parameters
                                success:(A0APIClientNewIdTokenSuccess)success
                                failure:(A0APIClientError)failure;

/**
 *  Ask Auth0 API to return a new `id_token` for the user using a currently valid `id_token`
 *
 *  @param idToken          user's JWT token
 *  @param parameters       optional parameters for Auth0 API. It can be nil
 *  @param success          block called on successful request with new token information
 *  @param failure          block called on failure with the reason as a parameter
 */
- (void)fetchNewIdTokenWithIdToken:(NSString *)idToken
                        parameters:(A0AuthParameters *)parameters
                           success:(A0APIClientNewIdTokenSuccess)success
                           failure:(A0APIClientError)failure;

///----------------------------------------
/// @name Delegation API
///----------------------------------------

/**
 *  Performs delegated authentication against Auth0 API and returns a new token to call for example another API.
 *
 *  @param parameters delegation API parameters. Must not be nil
 *  @param success    block called on successful request with the token information
 *  @param failure    block called on failure with the reason of failure
 */
- (void)fetchDelegationTokenWithParameters:(A0AuthParameters *)parameters
                                   success:(A0APIClientNewDelegationTokenSuccess)success
                                   failure:(A0APIClientError)failure;

///----------------------------------------
/// @name User Profile
///----------------------------------------

/**
 *  Obtains the user's profile information from Auth0
 *
 *  @param idToken user's id_token
 *  @param success block called on successful request with user's profile
 *  @param failure block called on failure with the reason as a parameter
 */
- (void)fetchUserProfileWithIdToken:(NSString *)idToken
                            success:(A0APIClientUserProfileSuccess)success
                            failure:(A0APIClientError)failure;

///----------------------------------------
/// @name Link Account
///----------------------------------------

/**
 *  Unlink a specific account
 *
 *  @param userId      id of the account to unlink with the format `provider|identity_user_id`, e.g: `facebook|123456678`. You can use `A0UserIdentity`'s `identityId` method.
 *  @param accessToken Auth0 acces token for the user
 *  @param success     block called on successful unlink request
 *  @param failure     block called on failure with the reason as a parameter
 */
- (void)unlinkAccountWithUserId:(NSString *)userId
                    accessToken:(NSString *)accessToken
                        success:(void(^)())success
                        failure:(A0APIClientError)failure;
@end

@interface A0APIClient (Deprecated)

/**
 *  Calls Auth0 delegation API with the refresh_token to obtain a new id_token.
 *
 *  This method is deprecated please use `fetchNewIdTokenWithIdToken:parameters:success:failure:` or `fetchNewIdTokenWithRefreshToken:parameters:success:failure:` to get a new `id_token` or `fetchDelegationTokenWithParameters:success:failure:` to get a delegation token for another API.

 *  @param refreshToken user's refresh token
 *  @param parameters   optional parameters for Auth0 API. It can be nil
 *  @param success      block called on successful request with new token information.
 *  @param failure      block called on failure with the reason as a parameter
 *
 *  @deprecated 1.1.0
 */
- (void)delegationWithRefreshToken:(NSString *)refreshToken
                        parameters:(A0AuthParameters *)parameters
                           success:(A0APIClientDelegationSuccess)success
                           failure:(A0APIClientError)failure __attribute__((deprecated));

/**
 *  Calls Auth0 delegation API with the id_token to obtain a new id_token.
 *
 *  This method is deprecated please use `fetchNewIdTokenWithIdToken:parameters:success:failure:` or `fetchNewIdTokenWithRefreshToken:parameters:success:failure:` to get a new `id_token` or `fetchDelegationTokenWithParameters:success:failure:` to get a delegation token for another API.
 *
 *  @param idToken          user's id token
 *  @param parameters       optional parameters for Auth0 API. It can be nil
 *  @param success          block called on successful request with new token information.
 *  @param failure          block called on failure with the reason as a parameter
 *
 *  @deprecated 1.1.0
 */
- (void)delegationWithIdToken:(NSString *)idToken
                   parameters:(A0AuthParameters *)parameters
                      success:(A0APIClientDelegationSuccess)success
                      failure:(A0APIClientError)failure __attribute__((deprecated));

/**
 *  Obtains the user's profile information from Auth0 using Auth0's API accessToken
 *
 *  This method is deprecated, please use `A0UserAPIClient` to perform user authenticated request either with accessToken or JWT token.
 *  @param accessToken user's access_token
 *  @param success     block called on successful request with user's profile
 *  @param failure     block called on failure with the reason as a parameter
 *
 *  @see A0UserAPIClient
 *  @deprecated 1.3.0
 */
- (void)fetchUserProfileWithAccessToken:(NSString *)accessToken
                                success:(A0APIClientUserProfileSuccess)success
                                failure:(A0APIClientError)failure __attribute__((deprecated));

@end