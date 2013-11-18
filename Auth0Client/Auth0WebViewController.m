#import "Auth0WebViewController.h"
#import "Auth0Client.h"

@interface Auth0Client (Private)
@end

@implementation Auth0WebViewController

- (id)initWithAuthorizeUrl:(NSURL *)authzUrl returnUrl:(NSString*)returnUrl allowsClose:(BOOL)allowsClose withCompletionHandler:(void (^)(NSString* token, NSString * jwtToken))block
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
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonSystemItemCancel target:self action:@selector(Cancel:)];
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
    if (![[self presentedViewController] isBeingDismissed])
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - View lifecycle

- (void)loadView
{
    self.title = @"Auth0";

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
    //Ignore frame load error
    if( error.code == 102 ) return;
    
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
        //Quick and Dirty parsing of the return URL withe access_token in the URL fragment
        NSArray * fragments = [requestURLString componentsSeparatedByString:@"#"];
        NSString * url_access_token = [fragments lastObject];
        NSArray * url_token = [url_access_token componentsSeparatedByString:@"&"];
        NSString * accessToken = [url_token objectAtIndex:0];
        NSString * c_jwtToken = [url_token objectAtIndex:1];
        
        NSArray * jwt_fragments = [c_jwtToken componentsSeparatedByString:@"="];
        NSString * jwtToken = [jwt_fragments objectAtIndex:1];
        
        //Notify caller
        _block(accessToken, jwtToken);
        
        return NO;
    }

    [_spinner startAnimating];
    return YES;
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
