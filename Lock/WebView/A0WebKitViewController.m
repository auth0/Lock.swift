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
#import "A0Theme.h"
#import "Constants.h"
#import "A0PKCE.h"
#import <Masonry/Masonry.h>

@interface A0WebKitViewController () <WKNavigationDelegate>

@property (strong, nonatomic) A0WebAuthentication *authentication;
@property (strong, nonatomic) A0APIClient *client;
@property (strong, nonatomic) NSURL *authorizeURL;
@property (copy, nonatomic) NSString *connectionName;
@property (strong, nonatomic) A0PKCE *pkce;

@property (weak, nonatomic) WKWebView *webview;
@property (weak, nonatomic) UIView *messageView;
@property (weak, nonatomic) UILabel *messageTitleLabel;
@property (weak, nonatomic) UILabel *messageDescriptionLabel;
@property (weak, nonatomic) UIButton *retryButton;

- (IBAction)cancel:(id)sender;
- (IBAction)retry:(id)sender;

@end

@implementation A0WebKitViewController

- (instancetype)initWithAPIClient:(A0APIClient *)client connectionName:(NSString *)connectionName parameters:(nullable A0AuthParameters *)parameters usePKCE:(BOOL)usePKCE {
    self = [self init];
    if (self) {
        _pkce = usePKCE ? [[A0PKCE alloc] init] : nil;
        _authentication = [[A0WebAuthentication alloc] initWithClientId:client.clientId domainURL:client.baseURL connectionName:connectionName];
        NSMutableDictionary *dictionary = [[parameters asAPIPayload] mutableCopy];
        if (_pkce) {
            [dictionary addEntriesFromDictionary:[_pkce authorizationParameters]];
        }
        [_authentication setTelemetryInfo:[client telemetryInfo]];
        _authorizeURL = [_authentication authorizeURLWithParameters:dictionary usePKCE:usePKCE];
        _connectionName = connectionName;
        _client = client;
    }
    return self;
}

