#import "ViewController.h"
#import "Auth0Client.h"

@interface ViewController ()
@end

NSString * const domain = @"YOUR_AUTH0_DOMAIN"; // e.g.: contoso.auth0.com
NSString * const clientId = @"YOUR_CLIENT_ID";
NSString * const connection = @"google-oauth2"; // change to "facebook", "paypal", "linkedin", etc.
NSString * const userPassConnection = @"Username-Password-Authentication"; // only Database and ADLDAP connections

Auth0Client *client;

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    client = [Auth0Client auth0Client:domain clientId:clientId offlineAccess:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginWithConnection:(id)sender {
    [client loginAsync:self connection:connection withCompletionHandler:^(NSMutableDictionary* error) {
        if (error) {
            NSLog(@"Error authenticating: %@", [error objectForKey:@"error"]);
            self.profileLabel.text = @"Error (see logs)";
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
    [client loginAsync:self withCompletionHandler:^(NSMutableDictionary* error) {
        if (error) {
            NSLog(@"Error authenticating: %@", [error objectForKey:@"error"]);
            self.profileLabel.text = @"Error (see logs)";
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

- (IBAction)loginWithUsernamePassword:(id)sender {
    [client loginAsync:self connection:userPassConnection username:self.usernameText.text password:self.passwordText.text withCompletionHandler:^(NSMutableDictionary* error) {
        if (error) {
            NSLog(@"Error authenticating: %@ - %@", [error objectForKey:@"error"], [error objectForKey:@"error_description"]);
            self.profileLabel.text = @"Error (see logs)";
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
