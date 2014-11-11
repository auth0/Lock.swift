//  A0FullActiveDirectoryViewController.m
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

#import "A0FullActiveDirectoryViewController.h"
#import "A0Application.h"
#import "A0Strategy.h"
#import "A0ServiceCollectionViewCell.h"
#import "A0IdentityProviderAuthenticator.h"
#import "UIButton+A0SolidButton.h"
#import "A0APIClient.h"
#import "A0Errors.h"
#import "A0Theme.h"
#import "A0ServicesTheme.h"
#import "A0WebViewController.h"
#import "UIFont+A0Social.h"

#import <libextobjc/EXTScope.h>

#define kCellIdentifier @"ServiceCell"

static void showAlertErrorView(NSString *title, NSString *message) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:A0LocalizedString(@"OK")
                                          otherButtonTitles:nil];
    [alert show];
}

@interface A0FullActiveDirectoryViewController ()

@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UILabel *orLabel;
@property (strong, nonatomic) A0ServicesTheme *services;
@property (strong, nonatomic) NSArray *activeServices;

@end

@implementation A0FullActiveDirectoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UINib *cellNib = [UINib nibWithNibName:@"A0ServiceCollectionViewCell" bundle:nil];
    [self.serviceCollectionView registerNib:cellNib forCellWithReuseIdentifier:kCellIdentifier];
    self.services = [[A0ServicesTheme alloc] init];
    self.activeServices = self.application.socialStrategies;
    self.serviceCollectionView.scrollEnabled = self.activeServices.count > 5;
    A0Theme *theme = [A0Theme sharedInstance];
    self.orLabel.font = [theme fontForKey:A0ThemeTextFieldFont defaultFont:self.orLabel.font];
    self.orLabel.textColor = [theme colorForKey:A0ThemeTextFieldTextColor defaultColor:self.orLabel.textColor];
    self.orLabel.text = A0LocalizedString(@"OR");
}

- (void)triggerAuth:(UIButton *)sender {
    @weakify(self);
    A0APIClientAuthenticationSuccess successBlock = ^(A0UserProfile *profile, A0Token *token){
        @strongify(self);
        [self setInProgress:NO];
        if (self.onLoginBlock) {
            self.onLoginBlock(profile, token);
        }
    };

    void(^failureBlock)(NSError *error) = ^(NSError *error) {
        @strongify(self);
        [self setInProgress:NO];
        if (error.code != A0ErrorCodeFacebookCancelled && error.code != A0ErrorCodeTwitterCancelled && error.code != A0ErrorCodeAuth0Cancelled) {
            switch (error.code) {
                case A0ErrorCodeTwitterAppNotAuthorized:
                case A0ErrorCodeTwitterInvalidAccount:
                case A0ErrorCodeTwitterNotConfigured:
                case A0ErrorCodeAuth0NotAuthorized:
                case A0ErrorCodeAuth0InvalidConfiguration:
                case A0ErrorCodeAuth0NoURLSchemeFound:
                    showAlertErrorView(error.localizedDescription, error.localizedFailureReason);
                    break;
                default:
                    showAlertErrorView(A0LocalizedString(@"There was an error logging in"), [A0Errors localizedStringForSocialLoginError:error]);
                    break;
            }
        }
    };
    [self setInProgress:YES];

    A0Strategy *strategy = self.application.socialStrategies[sender.tag];
    A0IdentityProviderAuthenticator *authenticator = [A0IdentityProviderAuthenticator sharedInstance];
    if ([authenticator canAuthenticateStrategy:strategy]) {
        Auth0LogVerbose(@"Authenticating using third party iOS application for strategy %@", strategy.name);
        [authenticator authenticateForStrategy:strategy parameters:self.parameters success:successBlock failure:failureBlock];
    } else {
        Auth0LogVerbose(@"Authenticating using embedded UIWebView for strategy %@", strategy.name);
        A0WebViewController *controller = [[A0WebViewController alloc] initWithApplication:self.application strategy:strategy parameters:self.parameters];
        controller.modalPresentationStyle = UIModalPresentationCurrentContext;
        controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        controller.onAuthentication = successBlock;
        controller.onFailure = failureBlock;
        [self presentViewController:controller animated:YES completion:nil];
    }
}

#pragma mark - UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


#pragma mark - UICollectionViewDelegateFlowLayout

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    NSInteger numberOfCells = self.activeServices.count;
    UIEdgeInsets insets;
    if (numberOfCells > 5) {
        insets = UIEdgeInsetsZero;
    } else {
        CGFloat cellsWidth = (numberOfCells * 40) + MAX(0, (numberOfCells - 1) * 10);

        NSInteger edgeInsets = (self.serviceCollectionView.frame.size.width - cellsWidth) / 2;

        insets = UIEdgeInsetsMake(0, edgeInsets, 0, edgeInsets);
    }
    return insets;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.activeServices.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    A0ServiceCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
    NSString *serviceName = [self.activeServices[indexPath.item] name];
    UIColor *background = [self.services backgroundColorForServiceWithName:serviceName];
    UIColor *selectedBackground = [self.services selectedBackgroundColorForServiceWithName:serviceName];
    cell.serviceButton.titleLabel.font = [UIFont zocialFontOfSize:14.0f];
    [cell.serviceButton setTitleColor:[self.services foregroundColorForServiceWithName:serviceName] forState:UIControlStateNormal];
    [cell.serviceButton setTitle:[self.services iconCharacterForServiceWithName:serviceName] forState:UIControlStateNormal];
    [cell.serviceButton setBackgroundColor:background forState:UIControlStateNormal];
    [cell.serviceButton setBackgroundColor:selectedBackground forState:UIControlStateHighlighted];
    [cell.serviceButton addTarget:self action:@selector(triggerAuth:) forControlEvents:UIControlEventTouchUpInside];
    cell.serviceButton.tag = indexPath.item;
    return cell;
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
