//  A0SocialTableViewController.m
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

#import "A0SocialLoginViewController.h"
#import "A0Application.h"
#import "A0Strategy.h"
#import "A0IdentityProviderAuthenticator.h"
#import "UIButton+A0SolidButton.h"
#import "A0ServiceTableViewCell.h"
#import "A0APIClient.h"
#import "A0Errors.h"
#import "A0ProgressButton.h"
#import "A0Alert.h"
#import "A0LockConfiguration.h"
#import "UIViewController+LockNotification.h"
#import "A0Lock.h"
#import "NSObject+A0AuthenticatorProvider.h"
#import "NSError+A0APIError.h"
#import "NSError+A0LockErrors.h"
#import "A0ServiceViewModel.h"
#import "A0Connection.h"
#import "Constants.h"

static NSString * const ServiceCellIdentifier = @"ServiceCell";
static const CGFloat ServiceCellHeight = 55.0;

@interface A0SocialLoginViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSDictionary *serviceTheme;
@property (strong, nonatomic) NSArray<A0ServiceViewModel *> *services;
@property (assign, nonatomic) NSInteger selectedService;

@end

@implementation A0SocialLoginViewController

- (void)viewDidLoad {
    [self setupUI];
}

- (void)setupLayout {
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:tableView];

    NSDictionary<NSString *, id> *metrics = @{
                                              @"horizontalMargin": @20,
                                              @"verticalMargin": @0,
                                              };
    NSDictionary<NSString *, id> *views = NSDictionaryOfVariableBindings(tableView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-horizontalMargin-[tableView]-horizontalMargin-|"
                                                                      options:0 metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-verticalMargin-[tableView]-verticalMargin-|"
                                                                      options:0 metrics:metrics views:views]];

    self.tableView = tableView;
}

- (void)setupUI {
    [self setupLayout];

    self.title = A0LocalizedString(@"Login");
    self.services = [A0ServiceViewModel servicesFromStrategies:self.configuration.socialStrategies];
    self.selectedService = NSNotFound;

    self.tableView.allowsMultipleSelection = NO;
    self.tableView.allowsSelectionDuringEditing = NO;
    self.tableView.rowHeight = ServiceCellHeight;
    [self.tableView registerClass:A0ServiceTableViewCell.class forCellReuseIdentifier:ServiceCellIdentifier];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];

    self.view.backgroundColor = [UIColor clearColor];
    [self.view setNeedsUpdateConstraints];
}

- (void)triggerAuth:(UIButton *)sender {
    self.selectedService = sender.tag;
    A0ServiceViewModel *service = self.services[sender.tag];
    A0Connection *connection = service.connection;
    A0APIClientAuthenticationSuccess successBlock = ^(A0UserProfile *profile, A0Token *token){
        [self postLoginSuccessfulForConnection:service.connection];
        [self setInProgress:NO];
        if (self.onLoginBlock) {
            self.onLoginBlock(profile, token);
        }
    };

    void(^failureBlock)(NSError *) = ^(NSError *error) {
        [self postLoginErrorNotificationWithError:error];
        [self setInProgress:NO];
        if (![error a0_cancelledSocialAuthenticationError]) {
            switch (error.code) {
                case A0ErrorCodeTwitterAppNotAuthorized:
                case A0ErrorCodeTwitterInvalidAccount:
                case A0ErrorCodeTwitterNotConfigured:
                case A0ErrorCodeAuth0NotAuthorized:
                case A0ErrorCodeAuth0InvalidConfiguration:
                case A0ErrorCodeAuth0NoURLSchemeFound:
                case A0ErrorCodeNotConnectedToInternet:
                case A0ErrorCodeGooglePlusFailed: {
                    [A0Alert showInController:self errorAlert:^(A0Alert *alert) {
                        alert.title = error.localizedDescription;
                        alert.message = error.localizedFailureReason;
                    }];
                    break;
                }
                default: {
                    [A0Alert showInController:self errorAlert:^(A0Alert *alert) {
                        alert.title = A0LocalizedString(@"There was an error logging in");
                        alert.message = [error a0_localizedStringErrorForConnectionName:connection.name];
                    }];
                    break;
                }
            }
        }
    };
    [self setInProgress:YES];
    A0IdentityProviderAuthenticator *authenticator = [self a0_identityAuthenticatorFromProvider:self.lock];
    A0LogVerbose(@"Authenticating with connection %@", connection.name);
    [authenticator authenticateWithConnectionName:connection.name parameters:self.parameters success:successBlock failure:failureBlock];
}

- (CGRect)rectToKeepVisibleInView:(UIView *)view {
    return CGRectZero;
}

- (void)hideKeyboard {}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return (tableView.bounds.size.height - tableView.rowHeight * self.services.count)  / 2;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.services.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    A0ServiceViewModel *service = self.services[indexPath.row];
    A0ServiceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ServiceCellIdentifier forIndexPath:indexPath];
    [cell applyTheme:service.theme];
    [cell.button addTarget:self action:@selector(triggerAuth:) forControlEvents:UIControlEventTouchUpInside];
    cell.button.tag = indexPath.row;
    [cell.button setInProgress:self.selectedService == indexPath.row];
    return cell;
}

#pragma mark - Utility methods

- (void)setInProgress:(BOOL)inProgress {
    self.view.userInteractionEnabled = !inProgress;
    [self.tableView reloadData];
    if (!inProgress) {
        self.selectedService = NSNotFound;
    }
}

@end
