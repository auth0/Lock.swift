//
//  A0WebViewController.m
//  Pods
//
//  Created by Hernan Zalazar on 9/24/14.
//
//

#import "A0WebViewController.h"
#import "A0Errors.h"
#import "A0Application.h"
#import "A0Strategy.h"
#import "NSDictionary+A0QueryParameters.h"
#import "A0APIClient.h"
#import "A0Token.h"

#import <libextobjc/EXTScope.h>

#define kCallbackURLString @"a0%@://%@.auth.com/authorize"

@interface A0WebViewController () <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webview;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;
@property (strong, nonatomic) A0Strategy *strategy;
@property (strong, nonatomic) NSURL *authorizeURL;
@property (strong, nonatomic) NSURL *redirectURL;

- (IBAction)cancel:(id)sender;

@end

@implementation A0WebViewController

- (instancetype)initWithApplication:(A0Application *)application strategy:(A0Strategy *)strategy {
    self = [super init];
    if (self) {
        NSURLComponents *components = [[NSURLComponents alloc] initWithURL:application.authorizeURL resolvingAgainstBaseURL:NO];
        NSString *connectionName = strategy.connection[@"name"];
        NSString *redirectURI = [NSString stringWithFormat:kCallbackURLString, application.identifier, connectionName].lowercaseString;
        NSDictionary *parameters = @{
                                     @"scope": [[A0APIClient sharedClient] defaultScopeValue],
                                     @"response_type": @"token",
                                     @"connection": connectionName,
                                     @"client_id": application.identifier,
                                     @"redirect_uri": redirectURI,
                                     };
        if ([[[A0APIClient sharedClient] defaultScopes] containsObject:A0APIClientScopeOfflineAccess]) {
            NSMutableDictionary *dict = [parameters mutableCopy];
            dict[@"device"] = [[UIDevice currentDevice] name];
            parameters = dict;
        }
        components.query = parameters.queryString;
        _strategy = strategy;
        _authorizeURL = components.URL;
        _redirectURL = [NSURL URLWithString:redirectURI];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSURLRequest *request = [NSURLRequest requestWithURL:self.authorizeURL];
    [self.webview loadRequest:request];
}

- (void)cancel:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    if (self.onFailure) {
        self.onFailure([A0Errors auth0CancelledForStrategy:self.strategy.name]);
    }
    self.onFailure = nil;
    self.onAuthentication = nil;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    Auth0LogVerbose(@"About to load URL %@", request);
    BOOL shouldStart = YES;
    if ([request.URL.scheme isEqualToString:self.redirectURL.scheme] && [request.URL.host isEqualToString:self.redirectURL.host]) {
        shouldStart = NO;
        NSURL *url = request.URL;
        NSString *queryString = url.query ?: url.fragment;
        NSDictionary *params = [NSDictionary fromQueryString:queryString];
        Auth0LogDebug(@"Received params %@ from URL %@", params, url);
        NSString *errorMessage = params[@"error"];
        if (errorMessage) {
            NSError *error = [errorMessage isEqualToString:@"access_denied"] ? [A0Errors auth0NotAuthorizedForStrategy:self.strategy.name] : [A0Errors auth0InvalidConfigurationForStrategy:self.strategy.name];
            if (self.onFailure) {
                self.onFailure(error);
            }
        } else {
            NSString *accessToken = params[@"access_token"];
            NSString *idToken = params[@"id_token"];
            NSString *tokenType = params[@"token_type"];
            NSString *refreshToken = params[@"refresh_token"];
            if (idToken) {
                A0Token *token = [[A0Token alloc] initWithAccessToken:accessToken idToken:idToken tokenType:tokenType refreshToken:refreshToken];
                void(^success)(A0UserProfile *, A0Token *) = self.onAuthentication;
                @weakify(self);
                [[A0APIClient sharedClient] fetchUserProfileWithIdToken:idToken success:^(A0UserProfile *profile) {
                    @strongify(self);
                    self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
                    if (success) {
                        success(profile, token);
                    }
                } failure:self.onFailure];
            } else {
                Auth0LogError(@"Failed to obtain id_token from URL %@", url);
                if (self.onFailure) {
                    self.onFailure([A0Errors auth0NotAuthorizedForStrategy:self.strategy.name]);
                }
            }
        }
        self.onAuthentication = nil;
        self.onFailure = nil;
        [self.activityView stopAnimating];
    }
    if (shouldStart) {
        [self.activityView startAnimating];
        self.activityView.hidden = NO;
    }
    return shouldStart;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    Auth0LogVerbose(@"Loaded URL %@", webView.request);
    [self.activityView stopAnimating];
}

@end
