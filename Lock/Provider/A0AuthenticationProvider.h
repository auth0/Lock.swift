// A0AuthenticationProvider.h
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

@class A0UserProfile, A0Token, A0AuthParameters;

typedef void(^A0IdPAuthenticationBlock)(A0UserProfile* __nonnull profile, A0Token* __nonnull token);
typedef void(^A0IdPAuthenticationErrorBlock)(NSError* __nonnull error);

NS_ASSUME_NONNULL_BEGIN

/**
 *  Protocol for all Identity Providers
 */
@protocol A0AuthenticationProvider <NSObject>

@required

/**
 *  Identity provider identifier. Must be equal to your app's connection name
 *
 *  @return provider identifier
 */
- (NSString *)identifier;

/**
 *  Authenticates the user with this identity provider
 *
 *  @param parameters authentication parameters for Auth0 API
 *  @param success block called on successful authentication with user's credentials
 *  @param failure block called on error with reason as a parameter
 */
- (void)authenticateWithParameters:(A0AuthParameters *)parameters success:(A0IdPAuthenticationBlock)success failure:(A0IdPAuthenticationErrorBlock)failure;

/**
 *  Clear all active sessions of this identity provider
 */
- (void)clearSessions;

/**
 *  Handles an URL when authenticating with a third party app.
 *
 *  @param url               url with authentication information
 *  @param sourceApplication application that performed the authentication
 *
 *  @return if the URL is valid
 */
- (BOOL)handleURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication;

/**
 *  Notifies the Authenticator that the application has been launched. 
 *  This method should not perform any UI or action that will alter the normal flow of an application, 
 *  its meant to be a way to initialize the authenticator itself on application launch.
 *
 *  @param launchOptions Options used to launch the application
 */
- (void)applicationLaunchedWithOptions:(nullable NSDictionary *)launchOptions;

@end

NS_ASSUME_NONNULL_END
