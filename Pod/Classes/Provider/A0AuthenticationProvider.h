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
#import "A0IdentityProviderCredentials.h"

@class A0UserProfile, A0Token, A0AuthParameters;

/**
 *  Protocol for all Identity Providers
 */
@protocol A0AuthenticationProvider <NSObject>

@required

/**
 *  Identity provider identifier. Must be equal to your app's strategy name
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
- (void)authenticateWithParameters:(A0AuthParameters *)parameters success:(void(^)(A0UserProfile *profile, A0Token *token))success failure:(void(^)(NSError *))failure;

/**
 *  Clear all active sessions of this identity provider
 */
- (void)clearSessions;

@optional

/**
 *  Handles an URL when authenticating with a third party app.
 *
 *  @param url               url with authentication information
 *  @param sourceApplication application that performed the authentication
 *
 *  @return if the URL is valid
 */
- (BOOL)handleURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication;

@end
