# Auth0.iOS

[![CI Status](http://img.shields.io/travis/auth0/Auth0.iOS.svg?style=flat)](https://travis-ci.org/auth0/Auth0.iOS)
[![Version](https://img.shields.io/cocoapods/v/Auth0.iOS.svg?style=flat)](http://cocoadocs.org/docsets/Auth0.iOS)
[![License](https://img.shields.io/cocoapods/l/Auth0.iOS.svg?style=flat)](http://cocoadocs.org/docsets/Auth0.iOS)
[![Platform](https://img.shields.io/cocoapods/p/Auth0.iOS.svg?style=flat)](http://cocoadocs.org/docsets/Auth0.iOS)

[Auth0](https://auth0.com) is an authentication broker that supports social identity providers as well as enterprise identity providers such as Active Directory, LDAP, Google Apps and Salesforce.

## Key features

* **Integrates** your iOS app with **Auth0**
* Provides a **beautiful native UI** to log your users in
* Provides support for **Social Providers** (Facebook, Twitter, etc.), **Enterprise Providers** (AD, LDAP, etc.) and **Username & Password**
* Provides **Tokens and User information management tools** for you. You don't have to worry about saving any information if you don't want to!
* **Tokens lifecycle (Expiration, Refreshing, etc.)** is managed automatically for you.
* Provides the ability to do **SSO** with 2 or more mobile apps similar to Facebook and Messenger apps.

## Install

The Auth0.iOS pod is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:
```ruby
pod "Auth0.iOS", "~> 1.0.0-rc"
```

Then in your project's `Info.plist` file add the following entries:

* _Auth0ClientId_: `YOUR_AUTH0_APP_CLIENT_ID`
* _Auth0Tenant_: `YOUR_AUTH0_TENANT_NAME`

For example:

[![Auth0 plist](https://cloudup.com/cdHr2oMAN7d+)](http://auth0.com)

## Usage

You can use Auth0.iOS with our native widget to handle authentication for you. It fetches your Auth0 app configuration and configures itself accordingly.

To get started, import this file in your `AppDelegate.m` file.

```objc
#import <Auth0.iOS/Auth0.h>
```

And add the following methods:

```objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  A0TwitterAuthenticator *twitter = [A0TwitterAuthenticator newAuthenticationWithKey:@"???" andSecret:@"????"];
  A0FacebookAuthenticator *facebook = [A0FacebookAuthenticator newAuthenticationWithDefaultPermissions];
  [[A0IdentityProviderAuthenticator sharedInstance] registerSocialAuthenticatorProviders:@[twitter, facebook]];
  return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [[A0IdentityProviderAuthenticator sharedInstance] handleURL:url sourceApplication:sourceApplication];
}
```

For more information on how to configure Facebook & Twitter go to [Identity Provider Authentication](#identity-provider-authentication)

Import the following header files in the class where you want to display our native widget:

```objc
#import <Auth0.iOS/Auth0.h>
#import <libextobjc/EXTScope.h>
```

And to present our widget as a modal view controller:

```objc
A0AuthenticationViewController *controller = [[A0AuthenticationViewController alloc] init];
@weakify(self);
controller.onAuthenticationBlock = ^(A0UserProfile *profile, A0Token *token) {
    @strongify(self);
    // Do something with token & profile. e.g.: save them.
    // And dismiss the ViewController
    [self dismissViewControllerAnimated:YES completion:nil];
};
[self presentViewController:controller animated:YES completion:nil];
```

After a successful authentication we recommend storing user's token and profile in `A0UserSessionDataSource` and refresh user's token with `A0Session`. You can instantiate them and keep them in a Global object so you can access them everywhere, for example an object called `MyApplication`.

```objc
#import <Auth0.iOS/Auth0.h>

@interface MyApplication: NSObject

+ (MyApplication *)sharedInstance;

- (A0Session *)session;

@end

@implementation MyApplication

+ (MyApplication *)sharedInstance {
    static MyApplication *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MyApplication alloc] init];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
      _session = [A0Session newDefaultSession];
    }
    return self;
}

@end

```

This example creates a new `A0Session` and initialise itself with a new instance of `A0UserSessionDataSource` so there is no need to create it yourself. You can access the DataSource with the following code:

```objc
[MyApplication sharedInstance].session.dataSource;
```

Then after a successful authentication you can save both the token and user's profile using the DataSource.

```objc
A0AuthenticationViewController *controller = [[A0AuthenticationViewController alloc] init];
@weakify(self);
controller.onAuthenticationBlock = ^(A0UserProfile *profile, A0Token *token) {
    @strongify(self);
    // Here we save A0UserProfile and A0Token
    A0Session *session = [MyApplication sharedInstance].session;
    [session.dataSource storeToken:token andUserProfile:profile];
    // And dismiss the ViewController
    [self dismissViewControllerAnimated:YES completion:nil];
};
[self presentViewController:controller animated:YES completion:nil];
```

With the token stored in the DataSource, `A0Session` allows you to check the expiration of the *id_token* and request a new one using a the *id_token*, if not expired, or using the *refresh_token*. Remember to have `A0ScopeOfflineAccess` as one of the scopes when performing authentication in order to get the user's *refresh_token*, by default Auth0.iOS includes it in the list of scopes.

Here is how you can renew your *id_token*:

```objc
A0Session *session = [MyApplication sharedInstance].session;
[session refreshWithSuccess:^(A0UserProfile *profile, A0Token *token) {
  NSLog(@"Token renewed %@", token);
} failure:^(NSError *error) {
  NSLog(@"Failed to renew token %@", error);
}];
```


### Identity Provider Authentication

Before using authentication from other identity providers, e.g. Twitter or Facebook, you'll need to follow some steps.

First in your `AppDelegate.m`, add the following method:
```objc
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [[A0SocialAuthenticator sharedInstance] handleURL:url sourceApplication:sourceApplication];
}
```
This will allow Auth0.iOS to handle a successful login from Facebook, Twitter and any other Identity Providers. And finally you need to define a new URL Type for Auth0 that has a Custom Scheme with the following format: `a0${AUTH0_CLIENT_ID}`, you can do it in your app's target inside Xcode (Under the _Info_ section) or directly in your application's info plist file. This custom scheme is used by *Auth0.iOS* to handle all authentication that requires the use a web browser (Safari or UIWebView).

By default Auth0.iOS includes Twitter & Facebook integration (and its dependencies) but you can discard what you don't need . If you only want Facebook auth just add this to your Podfile:

```ruby
pod "Auth0.iOS/Core", "~> 1.0"
pod "Auth0.iOS/Facebook"
pod "Auth0.iOS/UI"
```

####Facebook

Auth0.iOS uses Facebook iOS SDK to obtain user's access token so you'll need to configure it using your Facebook App info:

First, add the following entries to the `Info.plist`:
* _FacebookAppId_: `YOUR_FACEBOOK_APP_ID`
* _FacebookDisplayName_: `YOUR_FACEBOOK_DISPLAY_NAME`

Register a custom URL Type with the format `fb<FacebookAppId>`. For more information please check [Facebook Getting Started Guide](https://developers.facebook.com/docs/ios/getting-started).

Here's an example of how the entries should look like:

[![FB plist](https://cloudup.com/cYOWHbPp8K4+)](http://auth0.com)

Finally, you need to register Auth0 Facebook Provider somewhere in your application. You can do that in the `AppDelegate.m` file, for example:

```objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  A0FacebookAuthenticator *facebook = [A0FacebookAuthenticator newAuthenticationWithDefaultPermissions];
  [[A0SocialAuthenticator sharedInstance] registerSocialAuthenticatorProvider:facebook];
}
```

####Twitter

Twitter authentication is done using [Reverse Auth](https://dev.twitter.com/docs/ios/using-reverse-auth) in order to obtain a valid access_token that can be sent to Auth0 Server and validate the user. By default we use iOS Twitter Integration but we support OAuth Web Flow (with Safari) as a fallback mechanism in case a user has no accounts configured in his/her Apple Device.

To support Twitter authentication you need to configure the Twitter authentication provider:

```objc
NSString *twitterApiKey = ... //Remember to obfuscate your api key
NSString *twitterApiSecret = ... //Remember to obfuscate your api secret
A0TwitterAuthenticator *twitter = [A0TwitterAuthenticator newAuthenticationWithKey:twitterApiKey                                                                            andSecret:twitterApiSecret];
[[A0SocialAuthenticator sharedInstance] registerSocialAuthenticatorProvider:twitter];
```

We need your twitter app's key & secret in order to sign the reverse auth request. For more info please read the Twitter documentation related to [Authorizing Requests](https://dev.twitter.com/docs/auth/authorizing-request) and [Reverse Auth](https://dev.twitter.com/docs/ios/using-reverse-auth).

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

####A0AuthenticationViewController#authenticationParameters
```objc
@property (assign, nonatomic) A0AuthParameters *authenticationParameters;
```
List of optional parameters that will be used for every authentication request with Auth0 API. By default it only has  'openid' and 'offline_access' scope values. For more information check out our [Wiki](https://github.com/auth0/Auth0.iOS/wiki/Sending-authentication-parameters)
```objc
controller.authenticationParameters.scopes = @[A0ScopeOfflineAccess, A0ScopeProfile];
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
####A0AuthenticationViewController#useWebView
```objc
@property (assign, nonatomic) BOOL useWebView;
```
When the authentication requires to open a web login, for example Linkedin, it will use an embedded UIWebView instead of Safari if it's `YES`. We recommend using Safari for Authentication since it will always save the User session. This means that if he's already signed in, for example in Linkedin, and he clicks in the Linkedin button, it will just work. Default values is `NO`
```objc
controller.useWebView = YES
```

###A0Session

`A0Session` objective is to handle expiration and refresh of Session information (Tokens) without the need to **manually** call the  [Auth0 Delegation API](https://docs.auth0.com/auth-api#delegated). It delegates storage handling of Token & User's profile to an instance of `A0SessionDataSource`. Auth0.iOS comes with a basic class called `A0SessionDataSource` that stores the **User's token in iOS Keychain** and the **User's profile in `NSUserDefaults`**, but you can write your own `A0SessionDataSource` class and supply it to your `A0Session` instance.

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

###A0UserSessionDataSource

`A0UserSessionDataSource` stores/retrieves user's token information from iOS Keychain and user's profile from NSUserDefaults. It implements `A0SessionDataSource` protocol

####A0UserSessionDataSource#init
```objc
- (instancetype)init;
```
Initialise a default instance with no special configuration.
```objc
[[A0UserSessionDataSource alloc] init];
```

####A0UserSessionDataSource#initWithAccessGroup:
```objc
- (instancetype)initWithAccessGroup:(NSString *)accessGroup;
```
Initialise an instance to allow iOS Keychain sharing using the accessGroup string passed as a paramter.
```objc
[[A0UserSessionDataSource alloc] initWithAccessGroup:@"HH3H3.com.mygroup.app"];
```

###A0SessionDataSource

`A0UserSessionDataSource` stores/retrieves user's token information from iOS Keychain and user's profile from NSUserDefaults.

####A0SessionDataSource#storeToken:andUserProfile
```objc
- (void)storeToken:(A0Token *)token andUserProfile:(A0UserProfile *)userProfile;
```
Stores both the user's profile and token.
```objc
[dataSource storeToken:token andUserProfile:profile];
```

####A0SessionDataSource#storeToken
```objc
- (void)storeToken:(A0Token *)token;
```
Stores the user's token.
```objc
[dataSource storeToken:token];
```

####A0SessionDataSource#storeUserProfile
```objc
- (void)storeUserProfile:(A0UserProfile *)userProfile;
```
Stores the user's profile.
```objc
[dataSource storeUserProfile:profile];
```

####A0SessionDataSource#clearAll
```objc
- (void)clearAll;
```
Removes all information of the session
```objc
[dataSource clearAll];
```

####A0SessionDataSource#currentToken
```objc
- (A0Token *)currentToken;
```
Returns the current token stored or nil.
```objc
[dataSource currentToken];
```

####A0SessionDataSource#currentUserProfile
```objc
- (A0UserProfile *)currentUserProfile;
```
Returns the current user's profile or nil
```objc
[dataSource currentUserProfile];
```

## Logging

Auth0.iOS logs serveral useful debugging information using [CocoaLumberjack](https://github.com/CocoaLumberjack/CocoaLumberjack). By default all log messages are disabled but you can enable them following these steps:

Go to `A0Logging.h` and change the `auth0LogLevel` variable with the Log Level you'll want to see. for example:
```objc
static const int auth0LogLevel = LOG_LEVEL_ALL;
```

And then you'll need to configure CocoaLumberjack (if you haven't done it for your app). You need to do it once so we recommend doing it in your `AppDelegate`:

```objc
#import <CocoaLumberjack/DDASLLogger.h>
#import <CocoaLumberjack/DDTTYLogger.h>
#import <CocoaLumberjack/DDLog.h>

@implementation A0AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    return YES;
}

@end
```
## What is Auth0?

Auth0 helps you to:

* Add authentication with [multiple authentication sources](https://docs.auth0.com/identityproviders), either social like **Google, Facebook, Microsoft Account, LinkedIn, GitHub, Twitter, Box, Salesforce, amont others**, or enterprise identity systems like **Windows Azure AD, Google Apps, Active Directory, ADFS or any SAML Identity Provider**.
* Add authentication through more traditional **[username/password databases](https://docs.auth0.com/mysql-connection-tutorial)**.
* Add support for **[linking different user accounts](https://docs.auth0.com/link-accounts)** with the same user.
* Support for generating signed [Json Web Tokens](https://docs.auth0.com/jwt) to call your APIs and **flow the user identity** securely.
* Analytics of how, when and where users are logging in.
* Pull data from other sources and add it to the user profile, through [JavaScript rules](https://docs.auth0.com/rules).

## Create a free account in Auth0

1. Go to [Auth0](https://auth0.com) and click Sign Up.
2. Use Google, GitHub or Microsoft Account to login.

## Author

Auth0

## License

Auth0.iOS is available under the MIT license. See the LICENSE file for more info.
