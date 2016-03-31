//  A0FullLoginViewController.m
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

#import "A0FullLoginViewController.h"

#import "A0ServiceCollectionViewLayoutDelegate.h"
#import "A0LockConfiguration.h"
#import "A0SmallSocialServiceCollectionView.h"
#import "A0Theme.h"
#import "A0Alert.h"
#import "Constants.h"
#import "A0LoginView.h"
#import <Masonry/Masonry.h>

@interface A0FullLoginViewController () <A0SmallSocialServiceCollectionViewDelegate>

@property (weak, nonatomic) A0SmallSocialServiceCollectionView *serviceCollectionView;
@property (weak, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) UIView *loadingView;
@property (weak, nonatomic) UILabel *orLabel;
@property (weak, nonatomic) UIView *socialView;

@end

@implementation A0FullLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    A0LoginView *loginView = self.loginView;
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    UIView *loadingView = [[UIView alloc] initWithFrame:CGRectZero];
    A0SmallSocialServiceCollectionView *collectionView = [[A0SmallSocialServiceCollectionView alloc] init];
    UILabel *orLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    UIView *socialView = [[UIView alloc] initWithFrame:CGRectZero];
    [loginView removeFromSuperview];

    [loadingView addSubview:activityIndicator];
    [self.view addSubview:loadingView];
    [socialView addSubview:collectionView];
    [socialView addSubview:orLabel];
    [self.view addSubview:socialView];
    [self.view addSubview:loginView];
    [self.view bringSubviewToFront:self.loadingView];

    self.serviceCollectionView = collectionView;
    self.activityIndicator = activityIndicator;
    self.loadingView = loadingView;
    self.orLabel = orLabel;
    self.socialView = socialView;
    self.loginView = loginView;

    [loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [activityIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(loadingView);
    }];

    [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(socialView.mas_top);
        make.left.equalTo(socialView.mas_left);
        make.right.equalTo(socialView.mas_right);
        make.height.equalTo(@60);
    }];
    [orLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(socialView);
        make.top.equalTo(collectionView.mas_bottom).offset(8);
        make.bottom.equalTo(socialView.mas_bottom);
        make.height.equalTo(@20);
    }];
    [socialView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
    }];

    [loginView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.socialView.mas_bottom);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom);
    }];

    A0Theme *theme = [A0Theme sharedInstance];

    self.loadingView.hidden = YES;
    self.title = A0LocalizedString(@"Login");
    self.orLabel.font = [theme fontForKey:A0ThemeSeparatorTextFont];
    self.orLabel.textColor = [theme colorForKey:A0ThemeSeparatorTextColor];
    self.orLabel.text = A0LocalizedString(@"OR");
    self.serviceCollectionView.authenticationDelegate = self;
    self.serviceCollectionView.parameters = self.parameters;
    self.serviceCollectionView.lock = self.lock;
    self.serviceCollectionView.backgroundColor = [UIColor clearColor];
    [self.serviceCollectionView showSocialServicesForConfiguration:self.configuration];
    self.activityIndicator.color = [[A0Theme sharedInstance] colorForKey:A0ThemeTitleTextColor];
    self.loadingView.backgroundColor = [UIColor clearColor];
}

- (void)socialServiceCollectionView:(A0SmallSocialServiceCollectionView *)collectionView
            didAuthenticateUserWithProfile:(A0UserProfile *)profile
                                     token:(A0Token *)token {
    if (self.onLoginBlock) {
        self.onLoginBlock(self, profile, token);
    }
}

- (void)socialServiceCollectionView:(A0SmallSocialServiceCollectionView *)collectionView
                   didFailWithError:(NSError *)error {
    [A0Alert showInController:self errorAlert:^(A0Alert *alert) {
        alert.title = error.localizedDescription;
        alert.message = error.localizedFailureReason;
    }];
}

- (void)authenticationDidStartForSocialCollectionView:(A0SmallSocialServiceCollectionView *)collectionView {
    [self setInProgress:YES];
}

- (void)authenticationDidEndForSocialCollectionView:(A0SmallSocialServiceCollectionView *)collectionView {
    [self setInProgress:NO];
}

- (void)socialServiceCollectionView:(A0SmallSocialServiceCollectionView *)collectionView
              presentViewController:(UIViewController *)controller {
    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark - Utility methods

- (void)setInProgress:(BOOL)inProgress {
    if (inProgress) {
        self.loadingView.alpha = 0.0f;
        self.loadingView.hidden = NO;
        [self.view bringSubviewToFront:self.loadingView];
        [UIView animateWithDuration:0.5f animations:^{
            self.loadingView.alpha = 1.0f;
        }];
    } else {
        [UIView animateWithDuration:0.5f animations:^{
            self.loadingView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            self.loadingView.hidden = YES;
            [self.view sendSubviewToBack:self.loadingView];
        }];
    }
}

@end
