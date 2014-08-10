//
//  A0TwitterAuthentication.m
//  Pods
//
//  Created by Hernan Zalazar on 8/9/14.
//
//

#import "A0TwitterAuthentication.h"

#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>
#import <BDBOAuth1Manager/BDBOAuth1RequestOperationManager.h>
#import <TWReverseAuth/TWAPIManager.h>
#import <OAuthCore/OAuthCore.h>
#import <OAuthCore/OAuth+Additions.h>

static NSString * const A0TwitterAuthenticationName = @"twitter";

@interface A0TwitterAuthentication ()

@property (strong, nonatomic) BDBOAuth1RequestOperationManager *manager;
@property (strong, nonatomic) NSURL *callbackURL;


@end

@implementation A0TwitterAuthentication

+ (A0TwitterAuthentication *)newAuthenticationWithKey:(NSString *)key andSecret:(NSString *)secret callbackURL:(NSURL *)callbackURL {
    return [[A0TwitterAuthentication alloc] initWithKey:key andSecret:secret callbackURL:callbackURL];
}

- (instancetype)initWithKey:(NSString *)key andSecret:(NSString *)secret callbackURL:(NSURL *)callbackURL {
    self = [super init];
    if (self) {
        _manager = [[BDBOAuth1RequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"https://api.twitter.com/"]
                                                                 consumerKey:key
                                                              consumerSecret:secret];
        [_manager deauthorize];
        [TWAPIManager registerTwitterAppKey:key andAppSecret:secret];
        _callbackURL = callbackURL;
    }
    return self;
}

#pragma mark - A0SocialProviderAuth

- (NSString *)identifier {
    return A0TwitterAuthenticationName;
}

- (BOOL)handleURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication {
    BOOL handled = NO;
    if ([url.scheme.lowercaseString isEqualToString:self.callbackURL.scheme.lowercaseString] && [url.host isEqualToString:self.callbackURL.host]) {
        handled = YES;
        NSLog(@"Received URL callback %@", url);
        NSDictionary *parameters = [NSURL ab_parseURLQueryString:url.query];
        if (parameters[@"oauth_token"] && parameters[@"oauth_verifier"]) {
            [self.manager fetchAccessTokenWithPath:@"/oauth/access_token" method:@"POST" requestToken:[BDBOAuthToken tokenWithQueryString:url.query] success:^(BDBOAuthToken *accessToken) {
                NSLog(@"Obtained access to account %@", accessToken.userInfo);
                [self reverseAuthWithNewAccountWithInfo:accessToken];
            } failure:^(NSError *error) {
                NSLog(@"Failed to get authorization from user %@", error);
            }];
        }
    }
    return handled;
}

- (void)authenticateWithSuccess:(void(^)(A0SocialCredentials *socialCredentials))success failure:(void(^)(NSError *))failure {
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];

    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
            NSLog(@"GRANTED %@", @(granted));
            if (granted) {
                ACAccount *account = [[accountStore accountsWithAccountType:accountType] firstObject];
                [self reverseAuthForAccount:account];
            }
        }];
    } else {
        NSLog(@"NEW LOGIN");
        [self.manager deauthorize];
        [self.manager fetchRequestTokenWithPath:@"/oauth/request_token" method:@"POST" callbackURL:self.callbackURL scope:nil success:^(BDBOAuthToken *requestToken) {
            NSLog(@"REQUEST OBTAINED %@", requestToken);
            NSString *authURL = [NSString stringWithFormat:@"https://api.twitter.com/oauth/authorize?oauth_token=%@", requestToken.token];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:authURL]];
        } failure:^(NSError *error) {
            NSLog(@"FAILED TO OBTAIN REQUEST %@", error);
        }];
    }
}

#pragma mark - Twitter Reverse Auth
- (void)reverseAuthWithNewAccountWithInfo:(BDBOAuthToken *)info {
    ACAccountStore * accountStore  =  [[ACAccountStore alloc] init];
    ACAccountType  * accountType   = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];

    ACAccountCredential * credential    = [[ACAccountCredential alloc]
                                           initWithOAuthToken:info.token tokenSecret:info.secret];
    ACAccount * account = [[ACAccount alloc]
                           initWithAccountType:accountType];
    account.accountType = accountType;
    account.credential = credential;
    account.username = [NSString stringWithFormat:@"@%@", info.userInfo[@"screen_name"]];
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        if (granted) {
            ACAccountStore *accountStore  =  [[ACAccountStore alloc] init];
            [accountStore saveAccount:account withCompletionHandler:^(BOOL success, NSError *error) {
                NSLog(@"Account saved: %@ error %@", @(success), error);
                if (success) {
                    ACAccountStore *accountStore  =  [[ACAccountStore alloc] init];
                    ACAccountType  * accountType   = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
                    ACAccount *account = [[accountStore accountsWithAccountType:accountType] firstObject];
                    [self reverseAuthForAccount:account];
                }
            }];
        }
        else {
            NSLog(@"Failed to save account");
        }
    }];
}

- (void)reverseAuthForAccount:(ACAccount *)account {
    ACAccountStore * accountStore  =  [[ACAccountStore alloc] init];
    ACAccountType  * accountType   = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    account.accountType = accountType;
    [TWAPIManager performReverseAuthForAccount:account withHandler:^(NSData *responseData, NSError *error) {

        if(responseData == nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"FAILED with no answer");
                return;
            });
        }

        NSString *responseStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];

        NSDictionary * response = [NSURL ab_parseURLQueryString:responseStr];

        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Should be success %@", response);
        });

    }];
}

@end
