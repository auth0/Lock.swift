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
    self.databaseAuthView.loginBlock = ^(NSString *username, NSString *password) {
        [[A0APIClient sharedClient] loginWithUsername:username password:password success:^(id payload) {
            @strongify(self);
            [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
                if (self.authBlock) {
                    self.authBlock(self, payload);
                }
            }];
        } failure:^(NSError *error) {
            NSLog(@"ERROR %@", error);
        }];
    };

    [[A0APIClient sharedClient] fetchAppInfoWithSuccess:^(A0Application *application) {
        @strongify(self);
        [[A0APIClient sharedClient] configureForApplication:application];
        if ([application hasDatabaseConnection]) {
            self.authView = [self layoutUserPassView:self.databaseAuthView inContainer:self.containerView];
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
    CGRect keyboardFrame = [notification keyboardEndFrame];
    CGFloat animationDuration = [notification keyboardAnimationDuration];
    NSUInteger animationCurve = [notification keyboardAnimationCurve];
    CGRect buttonFrame = [self.view convertRect:self.databaseAuthView.accessButton.frame fromView:self.databaseAuthView.accessButton.superview];
    CGRect frame = self.view.frame;
    CGFloat newY = frame.origin.y - (buttonFrame.origin.y + buttonFrame.size.height) - keyboardFrame.origin.y;
    frame.origin.y = MAX(newY, 0);
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
