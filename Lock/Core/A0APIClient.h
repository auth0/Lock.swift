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
#import "A0APIRouter.h"

@class A0Application, A0Strategy, A0IdentityProviderCredentials, A0UserProfile, A0Token, A0AuthParameters;

typedef void(^A0APIClientFetchAppInfoSuccess)(A0Application* __nonnull application);
typedef void(^A0APIClientAuthenticationSuccess)(A0UserProfile* __nonnull profile, A0Token* __nonnull tokenInfo);
typedef void(^A0APIClientSignUpSuccess)(A0UserProfile* __nullable profile, A0Token* __nullable tokenInfo);
typedef void(^A0APIClientUserProfileSuccess)(A0UserProfile* __nonnull profile);
typedef void(^A0APIClientError)(NSError* __nonnull error);

typedef void(^A0APIClientNewIdTokenSuccess)(A0Token* __nonnull token);
typedef void(^A0APIClientNewDelegationTokenSuccess)(NSDictionary* __nonnull delegationToken);

typedef void(^A0APIClientDelegationSuccess)(A0Token* __nonnull tokenInfo);

NS_ASSUME_NONNULL_BEGIN

/**
 `A0APIClient` is a class with convenience methods for Auth0 REST API.
 */
@interface A0APIClient : NSObject

///----------------------------------------
/// @name Initialization
///----------------------------------------

/**
 Initialise the Client with a API router
 @param router API routes handler
 @return a new `A0APIClient` instance
 */
- (instancetype)initWithAPIRouter:(id<A0APIRouter>)router;

/**
 Logout from Auth0 API
 */
- (void)logout;

/**
 *  Returns a shared instance of `A0APIClient`. This instance is initialised with clientId and tenant from Info plist file entries. These entries are `Auth0ClientId` and `Auth0Tenant`.
 *  It can also be instantiated with a custom domain instead of Auth0's.
 *  We recommend keeping yourself the `A0APIClient` instead instead of relying in this singleton, for this reason this method is deprecated and we suggest using A0Lock class to obtain an instance of this class.
 *  @deprecated 1.12.0. We recommend creating an instance of A0Lock and call its method `-apiClient` to obtain an instance of this object.
 *  @return a shared `A0APIClient` instance.
 */
+ (instancetype)sharedClient DEPRECATED_MSG_ATTRIBUTE("Call A0Lock -apiClient to get an instance");

///----------------------------------------
/// @name Configuration for Auth0 App
///----------------------------------------

/**
 *  Object that provides all URLs and Paths of Auth0 API. By default a router for API v1 is used.
 */
@property (strong, nonatomic) id<A0APIRouter> router;

/**
 *  Auth0 app client id
 */
@property (readonly, nonatomic) NSString *clientId;

/**
 *  Auth0 app tenant name
 */
@property (readonly, nonatomic) NSString *tenant;

/**
 *  Auth0 app base URL
 */
@property (readonly, nonatomic) NSURL *baseURL;

/**
 *  Auth0 application information after a call to fetchAppInfoWithSuccess:failure:. Default is nil.
 */
@property (readonly, nullable, nonatomic) A0Application *application;

/**
 *  Auth0's telemetry info sent along with every request
 */
@property (nullable, nonatomic) NSString *telemetryInfo;

/**
 Fetches Auth0 application info from Auth0 and configure itself.
 @param success block called on successful fetch of app info. Application information will be passed as a block parameter.
 @param failure block called when fetch of App information fails and reason of failure will be in error parameter
 */
- (NSURLSessionDataTask *)fetchAppInfoWithSuccess:(A0APIClientFetchAppInfoSuccess)success
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
 *  @return an instance of `NSURLSessionDataTask`
 *  @see A0AuthParameters
 */
- (NSURLSessionDataTask *)loginWithUsername:(NSString *)username
                                   password:(NSString *)password
                                 parameters:(nullable A0AuthParameters *)parameters
                                    success:(A0APIClientAuthenticationSuccess)success
                                    failure:(A0APIClientError)failure;