- (instancetype)initWithAPIClient:(A0APIClient * __nonnull)client
                   connectionName:(NSString * __nonnull)connectionName
                       parameters:(nullable A0AuthParameters *)parameters {
    return [self initWithAPIClient:client connectionName:connectionName parameters:parameters usePKCE:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIView *messageView = [[UIView alloc] initWithFrame:CGRectZero];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    UIButton *retryButton = [UIButton buttonWithType:UIButtonTypeSystem];
    WKWebView *webview = [[WKWebView alloc] initWithFrame:CGRectZero configuration:[[WKWebViewConfiguration alloc] init]];

    [messageView addSubview:titleLabel];
    [messageView addSubview:descriptionLabel];
    [messageView addSubview:retryButton];

    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(messageView);
    }];
    [retryButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(messageView);
        make.width.equalTo(@100);
        make.top.equalTo(descriptionLabel.mas_bottom).offset(20);
    }];
    [descriptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(messageView).offset(0.5);
        make.left.equalTo(messageView.mas_left).offset(20);
        make.right.equalTo(messageView.mas_right).offset(-20);
        make.top.equalTo(titleLabel.mas_bottom).offset(16);
    }];

    [self.view addSubview:webview];
    [self.view addSubview:messageView];
    [self.view bringSubviewToFront:messageView];

    [webview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    [messageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    webview.navigationDelegate = self;
    [webview loadRequest:[NSURLRequest requestWithURL:self.authorizeURL]];
    self.automaticallyAdjustsScrollViewInsets = YES;

    self.messageView = messageView;
    self.messageTitleLabel = titleLabel;
    self.messageDescriptionLabel = descriptionLabel;
    self.webview = webview;
    self.retryButton = retryButton;

    NSString *cancelTitle = self.localizedCancelButtonTitle ?: A0LocalizedString(@"Cancel");
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:cancelTitle style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)]];

    self.messageView.hidden = YES;
    A0Theme *theme = [A0Theme sharedInstance];
    [theme configureLabel:self.messageDescriptionLabel];
    self.messageTitleLabel.text = A0LocalizedString(@"Could not connect to server");
    self.messageTitleLabel.font = [theme fontForKey:A0ThemeTitleFont];
    self.messageTitleLabel.textColor = [theme colorForKey:A0ThemeTitleTextColor];
    self.messageDescriptionLabel.numberOfLines = 5;
    self.messageDescriptionLabel.textAlignment = NSTextAlignmentCenter;
    self.messageDescriptionLabel.font = [theme fontForKey:A0ThemeDescriptionFont];
    self.messageDescriptionLabel.textColor = [theme colorForKey:A0ThemeDescriptionTextColor];
    self.retryButton.tintColor = self.navigationController.navigationBar.tintColor;
    [self.retryButton setTitle:A0LocalizedString(@"Retry") forState:UIControlStateNormal];
    [self.retryButton addTarget:self action:@selector(retry:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setTelemetryInfo:(NSString *)telemetryInfo {
    self.authentication.telemetryInfo = telemetryInfo;
}

- (IBAction)cancel:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    if (self.onFailure) {
        self.onFailure([A0Errors auth0CancelledForConnectionName:self.connectionName]);
    }
    [self cleanCallbacks];
}

- (void)retry:(id)sender {
    [self.webview loadRequest:[NSURLRequest requestWithURL:self.authorizeURL]];
    self.messageView.hidden = YES;
}

- (void)dealloc {
    [self cleanCallbacks];
}

- (void)networkTimedOutForNavigation:(WKNavigation *)navigation {
    A0LogError(@"Network timed out for navigation %@", navigation);
    self.messageDescriptionLabel.text = A0LocalizedString(@"Sorry, we couldn't reach our authentication server. Please check your network connection and try again.");
    [self.messageView updateConstraints];
    self.messageView.hidden = NO;
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, self.messageTitleLabel);
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    A0LogVerbose(@"Loaded page with navigation: %@", navigation);
    [self hideProgressIndicator];
    self.messageView.hidden = YES;
    self.title = webView.title;
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, self.title);
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    A0LogVerbose(@"Started to load page with navigation: %@", navigation);
    NSString *annoucement = [NSString stringWithFormat:@"Loading page at %@", self.webview.URL.host];
    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, A0LocalizedString(annoucement));

    [self showProgressIndicator];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    A0LogDebug(@"Failed navigation %@ with error %@", navigation, error);
    if (error.code == NSURLErrorTimedOut || error.code == NSURLErrorCannotConnectToHost) {
        [self networkTimedOutForNavigation:navigation];
    }
    [self hideProgressIndicator];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    A0LogVerbose(@"Failed provisional navigation %@ with error %@", navigation, error);
    if (error.code == NSURLErrorTimedOut || error.code == NSURLErrorCannotConnectToHost || error.code == NSURLErrorNotConnectedToInternet) {
        [self networkTimedOutForNavigation:navigation];
    }
    [self hideProgressIndicator];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    A0LogVerbose(@"Loading URL %@", navigationAction.request.URL);
    NSURLRequest *request = navigationAction.request;
    NSURL *url = request.URL;
    BOOL isCallback = [self.authentication validateURL:url];
    if (!isCallback) {
        decisionHandler(WKNavigationActionPolicyAllow);
        return;
    }
    NSError *error;

    A0IdPAuthenticationBlock success = self.onAuthentication;
    void(^fetchProfile)(A0Token *) = ^(A0Token *token) {
        [self.client fetchUserProfileWithIdToken:token.idToken success:^(A0UserProfile *profile) {
            decisionHandler(WKNavigationActionPolicyCancel);
            [self dismissWithCompletion:^{
                if (success) {
                    success(profile, token);
                }
            }];
        } failure:^(NSError *error) {
            [self handleError:error decisionHandler:decisionHandler];
        }];
    };
    [self showProgressIndicator];
    if (self.pkce) {
        NSString *code = [self.authentication authorizationCodeFromURL:url error:&error];
        if (code) {
            NSMutableDictionary *params = [[self.pkce tokenParametersWithAuthorizationCode:code] mutableCopy];
            [params addEntriesFromDictionary:@{
                                               @"redirect_uri": self.authentication.callbackURL.absoluteString,
                                               }];
            [self.client requestTokenWithParameters:params
                                           callback:^(NSError * _Nonnull error, A0Token * _Nonnull token) {
                                               if (error) {
                                                   [self handleError:error decisionHandler:decisionHandler];
                                                   return;
                                               }
                                               fetchProfile(token);
                                           }];
        } else {
            [self handleError:error decisionHandler:decisionHandler];
        }
    } else {
        A0Token *token = [self.authentication tokenFromURL:url error:&error];
        if (error) {
            [self handleError:error decisionHandler:decisionHandler];
            return;
        }
        fetchProfile(token);
    }
}

#pragma mark - Utility methods

- (void)cleanCallbacks {
    self.onAuthentication = nil;
    self.onFailure = nil;
}

- (void)dismissWithCompletion:(void(^)())completion {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        completion();
        [self cleanCallbacks];
    }];
}

- (void)handleError:(NSError *)error decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    decisionHandler(WKNavigationActionPolicyCancel);
    [self dismissWithCompletion:^{
        if (self.onFailure) {
            self.onFailure(error);
        }
    }];
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
