// A0ContainerViewController.m
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

#import "A0ContainerViewController.h"
#import "A0NavigationView.h"
#import "A0KeyboardHandler.h"
#import "A0Theme.h"
#import "A0TitleView.h"
#import "Constants.h"

@interface A0ContainerViewController ()

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet A0NavigationView *navigationView;

@property (strong, nonatomic) A0KeyboardHandler *keyboardHandler;

@end

@implementation A0ContainerViewController

AUTH0_DYNAMIC_LOGGER_METHODS

- (void)viewDidLoad {
    [super viewDidLoad];
    self.keyboardHandler = [[A0KeyboardHandler alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.keyboardHandler start];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.keyboardHandler stop];
}

- (void)displayController:(UIViewController<A0KeyboardEnabledView> *)controller layout:(A0ContainerLayoutVertical)layout {
    [self layoutController:controller inContainer:self.containerView layout:layout];
}

#pragma mark - Container methods

- (void)displayController:(UIViewController<A0KeyboardEnabledView> *)controller {
    [self displayController:controller layout:A0ContainerLayoutVerticalCenter];
}

- (UIViewController<A0KeyboardEnabledView> *)layoutController:(UIViewController<A0KeyboardEnabledView> *)controller inContainer:(UIView *)containerView layout:(A0ContainerLayoutVertical)layout {
    UIViewController *from = self.childViewControllers.firstObject;
    controller.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.keyboardHandler handleForView:controller inView:self.view];
    [from willMoveToParentViewController:nil];
    [self addChildViewController:controller];
    if (layout == A0ContainerLayoutVerticalFill) {
        [self layoutAuthView:controller.view toFillInContainerView:containerView];
    } else {
        [self layoutAuthView:controller.view centeredInContainerView:containerView];
    }
    [self animateFromViewController:from toViewController:controller];
    return controller;
}

- (void)layoutAuthView:(UIView *)authView toFillInContainerView:(UIView *)containerView {
    containerView.translatesAutoresizingMaskIntoConstraints = NO;
    [containerView addSubview:authView];
    NSDictionary *views = NSDictionaryOfVariableBindings(authView);
    [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[authView]|" options:0 metrics:nil views:views]];
    [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[authView]|" options:0 metrics:nil views:views]];
}

- (void)layoutAuthView:(UIView *)authView centeredInContainerView:(UIView *)containerView {
    containerView.translatesAutoresizingMaskIntoConstraints = NO;
    [containerView addSubview:authView];
    [containerView addConstraint:[NSLayoutConstraint constraintWithItem:containerView
                                                              attribute:NSLayoutAttributeCenterY
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:authView
                                                              attribute:NSLayoutAttributeCenterY
                                                             multiplier:1.0f
                                                               constant:0.0f]];
    NSDictionary *views = NSDictionaryOfVariableBindings(authView);
    [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[authView]|" options:0 metrics:nil views:views]];
}

- (void)animateFromViewController:(UIViewController *)from toViewController:(UIViewController *)to {
    A0LogDebug(@"Starting animation to show %@", NSStringFromClass(to.class));
    to.view.alpha = 0.0f;
    from.view.alpha = 0.0f;
    self.navigationView.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.3f animations:^{
        to.view.alpha = 1.0f;
        self.titleView.title = to.title;
    } completion:^(BOOL finished) {
        [from.view removeFromSuperview];
        [from removeFromParentViewController];
        [to didMoveToParentViewController:self];
        self.navigationView.userInteractionEnabled = YES;
    }];
}

@end