/**
 *  Perform signup for a new user in the application's database connection using email, username & password.
 *  It can login the user after a succesful signup.
 *  By default it will use the first database connection name found in `application` property, if it's nil a *connection_name* must be set in parameters.
 *
 *  @param email          email of the new user
 *  @param username       username of the new user
 *  @param password       password of the new user
 *  @param loginOnSuccess if after the signup the user should be automatically logged in
 *  @param parameters     optional parameters for Auth0 API. It can be nil
 *  @param success        block called on successful signup or login. If the user is not logged in both parameters are nil.
 *  @param failure        block called on failure with the reason as a parameter
 *
 *  @return an instance of `NSURLSessionDataTask`
 */
- (NSURLSessionDataTask *)signUpWithEmail:(NSString *)email
                                 username:(nullable NSString *)username
                                 password:(NSString *)password
                           loginOnSuccess:(BOOL)loginOnSuccess
                               parameters:(nullable A0AuthParameters *)parameters
                                  success:(A0APIClientSignUpSuccess)success
                                  failure:(A0APIClientError)failure;

/**
 *  Perform signup for a new user in the application's database connection using email & password.
 *  Only use this method if the Database connection does not require username.
 *  It can login the user after a succesful signup.
 *  By default it will use the first database connection name found in `application` property, if it's nil a *connection_name* must be set in parameters.
 *
 *  @param email          email of the new user
 *  @param password       password of the new user
 *  @param loginOnSuccess if after the signup the user should be automatically logged in
 *  @param parameters     optional parameters for Auth0 API. It can be nil
 *  @param success        block called on successful signup or login. If the user is not logged in both parameters are nil.
 *  @param failure        block called on failure with the reason as a parameter
 *
 *  @return an instance of `NSURLSessionDataTask`
 */
- (NSURLSessionDataTask *)signUpWithEmail:(NSString *)email
                                 password:(NSString *)password
                           loginOnSuccess:(BOOL)loginOnSuccess
                               parameters:(nullable A0AuthParameters *)parameters
                                  success:(A0APIClientSignUpSuccess)success
                                  failure:(A0APIClientError)failure;

/**
 *  Perform signup for a new user in the application's database connection using username & password.
 *  Only use this method if the Database connection uses a custom DB otherwise it will fail.
 *  It can login the user after a succesful signup.
 *  By default it will use the first database connection name found in `application` property, if it's nil a *connection_name* must be set in parameters.
 *
 *  @param username       username of the new user
 *  @param password       password of the new user
 *  @param loginOnSuccess if after the signup the user should be automatically logged in
 *  @param parameters     optional parameters for Auth0 API. It can be nil
 *  @param success        block called on successful signup or login. If the user is not logged in both parameters are nil.
 *  @param failure        block called on failure with the reason as a parameter
 *
 *  @return an instance of `NSURLSessionDataTask`
 */
- (NSURLSessionDataTask *)signUpWithUsername:(NSString *)username
                                    password:(NSString *)password
                              loginOnSuccess:(BOOL)loginOnSuccess
                                  parameters:(nullable A0AuthParameters *)parameters
                                     success:(A0APIClientSignUpSuccess)success
                                     failure:(A0APIClientError)failure;

/**
 *  Request a change password for the given user. Auth0 will send an email with a link to input a new password.
 *  By default it will use the first database connection name found in `application` property. If it's nil a *connection_name* must be set in parameters.
 *
 *  @param username    username to change its password. It can be an email or a username
 *  @param parameters  optional parameters for Auth0 API. It can be nil
 *  @param success     block called on success
 *  @param failure     block called on failure with the reason as a parameter
 *
 *  @return an instance of `NSURLSessionDataTask`
 */
- (NSURLSessionDataTask *)requestChangePasswordForUsername:(NSString *)username
                                                parameters:(nullable A0AuthParameters *)parameters
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
 *
 *  @return an instance of `NSURLSessionDataTask`
 */
- (NSURLSessionDataTask *)loginWithIdToken:(NSString *)idToken
                                deviceName:(NSString *)deviceName
                                parameters:(nullable A0AuthParameters *)parameters
                                   success:(A0APIClientAuthenticationSuccess)success
                                   failure:(A0APIClientError)failure;

///----------------------------------------
/// @name SMS Authentication
///----------------------------------------

/**
 *  Perform login of a user with phone number & SMS code using `sms` connection.
 *  If app info is available and it doesn't have a `sms` connection, it will fail.
 *
 *  @param phoneNumber  phone number where the user received the code and previously registered with.
 *  @param passcode     passcode received by SMS.
 *  @param parameters   optional parameters for Auth0 API. It can be nil
 *  @param success      block called on successful login with it's token info and profile
 *  @param failure      block called on failure with the reason as a parameter
 *
 *  @return an instance of `NSURLSessionDataTask`
 *  @see A0AuthParameters
 */
