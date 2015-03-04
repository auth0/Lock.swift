// A0GooglePlusAuthenticator.h
//
// Copyright (c) 2015 Auth0 (http://auth0.com)
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

/**
 * `A0GooglePlusAuthenticator` performs Google+ authentication using Google's official SDK.
 */
@interface A0GooglePlusAuthenticator : NSObject<A0AuthenticationProvider>

/**
 *  Creates a new authenticator with default scopes (login and email) and a clientId.
 *
 *  @param clientId application clientId in Google+
 *
 *  @return a new instance
 */
+ (instancetype)newAuthenticatorWithClientId:(NSString *)clientId;

/**
 *  Creates a new authenticator with a list of scopes and a clientId.
 *
 *  @param clientId application clientId in Google+
 *  @param scopes   list of scopes to send to Google+ API.
 *
 *  @return a new instance
 */
+ (instancetype)newAuthenticatorWithClientId:(NSString *)clientId andScopes:(NSArray *)scopes;
@end
