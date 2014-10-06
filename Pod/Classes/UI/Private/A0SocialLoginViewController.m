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
#import "A0ServicesTheme.h"
#import "A0WebViewController.h"

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

@interface A0SocialLoginViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (strong, nonatomic) A0ServicesTheme *services;
@property (strong, nonatomic) NSArray *activeServices;
@property (assign, nonatomic) NSInteger selectedService;

@end

@implementation A0SocialLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = A0LocalizedString(@"Login");
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UINib *cellNib = [UINib nibWithNibName:@"A0ServiceTableViewCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:kCellIdentifier];
    self.services = [[A0ServicesTheme alloc] init];
    self.activeServices = self.application.socialStrategies;
    self.selectedService = NSNotFound;
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

    void(^failureBlock)(NSError *) = ^(NSError *error) {
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
    self.selectedService = sender.tag;
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

- (CGRect)rectToKeepVisibleInView:(UIView *)view {
    return CGRectZero;
}

- (void)hideKeyboard {}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.activeServices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *serviceName = [self.activeServices[indexPath.row] name];
    UIColor *background = [self.services backgroundColorForServiceWithName:serviceName];
    UIColor *selectedBackground = [self.services selectedBackgroundColorForServiceWithName:serviceName];
    UIColor *foreground = [self.services foregroundColorForServiceWithName:serviceName];
    A0ServiceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    [cell configureWithBackground:background
                      highlighted:selectedBackground
                       foreground:foreground
                           symbol:[self.services iconCharacterForServiceWithName:serviceName]
                             name:[self.services titleForServiceWithName:serviceName]];
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