- (NSURLSessionDataTask *)loginWithPhoneNumber:(NSString *)phoneNumber
                                      passcode:(NSString *)passcode
                                    parameters:(nullable A0AuthParameters *)parameters
                                       success:(A0APIClientAuthenticationSuccess)success
                                       failure:(A0APIClientError)failure;

///----------------------------------------
/// @name Email Authentication
///----------------------------------------

/**
 *  Perform login of a user with email address & code using `email` connection.
 *  If app info is available and it doesn't have a `email` connection, it will fail.
 *
 *  @param email        address where the user received the code and previously registered with.
 *  @param passcode     passcode received by email.
 *  @param parameters   optional parameters for Auth0 API. It can be nil
 *  @param success      block called on successful login with it's token info and profile
 *  @param failure      block called on failure with the reason as a parameter
 *
 *  @return an instance of `NSURLSessionDataTask`
 *  @see A0AuthParameters
 */
- (NSURLSessionDataTask *)loginWithEmail:(NSString *)email
                                passcode:(NSString *)passcode
                              parameters:(nullable A0AuthParameters *)parameters
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
 *
 *  @return an instance of `NSURLSessionDataTask`
 */
- (NSURLSessionDataTask *)authenticateWithSocialConnectionName:(NSString *)connectionName
                                                   credentials:(A0IdentityProviderCredentials *)socialCredentials
                                                    parameters:(nullable A0AuthParameters *)parameters
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
 *
 *  @return an instance of `NSURLSessionDataTask`
 */
- (NSURLSessionDataTask *)fetchNewIdTokenWithRefreshToken:(NSString *)refreshToken
                                               parameters:(nullable A0AuthParameters *)parameters
                                                  success:(A0APIClientNewIdTokenSuccess)success
                                                  failure:(A0APIClientError)failure;

/**
 *  Ask Auth0 API to return a new `id_token` for the user using a currently valid `id_token`
 *
 *  @param idToken          user's JWT token
 *  @param parameters       optional parameters for Auth0 API. It can be nil
 *  @param success          block called on successful request with new token information
 *  @param failure          block called on failure with the reason as a parameter
 *
 *  @return an instance of `NSURLSessionDataTask`
 */
- (NSURLSessionDataTask *)fetchNewIdTokenWithIdToken:(NSString *)idToken
                                          parameters:(nullable A0AuthParameters *)parameters
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
 *
 *  @return an instance of `NSURLSessionDataTask`
 */
- (NSURLSessionDataTask *)fetchDelegationTokenWithParameters:(A0AuthParameters *)parameters
                                                     success:(A0APIClientNewDelegationTokenSuccess)success
                                                     failure:(A0APIClientError)failure;

///----------------------------------------
/// @name Token Request
///----------------------------------------

/**
 *  Change an authorization code obtained from authorize endpoint for Auth0 token using the token endpoint
 *
 *  @param parameters sent to token endpoint
 *  @param callback   called with an error or the Auth0 token obtained
 *
 *  @return an instance of `NSURLSessionDataTask`
 */
- (NSURLSessionDataTask *)requestTokenWithParameters:(NSDictionary *)parameters
                                            callback:(void(^)(NSError * _Nonnull error, A0Token * _Nonnull token))callback;

///----------------------------------------
/// @name User Profile
///----------------------------------------

/**
 *  Obtains the user's profile information from Auth0
 *
 *  @param idToken user's id_token
 *  @param success block called on successful request with user's profile
 *  @param failure block called on failure with the reason as a parameter
 *
 *  @return an instance of `NSURLSessionDataTask`
 */
- (NSURLSessionDataTask *)fetchUserProfileWithIdToken:(NSString *)idToken
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
 *
 *  @return an instance of `NSURLSessionDataTask`
 */
- (NSURLSessionDataTask *)unlinkAccountWithUserId:(NSString *)userId
                                      accessToken:(NSString *)accessToken
                                          success:(void(^)())success
                                          failure:(A0APIClientError)failure;

///----------------------------------------
/// @name Passwordless Authentication
///----------------------------------------

