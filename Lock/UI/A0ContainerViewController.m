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

- (void)layoutContainerViews {
    A0TitleView *titleView = [[A0TitleView alloc] init];
    UIView *containerView = [[UIView alloc] init];
    A0NavigationView *navigationView = [[A0NavigationView alloc] init];

    titleView.translatesAutoresizingMaskIntoConstraints = NO;
    containerView.translatesAutoresizingMaskIntoConstraints = NO;
    navigationView.translatesAutoresizingMaskIntoConstraints = NO;

    [self.view addSubview:titleView];
    [self.view addSubview:containerView];
    [self.view addSubview:navigationView];


    [titleView addConstraint:[NSLayoutConstraint constraintWithItem:titleView attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1.0 constant:110.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:titleView attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0 constant:0.0]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[titleView]-10-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(titleView)]];
    NSLayoutConstraint *lowPriorityConstraint = [NSLayoutConstraint constraintWithItem:titleView attribute:NSLayoutAttributeTop
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:self.view attribute:NSLayoutAttributeTop
                                                                            multiplier:1.0 constant:20.0];
    lowPriorityConstraint.priority = 500;
    NSLayoutConstraint *highPriorityConstraint = [NSLayoutConstraint constraintWithItem:titleView attribute:NSLayoutAttributeTop
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:self.view attribute:NSLayoutAttributeTop
                                                                             multiplier:1.0 constant:60.0];
    highPriorityConstraint.priority = 800;
    [self.view addConstraints:@[lowPriorityConstraint, highPriorityConstraint]];

    [containerView addConstraint:[NSLayoutConstraint constraintWithItem:containerView attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                 toItem:nil attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1.0 constant:284.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:containerView attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:titleView attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0 constant:0.0]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[containerView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(containerView)]];


    [navigationView addConstraint:[NSLayoutConstraint constraintWithItem:navigationView attribute:NSLayoutAttributeHeight
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:nil attribute:NSLayoutAttributeNotAnAttribute
                                                              multiplier:1.0 constant:48.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:navigationView attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:containerView attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:navigationView attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0 constant:0.0]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[navigationView]-20-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(navigationView)]];

    self.titleView = titleView;
    self.containerView = containerView;
    self.navigationView = navigationView;

    [self.view needsUpdateConstraints];
}

- (void)setupContainerUI {
    [self layoutContainerViews];

    self.containerView.clipsToBounds = YES;
    self.containerView.backgroundColor = [UIColor clearColor];
    self.titleView.backgroundColor = [UIColor clearColor];
    self.navigationView.backgroundColor = [UIColor clearColor];

    self.keyboardHandler = [[A0KeyboardHandler alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupContainerUI];
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
