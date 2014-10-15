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
#import "A0AuthenticationProvider.h"

@class A0Application, A0Strategy, A0UserProfile, A0Token, A0AuthParameters;

/**
 *  `A0IdentityProviderAuthenticator` provides a single interface to handle all interactions with different identity providers. Each identity provider (a class that conforms with the protocol `A0AuthenticationProvider`) to be used must be registered with this object.
 */
@interface A0IdentityProviderAuthenticator : NSObject

/**
 *  When no specific authentication provider is registered it will fallback to Safari Web Flow otherwise it will raise an error. Default is YES.
 */
@property (assign, nonatomic) BOOL useWebAsDefault;

/**
 *  Returns a shared instance of `A0IdentityProviderAuthenticator`
 *
 *  @return shared instance
 */
+ (A0IdentityProviderAuthenticator *)sharedInstance;

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
- (void)registerAuthenticationProvider:(id<A0AuthenticationProvider>)authenticationProvider;

/**
 *  Configures the authentication with the enabled identity providers in Auth0's application. Must be called at least once before trying to authenticate with any connection.
 *
 *  @param application Auth0 application with the identity provider configuration
 */
- (void)configureForApplication:(A0Application *)application;

/**
 *  Authenticates a user using an identity provider specified by `A0Strategy` and the registered method (Safari or Native). 
 *  For the connection name it will use the first one by default.
 *  You can override the default connection name setting in parameters the key `connection` with the name of the connection that should be used instead.
 *
 *  @param strategy   object that represent an authentication strategy with an identity provider.
 *  @param parameters  authentication parameters for Auth0 API.
 *  @param success    block called on successful authentication with user's token info and profile
 *  @param failure    block called on error with the reason as a parameter
 */
- (void)authenticateForStrategy:(A0Strategy *)strategy
                     parameters:(A0AuthParameters *)parameters
                        success:(void(^)(A0UserProfile *profile, A0Token *token))success
                        failure:(void(^)(NSError *error))failure;

/**
 *  Checks if the given startegy has a registered authenticator (either Native or Safari).
 *
 *  @param strategy an Auth0 strategy
 *
 *  @return if the authenticator can authenticate with the strategy
 */
- (BOOL)canAuthenticateStrategy:(A0Strategy *)strategy;

/**
 *  Method to handle authentication performed by a third party native application e.g. Facebook App. It must be called from your app's AppDelegate `-application:openURL:sourceApplication:annotation:` method.
 *
 *  @param url         url with authentication result
 *  @param application application that performed the authentication
 *  @return if the URL could be handled by the application
 */
- (BOOL)handleURL:(NSURL *)url sourceApplication:(NSString *)application;

/**
 *  Clear all identity provider session information.
 */
- (void)clearSessions;

@end
