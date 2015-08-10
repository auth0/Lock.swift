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

@interface NSTimer (WebKitNetworkTimer)

@property (readonly, nonatomic) WKNavigation *navigation;

+ (NSTimer *)networkTimerWithInterval:(NSTimeInterval)interval navigation:(WKNavigation *)navigation target:(id)target selector:(SEL)selector;

@end

@interface A0WebKitViewController () <WKNavigationDelegate>

@property (strong, nonatomic) A0WebAuthentication *authentication;
@property (strong, nonatomic) A0APIClient *client;
@property (strong, nonatomic) NSURL *authorizeURL;
@property (copy, nonatomic) NSString *connectionName;
@property (strong, nonatomic) NSTimer *networkTimer;

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
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[webview]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(webview)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[webview]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(webview)]];
    [self.view updateConstraints];

    webview.navigationDelegate = self;
    [webview loadRequest:[NSURLRequest requestWithURL:self.authorizeURL]];

    NSString *cancelTitle = self.localizedCancelButtonTitle ?: A0LocalizedString(@"Cancel");
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:cancelTitle style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)]];
    [self showProgressIndicator];
}

- (IBAction)cancel:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    if (self.onFailure) {
        self.onFailure([A0Errors auth0CancelledForConnectionName:self.connectionName]);
    }
    [self cleanCallbacks];
}

- (void)dealloc {
    [self cleanCallbacks];
    [self cleanNetworkTimeout];
}

- (void)networkTimedOut:(NSTimer *)timer {
    A0LogError(@"Network timed out for navigation %@", timer.userInfo[@"navigation"]);
}

- (void)cleanNetworkTimeout {
    A0LogDebug(@"Cleaned network timeout for navigation %@", self.networkTimer.navigation);
    [self.networkTimer invalidate];
    self.networkTimer = nil;
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    A0LogVerbose(@"Loaded page with navigation: %@", navigation);
    [self hideProgressIndicator];
    self.title = webView.title;
    if ([self.networkTimer.navigation isEqual:navigation]) {
        [self cleanNetworkTimeout];
    }
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    A0LogVerbose(@"Started to load page with navigation: %@", navigation);
    [self cleanNetworkTimeout];
    self.networkTimer = [NSTimer networkTimerWithInterval:3.0 navigation:navigation target:self selector:@selector(networkTimedOut:)];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    A0LogDebug(@"Failed navigation %@ with error %@", navigation, error);
    [self cleanNetworkTimeout];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    A0LogVerbose(@"Failed provisional navigation %@ with error %@", navigation, error);
    [self cleanNetworkTimeout];
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
            [self showProgressIndicator];
            [self.client fetchUserProfileWithIdToken:token.idToken success:^(A0UserProfile *profile) {
                @strongify(self);
                if (success) {
                    success(profile, token);
                }
                decisionHandler(WKNavigationActionPolicyCancel);
                [self dismiss];
            } failure:^(NSError *error) {
                @strongify(self);
                [self handleError:error decisionHandler:decisionHandler];
            }];
        } else {
            [self handleError:error decisionHandler:decisionHandler];
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

- (void)dismiss {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    [self cleanCallbacks];
}

- (void)handleError:(NSError *)error decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if (self.onFailure) {
        self.onFailure(error);
    }
    decisionHandler(WKNavigationActionPolicyCancel);
    [self dismiss];
}

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

@implementation NSTimer (WebKitNetworkTimer)

- (WKNavigation *)navigation {
    return self.userInfo[@"navigation"];
}

+ (NSTimer *)networkTimerWithInterval:(NSTimeInterval)interval navigation:(WKNavigation *)navigation target:(id)target selector:(SEL)selector {
    return [NSTimer scheduledTimerWithTimeInterval:3.0
                                            target:target
                                          selector:selector
                                          userInfo:@{@"navigation": navigation}
                                           repeats:NO];
}
@end
