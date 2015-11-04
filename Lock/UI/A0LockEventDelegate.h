// A0LockEventDelegate.h
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

NS_ASSUME_NONNULL_BEGIN

@class A0Token, A0UserProfile, A0LockViewController;

/**
 *  Object that allows to control to some extent the navigation inside Lock UI.
 */
@interface A0LockEventDelegate : NSObject

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithLockViewController:(A0LockViewController *)controller NS_DESIGNATED_INITIALIZER;

/**
 *  Dismiss all custom UIViewControllers pushed inside Lock and shows it's main UI.
 */
- (void)backToLock;

/**
 *  Dismiss A0LockViewController, like tapping the close button if `closable` is true
 */
- (void)dismissLock;

/**
 *  Calls `onAuthenticationBlock` of `A0LockViewController` with token and profile
 *
 *  @param token   obtained during authentication
 *  @param profile of the authenticated user
 */
- (void)userAuthenticatedWithToken:(A0Token *)token profile:(A0UserProfile *)profile;

@end

NS_ASSUME_NONNULL_END