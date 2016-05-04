// A0SMSMagicLinkViewController.m
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

#import "A0SMSMagicLinkViewController.h"
#import "A0PasswordlessLockViewModel.h"
#import "NSError+A0APIError.h"
#import "A0Alert.h"
#import "A0Theme.h"
#import "A0LoadingView.h"
#import "A0Errors.h"
#import "Constants.h"
#import "NSError+A0LockErrors.h"
#import <Masonry/Masonry.h>

const NSTimeInterval A0SMSMagicLinkRetryInSeconds = 40;

@interface A0SMSMagicLinkViewController ()

@property (strong, nonatomic) A0PasswordlessLockViewModel *viewModel;
@property (strong, nonatomic) NSTimer *resendTimer;

@property (weak, nonatomic) IBOutlet UILabel *checkLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIButton *resendButton;
@property (weak, nonatomic) A0LoadingView *loadingView;

- (IBAction)resend:(id)sender;

@end

@implementation A0SMSMagicLinkViewController

- (instancetype)initWithViewModel:(A0PasswordlessLockViewModel *)viewModel {
    self = [self init];
    if (self) {
        _viewModel = viewModel;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UILabel *checkLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    UIButton *resendButton = [UIButton buttonWithType:UIButtonTypeSystem];

    [self.view addSubview:checkLabel];
    [self.view addSubview:messageLabel];
    [self.view addSubview:resendButton];

    [messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.width.equalTo(@230);
    }];
    [checkLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(messageLabel.mas_top).offset(-30);
        make.height.equalTo(@54);
        make.width.equalTo(@54);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    [resendButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(messageLabel.mas_bottom).offset(20);
    }];

    self.checkLabel = checkLabel;
    self.messageLabel = messageLabel;
    self.resendButton = resendButton;

    self.title = A0LocalizedString(@"Magic Link Sent");

    A0Theme *theme = [A0Theme sharedInstance];
    UIFont *font = [theme fontForKey:A0ThemeDescriptionFont];
    NSMutableAttributedString *message = [[NSMutableAttributedString alloc] initWithString:A0LocalizedString(@"We sent you a link to sign in to ")
                                                                                attributes:@{
                                                                                             NSForegroundColorAttributeName: [theme colorForKey:A0ThemeDescriptionTextColor],
                                                                                             NSFontAttributeName: font,
                                                                                             }];
    [message appendAttributedString:[[NSAttributedString alloc] initWithString:self.viewModel.identifier
                                                                    attributes:@{
                                                                                 NSFontAttributeName: [UIFont boldSystemFontOfSize:font.pointSize],
                                                                                 }]];
    self.messageLabel.attributedText = message;
    self.messageLabel.textAlignment = NSTextAlignmentCenter;
    self.messageLabel.numberOfLines = 3;

    self.checkLabel.textAlignment = NSTextAlignmentCenter;
    self.checkLabel.layer.cornerRadius = 27;
    self.checkLabel.layer.masksToBounds = YES;
    self.checkLabel.backgroundColor = [UIColor colorWithRed:0.5686 green:0.749 blue:0.3059 alpha:1.0];
    self.checkLabel.text = @"✓";
    self.checkLabel.textColor = [UIColor whiteColor];
    self.checkLabel.font = [UIFont systemFontOfSize:45];

    [self scheduleToEnableResend];
    [self.resendButton setTitle:A0LocalizedString(@"Resend") forState:UIControlStateNormal];
    self.resendButton.tintColor = [theme colorForKey:A0ThemePrimaryButtonNormalColor];
    [self.resendButton addTarget:self action:@selector(resend:) forControlEvents:UIControlEventTouchUpInside];

    __weak A0SMSMagicLinkViewController *weakSelf = self;
    self.viewModel.onMagicLink = ^(NSError *error, BOOL completed) {
        if (error) {
            NSString *title = [error a0_auth0ErrorWithCode:A0ErrorCodeNotConnectedToInternet] ? error.localizedDescription : A0LocalizedString(@"There was an error logging in");
            NSString *message = [error a0_auth0ErrorWithCode:A0ErrorCodeNotConnectedToInternet] ? error.localizedFailureReason : [error a0_localizedStringForLoginError];
            [A0Alert showInController:weakSelf errorAlert:^(A0Alert *alert) {
                alert.title = title;
                alert.message = message;
            }];
            return;
        }
        if (completed) {
            [weakSelf hideLoadingView:weakSelf.loadingView];
        } else {
            [weakSelf showLoadingWithMessage:A0LocalizedString(@"Logging in with Magic Link…")];
        }
    };
}

- (void)dealloc {
    [self.resendTimer invalidate];
    self.resendTimer = nil;
}

- (IBAction)resend:(id)sender {
    self.loadingView = [self showLoadingWithMessage:A0LocalizedString(@"Resending magic link to your phone...")];

    self.resendButton.enabled = NO;
    [self.viewModel requestVerificationCodeWithCallback:^(NSError * _Nullable error) {
        self.resendButton.enabled = error == nil;
        [self hideLoadingView:self.loadingView];
        if (error) {
            A0LogError(@"Failed to send SMS code with error %@", error);
            NSString *title = [error a0_auth0ErrorWithCode:A0ErrorCodeNotConnectedToInternet] ? error.localizedDescription : A0LocalizedString(@"There was an error sending the SMS");
            NSString *message = [error a0_auth0ErrorWithCode:A0ErrorCodeNotConnectedToInternet] ? error.localizedFailureReason : A0LocalizedString(@"Couldn't send the SMS with your login link. Please try again later.");
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
    loadingView.message = message;
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
    self.resendTimer = [NSTimer scheduledTimerWithTimeInterval:A0SMSMagicLinkRetryInSeconds
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
