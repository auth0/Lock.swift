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
#import "A0UserPasswordView.h"
#import "A0SignUpView.h"
#import "A0RecoverPasswordView.h"

#import <libextobjc/EXTScope.h>

@implementation NSNotification (UIKeyboardInfo)

- (CGFloat)keyboardAnimationDuration {
    return [[self userInfo][UIKeyboardAnimationDurationUserInfoKey] doubleValue];
}

- (NSUInteger)keyboardAnimationCurve {
    return [[self userInfo][UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
}

- (CGRect)keyboardEndFrame {
    return [[self userInfo][UIKeyboardFrameEndUserInfoKey] CGRectValue];
}

@end

@interface A0LoginViewController ()

@property (strong, nonatomic) IBOutlet A0ServicesView *smallSocialAuthView;
@property (strong, nonatomic) IBOutlet A0UserPasswordView *databaseAuthView;
@property (strong, nonatomic) IBOutlet UIView *loadingView;
@property (strong, nonatomic) IBOutlet A0SignUpView *signUpView;
@property (strong, nonatomic) IBOutlet A0RecoverPasswordView *recoverView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) UIView *authView;

- (IBAction)dismiss:(id)sender;

@end

@implementation A0LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.modalPresentationStyle = UIModalPresentationFormSheet;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    @weakify(self);
    self.authView = [self layoutLoadingView:self.loadingView inContainer:self.containerView];

    self.databaseAuthView.signUpBlock = ^{
        @strongify(self);
        self.authView = [self layoutSignUpInContainer:self.containerView];
    };
    self.databaseAuthView.forgotPasswordBlock = ^{
        @strongify(self);
        self.authView = [self layoutRecoverInContainer:self.containerView];
    };

    A0APIClientError failureBlock = ^(NSError *error){
        NSLog(@"ERROR %@", error);
    };
    A0APIClientSuccess successBlock = ^(id payload) {
        @strongify(self);
        [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
            if (self.authBlock) {
                self.authBlock(self, payload);
            }
        }];
    };
    self.databaseAuthView.loginBlock = ^(NSString *username, NSString *password) {
        [[A0APIClient sharedClient] loginWithUsername:username password:password success:successBlock failure:failureBlock];
    };

    self.signUpView.signUpBlock = ^(NSString *username, NSString *password){
        [[A0APIClient sharedClient] signUpWithUsername:username password:password success:successBlock failure:failureBlock];
    };
    self.signUpView.cancelBlock = ^{
        @strongify(self);
        self.authView = [self layoutDatabaseOnlyAuthViewInContainer:self.containerView];
    };
    self.recoverView.cancelBlock = ^{
        @strongify(self);
        self.authView = [self layoutDatabaseOnlyAuthViewInContainer:self.containerView];
    };
    [[A0APIClient sharedClient] fetchAppInfoWithSuccess:^(A0Application *application) {
        @strongify(self);
        [[A0APIClient sharedClient] configureForApplication:application];
        if ([application hasDatabaseConnection]) {
            self.authView = [self layoutDatabaseOnlyAuthViewInContainer:self.containerView];
        } else {
            //Layout only social or error
        }
    } failure:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHided:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (void)dismiss:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)keyboardWillBeShown:(NSNotification *)notification {
    CGRect keyboardFrame = [self.view convertRect:[notification keyboardEndFrame] fromView:nil];
    CGFloat animationDuration = [notification keyboardAnimationDuration];
    NSUInteger animationCurve = [notification keyboardAnimationCurve];
    CGRect buttonFrame = [self.view convertRect:self.databaseAuthView.accessButton.frame fromView:self.databaseAuthView.accessButton.superview];
    CGRect frame = self.view.frame;
    CGFloat newY = keyboardFrame.origin.y - (buttonFrame.origin.y + buttonFrame.size.height);
    frame.origin.y = MIN(newY, 0);
    [UIView animateWithDuration:animationDuration delay:0.0f options:animationCurve animations:^{
        self.view.frame = frame;
    } completion:nil];
}

