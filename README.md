# Lock

[![CI Status](http://img.shields.io/travis/auth0/Lock.svg?style=flat)](https://travis-ci.org/auth0/Lock.iOS-OSX)
[![Version](https://img.shields.io/cocoapods/v/Lock.svg?style=flat)](http://cocoadocs.org/docsets/Lock)
[![License](https://img.shields.io/cocoapods/l/Lock.svg?style=flat)](http://cocoadocs.org/docsets/Lock)
[![Platform](https://img.shields.io/cocoapods/p/Lock.svg?style=flat)](http://cocoadocs.org/docsets/Lock)

[Auth0](https://auth0.com) is an authentication broker that supports social identity providers as well as enterprise identity providers such as Active Directory, LDAP, Google Apps and Salesforce.

## Key features

* **Integrates** your iOS app with **Auth0**
* Provides a **beautiful native UI** to log your users in
* Provides support for **Social Providers** (Facebook, Twitter, etc.), **Enterprise Providers** (AD, LDAP, etc.) and **Username & Password**
* Provides the ability to do **SSO** with 2 or more mobile apps similar to Facebook and Messenger apps.

![iOS Gif](https://cloudup.com/cnccuUlFiYI+)

## Requierements

iOS 7+. If you need to use our SDK in an earlier version please use our previous SDK pod `Auth0Client` or check the branch [old-sdk](https://github.com/auth0/Lock.iOS-OSX/tree/old-sdk) of this repo.

## Install

The Lock pod is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod "Lock", "~> 1.4"
```

Then in your project's `Info.plist` file add the following entries:

* _Auth0ClientId_: `YOUR_AUTH0_APP_CLIENT_ID`
* _Auth0Tenant_: `YOUR_AUTH0_TENANT_NAME`

For example:

[![Auth0 plist](https://cloudup.com/cdHr2oMAN7d+)](http://auth0.com)

## Usage

You can use Lock with our native widget to handle authentication for you. It fetches your Auth0 app configuration and configures itself accordingly.

To get started, import this file in your `AppDelegate.m` file.

```objc
#import <Lock/Lock.h>
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
#import <Lock/Lock.h>
#import <libextobjc/EXTScope.h>
```

And to present our widget as a modal view controller:

```objc
A0LockViewController *controller = [[A0LockViewController alloc] init];
@weakify(self);
controller.onAuthenticationBlock = ^(A0UserProfile *profile, A0Token *token) {
    @strongify(self);
    // Do something with token & profile. e.g.: save them.
    // Lock will not save the Token and the profile for you. Please read below
    // And dismiss the ViewController
    [self dismissViewControllerAnimated:YES completion:nil];
};
[self presentViewController:controller animated:YES completion:nil];
```

If you need to save and refresh the user's JWT token, please read the [following guide](https://github.com/auth0/Lock.iOS-OSX/wiki/How-to-save-and-refresh-JWT-token) in our Wiki.

Also you can check our [Swift](https://github.com/auth0/Lock.iOS-OSX/tree/master/Examples/basic-sample-swift) and [Objective-C](https://github.com/auth0/Lock.iOS-OSX/tree/master/Examples/basic-sample) example apps. For more information on how to use **Lock** with Swift please check [this guide](https://github.com/auth0/Lock.iOS-OSX/wiki/Auth0.iOS-&-Swift)

### Identity Provider Authentication

Before using authentication from other identity providers, e.g. Twitter or Facebook, you'll need to follow some steps.

First in your `AppDelegate.m`, add the following method:

```objc
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [[A0SocialAuthenticator sharedInstance] handleURL:url sourceApplication:sourceApplication];
}
```
This will allow Lock to handle a successful login from Facebook, Twitter and any other Identity Providers. And finally you need to define a new URL Type for Auth0 that has a Custom Scheme with the following format: `a0${AUTH0_CLIENT_ID}`, you can do it in your app's target inside Xcode (Under the _Info_ section) or directly in your application's info plist file. This custom scheme is used by *Lock* to handle all authentication that requires the use a web browser (Safari or UIWebView).

By default Lock includes Twitter & Facebook integration (and its dependencies) but you can discard what you don't need . If you only want Facebook auth just add this to your Podfile:

```ruby
pod "Lock/Core"
pod "Lock/Facebook"
pod "Lock/UI"
```

####Facebook

Lock uses Facebook iOS SDK to obtain user's access token so you'll need to configure it using your Facebook App info:

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

## SSO

A very cool thing you can do with Lock is use SSO. Imagine you want to create 2 apps. However, you want that if the user is logged in in app A, he will be already logged in in app B as well. Something similar to what happens with Messenger and Facebook as well as Foursquare and Swarm. 

Read [this guide](https://github.com/auth0/Lock.iOS-OSX/wiki/SSO-on-Mobile-Apps) to learn how to accomplish this with this library.

##API

###A0LockViewController

####A0LockViewController#init
```objc
- (instancetype)init;
```
Initialise 'A0LockViewController' using `Auth0ClientId` & `Auth0Tenant` from info plist file.
```objc
A0LockViewController *controller = [[A0LockViewController alloc] init];
```

####A0LockViewController#onAuthenticationBlock
```objc
@property (copy, nonatomic) void(^onAuthenticationBlock)(A0UserProfile *profile, A0Token *token);
```
Block that is called on successful authentication. It has two parameters profile and token, which will be non-nil unless login is disabled after signup.
```objc
controller.onAuthenticationBlock = ^(A0UserProfile *profile, A0Token *token) {
  NSLog(@"Auth successful: profile %@, token %@", profile, token);
};
```

####A0LockViewController#onUserDismissBlock
```objc
@property (copy, nonatomic) void(^onUserDismissBlock)();
```
Block that is called on when the user dismisses the Login screen. Only when `closable` property is `YES`.
```objc
controller.onUserDismissBlock = ^() {
  NSLog(@"User dismissed login screen.");
};
```

####A0LockViewController#usesEmail
```objc
@property (assign, nonatomic) BOOL usesEmail;
```
Enable the username to be treated as an email (and validated as one too) in all Auth0 screens. Default is `YES`
```objc
controller.usesEmail = NO;
```

####A0LockViewController#closable
```objc
@property (assign, nonatomic) BOOL closable;
```
Allows the `A0LockViewController` to be dismissed by adding a button. Default is `NO`
```objc
controller.closable = YES;
```

####A0LockViewController#loginAfterSignup
```objc
@property (assign, nonatomic) BOOL loginAfterSignUp;
```
After a successful Signup, `A0LockViewController` will attempt to login the user if this property is `YES` otherwise will call `onAuthenticationBlock` with both parameters nil. Default value is `YES`
```objc
controller.loginAfterSignup = NO;
```

####A0LockViewController#authenticationParameters
```objc
@property (assign, nonatomic) A0AuthParameters *authenticationParameters;
```
List of optional parameters that will be used for every authentication request with Auth0 API. By default it only has  'openid' and 'offline_access' scope values. For more information check out our [Wiki](https://github.com/auth0/Lock.iOS-OSX/wiki/Sending-authentication-parameters)
```objc
controller.authenticationParameters.scopes = @[A0ScopeOfflineAccess, A0ScopeProfile];
```

###A0LockViewController#signupDisclaimerView
```objc
@property (strong, nonatomic) UIView *signUpDisclaimerView;
```
View that will appear in the bottom of Signup screen. It should be used to show Terms & Conditions of your app.
```objc
UIView *view = //..
controller.signupDisclaimerView = view;
```
####A0LockViewController#useWebView
```objc
@property (assign, nonatomic) BOOL useWebView;
```
When the authentication requires to open a web login, for example Linkedin, it will use an embedded UIWebView instead of Safari if it's `YES`. We recommend using Safari for Authentication since it will always save the User session. This means that if he's already signed in, for example in Linkedin, and he clicks in the Linkedin button, it will just work. Default values is `NO`
```objc
controller.useWebView = YES
```

## Logging

Lock logs serveral useful debugging information using [CocoaLumberjack](https://github.com/CocoaLumberjack/CocoaLumberjack). By default all log messages are disabled but you can enable them following these steps:

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

Lock is available under the MIT license. See the [LICENSE file](LICENSE) for more info.
