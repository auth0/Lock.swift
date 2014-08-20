#import "A0ViewController.h"

#import <Auth0Client/Auth0Client.h>
#import <UICKeyChainStore/UICKeyChainStore.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface A0ViewController ()

@property (strong, nonatomic) Auth0Client *client;
@property (strong, nonatomic) UICKeyChainStore *store;

@end

@implementation A0ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.store = [UICKeyChainStore keyChainStoreWithService:@"Auth0" accessGroup:kAuth0KeychainAccessGroup];
    self.client = [Auth0Client auth0Client:kAuth0Domain clientId:kAuth0ClientId offlineAccess:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLoginScreen) name:kAuth0NoRefreshTokenNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showProfileInfo) name:kAuth0RefreshTokenNotificationName object:nil];
    self.appLabel.text = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)showLoginScreen {
    self.welcomeLabel.text = @" ";
    if (!self.presentedViewController) {
        [self.client loginAsync:self withCompletionHandler:^(NSMutableDictionary *error) {
            NSLog(@"Logged in with result %@", self.client.auth0User);
            [self.store setString:self.client.auth0User.refreshToken forKey:@"refresh_token"];
            [self.store synchronize];
            [[NSNotificationCenter defaultCenter] postNotificationName:kAuth0RefreshTokenNotificationName object:self];
        }];
    }
}

- (void)showProfileInfo {
    [SVProgressHUD show];
    NSDictionary *options = @{
                              @"refresh_token": [self.store stringForKey:@"refresh_token"],
                              @"scope": @"openid",
                              @"api_type": @"app"
                              };
    [self.client getDelegationToken:kAuth0ClientId options:[options mutableCopy] withCompletionHandler:^(NSMutableDictionary *delegationResult) {
        NSString *idToken = delegationResult[@"id_token"];
        [self.client getUserInfoWithIdToken:idToken withCompletionHandler:^(NSMutableDictionary *profile) {
            NSLog(@"User info %@", profile);
            self.welcomeLabel.text = [NSString stringWithFormat:@"Welcome %@", profile[@"email"]];
            [SVProgressHUD dismiss];
        }];
    }];
}

- (void)logout:(id)sender {
    [self.store removeItemForKey:@"refresh_token"];
    [self.store synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:kAuth0NoRefreshTokenNotificationName object:self];
}
@end
