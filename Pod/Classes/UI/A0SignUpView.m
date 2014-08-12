// A0SignUpView.m
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

#import "A0SignUpView.h"
#import "UIButton+A0SolidButton.h"
#import "A0Errors.h"
#import "A0SignUpCredentialValidator.h"
#import "A0ProgressButton.h"

@interface A0SignUpView ()

@property (weak, nonatomic) IBOutlet UIView *userContainerView;
@property (weak, nonatomic) IBOutlet UIView *passwordContainerView;

- (IBAction)signUp:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)goToPasswordField:(id)sender;

@end

@implementation A0SignUpView

- (void)awakeFromNib {
    [super awakeFromNib];

    self.userContainerView.layer.borderWidth = 1.0f;
    self.userContainerView.layer.borderColor = [[UIColor colorWithWhite:0.302 alpha:1.000] CGColor];
    self.passwordContainerView.layer.borderWidth = 1.0f;
    self.passwordContainerView.layer.borderColor = [[UIColor colorWithWhite:0.302 alpha:1.000] CGColor];

    [self.signUpButton setBackgroundColor:[UIColor colorWithRed:0.086 green:0.129 blue:0.302 alpha:1.000] forState:UIControlStateNormal];
    [self.signUpButton setBackgroundColor:[UIColor colorWithRed:0.043 green:0.063 blue:0.145 alpha:1.000] forState:UIControlStateHighlighted];
    self.signUpButton.layer.cornerRadius = 5;
    self.signUpButton.clipsToBounds = YES;
}

- (void)hideKeyboard {
    [self.userTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

- (void)signUp:(id)sender {
    NSError *error;
    [self.validator setUsername:self.userTextField.text password:self.passwordTextField.text];
    if ([self.validator validateCredential:&error]) {
        [self hideKeyboard];
        if (self.signUpBlock) {
            NSString *username = [self.userTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            self.signUpBlock(username, self.passwordTextField.text);
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

- (void)goToPasswordField:(id)sender {
    [self.passwordTextField becomeFirstResponder];
}

- (void)cancel:(id)sender {
    if (self.cancelBlock) {
        self.cancelBlock();
    }
}

- (CGRect)rectToKeepVisibleInView:(UIView *)view {
    CGRect rect = [view convertRect:self.signUpButton.frame fromView:self.signUpButton.superview];
    return rect;
}

- (void)showInProgress {
    self.userInteractionEnabled = NO;
    [self.signUpButton setInProgress:YES];
}

- (void)hideInProgress {
    self.userInteractionEnabled = YES;
    [self.signUpButton setInProgress:NO];
}
#pragma mark - Error Handling

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
