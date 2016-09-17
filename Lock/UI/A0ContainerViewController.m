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
#import <Masonry/Masonry.h>

@interface A0ContainerViewController ()

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet A0NavigationView *navigationView;

@property (strong, nonatomic) A0KeyboardHandler *keyboardHandler;

@end

@implementation A0ContainerViewController

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

    [titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@110);
        make.centerX.equalTo(self.view);
        make.left.and.right.equalTo(self.view);
        make.top.equalTo(self.view).offset(20).with.priority(500);
        make.top.equalTo(self.view).offset(60).with.priority(800);
    }];

    [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.greaterThanOrEqualTo(@284);
        make.top.equalTo(titleView.mas_bottom);
        make.left.and.right.equalTo(self.view);
    }];

    [navigationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@48);
        make.top.equalTo(containerView.mas_bottom);
        make.left.and.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];

    self.titleView = titleView;
    self.containerView = containerView;
    self.navigationView = navigationView;
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, self.titleView);
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
    [authView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(containerView);
    }];
}

- (void)layoutAuthView:(UIView *)authView centeredInContainerView:(UIView *)containerView {
    containerView.translatesAutoresizingMaskIntoConstraints = NO;
    [containerView addSubview:authView];

    [authView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(containerView);
        make.left.and.right.equalTo(containerView);
    }];
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
