// A0SmallSocialAuthenticationCollectionView.m
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

#import "A0SmallSocialAuthenticationCollectionView.h"

#import <libextobjc/EXTScope.h>

#import "A0ServicesTheme.h"
#import "A0ServiceCollectionViewLayoutDelegate.h"
#import "A0ServiceCollectionViewCell.h"
#import "UIFont+A0Social.h"
#import "UIButton+A0SolidButton.h"
#import "A0APIClient.h"
#import "A0Errors.h"
#import "A0IdentityProviderAuthenticator.h"
#import "A0Strategy.h"
#import "A0WebViewController.h"
#import "A0LockConfiguration.h"
#import "A0LockNotification.h"
#import "A0Connection.h"
#import "A0AuthParameters.h"
#import "NSObject+A0AuthenticatorProvider.h"
#import "A0Lock.h"


#define kCellIdentifier @"ServiceCell"

@interface A0SmallSocialAuthenticationCollectionView () <UICollectionViewDataSource>

@property (strong, nonatomic) A0LockConfiguration *configuration;
@property (strong, nonatomic) NSArray *socialServices;
@property (strong, nonatomic) A0ServicesTheme *servicesTheme;
@property (strong, nonatomic) A0ServiceCollectionViewLayoutDelegate *layoutDelegate;

@end

@implementation A0SmallSocialAuthenticationCollectionView

AUTH0_DYNAMIC_LOGGER_METHODS

- (void)awakeFromNib {
    [super awakeFromNib];
    self.layoutDelegate = [[A0ServiceCollectionViewLayoutDelegate alloc] initWithServiceCount:self.socialServices.count];
    self.delegate = self.layoutDelegate;
    self.dataSource = self;
    self.scrollEnabled = self.layoutDelegate.shouldScroll;
    self.servicesTheme = [[A0ServicesTheme alloc] init];
    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass([A0ServiceCollectionViewCell class])
                                    bundle:[NSBundle bundleForClass:[self class]]];
    [self registerNib:cellNib forCellWithReuseIdentifier:kCellIdentifier];
}

- (void)showSocialServicesForConfiguration:(A0LockConfiguration *)configuration {
    self.configuration = configuration;
    self.socialServices = [configuration socialStrategies];
    self.layoutDelegate.serviceCount = self.socialServices.count;
    self.scrollEnabled = self.layoutDelegate.shouldScroll;
    [self reloadData];
}

- (void)triggerAuth:(UIButton *)sender {
    @weakify(self);
    A0Strategy *strategy = self.socialServices[sender.tag];
    A0APIClientAuthenticationSuccess successBlock = ^(A0UserProfile *profile, A0Token *token){
        @strongify(self);
        [self postLoginSuccessfulForConnection:strategy.connections.firstObject];
        [self.authenticationDelegate authenticationDidEndForSocialCollectionView:self];
        [self.authenticationDelegate socialAuthenticationCollectionView:self didAuthenticateUserWithProfile:profile token:token];
    };

    void(^failureBlock)(NSError *error) = ^(NSError *error) {
        @strongify(self);
        [self postLoginErrorNotificationWithError:error];
        [self.authenticationDelegate authenticationDidEndForSocialCollectionView:self];
        NSError *authenticationError;
        if (![A0Errors isCancelledSocialAuthentication:error]) {
            switch (error.code) {
                case A0ErrorCodeTwitterAppNotAuthorized:
                case A0ErrorCodeTwitterInvalidAccount:
                case A0ErrorCodeTwitterNotConfigured:
                case A0ErrorCodeAuth0NotAuthorized:
                case A0ErrorCodeAuth0InvalidConfiguration:
                case A0ErrorCodeAuth0NoURLSchemeFound:
                case A0ErrorCodeNotConnectedToInternet:
                case A0ErrorCodeGooglePlusFailed:
                    authenticationError = error;
                    break;
                default:
                    authenticationError = [A0Errors defaultLoginErrorFor:error];
                    break;
            }
            [self.authenticationDelegate socialAuthenticationCollectionView:self didFailWithError:authenticationError];
        }
    };
    [self.authenticationDelegate authenticationDidStartForSocialCollectionView:self];

    A0AuthParameters *parameters = [self.parameters copy];
    parameters[A0ParameterConnection] = strategy.name;
    A0IdentityProviderAuthenticator *authenticator = [self a0_identityAuthenticatorFromProvider:self.lock];
    if ([authenticator canAuthenticateStrategy:strategy]) {
        A0LogVerbose(@"Authenticating using third party iOS application for strategy %@", strategy.name);
        [authenticator authenticateForStrategy:strategy parameters:parameters success:successBlock failure:failureBlock];
    } else {
        A0LogVerbose(@"Authenticating using embedded UIWebView for strategy %@", strategy.name);
        A0WebViewController *controller = [[A0WebViewController alloc] initWithApplication:self.configuration.application
                                                                                  strategy:strategy
                                                                                parameters:parameters];
        controller.modalPresentationStyle = UIModalPresentationCurrentContext;
        controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        controller.onAuthentication = successBlock;
        controller.onFailure = failureBlock;
        controller.lock = self.lock;
        [self.authenticationDelegate socialAuthenticationCollectionView:self presentAuthenticationViewController:controller];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.socialServices.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    A0ServiceCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
    NSString *serviceName = [self.socialServices[indexPath.item] name];
    UIColor *background = [self.servicesTheme backgroundColorForServiceWithName:serviceName];
    UIColor *selectedBackground = [self.servicesTheme selectedBackgroundColorForServiceWithName:serviceName];
    cell.serviceButton.titleLabel.font = [UIFont zocialFontOfSize:16.0f];
    [cell.serviceButton setTitleColor:[self.servicesTheme foregroundColorForServiceWithName:serviceName] forState:UIControlStateNormal];
    [cell.serviceButton setTitle:[self.servicesTheme iconCharacterForServiceWithName:serviceName] forState:UIControlStateNormal];
    [cell.serviceButton setBackgroundColor:background forState:UIControlStateNormal];
    [cell.serviceButton setBackgroundColor:selectedBackground forState:UIControlStateHighlighted];
    [cell.serviceButton addTarget:self action:@selector(triggerAuth:) forControlEvents:UIControlEventTouchUpInside];
    cell.serviceButton.tag = indexPath.item;
    return cell;
}

#pragma mark - Lock notifications

- (void)postLoginErrorNotificationWithError:(NSError *)error {
    [[NSNotificationCenter defaultCenter] postNotificationName:A0LockNotificationLoginFailed
                                                        object:nil
                                                      userInfo:@{
                                                                 A0LockNotificationErrorParameterKey: error,
                                                                 }];
}

- (void)postLoginSuccessfulForConnection:(A0Connection *)connection {
    [[NSNotificationCenter defaultCenter] postNotificationName:A0LockNotificationLoginSuccessful
                                                        object:nil
                                                      userInfo:@{
                                                                 A0LockNotificationConnectionParameterKey: connection.name,
                                                                 }];
}
@end
