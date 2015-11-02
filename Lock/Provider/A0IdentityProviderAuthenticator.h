// A0IdentityProviderAuthenticator.h
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
#import "A0BaseAuthenticator.h"

@class A0Application, A0Strategy, A0UserProfile, A0Token, A0AuthParameters, A0Lock;

NS_ASSUME_NONNULL_BEGIN

/**
 *  `A0IdentityProviderAuthenticator` provides a single interface to handle all interactions with different identity providers. Each identity provider (a class that conforms with the protocol `A0AuthenticationProvider`) to be used must be registered with this object.
 *  We recommend using `A0Lock` object instead of this object directly.
 *  @see A0Lock
 */
@interface A0IdentityProviderAuthenticator : NSObject

/**
 *  Initialize IdP authenticator with for a Lock instance.
 *
 *  @param lock instance of A0Lock that provides app configuration and Auth API client.
 *
 *  @return an initialized instance
 */
- (instancetype)initWithLock:(A0Lock *)lock;

/**
 *  Register an array of identity providers.
 *
 *  @param authenticationProviders array of object that conforms `A0AuthenticationProvider` protocol
 *  @see -registerAuthenticationProvider:
 */
- (void)registerAuthenticationProviders:(NSArray *)authenticationProviders;

/**
 *  Register an identity provider using it's identifier, so if a provider was already registered with the same identifier, it will be replaced.
 *
 *  @param authenticationProvider object that conforms `A0AuthenticationProvider` protocol
 */
- (void)registerAuthenticationProvider:(A0BaseAuthenticator *)authenticationProvider;

/**
 *  Authenticate a user with a specific connection name using a registered IdP authenticator registered for the Auth0 connection.
 *
 *  @param connectionName   that will be used to authenticate the user. It must be enabled in your Auth0 Application (via Dashboard).
 *  @param parameters       authentication parameters for Auth0 API.
 *  @param success          block called on successful authentication with user's token info and profile
 *  @param failure          block called on error with the reason as a parameter
 */
- (void)authenticateWithConnectionName:(NSString *)connectionName
                            parameters:(nullable A0AuthParameters *)parameters
                               success:(A0IdPAuthenticationBlock)success
                               failure:(A0IdPAuthenticationErrorBlock)failure;
/**
 *  Method to handle authentication performed by a third party native application e.g. Facebook App. It must be called from your app's AppDelegate `-application:openURL:sourceApplication:annotation:` method.
 *
 *  @param url         url with authentication result
 *  @param application application that performed the authentication
 *  @return if the URL could be handled by the application
 */
- (BOOL)handleURL:(NSURL *)url sourceApplication:(nullable NSString *)application;

/**
 *  Clear all identity provider session information.
 */
- (void)clearSessions;

/**
 *  Notifies all authenticator that application has been launched.
 *
 *  @param launchOptions dictionary with launch options
 */
- (void)applicationLaunchedWithOptions:(nullable NSDictionary *)launchOptions;

@end

@interface A0IdentityProviderAuthenticator (Deprecated)

/**
 *  When no specific authentication provider is registered it will fallback to Safari Web Flow otherwise it will raise an error. Default is YES.
 *  @deprecated 1.15.0. Since Apple does not allow Safari authentication by default we don't assume Safari
 */
@property (assign, nonatomic) BOOL useWebAsDefault DEPRECATED_MSG_ATTRIBUTE("By default now it raises an error when no provider is registered");

/**
 *  Initialize IdP authenticator
 *
 *  @return an initialized instance.
 *  @deprecated 1.12.0. Use `-initWithLock:` instead or create an instance of A0Lock and call its method `-identityProviderAuthenticator` to obtain an instance of this object.
 */
- (instancetype)init DEPRECATED_MSG_ATTRIBUTE("Use -initWithLock: instead");

/**
 *  Returns a shared instance of `A0IdentityProviderAuthenticator`
 *
 *  @return shared instance
 *  @deprecated 1.12.0. We recommend creating an instance of A0Lock and call its method `-identityProviderAuthenticator` to obtain an instance of this object.
 *  @see A0Lock
 */
+ (A0IdentityProviderAuthenticator *)sharedInstance DEPRECATED_MSG_ATTRIBUTE("Use A0Lock identityProviderAuthenticator to obtain an instance");

/**
 *  Configures the authentication with the enabled identity providers in Auth0's application. Must be called at least once before trying to authenticate with any connection.
 *
 *  @param application Auth0 application with the identity provider configuration
 *  @deprecated 1.15.0. There is no need to call this method to configure this object with Auth0 account information.
 */
- (void)configureForApplication:(A0Application *)application DEPRECATED_MSG_ATTRIBUTE("Configuring IdP authenticator with Auth0 app is no longer necessary");

/**
 *  Authenticates a user using an identity provider specified by `A0Strategy` and the registered method (Safari or Native).
 *  For the connection name it will use the first one by default.
 *  You can override the default connection name setting in parameters the key `connection` with the name of the connection that should be used instead.
 *
 *  @param strategy   object that represent an authentication strategy with an identity provider.
 *  @param parameters  authentication parameters for Auth0 API.
 *  @param success    block called on successful authentication with user's token info and profile
 *  @param failure    block called on error with the reason as a parameter
 *  @deprecated 1.15.0. Use `-authenticateWithConnectionName:parameters:success:failure:` instead
 */
- (void)authenticateForStrategy:(A0Strategy *)strategy
                     parameters:(nullable A0AuthParameters *)parameters
                        success:(A0IdPAuthenticationBlock)success
                        failure:(A0IdPAuthenticationErrorBlock)failure DEPRECATED_MSG_ATTRIBUTE("Use -authenticateWithConnectionName:parameters:success:failure: instead");

/**
 *  Authenticates a user using an identity provider specified by `A0Strategy`'s name and the registered method (Safari or Native).
 *  For the connection name it will use the first one by default.
 *  You can override the default connection name setting in parameters the key `connection` with the name of the connection that should be used instead.
 *
 *  @param strategy   object that represent an authentication strategy with an identity provider.
 *  @param parameters  authentication parameters for Auth0 API.
 *  @param success    block called on successful authentication with user's token info and profile
 *  @param failure    block called on error with the reason as a parameter
 *  @deprecated 1.15.0. Use `-authenticateWithConnectionName:parameters:success:failure:` instead
 */
- (void)authenticateForStrategyName:(NSString *)strategyName
                         parameters:(A0AuthParameters *)parameters
                            success:(A0IdPAuthenticationBlock)success
                            failure:(A0IdPAuthenticationErrorBlock)failure DEPRECATED_MSG_ATTRIBUTE("Use -authenticateWithConnectionName:parameters:success:failure: instead");

/**
 *  Checks if the given startegy has a registered authenticator (either Native or Safari).
 *
 *  @param strategy an Auth0 strategy
 *
 *  @return if the authenticator can authenticate with the strategy
 *  @deprecated 1.15.0. If no IdP authenticator is registered a default will be used.
 */
- (BOOL)canAuthenticateStrategy:(A0Strategy *)strategy DEPRECATED_ATTRIBUTE;

@end

NS_ASSUME_NONNULL_END
