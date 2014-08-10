//
//  A0UserPasswordView.m
//  Pods
//
//  Created by Hernan Zalazar on 6/30/14.
//
//

#import "A0UserPasswordView.h"
#import "UIButton+A0SolidButton.h"
#import "A0Errors.h"
#import "A0DatabaseLoginCredentialValidator.h"
#import "A0ProgressButton.h"

#import <CoreGraphics/CoreGraphics.h>

@interface A0UserPasswordView ()

@property (weak, nonatomic) IBOutlet UIView *userContainerView;
@property (weak, nonatomic) IBOutlet UIView *passwordContainerView;

- (IBAction)access:(id)sender;
- (IBAction)goToPasswordField:(id)sender;
- (IBAction)showSignUp:(id)sender;
- (IBAction)showForgotPassword:(id)sender;

@end

@implementation A0UserPasswordView

- (void)awakeFromNib {
    [super awakeFromNib];

    self.userContainerView.layer.borderWidth = 1.0f;
    self.userContainerView.layer.borderColor = [[UIColor colorWithWhite:0.302 alpha:1.000] CGColor];
    self.passwordContainerView.layer.borderWidth = 1.0f;
    self.passwordContainerView.layer.borderColor = [[UIColor colorWithWhite:0.302 alpha:1.000] CGColor];

    [self.accessButton setBackgroundColor:[UIColor colorWithRed:0.086 green:0.129 blue:0.302 alpha:1.000] forState:UIControlStateNormal];
    [self.accessButton setBackgroundColor:[UIColor colorWithRed:0.043 green:0.063 blue:0.145 alpha:1.000] forState:UIControlStateHighlighted];
    self.accessButton.layer.cornerRadius = 5;
    self.accessButton.clipsToBounds = YES;
}

- (void)access:(id)sender {
    NSError *error;
    [self.validator setUsername:self.userTextField.text password:self.passwordTextField.text];
    if ([self.validator validateCredential:&error]) {
        [self hideKeyboard];
        if (self.loginBlock) {
            NSString *username = [self.userTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            self.loginBlock(username, self.passwordTextField.text);
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:error.localizedDescription
                                                        message:error.localizedFailureReason
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles: nil];
        [alert show];
    }
    [self updateUIWithError:error];
}

- (void)hideKeyboard {
    [self.userTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

- (void)goToPasswordField:(id)sender {
    [self.passwordTextField becomeFirstResponder];
}

- (void)showSignUp:(id)sender {
    if (self.signUpBlock) {
        self.signUpBlock();
    }
}

- (void)showForgotPassword:(id)sender {
    if (self.forgotPasswordBlock) {
        self.forgotPasswordBlock();
    }
}

- (CGRect)rectToKeepVisibleInView:(UIView *)view {
    CGRect rect = [view convertRect:self.accessButton.frame fromView:self.accessButton.superview];
    return rect;
}

- (void)showInProgress {
    self.userInteractionEnabled = NO;
    [self.accessButton setInProgress:YES];
}

- (void)hideInProgress {
    self.userInteractionEnabled = YES;
    [self.accessButton setInProgress:NO];
}

#pragma mark - Error hanlding

- (void)updateUIWithError:(NSError *)error {
    self.userTextField.textColor = [UIColor blackColor];
    self.passwordTextField.textColor = [UIColor blackColor];
    if (error) {
        switch (error.code) {
            case A0ErrorCodeInvalidCredentials:
                self.userTextField.textColor = [UIColor redColor];
                self.passwordTextField.textColor = [UIColor redColor];
                break;
            case A0ErrorCodeInvalidPassword:
                self.passwordTextField.textColor = [UIColor redColor];
                break;
            case A0ErrorCodeInvalidUsername:
                self.userTextField.textColor = [UIColor redColor];
                break;
        }
    }
}

@end
