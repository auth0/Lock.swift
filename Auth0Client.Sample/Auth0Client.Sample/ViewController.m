#import "ViewController.h"
#import "Auth0Client.h"

@interface ViewController ()
@end

NSString * const tenant = @"YOUR_TENANT";
NSString * const clientId = @"YOUR_CLIENT_ID";
NSString * const clientSecret = @"YOUR_CLIENT_SECRET";
NSString * const connection = @"google-oauth2"; // change to "facebook", "paypal", "linkedin", etc.

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginWithConnection:(id)sender {
    Auth0Client *client = [Auth0Client auth0Client:tenant
                                       clientId:clientId
                                       clientSecret:clientSecret]; // scope parameter is optional, e.g.: scope:@"openid%20profile"
    
    [client loginAsync:self connection:connection withCompletionHandler:^(BOOL authenticated) {
        if (!authenticated) {
            NSLog(@"Error authenticating");
        }
        else {
            // * Use client.auth0User to do wonderful things, e.g.:
            // - get user email => [client.auth0User.Profile objectForKey:@"email"]
            // - get facebook/google/twitter/etc access token => [[[client.auth0User.Profile objectForKey:@"identities"] objectAtIndex:0] objectForKey:@"access_token"]
            // - get Windows Azure AD groups => [client.auth0User.Profile objectForKey:@"groups"]
            // - etc.
            NSString *userName = [client.auth0User.Profile objectForKey:@"name"];
            self.profileLabel.text = [NSString stringWithFormat:@"Hi %@!", userName];
        }
    }];
}

- (IBAction)loginWithWidget:(id)sender {
    Auth0Client *client = [Auth0Client auth0Client:tenant
                                       clientId:clientId
                                       clientSecret:clientSecret]; // scope parameter is optional, e.g.: scope:@"openid%20profile"
    
    [client loginAsync:self withCompletionHandler:^(BOOL authenticated) {
        if (!authenticated) {
            NSLog(@"Error authenticating");
        }
        else {
            // * Use client.auth0User to do wonderful things, e.g.:
            // - get user email => [client.auth0User.Profile objectForKey:@"email"]
            // - get facebook/google/twitter/etc access token => [[[client.auth0User.Profile objectForKey:@"identities"] objectAtIndex:0] objectForKey:@"access_token"]
            // - get Windows Azure AD groups => [client.auth0User.Profile objectForKey:@"groups"]
            // - etc.
            NSString *userName = [client.auth0User.Profile objectForKey:@"name"];
            self.profileLabel.text = [NSString stringWithFormat:@"Hi %@!", userName];
        }
    }];
}

@end
