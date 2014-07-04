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

@interface A0LoginViewController ()

@property (strong, nonatomic) A0ServicesView *socialSmallView;
@property (strong, nonatomic) IBOutlet UIView *userPassSmallView;

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) UIView *authView;

@end

@implementation A0LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [[A0APIClient sharedClient] fetchAppInfoWithSuccess:^(id response) {
        NSLog(@"%@", response);
        self.socialSmallView.serviceNames = @[@"amazon", @"twitter", @"yahoo", @"google+", @"facebook"];
        self.authView = [self layoutSocialView:self.socialSmallView
                               andUserPassView:self.userPassSmallView
                               inContainerView:self.containerView];
    } failure:nil];
}

- (BOOL)shouldAutorotate {
    return NO;
}

#pragma mark - Utility methods

- (UIView *)layoutSocialView:(UIView *)socialView andUserPassView:(UIView *)userPassView inContainerView:(UIView *)containerView {
    UIView *authView = [[UIView alloc] init];

    containerView.translatesAutoresizingMaskIntoConstraints = NO;
    authView.translatesAutoresizingMaskIntoConstraints = NO;
    socialView.frame = CGRectMake(0, 0, socialView.frame.size.width, socialView.frame.size.height);
    userPassView.frame = CGRectOffset(userPassView.frame, 0, socialView.frame.size.height);
    [authView addSubview:userPassView];
    [authView addSubview:socialView];
    [containerView addSubview:authView];

    NSDictionary *views = NSDictionaryOfVariableBindings(socialView, userPassView);
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[socialView][userPassView]|"
                                                                           options:0
                                                                           metrics:nil
                                                                             views:views];
    [authView addConstraints:verticalConstraints];
    [authView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[socialView]|" options:0 metrics:nil views:views]];
    [authView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[userPassView]|" options:0 metrics:nil views:views]];

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
    return authView;
}

@end
