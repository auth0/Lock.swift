#import <FacebookSDK/FacebookSDK.h>
#import "Auth0Client.h"
#import "LoginViewController.h"

@interface LoginViewController ()
@property (strong, nonatomic) IBOutlet UILabel *resultLabel;
@end

// **********
// IMPORTANT: these are demo credentials, and the settings will be reset periodically
//            You can obtain your own at https://auth0.com when creating a iOS App in the dashboard
// ***********
NSString * const auth0_domain = @"contoso.auth0.com";
NSString * const auth0_clientId = @"ngQciQNNrziQnFBJYIqb8EIitinDgsfv";

Auth0Client *auth0Client;

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // Auth0 client
    auth0Client = [Auth0Client auth0Client:auth0_domain clientId:auth0_clientId offlineAccess:YES];
    
    // Add Facebook Login button
    FBLoginView *loginView = [[FBLoginView alloc] initWithReadPermissions: @[@"public_profile", @"email", @"user_friends"]];
    loginView.frame = CGRectOffset(loginView.frame, (self.view.center.x - (loginView.frame.size.width / 2)), 50);
    loginView.delegate = self;
    [self.view addSubview:loginView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

// *********************** Facebook Events *********************** //

// This method will be called when the user information has been fetched
- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)fbUser {
    
    self.resultLabel.text = @"Loading...";
    
    // Auth0 authentication with Facebook access_token
    NSString *fb_access_token = [[FBSession.activeSession accessTokenData] accessToken];
    
    [auth0Client loginAsync:self connection:@"facebook"
                                accessToken:fb_access_token
                      withCompletionHandler:^(NSMutableDictionary* error) {
     if (error) {
         NSLog(@"Error authenticating: %@ - %@", [error objectForKey:@"error"], [error objectForKey:@"error_description"]);
     }
     else {
         // * Use client.auth0User to do wonderful things, e.g.:
         // - get user email => [client.auth0User.Profile objectForKey:@"email"]
         // - get user picture => [client.auth0User.Profile objectForKey:@"picture"]
         // - get Windows Azure AD groups => [client.auth0User.Profile objectForKey:@"groups"]
         // - etc.
         NSString *userName = [auth0Client.auth0User.Profile objectForKey:@"name"];
         self.resultLabel.text = [NSString stringWithFormat:@"Hi %@!", userName];
     }
 }];
}

// Logged-out user experience
- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    self.resultLabel.text = @"Not logged in yet.";
}

// Handle possible errors that can occur during login
- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    self.resultLabel.text = [NSString stringWithFormat:@"ERROR: %@!", [FBErrorUtility userMessageForError:error]];
}

// **************************************************************** //

@end
