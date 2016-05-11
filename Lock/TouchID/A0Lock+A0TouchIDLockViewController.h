// A0Lock+A0TouchIDLockViewController.h
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

@class A0TouchIDLockViewController;

@interface A0Lock (A0TouchIDLockViewController)

/**
 *  Creates a new instance of `A0TouchIDLockViewController`
 *
 *  @return a new instance
 */
- (A0TouchIDLockViewController *)newTouchIDViewController;

/**
 *  Presents a `A0TouchIDLockViewController` from a UIViewController. This method takes care of embedding the `A0TouchIDLockViewController` inside a `UINavigationController`
 *
 *  @param touchIDController controller to present
 *  @param controller        controller that will present the TouchID VC.
 */
- (void)presentTouchIDController:(A0TouchIDLockViewController *)touchIDController fromController:(UIViewController *)controller;

/**
 *  Presents a `A0TouchIDLockViewController` from a UIViewController. This method takes care of embedding the `A0TouchIDLockViewController` inside a `UINavigationController`
 *
 *  @param touchIDController controller to present
 *  @param controller        controller that will present the TouchID UIViewController
 *  @param presentationStyle    used to present as modal TouchID UIViewController
 */
- (void)presentTouchIDController:(A0TouchIDLockViewController *)touchIDController fromController:(UIViewController *)controller presentationStyle:(UIModalPresentationStyle)presentationStyle;

@end
