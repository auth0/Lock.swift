//  A0WebViewController.m
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

#import "A0WebViewController.h"
#import "A0Errors.h"
#import "A0Application.h"
#import "A0Strategy.h"
#import "A0APIClient.h"
#import "A0Token.h"
#import "A0WebAuthentication.h"
#import "NSDictionary+A0QueryParameters.h"
#import "A0AuthParameters.h"
#import "A0Lock.h"
#import "Constants.h"
#import <Masonry/Masonry.h>

@interface A0WebViewController () <UIWebViewDelegate>
@property (weak, nonatomic) UIWebView *webview;
@property (strong, nonatomic) NSURL *authorizeURL;
@property (strong, nonatomic) A0WebAuthentication *authentication;
@property (copy, nonatomic) NSString *connectionName;
@property (strong, nonatomic) A0APIClient *client;

- (IBAction)cancel:(id)sender;

@end

@implementation A0WebViewController

AUTH0_DYNAMIC_LOGGER_METHODS

- (instancetype)initWithAPIClient:(A0APIClient * __nonnull)client
                   connectionName:(NSString * __nonnull)connectionName
                       parameters:(nullable A0AuthParameters *)parameters {
    self = [self init];
    if (self) {
        _authentication = [[A0WebAuthentication alloc] initWithClientId:client.clientId domainURL:client.baseURL connectionName:connectionName];
        [_authentication setTelemetryInfo:[client telemetryInfo]];
        _authorizeURL = [_authentication authorizeURLWithParameters:[parameters asAPIPayload]];
        _connectionName = connectionName;
        _client = client;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UIWebView *webview = [[UIWebView alloc] initWithFrame:CGRectZero];

    [self.view addSubview:webview];
    [webview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    self.webview = webview;
    self.automaticallyAdjustsScrollViewInsets = YES;
    NSURLRequest *request = [NSURLRequest requestWithURL:self.authorizeURL];
    [self.webview loadRequest:request];
    NSString *cancelTitle = self.localizedCancelButtonTitle ?: A0LocalizedString(@"Cancel");
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:cancelTitle style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)]];
    [self showProgressIndicator];
}

- (void)setTelemetryInfo:(NSString *)telemetryInfo {
    self.authentication.telemetryInfo = telemetryInfo;
}

- (void)cancel:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    if (self.onFailure) {
        self.onFailure([A0Errors auth0CancelledForConnectionName:self.connectionName]);
    }
    self.onFailure = nil;
    self.onAuthentication = nil;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    A0LogVerbose(@"About to load URL %@", request);
    BOOL isCallback = [self.authentication validateURL:request.URL];
    if (isCallback) {
        NSError *error;
        A0Token *token = [self.authentication tokenFromURL:request.URL error:&error];
        if (token) {
            A0IdPAuthenticationBlock success = self.onAuthentication;
            [self.client fetchUserProfileWithIdToken:token.idToken success:^(A0UserProfile *profile) {
                self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
                if (success) {
                    success(profile, token);
                }
            } failure:self.onFailure];
            [self showProgressIndicator];
        } else {
            if (self.onFailure) {
                self.onFailure(error);
            }
            [self hideProgressIndicator];
        }
        self.onAuthentication = nil;
        self.onFailure = nil;
    }
    return !isCallback;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    A0LogVerbose(@"Loaded URL %@", webView.request);
    [self hideProgressIndicator];
}

#pragma mark - Utility methods

- (void)showProgressIndicator {
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.color = self.navigationController.navigationBar.tintColor;
    [indicator startAnimating];
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:indicator] animated:YES];
}

- (void)hideProgressIndicator {
    [self.navigationItem setRightBarButtonItem:nil animated:NO];
}

@end
