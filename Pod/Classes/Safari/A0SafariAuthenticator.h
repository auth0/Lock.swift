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
 *  Handles authentication for a Auth0 connection that doesn't have native integration using `SFSafariViewController`.
 *  In iOS 9 you need to have Universal Links configured for your Auth0 subdomain and for older versions it will fallback to custom schemes.
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

@end

NS_ASSUME_NONNULL_END