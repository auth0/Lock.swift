// A0Lock+A0LockViewController.h
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

#import <UIKit/UIKit.h>
#import "A0Lock.h"

@class A0LockViewController, A0LockSignUpViewController;

@interface A0Lock (A0LockViewController)

/**
 *  Creates a new `A0LockViewController` instance
 *
 *  @return a new Lock ViewController
 */
- (A0LockViewController *)newLockViewController;

/**
 *  Creates a new `A0LockSignUpViewController` instance
 *
 *  @return a new Lock SignUp ViewController
 */
- (A0LockSignUpViewController *)newSignUpViewController;

/**
 *  Presents `A0LockViewController` from a UIViewController.
 *
 *  @param lockController   controller to present
 *  @param controller       controller that will present Lock UIViewController.
 */
- (void)presentLockController:(A0LockViewController *)lockController fromController:(UIViewController *)controller;

/**
 *  Presents `A0LockViewController` from a UIViewController.
 *
 *  @param lockController       controller to present
 *  @param controller           controller that will present Lock UIViewController.
 *  @param presentationStyle    used to present as modal Lock UIViewController
 */
- (void)presentLockController:(A0LockViewController *)lockController fromController:(UIViewController *)controller presentationStyle:(UIModalPresentationStyle)presentationStyle;

@end
