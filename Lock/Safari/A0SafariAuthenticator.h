// A0SafariAuthenticator.h
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
#import <Lock/A0BaseAuthenticator.h>

NS_ASSUME_NONNULL_BEGIN

@class A0Lock;

/**
 *  Handles authentication using `SFSafariViewController` for either a specific connection or just shows Auth0 Lock web login form.
 *  In iOS 9 you need to have Universal Links configured for your Auth0 subdomain and for older versions it will fallback to custom schemes.
 *  The callback URL will be:
 *  - Universal Link: `https://{YOUR_AUTH0_DOMAIN}/ios/{BUNDLE_IDENTIFIER}/callback`
 *  - Custom Scheme: `{BUNDLE_IDENTIFIER}://{YOUR_AUTH0_DOMAIN}/ios/{BUNDLE_IDENTIFIER}/callback`
 *  So you need to add them to your Application `Allowed Callbacks` section in Auth0 Dashboard
 *
 *  You can also force it to use a custom scheme by setting the flag `useUniversalLink` to `NO` when initialising the authenticator
 * 
 * ## Universal Links (iOS 9+)
 * 
 * Auth0 provides support to use callbacks as universal links by serving the file `https://{auth0 domain}/apple-app-site-association`, 
 * the only requirement is to provide the application bundleIdentifier and Apple Developer TeamId in your Auth0 Application settings.
 */
@interface A0SafariAuthenticator : A0BaseAuthenticator

/**
 *  Initialise the authenticator with a Lock instance for a specific connection name.
 *
 *  @param lock           instance with Auth0 credentials
 *  @param connectionName that will be handled by this authenticator
 *
 *  @return an initialised instance.
 */
- (instancetype)initWithLock:(A0Lock *)lock connectionName:(NSString *)connectionName;

/**
 *  Initialise the authenticator with a Lock instance for a specific connection name.
 *
 *  @param lock                 instance with Auth0 credentials
 *  @param connectionName       that will be handled by this authenticator
 *  @param useUniversalLink     for callback, if the device is running iOS 9+ otherwise use custom schemes
 *
 *  @return an initialised instance.
 */
- (instancetype)initWithLock:(A0Lock *)lock connectionName:(NSString *)connectionName useUniversalLink:(BOOL)useUniversalLink;

/**
 *  Initialise the authenticator with a Lock instance that will show Auth0's configured web login page
 *
 *  @param lock           instance with Auth0 credentials
 *
 *  @return an initialised instance.
 */
- (instancetype)initWithLock:(A0Lock *)lock;

/**
 *  Initialise the authenticator with a Lock instance that will show Auth0's configured web login page
 *
 *  @param lock                 instance with Auth0 credentials
 *  @param useUniversalLink     for callback, if the device is running iOS 9+ otherwise use custom schemes. If it's NO it will always use custom schemes
 *
 *  @return an initialised instance.
 */
- (instancetype)initWithLock:(A0Lock *)lock useUniversalLink:(BOOL)useUniversalLink;

@end

NS_ASSUME_NONNULL_END