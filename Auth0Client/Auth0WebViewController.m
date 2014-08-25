#import "Auth0WebViewController.h"
#import "Auth0Client.h"

@interface Auth0Client (Private)
@end

@implementation Auth0WebViewController

- (id)initWithAuthorizeUrl:(NSURL *)authzUrl returnUrl:(NSString*)returnUrl allowsClose:(BOOL)allowsClose withCompletionHandler:(void (^)(NSString* token, NSString * jwtToken, NSString *refreshToken, NSString *error))block
{
    if ((self = [super initWithNibName:nil bundle:nil]))
    {
        _authzUrl = authzUrl;
        _returnUrl = returnUrl;
		_block = [block copy];
		_allowsClose = allowsClose;
        
        // Feedback
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _spinner.hidesWhenStopped = YES;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_spinner];
        
        // Cancel button
		if (_allowsClose) {
			self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(Cancel:)];
		}
		
		// Title
		self.title = @"Auth0";
	}
    return self;
}

- (void)dealloc
{
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void) Cancel:(id)sender
{
	if (_allowsClose) {
		if (![[self presentedViewController] isBeingDismissed])
		{
			[self dismissViewControllerAnimated:YES completion:nil];
		}
	}
}

#pragma mark - View lifecycle

- (void)loadView
{
    // create our web view
    _webView = [[UIWebView alloc] init];
    _webView.delegate = self;
    _webView.scalesPageToFit = YES;

    self.view = _webView;

    // navigate to the login url
    NSURLRequest *request = [NSURLRequest requestWithURL:_authzUrl];
    [_webView loadRequest:request];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES; //(interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark UIWebViewDelegate

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    // Ignore some errors
    if (error.code == 102 || error.code == -999) return;
    
    NSLog(@"error %@", [error description]);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:[error description]
                                                    delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
    [alert show];
    [_spinner stopAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [_spinner stopAnimating];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *requestURLString = request.URL.absoluteString;
    
    NSLog(@"HTTPMethod: %@\n", request.HTTPMethod);
    NSLog(@"Fields: %@\n", [request.allHTTPHeaderFields description]);
    NSLog(@"URL: %@\n", request.URL.absoluteString);
    
    // Checking if the URL is the redirect_url
    if ([requestURLString rangeOfString:_returnUrl].location == 0)
    {
		NSDictionary* queryString = [self queryStringForUrl:request.URL];
		NSString * accessToken = queryString[@"access_token"];
		NSString * jwtToken = queryString[@"id_token"];
        NSString * error = queryString[@"denied"] ? @"access_denied" : queryString[@"error"];
        NSString * refreshToken = queryString[@"refresh_token"];
		
        if (!error) {
            if (!accessToken) {
                NSLog(@"Error: accessToken missing");
                [self Cancel:nil];
                return NO;
            }
            
            if (!jwtToken) {
                NSLog(@"Error: jwtToken missing");
                [self Cancel:nil];
                return NO;
            }
        }
		
		//Notify caller
		_block(accessToken, jwtToken, refreshToken, error);
        
        return NO;
    }

    [_spinner startAnimating];
    return YES;
}

- (NSDictionary*)queryStringForUrl:(NSURL*)URL
{
    NSString *queryString = [URL query] ?: [URL fragment];
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    NSArray *parameters = [queryString componentsSeparatedByString:@"&"];
    for (NSString *parameter in parameters) {
        NSArray *parts = [parameter componentsSeparatedByString:@"="];
        NSString *key = [[parts objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        if ([parts count] > 1) {
            id value = [[parts objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [result setObject:value forKey:key];
        }
    }
    return result;
}

+ (void)clearCookies
{
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
}
@end