/**
 *  Start passwordless authentication using SMS to send a One Time Password to the user
 *
 *  @param phoneNumber of the phone that will receive the OTP via SMS message
 *  @param success     block called when the SMS was sent successfully
 *  @param failure     block called on failure with the reason as a parameter
 *
 *  @return an instance of `NSURLSessionDataTask`
 */
- (NSURLSessionDataTask *)startPasswordlessWithPhoneNumber:(NSString *)phoneNumber
                                                   success:(void(^)())success
                                                   failure:(A0APIClientError)failure;

/**
 *  Start passwordless authentication using Email to send a One Time Password to the user
 *
 *  @param email    that will receive the OTP
 *  @param success  block called when the Email was sent successfully
 *  @param failure  block called on failure with the reason as a parameter
 *
 *  @return an instance of `NSURLSessionDataTask`
 */
- (NSURLSessionDataTask *)startPasswordlessWithEmail:(NSString *)email
                                             success:(void(^)())success
                                             failure:(A0APIClientError)failure;

/**
 *  Start passwordless authentication using Email to send a Magic Link to the user.
 *  The magic link will only work for iOS 9 and if the application is properly configured for Universal Links.
 *
 *  @param email        that will receive the magic link
 *  @param parameters   used when the user authenticates with the magic link
 *  @param success      block called when the Email was sent successfully
 *  @param failure      block called on failure with the reason as a parameter
 *
 *  @return an instance of `NSURLSessionDataTask`
 */
- (NSURLSessionDataTask *)startPasswordlessWithMagicLinkInEmail:(NSString *)email
                                                     parameters:(A0AuthParameters *)parameters
                                                        success:(void(^)())success
                                                        failure:(A0APIClientError)failure;

/**
 *  Start passwordless authentication using SMS to send a Magic Link to the user.
 *  The magic link will only work for iOS 9 and if the application is properly configured for Universal Links.
 *
 *  @param phoneNumber that will receive the magic link
 *  @param parameters  used when the user authenticates with the magic link
 *  @param success     block called when the Email was sent successfully
 *  @param failure     block called on failure with the reason as a parameter
 *
 *  @return an instance of `NSURLSessionDataTask`
 */
- (NSURLSessionDataTask *)startPasswordlessWithMagicLinkInSMS:(NSString *)phoneNumber
                                                   parameters:(A0AuthParameters *)parameters
                                                      success:(void(^)())success
                                                      failure:(A0APIClientError)failure;
@end

@interface A0APIClient (Deprecated)

/**
 *  Initialise the Client with Auth0's app client ID and tenant name.
 *
 *  @param clientId app's client ID.
 *  @param tenant app's tenant name
 *
 *  @deprecated 1.12.0. Use domain & clientId to build and instance of just use A0Lock class
 *  @see A0Lock
 *  @return a new `A0APIClient` instance
 */
- (instancetype)initWithClientId:(NSString *)clientId andTenant:(NSString *)tenant DEPRECATED_ATTRIBUTE;

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
                        parameters:(nullable A0AuthParameters *)parameters
                           success:(A0APIClientDelegationSuccess)success
                           failure:(A0APIClientError)failure DEPRECATED_ATTRIBUTE;

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
                   parameters:(nullable A0AuthParameters *)parameters
                      success:(A0APIClientDelegationSuccess)success
                      failure:(A0APIClientError)failure DEPRECATED_ATTRIBUTE;

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
                                failure:(A0APIClientError)failure DEPRECATED_ATTRIBUTE;


/**
 *  Change the password for a user.
 *  By default it will use the first database connection name found in `application` property. If it's nil a *connection_name* must be set in parameters.
 *
 *  @param newPassword new password for the user
 *  @param username    username to change its password. It can be an email or a username
 *  @param parameters  optional parameters for Auth0 API. It can be nil
 *  @param success     block called on success
 *  @param failure     block called on failure with the reason as a parameter
 *
 *  @return an instance of `NSURLSessionDataTask`
 *  @deprecated 1.22.1
 */
- (NSURLSessionDataTask *)changePassword:(NSString *)newPassword
                             forUsername:(NSString *)username
                              parameters:(nullable A0AuthParameters *)parameters
                                 success:(void(^)())success
                                 failure:(A0APIClientError)failure DEPRECATED_ATTRIBUTE;

@end

NS_ASSUME_NONNULL_END