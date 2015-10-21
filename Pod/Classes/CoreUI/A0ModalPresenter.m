// A0ModalPresenter.m
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

#import "A0ModalPresenter.h"

@implementation A0ModalPresenter

- (void)presentController:(UIViewController *)controller completion:(void (^)())completion {
    [[self presenterViewController] presentViewController:controller animated:YES completion:completion];
}

- (UIViewController *)presenterViewController {
    UIViewController* viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    return [self topViewControllerFromViewController:viewController];
}

- (UIViewController*) topViewControllerFromViewController:(UIViewController*)controller {
    if (controller.presentedViewController) {
        return [self topViewControllerFromViewController:controller.presentedViewController];
    }
    if ([controller isKindOfClass:[UISplitViewController class]]) {
        UISplitViewController* splitViewController = (UISplitViewController*) controller;
        if (splitViewController.viewControllers.count > 0) {
            return [self topViewControllerFromViewController:splitViewController.viewControllers.lastObject];
        } else {
            return controller;
        }
    }
    if ([controller isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*) controller;
        if (navigationController.viewControllers.count > 0) {
            return [self topViewControllerFromViewController:navigationController.topViewController];
        } else {
            return controller;
        }
    }
    if ([controller isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController*) controller;
        if (tabBarController.viewControllers.count > 0) {
            return [self topViewControllerFromViewController:tabBarController.selectedViewController];
        } else {
            return controller;
        }
    }
    return controller;
}

@end
