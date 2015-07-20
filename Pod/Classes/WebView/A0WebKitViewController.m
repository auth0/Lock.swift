// A0WebKitViewController.m
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

#import "A0WebKitViewController.h"
#import <WebKit/WebKit.h>
#import "A0Errors.h"
#import "A0WebAuthentication.h"
#import "A0APIClient.h"
#import "A0AuthParameters.h"
#import "A0Token.h"
#import <libextobjc/EXTScope.h>

@interface A0WebKitViewController () <WKNavigationDelegate>

@property (strong, nonatomic) A0WebAuthentication *authentication;
@property (strong, nonatomic) A0APIClient *client;
@property (strong, nonatomic) NSURL *authorizeURL;
@property (copy, nonatomic) NSString *connectionName;

@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet WKWebView *webview;
@property (weak, nonatomic) IBOutlet UIView *containerView;

- (IBAction)cancel:(id)sender;

@end

@implementation A0WebKitViewController

AUTH0_DYNAMIC_LOGGER_METHODS

- (instancetype)init {
    return [self initWithNibName:NSStringFromClass(self.class) bundle:[NSBundle bundleForClass:self.class]];
}

- (instancetype)initWithAPIClient:(A0APIClient * __nonnull)client
                   connectionName:(NSString * __nonnull)connectionName
                       parameters:(nullable A0AuthParameters *)parameters {
    self = [self init];
    if (self) {
        _authentication = [[A0WebAuthentication alloc] initWithClientId:client.clientId domainURL:client.baseURL connectionName:connectionName];
        _authorizeURL = [_authentication authorizeURLWithParameters:[parameters asAPIPayload]];
        _connectionName = connectionName;
        _client = client;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    WKWebView *webview = [[WKWebView alloc] initWithFrame:CGRectZero configuration:[[WKWebViewConfiguration alloc] init]];
    webview.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:webview];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_titleView][webview]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(webview, _titleView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[webview]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(webview)]];
    self.view.backgroundColor = [UIColor redColor];
    [self.view updateConstraints];

    webview.navigationDelegate = self;
    [webview loadRequest:[NSURLRequest requestWithURL:self.authorizeURL]];
    self.webview = webview;
    [self.cancelButton setTitle:A0LocalizedString(@"Cancel") forState:UIControlStateNormal];
}

- (IBAction)cancel:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    if (self.onFailure) {
        self.onFailure([A0Errors auth0CancelledForConnectionName:self.connectionName]);
    }
    self.onFailure = nil;
    self.onAuthentication = nil;
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    A0LogVerbose(@"Loaded page");
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    A0LogVerbose(@"Started to load page");
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    A0LogVerbose(@"Loading URL %@", navigationAction.request.URL);
    NSURLRequest *request = navigationAction.request;
    BOOL isCallback = [self.authentication validateURL:request.URL];
    if (isCallback) {
        NSError *error;
        A0Token *token = [self.authentication tokenFromURL:request.URL error:&error];
        if (token) {
            A0IdPAuthenticationBlock success = self.onAuthentication;
            @weakify(self);
            [self.client fetchUserProfileWithIdToken:token.idToken success:^(A0UserProfile *profile) {
                @strongify(self);
                if (success) {
                    success(profile, token);
                }
                decisionHandler(WKNavigationActionPolicyCancel);
                [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                [self cleanCallbacks];
            } failure:^(NSError *error) {
                @strongify(self);
                if (self.onFailure) {
                    self.onFailure(error);
                }
                decisionHandler(WKNavigationActionPolicyCancel);
                [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                [self cleanCallbacks];
            }];
        } else {
            if (self.onFailure) {
                self.onFailure(error);
            }
            decisionHandler(WKNavigationActionPolicyCancel);
            [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
            [self cleanCallbacks];
        }
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

#pragma mark - Utility methods

- (void)cleanCallbacks {
    self.onAuthentication = nil;
    self.onFailure = nil;
}

@end
