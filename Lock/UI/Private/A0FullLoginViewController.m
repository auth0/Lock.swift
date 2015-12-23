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

@interface A0FullLoginViewController () <A0SmallSocialServiceCollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UILabel *orLabel;

@end

@implementation A0FullLoginViewController

- (instancetype)init {
    return [self initWithNibName:NSStringFromClass(self.class) bundle:[NSBundle bundleForClass:self.class]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    A0Theme *theme = [A0Theme sharedInstance];
    self.orLabel.font = [theme fontForKey:A0ThemeSeparatorTextFont];
    self.orLabel.textColor = [theme colorForKey:A0ThemeSeparatorTextColor];
    self.orLabel.text = A0LocalizedString(@"OR");
    self.serviceCollectionView.authenticationDelegate = self;
    self.serviceCollectionView.parameters = self.parameters;
    self.serviceCollectionView.lock = self.lock;
   [self.serviceCollectionView showSocialServicesForConfiguration:self.configuration];
    self.activityIndicator.color = [[A0Theme sharedInstance] colorForKey:A0ThemeTitleTextColor];
}

- (void)socialServiceCollectionView:(A0SmallSocialServiceCollectionView *)collectionView
            didAuthenticateUserWithProfile:(A0UserProfile *)profile
                                     token:(A0Token *)token {
    if (self.onLoginBlock) {
        self.onLoginBlock(profile, token);
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
