// A0LockEventDelegate.m
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

#import "A0LockEventDelegate.h"
#import "A0LockViewController.h"
#import "A0LockNotification.h"

@interface A0LockEventDelegate ()
@property (weak, nonatomic) A0LockViewController *controller;
@end

@implementation A0LockEventDelegate

- (instancetype)initWithLockViewController:(A0LockViewController *)controller {
    self = [super init];
    if (self) {
        _controller = controller;
    }
    return self;
}

- (void)dismissLock {
    [[NSNotificationCenter defaultCenter] postNotificationName:A0LockNotificationLockDismissed object:nil];
    [self.controller.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    if (self.controller.onUserDismissBlock) {
        self.controller.onUserDismissBlock();
    }
}

- (void)backToLock {
    [self.controller.navigationController popToRootViewControllerAnimated:YES];
}

- (void)userAuthenticatedWithToken:(A0Token *)token profile:(A0UserProfile *)profile {
    if (self.controller.onAuthenticationBlock) {
        self.controller.onAuthenticationBlock(profile, token);
    }
}
@end
