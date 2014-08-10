//
//  A0TwitterAuthentication.m
//  Pods
//
//  Created by Hernan Zalazar on 8/9/14.
//
//

#import "A0TwitterAuthentication.h"
#import "A0Errors.h"
#import "A0Strategy.h"

#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>
#import <BDBOAuth1Manager/BDBOAuth1RequestOperationManager.h>
#import <TWReverseAuth/TWAPIManager.h>
#import <OAuthCore/OAuth+Additions.h>
#import <libextobjc/EXTScope.h>

@interface A0TwitterAuthentication ()

@property (strong, nonatomic) BDBOAuth1RequestOperationManager *manager;
@property (strong, nonatomic) NSURL *callbackURL;
@property (strong, nonatomic) ACAccountStore *accountStore;
@property (strong, nonatomic) ACAccountType *accountType;

@property (copy, nonatomic) void(^successBlock)(A0SocialCredentials *socialCredentials);
@property (copy, nonatomic) void(^failureBlock)(NSError *);

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
        @weakify(self);
        if (parameters[@"oauth_token"] && parameters[@"oauth_verifier"]) {
            [self.manager fetchAccessTokenWithPath:@"/oauth/access_token" method:@"POST" requestToken:[BDBOAuthToken tokenWithQueryString:url.query] success:^(BDBOAuthToken *accessToken) {
                @strongify(self);
                NSLog(@"Obtained access to account %@", accessToken.userInfo);
                [self reverseAuthWithNewAccountWithInfo:accessToken];
            } failure:^(NSError *error) {
                NSLog(@"Failed to get authorization from user %@", error);
                [self executeFailureWithError:error];
            }];
        } else {
            [self executeFailureWithError:[A0Errors twitterCancelled]];
        }
    }
    return handled;
}

- (void)authenticateWithSuccess:(void(^)(A0SocialCredentials *socialCredentials))success failure:(void(^)(NSError *))failure {
    self.successBlock = success;
    self.failureBlock = failure;
    self.accountStore = [[ACAccountStore alloc] init];
    self.accountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];

    @weakify(self);
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        [self.accountStore requestAccessToAccountsWithType:self.accountType options:nil completion:^(BOOL granted, NSError *error) {
            @strongify(self);
            NSLog(@"GRANTED %@", @(granted));
            if (granted && !error) {
                ACAccount *account = [[self.accountStore accountsWithAccountType:self.accountType] firstObject];
                [self reverseAuthForAccount:account];
            } else {
                [self executeFailureWithError:[A0Errors twitterAppNoAuthorized]];
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
            [self executeFailureWithError:error];
        }];
    }
}

#pragma mark - Twitter Reverse Auth
- (void)reverseAuthWithNewAccountWithInfo:(BDBOAuthToken *)info {
    ACAccountCredential * credential = [[ACAccountCredential alloc] initWithOAuthToken:info.token tokenSecret:info.secret];
    ACAccount * account = [[ACAccount alloc] initWithAccountType:self.accountType];
    account.accountType = self.accountType;
    account.credential = credential;
    account.username = [NSString stringWithFormat:@"@%@", info.userInfo[@"screen_name"]];

    @weakify(self);
    [self.accountStore requestAccessToAccountsWithType:self.accountType options:nil completion:^(BOOL granted, NSError *error) {
        if (granted) {
            [self.accountStore saveAccount:account withCompletionHandler:^(BOOL success, NSError *error) {
                @strongify(self);
                NSLog(@"Account saved: %@ error %@", @(success), error);
                if (success && !error) {
                    ACAccount *account = [[self.accountStore accountsWithAccountType:self.accountType] firstObject];
                    [self reverseAuthForAccount:account];
                } else {
                    [self executeFailureWithError:error];
                }
            }];
        }
        else {
            NSLog(@"Failed to save account");
            [self executeFailureWithError:[A0Errors twitterAppNoAuthorized]];
        }
    }];
}

- (void)reverseAuthForAccount:(ACAccount *)account {
    account.accountType = self.accountType;

    @weakify(self);
    [TWAPIManager performReverseAuthForAccount:account withHandler:^(NSData *responseData, NSError *error) {

        @strongify(self);
        if (!error && responseData) {
            NSString *responseStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            NSDictionary *response = [NSURL ab_parseURLQueryString:responseStr];
            NSDictionary *extraInfo = @{
                                        A0StrategySocialTokenParameter: response[@"oauth_token"],
                                        A0StrategySocialTokenSecretParameter: response[@"oauth_token_secret"],
                                        A0StrategySocialUserIdParameter: response[@"user_id"],
                                        };
            A0SocialCredentials *credentials = [[A0SocialCredentials alloc] initWithAccessToken:response[@"oauth_token"] extraInfo:extraInfo];
            [self executeSuccessWithCredentials:credentials];
            NSLog(@"Should be success %@", response);
        } else {
            [self executeFailureWithError:error];
        }
    }];
}

#pragma mark - Block handling

- (void)executeSuccessWithCredentials:(A0SocialCredentials *)credentials {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.successBlock) {
            self.successBlock(credentials);
        }
        self.successBlock = nil;
        self.failureBlock = nil;
        self.accountStore = nil;
        self.accountType = nil;
    });
}

- (void)executeFailureWithError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.failureBlock) {
            self.failureBlock(error);
        }
        self.successBlock = nil;
        self.failureBlock = nil;
        self.accountStore = nil;
        self.accountType = nil;
    });
}
@end
