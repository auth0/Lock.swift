//  A0WebAuthenticator.h
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
#import <Lock/A0BaseAuthenticator.h>

@class A0Strategy, A0Application;

 __attribute__((deprecated("Please use WebView authentication due to Apple rejecting apps that authenticate with Safari")))
/**
 Safari based authentication for IdP using Auth0
 @deprecated Use Embedded WebView based authentication due to Apple rejections
 */
@interface A0WebAuthenticator : A0BaseAuthenticator

/**
 *  Initialize object using Auth0 account information
 *
 *  @param authorizeURL   of the /authorize endpoint under your Auth0 subdomain
 *  @param clientId       of your Auth0 account
 *  @param connectionName of the IdP to authenticate with
 *
 *  @return an initialised object
 */
- (instancetype)initWithAuthorizeURL:(NSURL *)authorizeURL clientId:(NSString *)clientId connectionName:(NSString *)connectionName;

+ (instancetype)newWebAuthenticationForStrategy:(A0Strategy *)strategy
                                  ofApplication:(A0Application *)application;

@end
