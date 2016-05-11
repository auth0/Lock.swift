// A0Lock+A0LockViewController.m
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

#import "A0Lock+A0LockViewController.h"
#import "A0LockViewController.h"
#import "A0LockSignUpViewController.h"
#import "A0NavigationController.h"

@implementation A0Lock (A0LockViewController)

- (A0LockViewController *)newLockViewController {
    return [[A0LockViewController alloc] initWithLock:self];
}

- (A0LockSignUpViewController *)newSignUpViewController {
    return [[A0LockSignUpViewController alloc] initWithLock:self];
}

- (void)presentLockController:(A0LockViewController *)lockController fromController:(UIViewController *)controller {
    UIModalPresentationStyle style = UIModalPresentationFullScreen;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        style = UIModalPresentationFormSheet;
    }
    [self presentLockController:lockController fromController:controller presentationStyle:style];
}

- (void)presentLockController:(A0LockViewController *)lockController fromController:(UIViewController *)controller presentationStyle:(UIModalPresentationStyle)presentationStyle {
    UINavigationController *navigationController = [[A0NavigationController alloc] initWithRootViewController:lockController];
    navigationController.navigationBarHidden = YES;
    navigationController.modalPresentationStyle = presentationStyle;
    [controller presentViewController:navigationController animated:YES completion:nil];
}
@end
