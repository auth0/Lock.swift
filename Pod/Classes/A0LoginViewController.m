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
#import "A0LoadingView.h"
#import "A0KeyboardEnabledView.h"
#import "A0CompositeAuthView.h"
#import "A0Errors.h"
#import "A0KeyboardHandler.h"
#import "A0DatabaseLoginCredentialValidator.h"
#import "A0SignUpCredentialValidator.h"
#import "A0ChangePasswordCredentialValidator.h"

#import <libextobjc/EXTScope.h>

@interface A0LoginViewController ()

@property (strong, nonatomic) IBOutlet A0ServicesView *smallSocialAuthView;
@property (strong, nonatomic) IBOutlet A0UserPasswordView *databaseAuthView;
@property (strong, nonatomic) IBOutlet A0LoadingView *loadingView;
@property (strong, nonatomic) IBOutlet A0SignUpView *signUpView;
@property (strong, nonatomic) IBOutlet A0RecoverPasswordView *recoverView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) UIView<A0KeyboardEnabledView> *authView;

@property (strong, nonatomic) NSPredicate *emailPredicate;
@property (strong, nonatomic) A0KeyboardHandler *keyboardHandler;


- (IBAction)dismiss:(id)sender;

@end

@implementation A0LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.modalPresentationStyle = UIModalPresentationFormSheet;
        }
        _usesEmail = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    NSString *emailRegex = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    self.emailPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    self.keyboardHandler = [[A0KeyboardHandler alloc] init];

    @weakify(self);
    self.authView = [self layoutLoadingView:self.loadingView inContainer:self.containerView];

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

    [self configureDatabaseAuthViewWithSuccess:successBlock failure:failureBlock];
    [self configureSignUpViewWithSuccess:successBlock failure:failureBlock];
    [self configureChangePasswordViewWithFailure:failureBlock];

    [[A0APIClient sharedClient] fetchAppInfoWithSuccess:^(A0Application *application) {
        @strongify(self);
        [[A0APIClient sharedClient] configureForApplication:application];
        if ([application hasDatabaseConnection]) {
            self.authView = [self layoutDatabaseOnlyAuthViewInContainer:self.containerView];
//            self.smallSocialAuthView.serviceNames = @[@"facebook", @"twitter"];
//            self.authView = [self layoutFullAuthViewInContainer:self.containerView];
        } else {
            //Layout only social or error
        }
    } failure:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.keyboardHandler start];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.keyboardHandler stop];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (void)dismiss:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)hideKeyboard:(id)sender {
    [self.authView hideKeyboard];
}

#pragma mark - Validation

- (BOOL)validateUsername:(NSString *)username {
    if (self.usesEmail) {
        return [self.emailPredicate evaluateWithObject:username];
    } else {
        return username.length > 0;
    }
}

- (BOOL)validatePassword:(NSString *)password {
    return password.length > 0;
}

#pragma mark - Utility methods

- (UIView<A0KeyboardEnabledView> *)layoutSingleView:(UIView<A0KeyboardEnabledView> *)view withTitle:(NSString *)title inContainer:(UIView *)containerView {
    view.translatesAutoresizingMaskIntoConstraints = NO;
    [self layoutAuthView:view centeredInContainerView:containerView];
    [self animateFromView:self.authView toView:view withTitle:title];
    [self.keyboardHandler handleForView:view inView:self.view];
    return view;
}

- (UIView<A0KeyboardEnabledView> *)layoutLoadingView:(A0LoadingView *)loadingView inContainer:(UIView *)containerView {
    loadingView.translatesAutoresizingMaskIntoConstraints = NO;
    [self layoutAuthView:loadingView centeredInContainerView:containerView];
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
    NSDictionary *views = NSDictionaryOfVariableBindings(authView);
    [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[authView]|" options:0 metrics:nil views:views]];
}

- (UIView<A0KeyboardEnabledView> *)layoutDatabaseOnlyAuthViewInContainer:(UIView *)containerView {
    return [self layoutSingleView:self.databaseAuthView withTitle:NSLocalizedString(@"Login", nil) inContainer:containerView];
}

- (UIView<A0KeyboardEnabledView> *)layoutFullAuthViewInContainer:(UIView *)containerView {
    A0CompositeAuthView *authView = [[A0CompositeAuthView alloc] initWithFirstView:self.smallSocialAuthView
                                                                     andSecondView:self.databaseAuthView];
    authView.delegate = self.databaseAuthView;
    [self layoutAuthView:authView centeredInContainerView:containerView];
    [self animateFromView:self.authView toView:authView withTitle:NSLocalizedString(@"Login", nil)];
    [self.keyboardHandler handleForView:authView inView:self.view];
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

- (void)configureDatabaseAuthViewWithSuccess:(A0APIClientSuccess)success failure:(A0APIClientError)failure {
    @weakify(self);
    self.databaseAuthView.signUpBlock = ^{
        @strongify(self);
        self.authView = [self layoutSingleView:self.signUpView
                                     withTitle:NSLocalizedString(@"Sign Up", nil)
                                   inContainer:self.containerView];
    };
    self.databaseAuthView.forgotPasswordBlock = ^{
        @strongify(self);
        self.authView = [self layoutSingleView:self.recoverView
                                     withTitle:NSLocalizedString(@"Reset Password", nil)
                                   inContainer:self.containerView];
    };

    self.databaseAuthView.loginBlock = ^(NSString *username, NSString *password) {
        [[A0APIClient sharedClient] loginWithUsername:username password:password success:success failure:failure];
    };

    self.databaseAuthView.validator = [[A0DatabaseLoginCredentialValidator alloc] initWithUsesEmail:self.usesEmail];
}

- (void)configureSignUpViewWithSuccess:(A0APIClientSuccess)success failure:(A0APIClientError)failure {
    @weakify(self);

    self.signUpView.signUpBlock = ^(NSString *username, NSString *password){
        [[A0APIClient sharedClient] signUpWithUsername:username password:password success:success failure:failure];
    };

    self.signUpView.cancelBlock = ^{
        @strongify(self);
        self.authView = [self layoutDatabaseOnlyAuthViewInContainer:self.containerView];
    };

    self.signUpView.validator = [[A0SignUpCredentialValidator alloc] initWithUsesEmail:self.usesEmail];
}

- (void)configureChangePasswordViewWithFailure:(A0APIClientError)failure {
    @weakify(self);
    self.recoverView.recoverBlock = ^(NSString *username, NSString *password) {
        [[A0APIClient sharedClient] changePassword:password forUsername:username success:^(id payload) {
            @strongify(self);
            self.authView = [self layoutDatabaseOnlyAuthViewInContainer:self.containerView];
        } failure:failure];
    };

    self.recoverView.cancelBlock = ^{
        @strongify(self);
        self.authView = [self layoutDatabaseOnlyAuthViewInContainer:self.containerView];
    };

    self.recoverView.validator = [[A0ChangePasswordCredentialValidator alloc] initWithUsesEmail:self.usesEmail];
}
@end
