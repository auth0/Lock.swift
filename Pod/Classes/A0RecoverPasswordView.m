//
//  A0RecoverPasswordView.m
//  Pods
//
//  Created by Hernan Zalazar on 7/14/14.
//
//

#import "A0RecoverPasswordView.h"
#import "UIButton+A0SolidButton.h"
#import "A0Errors.h"

@interface A0RecoverPasswordView ()

@property (weak, nonatomic) IBOutlet UIView *userContainerView;
@property (weak, nonatomic) IBOutlet UIView *passwordContainerView;
@property (weak, nonatomic) IBOutlet UIView *repeatPasswordContainerView;

- (IBAction)recover:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)goToPasswordField:(id)sender;
- (IBAction)goToRepeatPasswordField:(id)sender;

@end

@implementation A0RecoverPasswordView

- (void)awakeFromNib {
    [super awakeFromNib];

    self.userContainerView.layer.borderWidth = 1.0f;
    self.userContainerView.layer.borderColor = [[UIColor colorWithWhite:0.302 alpha:1.000] CGColor];
    self.passwordContainerView.layer.borderWidth = 1.0f;
    self.passwordContainerView.layer.borderColor = [[UIColor colorWithWhite:0.302 alpha:1.000] CGColor];
    self.repeatPasswordContainerView.layer.borderWidth = 1.0f;
    self.repeatPasswordContainerView.layer.borderColor = [[UIColor colorWithWhite:0.302 alpha:1.000] CGColor];

    [self.recoverButton setBackgroundColor:[UIColor colorWithRed:0.086 green:0.129 blue:0.302 alpha:1.000] forState:UIControlStateNormal];
    [self.recoverButton setBackgroundColor:[UIColor colorWithRed:0.043 green:0.063 blue:0.145 alpha:1.000] forState:UIControlStateHighlighted];
    self.recoverButton.layer.cornerRadius = 5;
    self.recoverButton.clipsToBounds = YES;
}

- (IBAction)recover:(id)sender {
    NSError *error;
    if (!self.validateBlock || self.validateBlock(self.userTextField.text, self.passwordTextField.text, self.repeatPasswordTextField.text, &error)) {
        [self hideKeyboard];
        if (self.recoverBlock) {
            self.recoverBlock(self.userTextField.text, self.passwordTextField.text);
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

- (IBAction)cancel:(id)sender {
    if (self.cancelBlock) {
        self.cancelBlock();
    }
}

- (IBAction)goToPasswordField:(id)sender {
    [self.passwordTextField becomeFirstResponder];
}

- (IBAction)goToRepeatPasswordField:(id)sender {
    [self.repeatPasswordTextField becomeFirstResponder];
}

- (void)hideKeyboard {
    [self.userTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.repeatPasswordTextField resignFirstResponder];
}

- (CGRect)rectToKeepVisibleInView:(UIView *)view {
    CGRect buttonFrame = [view convertRect:self.recoverButton.frame fromView:self.recoverButton.superview];
    return buttonFrame;
}

- (void)updateUIWithError:(NSError *)error {
    self.userTextField.textColor = [UIColor blackColor];
    self.passwordTextField.textColor = [UIColor blackColor];
    self.repeatPasswordTextField.textColor = [UIColor blackColor];
    if (error) {
        switch (error.code) {
            case A0ErrorCodeInvalidCredentials:
                self.userTextField.textColor = [UIColor redColor];
                self.passwordTextField.textColor = [UIColor redColor];
                self.repeatPasswordTextField.textColor = [UIColor redColor];
                break;
            case A0ErrorCodeInvalidPassword:
                self.passwordTextField.textColor = [UIColor redColor];
                break;
            case A0ErrorCodeInvalidUsername:
                self.userTextField.textColor = [UIColor redColor];
                break;
            case A0ErrorCodeInvalidRepeatPassword:
                self.repeatPasswordTextField.textColor = [UIColor redColor];
                break;
            case A0ErrorCodeInvalidPasswordAndRepeatPassword:
                self.passwordTextField.textColor = [UIColor redColor];
                self.repeatPasswordTextField.textColor = [UIColor redColor];
                break;
        }
    }
}
@end
