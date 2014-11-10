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

@interface A0ContainerViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet A0NavigationView *navigationView;

@property (strong, nonatomic) A0KeyboardHandler *keyboardHandler;

@end

@implementation A0ContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.keyboardHandler = [[A0KeyboardHandler alloc] init];
    A0Theme *theme = [A0Theme sharedInstance];
    self.titleLabel.font = [theme fontForKey:A0ThemeTitleFont defaultFont:self.titleLabel.font];
    self.titleLabel.textColor = [theme colorForKey:A0ThemeTitleTextColor defaultColor:self.titleLabel.textColor];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.keyboardHandler start];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.keyboardHandler stop];
}

- (void)displayController:(UIViewController<A0KeyboardEnabledView> *)controller {
    [self layoutController:controller inContainer:self.containerView];
}

#pragma mark - Container methods

- (UIViewController<A0KeyboardEnabledView> *)layoutController:(UIViewController<A0KeyboardEnabledView> *)controller inContainer:(UIView *)containerView {
    UIViewController *from = self.childViewControllers.firstObject;
    controller.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.keyboardHandler handleForView:controller inView:self.view];
    [from willMoveToParentViewController:nil];
    [self addChildViewController:controller];
    [self layoutAuthView:controller.view centeredInContainerView:containerView];
    [self animateFromViewController:from toViewController:controller];
    return controller;
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
    to.view.alpha = 0.0f;
    from.view.alpha = 0.0f;
    [UIView animateWithDuration:0.3f animations:^{
        to.view.alpha = 1.0f;
        self.titleLabel.text = to.title;
    } completion:^(BOOL finished) {
        [from.view removeFromSuperview];
        [from removeFromParentViewController];
        [to didMoveToParentViewController:self];
    }];
}

@end
