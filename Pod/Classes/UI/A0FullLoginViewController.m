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
#import "A0Application.h"
#import "A0Strategy.h"
#import "A0ServiceCollectionViewCell.h"
#import "A0SocialAuthenticator.h"
#import "UIButton+A0SolidButton.h"
#import "A0APIClient.h"
#import "A0Errors.h"

#import <libextobjc/EXTScope.h>

#define UIColorFromRGBA(rgbValue, alphaValue) ([UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 \
green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0 \
blue:((float)(rgbValue & 0xFF)) / 255.0 \
alpha:alphaValue])

#define UIColorFromRGB(rgbValue) (UIColorFromRGBA((rgbValue), 1.0))

#define kCellIdentifier @"ServiceCell"

static void showAlertErrorView(NSString *title, NSString *message) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                          otherButtonTitles:nil];
    [alert show];
}

@interface A0FullLoginViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (strong, nonatomic) NSDictionary *services;
@property (strong, nonatomic) NSArray *activeServices;

@end

@implementation A0FullLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UINib *cellNib = [UINib nibWithNibName:@"A0ServiceCollectionViewCell" bundle:nil];
    [self.serviceCollectionView registerNib:cellNib forCellWithReuseIdentifier:kCellIdentifier];
    self.services = [A0FullLoginViewController servicesDictionary];
    self.activeServices = self.application.availableSocialStrategies;
}

- (void)triggerAuth:(UIButton *)sender {
    @weakify(self);
    A0APIClientAuthenticationSuccess successBlock = ^(A0UserProfile *profile){
        @strongify(self);
        [self setInProgress:NO];
        if (self.onLoginBlock) {
            self.onLoginBlock(profile);
        }
    };

    [self setInProgress:YES];
    A0Strategy *strategy = self.application.availableSocialStrategies[sender.tag];
    [[A0SocialAuthenticator sharedInstance] authenticateForStrategy:strategy withSuccess:^(A0SocialCredentials *socialCredentials) {
        [[A0APIClient sharedClient] authenticateWithSocialStrategy:strategy
                                                 socialCredentials:socialCredentials
                                                           success:successBlock
                                                           failure:^(NSError *error) {
                                                               @strongify(self);
                                                               [self setInProgress:NO];
                                                               showAlertErrorView(NSLocalizedString(@"There was an error logging in", nil), [A0Errors localizedStringForSocialLoginError:error]);
                                                           }];
    } failure:^(NSError *error) {
        @strongify(self);
        [self setInProgress:NO];
        if (error.code != A0ErrorCodeFacebookCancelled && error.code != A0ErrorCodeTwitterCancelled) {
            switch (error.code) {
                case A0ErrorCodeTwitterAppNotAuthorized:
                case A0ErrorCodeTwitterInvalidAccount:
                case A0ErrorCodeTwitterNotConfigured:
                    showAlertErrorView(error.localizedDescription, error.localizedFailureReason);
                    break;
                default:
                    showAlertErrorView(NSLocalizedString(@"There was an error logging in", nil), [A0Errors localizedStringForSocialLoginError:error]);
                    break;
            }
        }
    }];
}

#pragma mark - UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


#pragma mark - UICollectionViewDelegateFlowLayout

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    NSInteger numberOfCells = self.activeServices.count;
    CGFloat cellsWidth = (numberOfCells * 40) + MAX(0, (numberOfCells - 1) * 10);

    NSInteger edgeInsets = (self.view.frame.size.width - cellsWidth) / 2;

    return UIEdgeInsetsMake(0, edgeInsets, 0, edgeInsets);
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.activeServices.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    A0ServiceCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
    NSString *serviceName = [self.activeServices[indexPath.item] name];
    NSDictionary *serviceInfo = self.services[serviceName];
    UIColor *background = [A0FullLoginViewController colorFromString:serviceInfo[@"background_color"]];
    UIColor *selectedBackground = [A0FullLoginViewController colorFromString:serviceInfo[@"selected_background_color"]];
    cell.serviceButton.titleLabel.font = [UIFont fontWithName:@"connections" size:14.0f];
    cell.serviceButton.titleLabel.tintColor = [UIColor whiteColor];
    [cell.serviceButton setTitle:serviceInfo[@"icon_character"] forState:UIControlStateNormal];
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

+ (UIColor *)colorFromString:(NSString *)hexString {
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    unsigned hex;
    BOOL success = [scanner scanHexInt:&hex];

    if (!success) return nil;
    if ([hexString length] <= 6) {
        return UIColorFromRGB(hex);
    } else {
        unsigned color = (hex & 0xFFFFFF00) >> 8;
        CGFloat alpha = 1.0 * (hex & 0xFF) / 255.0;
        return UIColorFromRGBA(color, alpha);
    }
}

+ (NSDictionary *)servicesDictionary {
    NSString *resourceBundlePath = [[NSBundle mainBundle] pathForResource:@"Auth0" ofType:@"bundle"];
    NSBundle *resourceBundle = [NSBundle bundleWithPath:resourceBundlePath];
    NSString *plistPath = [resourceBundle pathForResource:@"Services" ofType:@"plist"];
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    return dictionary;
}

@end
