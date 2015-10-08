// A0EmailMagicLinkViewController.m
//
// Copyright (c) 2015 Auth0 (http://auth0.com)
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

#import "A0EmailMagicLinkViewController.h"
#import "A0EmailLockViewModel.h"
#import "NSError+A0APIError.h"
#import "A0Alert.h"
#import "A0Theme.h"
#import "A0LoadingView.h"

const NSTimeInterval A0EmailMagicLinkRetryInSeconds = 40;

@interface A0EmailMagicLinkViewController ()

@property (strong, nonatomic) A0EmailLockViewModel *viewModel;
@property (strong, nonatomic) NSTimer *resendTimer;

@property (weak, nonatomic) IBOutlet UILabel *checkLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIButton *resendButton;
@property (weak, nonatomic) A0LoadingView *loadingView;

- (IBAction)resend:(id)sender;

@end

@implementation A0EmailMagicLinkViewController

- (instancetype)initWithViewModel:(A0EmailLockViewModel *)viewModel {
    self = [self initWithNibName:NSStringFromClass(self.class) bundle:[NSBundle bundleForClass:self.class]];
    if (self) {
        _viewModel = viewModel;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = A0LocalizedString(@"Magic Link Sent");

    A0Theme *theme = [A0Theme sharedInstance];
    UIFont *font = [theme fontForKey:A0ThemeDescriptionFont];
    NSMutableAttributedString *message = [[NSMutableAttributedString alloc] initWithString:A0LocalizedString(@"We sent you a link to sign in to ")
                                                                                attributes:@{
                                                                                             NSForegroundColorAttributeName: [theme colorForKey:A0ThemeDescriptionTextColor],
                                                                                             NSFontAttributeName: font,
                                                                                             }];
    [message appendAttributedString:[[NSAttributedString alloc] initWithString:self.viewModel.email
                                                                    attributes:@{
                                                                                 NSFontAttributeName: [UIFont boldSystemFontOfSize:font.pointSize],
                                                                                 }]];
    self.messageLabel.attributedText = message;

    self.checkLabel.layer.cornerRadius = self.checkLabel.frame.size.height / 2;
    self.checkLabel.layer.masksToBounds = YES;
    
    [self scheduleToEnableResend];
    self.resendButton.tintColor = [theme colorForKey:A0ThemePrimaryButtonNormalColor];

}

- (void)dealloc {
    [self.resendTimer invalidate];
    self.resendTimer = nil;
}

- (IBAction)resend:(id)sender {
    self.loadingView = [self showLoadingWithMessage:A0LocalizedString(@"Resending magic link to your email...")];

    self.resendButton.enabled = NO;
    [self.viewModel requestVerificationCodeWithCallback:^(NSError * _Nullable error) {
        self.resendButton.enabled = error == nil;
        [self hideLoadingView:self.loadingView];
        if (error) {
            A0LogError(@"Failed to send SMS code with error %@", error);
            NSString *title = [error a0_auth0ErrorWithCode:A0ErrorCodeNotConnectedToInternet] ? error.localizedDescription : A0LocalizedString(@"There was an error sending the email");
            NSString *message = [error a0_auth0ErrorWithCode:A0ErrorCodeNotConnectedToInternet] ? error.localizedFailureReason : A0LocalizedString(@"Couldn't send the email with your login link. Please try again later.");
            [A0Alert showInController:self errorAlert:^(A0Alert *alert) {
                alert.title = title;
                alert.message = message;
            }];
            return;
        }

        [self scheduleToEnableResend];
    }];
}

- (A0LoadingView *)showLoadingWithMessage:(NSString *)message {
    A0LoadingView *loadingView = [[A0LoadingView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    loadingView.message = A0LocalizedString(@"Resending login link to your email...");
    [self.view addSubview:loadingView];
    [self.view bringSubviewToFront:loadingView];
    NSDictionary<NSString *, id> *views = NSDictionaryOfVariableBindings(loadingView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[loadingView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[loadingView]|" options:0 metrics:nil views:views]];
    return loadingView;
}

- (void)hideLoadingView:(A0LoadingView *)loadingView {
    [UIView animateWithDuration:0.5 animations:^{
        self.loadingView.hidden = YES;
    } completion:^(BOOL finished) {
        [self.loadingView removeFromSuperview];
    }];
}

- (void)enableResend {
    self.resendButton.hidden = NO;
    self.resendButton.enabled = YES;
    self.resendTimer = nil;
}

- (void)scheduleToEnableResend {
    self.resendTimer = [NSTimer scheduledTimerWithTimeInterval:A0EmailMagicLinkRetryInSeconds
                                                        target:self
                                                      selector:@selector(enableResend)
                                                      userInfo:nil
                                                       repeats:NO];
    self.resendButton.hidden = YES;
}

#pragma mark - A0KeyboardEnabledView

- (CGRect)rectToKeepVisibleInView:(UIView *)view {
    return CGRectZero;
}

- (void)hideKeyboard {
}

@end