- (void)keyboardWillBeHided:(NSNotification *)notification {
    CGFloat animationDuration = [notification keyboardAnimationDuration];
    NSUInteger animationCurve = [notification keyboardAnimationCurve];
    CGRect frame = self.view.frame;
    frame.origin.y = 0;
    [UIView animateWithDuration:animationDuration delay:0.0f options:animationCurve animations:^{
        self.view.frame = frame;
    } completion:nil];
}

- (void)hideKeyboard:(id)sender {
    [self.databaseAuthView hideKeyboard];
}

#pragma mark - Utility methods

- (UIView *)layoutRecoverInContainer:(UIView *)containerView {
    UIView *recoverView = self.recoverView;
    recoverView.translatesAutoresizingMaskIntoConstraints = NO;
    [self layoutAuthView:recoverView centeredInContainerView:containerView];
    NSDictionary *views = NSDictionaryOfVariableBindings(recoverView);
    [recoverView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[recoverView(325)]" options:0 metrics:nil views:views]];
    [recoverView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[recoverView(280)]" options:0 metrics:nil views:views]];
    [self animateFromView:self.authView toView:recoverView withTitle:NSLocalizedString(@"Reset Password", nil)];
    return recoverView;
}

- (UIView *)layoutSignUpInContainer:(UIView *)containerView {
    UIView *signUpView = self.signUpView;
    signUpView.translatesAutoresizingMaskIntoConstraints = NO;
    [self layoutAuthView:signUpView centeredInContainerView:containerView];
    NSDictionary *views = NSDictionaryOfVariableBindings(signUpView);
    [signUpView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[signUpView(260)]" options:0 metrics:nil views:views]];
    [signUpView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[signUpView(280)]" options:0 metrics:nil views:views]];
    [self animateFromView:self.authView toView:signUpView withTitle:NSLocalizedString(@"Sign Up", nil)];
    return signUpView;
}

- (UIView *)layoutLoadingView:(UIView *)loadingView inContainer:(UIView *)containerView {
    loadingView.translatesAutoresizingMaskIntoConstraints = NO;
    [self layoutAuthView:loadingView centeredInContainerView:containerView];
    NSDictionary *views = NSDictionaryOfVariableBindings(loadingView);
    [loadingView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[loadingView(232)]" options:0 metrics:nil views:views]];
    [loadingView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[loadingView(280)]" options:0 metrics:nil views:views]];
    return loadingView;
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

- (UIView *)layoutDatabaseOnlyAuthViewInContainer:(UIView *)containerView {
    UIView *userPassView = self.databaseAuthView;
    [self layoutAuthView:userPassView centeredInContainerView:containerView];
    userPassView.translatesAutoresizingMaskIntoConstraints = NO;
    [self layoutAuthView:userPassView centeredInContainerView:containerView];
    NSDictionary *views = NSDictionaryOfVariableBindings(userPassView);
    [userPassView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[userPassView(232)]" options:0 metrics:nil views:views]];
    [userPassView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[userPassView(280)]" options:0 metrics:nil views:views]];
    [self animateFromView:self.authView toView:userPassView withTitle:NSLocalizedString(@"Login", nil)];
    return userPassView;
}

- (UIView *)layoutFullAuthViewInContainer:(UIView *)containerView {
    UIView *authView = [[UIView alloc] init];
    UIView *socialView = self.smallSocialAuthView;
    UIView *userPassView = self.databaseAuthView;
    [self layoutAuthView:authView centeredInContainerView:containerView];
    authView.translatesAutoresizingMaskIntoConstraints = NO;
    socialView.translatesAutoresizingMaskIntoConstraints = NO;
    userPassView.translatesAutoresizingMaskIntoConstraints = NO;
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

    [self animateFromView:self.authView toView:authView withTitle:NSLocalizedString(@"Login", nil)];
    return authView;
}

- (void)animateFromView:(UIView *)fromView toView:(UIView *)toView withTitle:(NSString *)title {
    fromView.alpha = 1.0f;
    toView.alpha = 0.0f;
    [UIView animateWithDuration:0.5f animations:^{
        toView.alpha = 1.0f;
        fromView.alpha = 0.0f;
        self.titleLabel.text = title;
    } completion:^(BOOL finished) {
        [fromView removeFromSuperview];
    }];
}
@end
