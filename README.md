# Auth0.iOS

[![CI Status](http://img.shields.io/travis/auth0/Auth0.iOS.svg?style=flat)](https://travis-ci.org/auth0/Auth0.iOS)
[![Version](https://img.shields.io/cocoapods/v/Auth0Client.svg?style=flat)](http://cocoadocs.org/docsets/Auth0Client)
[![License](https://img.shields.io/cocoapods/l/Auth0Client.svg?style=flat)](http://cocoadocs.org/docsets/Auth0Client)
[![Platform](https://img.shields.io/cocoapods/p/Auth0Client.svg?style=flat)](http://cocoadocs.org/docsets/Auth0Client)

[Auth0](https://auth0.com) is an authentication broker that supports social identity providers as well as enterprise identity providers such as Active Directory, LDAP, Google Apps, Salesforce.

## Install

Auth0Client is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:
```ruby
pod "Auth0Client", "~> 1.0"
```

Then in your project's Info plist file add the following entries:

* _Auth0ClientId_: `YOUR_AUTH0_APP_CLIENT_ID`
* _Auth0Tenant_: `YOUR_AUTH0_TENANT_NAME`

For example:

[![Auth0 plist](https://cloudup.com/cdHr2oMAN7d)](http://auth0.com)

## Usage

You can use Auth0.iOS with our native widget to handle authentication for you. It fetches your Auth0 app configuration and configure itself accordingly.

To get started, import these files in your `AppDelegate`

```objc
#import <Auth0Client/A0FacebookAuthentication.h>
#import <Auth0Client/A0TwitterAuthentication.h>
#import <Auth0Client/A0IdentityProviderAuthenticator.h>
#import <Auth0Client/A0AuthCore.h>
```

And add the following methods:

```objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  A0TwitterAuthentication *twitter = [A0TwitterAuthentication newAuthenticationWithKey:@"???" andSecret:@"????" callbackURL:[NSURL URLWithString:@"com.auth0.Auth0Client://twitter"]];
  A0FacebookAuthentication *facebook = [A0FacebookAuthentication newAuthenticationWithDefaultPermissions];
  [[A0IdentityProviderAuthenticator sharedInstance] registerSocialAuthenticatorProviders:@[twitter, facebook]];
  return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [[A0IdentityProviderAuthenticator sharedInstance] handleURL:url sourceApplication:sourceApplication];
}
```

For more information on how to configure Facebook & Twitter go to [Identity Provider Authentication](#identity-provider-authentication)

In the class where you want to present our native widget import these header files :

```objc
#import <Auth0Client/A0AuthenticationViewController.h>
#import <Auth0Client/A0AuthCore.h>
#import <libextobjc/EXTScope.h>
```

And to present or widget as a modal view controller:

```objc
A0AuthenticationViewController *controller = [[A0AuthenticationViewController alloc] init];
@weakify(self);
controller.onAuthenticationBlock = ^(A0UserProfile *profile, A0Token *token) {
    @strongify(self);
    // Do something with token & profile. e.g.: save them.
    [self dismissViewControllerAnimated:YES completion:nil];
};
[self presentViewController:controller animated:YES completion:nil];
```

### Identity Provider Authentication

Before using authentication from other identity providers, e.g. Twitter or Facebook, you'll need to follow some steps.

First in your App's Delegate, add the following method:
```objc
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [[A0SocialAuthenticator sharedInstance] handleURL:url sourceApplication:sourceApplication];
}
```
This will allow Auth0.iOS to handle a successful login from Facebook, Twitter and any other Identity Providers.

By default Auth0.iOS includes Twitter & Facebook integration (and its dependencies) but you can discard what you don't need . If you'll only want Facebook auth just add this to your Podfile:

```ruby
pod "Auth0Client/Core", "~> 1.0"
pod "Auth0Client/Facebook"
pod "Auth0Client/UI"
```

####Facebook

Auth0.iOS uses Facebook iOS SDK to obtain user's access token so you'll need to configure it using your Facebook App info:

First in `Info plist file` add the following entries:
* _FacebookAppId_: `YOUR_FACEBOOK_APP_ID`
* _FacebookDisplayName_: `YOUR_FACEBOOK_DISPLAY_NAME`

Also you've to register a custom URL Type with the format `fb<FacebookAppId>`. For more information please check [Facebook Getting Started Guide](https://developers.facebook.com/docs/ios/getting-started).

Here's an example of how the entries should look like:

[![FB plist](https://cloudup.com/cYOWHbPp8K4)](http://auth0.com)

Finally, you need to register Auth0 Facebook Provider in one place. You can do that in the AppDelegate, for example:

```objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  A0FacebookAuthentication *facebook = [A0FacebookAuthentication newAuthenticationWithDefaultPermissions];
  [[A0SocialAuthenticator sharedInstance] registerSocialAuthenticatorProvider:facebook];
}
```

####Twitter

Twitter authentication is done using [Reverse Auth](https://dev.twitter.com/docs/ios/using-reverse-auth) in order to obtain a valid access_token that can be sent to Auth0 Server and validate the user. By default we use iOS Twitter Integration but we have OAuth Web Flow (with Safari) as a fallback in case the user has no accounts configured in his/her Apple Device.

Before we can authenticate with Twitter, you need to configure Twitter authentication provider:

```objc
NSString *twitterApiKey = ... //Remember to obfuscate your api key
NSString *twitterApiSecret = ... //Remember to obfuscate your api secret
NSURL *callbackURL = ... //URL that the app handles after going to Safari.
A0TwitterAuthentication *twitter = [A0TwitterAuthentication newAuthenticationWithKey:twitterApiKey                                                                            andSecret:twitterApiSecret callbackURL:callbackURL];
[[A0SocialAuthenticator sharedInstance] registerSocialAuthenticatorProvider:twitter];
```

We need your twitter app's key & secret in order to sign the reverse auth request. For more info please read twitter documentation about [Authorizing Requests](https://dev.twitter.com/docs/auth/authorizing-request) and [Reverse Auth](https://dev.twitter.com/docs/ios/using-reverse-auth).
The callback URL is used when authenticating with OAuth Web Flow in order to identify the correct call to `application:openURL:sourceApplication:annotation:` and extract the results of OAuth Web Flow. We recommend using a URL with a custom scheme equal to your app's Bundle Indentifier, e.g. _com.auth0.Example://twitter_

##API

###A0AuthenticationViewController

####A0AuthenticationViewController#init
```objc
- (instancetype)init;
```
Initialise 'A0AuthenticationViewController' using `Auth0ClientId` & `Auth0Tenant` from info plist file.
```objc
A0AuthenticationViewController *controller = [[A0AuthenticationViewController alloc] init];
```

####A0AuthenticationViewController#onAuthenticationBlock
```objc
@property (copy, nonatomic) void(^onAuthenticationBlock)(A0UserProfile *profile, A0Token *token);
```
Block that is called on successful authentication. It has two parameters profile and token, which will be non-nil unless login is disabled after signup.
```objc
controller.onAuthenticationBlock = ^(A0UserProfile *profile, A0Token *token) {
  NSLog(@"Auth successful: profile %@, token %@", profile, token);
};
```

####A0AuthenticationViewController#onUserDismissBlock
```objc
@property (copy, nonatomic) void(^onUserDismissBlock)();
```
Block that is called on when the user dismisses the Login screen. Only when `closable` property is `YES`.
```objc
controller.onUserDismissBlock = ^() {
  NSLog(@"User dismissed login screen.");
};
```

####A0AuthenticationViewController#usesEmail
```objc
@property (assign, nonatomic) BOOL usesEmail;
```
Enable the username to be treated as an email (and validated as one too) in all Auth0 screens. Default is `YES`
```objc
controller.usesEmail = NO;
```

####A0AuthenticationViewController#closable
```objc
@property (assign, nonatomic) BOOL closable;
```
Allows the `A0AuthenticationViewController` to be dismissed by adding a button. Default is `NO`
```objc
controller.closable = YES;
```

####A0AuthenticationViewController#loginAfterSignup
```objc
@property (assign, nonatomic) BOOL loginAfterSignUp;
```
After a successful Signup, `A0AuthenticationViewController` will attempt to login the user if this property is `YES` otherwise will call `onAuthenticationBlock` with both parameters nil. Default value is `YES`
```objc
controller.loginAfterSignup = NO;
```

####A0AuthenticationViewController#defaultScopes
```objc
@property (assign, nonatomic) NSArray *defaultScopes;
```
List of scopes used when authenticating against Auth0 REST API. By default the values are: `scope` & `offline_access` but you can use `A0APIClientScopeOpenId`, `A0APIClientScopeOfflineAccess` constants instead.
```objc
controller.defaultScopes = @[A0APIClientScopeOpenId, A0APIClientScopeOfflineAccess];
```

###A0AuthenticationViewController#signupDisclaimerView
```objc
@property (strong, nonatomic) UIView *signUpDisclaimerView;
```
View that will appear in the bottom of Signup screen. It should be used to show Terms & Conditions of your app.
```objc
UIView *view = //..
controller.signupDisclaimerView = view;
```

###A0Session

`A0Session` objective is to handle expiration and refresh of Session information without the need to call [Auth0 Delegation API](https://docs.auth0.com/auth-api#delegated) and delegates storage handling of Token & User's profile to an instance of `A0SessionDataSource`. Auth0.iOS comes with a basic class called `A0SessionDataSource` that stores the User's token in iOS Keychain and the User's profile in `NSUserDefaults`, but you can write your own `A0SessionDataSource` class and supply it to your `A0Session` instance.

####A0Session#newDefaultSession
```objc
+ (instancetype)newDefaultSession;
```
Returns a new `A0Session` instance with the default DataSource `A0UserSessionDataSource`.
```objc
A0Session *session = [A0Session newDefaultSession];
```

####A0Session#newSessionWithDataSource:
```objc
+ (instancetype)newSessionWithDataSource:(id<A0SessionDataSource>)dataSource;
```
Returns a new `A0Session` instance that uses dataSource parameter.
```objc
A0Session *session = [A0Session newDefaultSessionWithDataSource:dataSource];
```

####A0Session#initWithSessionDataSource:
```objc
- (instancetype)initWithSessionDataSource:(id<A0SessionDataSource>)sessionDataSource;
```
Initialise the session with info from the `dataSource`. You can implement your own or use Auth0's `A0UserSessionDataSource`.
```objc
id<A0SessionDataSource> dataSource = //...
A0Session *session = [[A0Session alloc] initWithSessionDataSource:dataSource];
```

####A0Session#isExpired
```objc
- (BOOL)isExpired;
```
Returns `YES` if the id_token is expired
```objc
BOOL expired = session.isExpired;
```

####A0Session#refreshWithSuccess:failure
```objc
- (void)refreshWithSuccess:(A0RefreshBlock)success failure:(A0RefreshFailureBlock)failure;
```
Checks whether the id_token is expired.
If it is, it will request a new one using the stored refresh_token. Otherwise it will request a new id_token using the old id_token. On success, it will update the stored id_token.
```objc
[session refreshWithSuccess:^(A0UserProfile *profile, A0Token *token) {
  NSLog(@"Token renewed %@", token);
} failure:^(NSError *error) {
  NSLog(@"Failed to renew token %@", error);
}];
```

####A0Session#refreshIfExpiredWithSuccess:failure
```objc
- (void)refreshIfExpiredWithSuccess:(A0RefreshBlock)success failure:(A0RefreshFailureBlock)failure;
```
It will only request a new id_token using the stored refresh_token if it's expired. On successful request of a new id_token it will update it in the DataSource. If the token is not expired, it will be returned as a paramater in the success block.
```objc
[session refreshIfExpiredWithSuccess:^(A0UserProfile *profile, A0Token *token) {
  NSLog(@"Token %@", token);
} failure:^(NSError *error) {
  NSLog(@"Failed to refresh token %@", error);
}];
```

####A0Session#renewUserProfileWithSuccess:failure
```objc
- (void)renewUserProfileWithSuccess:(A0RefreshBlock)success failure:(A0RefreshFailureBlock)failure;
```
Tries to refresh User's profile using the stored id_token. On success returns both the stored token and updated profile, and updates the DataSource with the new one.
```objc
[session renewUserProfileWithSuccess:^(A0UserProfile *profile, A0Token *token) {
  NSLog(@"Profile updated %@", token);
} failure:^(NSError *error) {
  NSLog(@"Failed to update profile %@", error);
}];
```

####A0Session#clear
```objc
- (void)clear;
```
Removes all session information & clears the DataSource calling it's `clearAll` method.
```objc
[session clear];
```

####A0Session#token
```objc
@property (readonly, nonatomic) A0Token *token;
```
Returns the current token from the DataSource or nil.
```objc
A0Token *token = session.token;
```

####A0Session#profile
```objc
@property (readonly, nonatomic) A0UserProfile *profile;
```
Returns the current profile from the DataSource or nil.
```objc
A0UserProfile *profile = session.profile;
```

## Author

Auth0

## License

Auth0Client is available under the MIT license. See the LICENSE file for more info.
