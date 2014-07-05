//
//  A0LoginViewController.m
//  Pods
//
//  Created by Hernan Zalazar on 6/29/14.
//
//

#import "A0LoginViewController.h"

#import "A0ServicesView.h"
#import "A0APIClient.h"
#import "A0Application.h"

@interface A0LoginViewController ()

@property (strong, nonatomic) IBOutlet A0ServicesView *smallSocialAuthView;
@property (strong, nonatomic) IBOutlet UIView *databaseAuthView;

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) UIView *authView;

@end

@implementation A0LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [[A0APIClient sharedClient] fetchAppInfoWithSuccess:^(A0Application *application) {
        if ([application hasDatabaseConnection]) {
            self.authView = [self layoutUserPassView:self.databaseAuthView inContainer:self.containerView];
        } else {
            //Layout only social or error
        }
    } failure:nil];
}

- (BOOL)shouldAutorotate {
    return NO;
}

#pragma mark - Utility methods

- (UIView *)layoutUserPassView:(UIView *)userPassView inContainer:(UIView *)containerView {
    userPassView.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *views = NSDictionaryOfVariableBindings(userPassView);
    [userPassView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[userPassView(232)]" options:0 metrics:nil views:views]];
    [userPassView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[userPassView(280)]" options:0 metrics:nil views:views]];
    [self layoutAuthView:userPassView centeredInContainerView:containerView];
    return userPassView;
}

- (UIView *)layoutSocialView:(UIView *)socialView andUserPassView:(UIView *)userPassView inContainerView:(UIView *)containerView {
    UIView *authView = [[UIView alloc] init];

    authView.translatesAutoresizingMaskIntoConstraints = NO;
    socialView.translatesAutoresizingMaskIntoConstraints = NO;
    userPassView.translatesAutoresizingMaskIntoConstraints = NO;
    socialView.frame = CGRectMake(0, 0, socialView.frame.size.width, socialView.frame.size.height);
    userPassView.frame = CGRectOffset(userPassView.frame, 0, socialView.frame.size.height);
    [authView addSubview:userPassView];
    [authView addSubview:socialView];

    NSDictionary *views = NSDictionaryOfVariableBindings(socialView, userPassView);
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[socialView(79)][userPassView(232)]|"
                                                                           options:0
                                                                           metrics:nil
                                                                             views:views];
    [authView addConstraints:verticalConstraints];
    [authView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[socialView(280)]|" options:0 metrics:nil views:views]];
    [authView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[userPassView(280)]|" options:0 metrics:nil views:views]];

    [self layoutAuthView:authView centeredInContainerView:self.containerView];
    return authView;
}

- (void)layoutAuthView:(UIView *)authView centeredInContainerView:(UIView *)containerView {
    containerView.translatesAutoresizingMaskIntoConstraints = NO;
    [containerView addSubview:authView];
    [containerView addConstraint:[NSLayoutConstraint constraintWithItem:containerView
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:authView
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.0f
                                                               constant:0.0f]];
    [containerView addConstraint:[NSLayoutConstraint constraintWithItem:containerView
                                                              attribute:NSLayoutAttributeCenterY
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:authView
                                                              attribute:NSLayoutAttributeCenterY
                                                             multiplier:1.0f
                                                               constant:0.0f]];
}

@end
