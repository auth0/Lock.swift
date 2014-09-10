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

## Usage

You can use Auth0.iOS with our native widget to handle authentication for you. It fetch's from Auth0 your app's configuration and configure itself accordingly.

First, you'll need to import some header files with the following lines:

```objc
#import <Auth0Client/A0AuthenticationViewController.h>
#import <Auth0Client/A0AuthCore.h>
```
And then to present it as a modal view controller:

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

### Social Authentication

Before using social authentication, e.g. Twitter or Facebook, you'll need to follow some steps.

First in your App's Delegate, add the following method:
```objc
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [[A0SocialAuthenticator sharedInstance] handleURL:url sourceApplication:sourceApplication];
}
```
This will allow Auth0.iOS to handle when we need to request the authentication to a social provider in a different app, e.g. Safari, Facebook, etc.

By default Auth0.iOS includes Twitter & Facebook integration (and its dependencies) but you can discard what you don't need . If you'll only want Facebook auth just add this to your Podfile:

```ruby
pod "Auth0Client/Core", "~> 1.0"
pod "Auth0Client/Facebook"
pod "Auth0Client/UI"
```

####Facebook

Auth0.iOS uses Facebook iOS SDK to obtain user's access token so you'll need to configure it using your Facebook App info:

First in Info plist file add the following entries:
* _FacebookAppId_: `YOUR_FACEBOOK_APP_ID`
* _FacebookDisplayName_: `YOUR_FACEBOOK_DISPLAY_NAME`

Also you've to register a custom URL Type with the format `fb<FacebookAppId>`. For more information please check [Facebook Getting Started Guide](https://developers.facebook.com/docs/ios/getting-started).

Here's an example of how the entries should look like:

__INSERT PIC OF PLIST FILE__

Finally, register Auth0 Facebook Auth Provider, e.g. in your AppDelegate's `application:didFinishLaunchingWithOptions:launchOptions`.

```objc
A0FacebookAuthentication *facebook = [A0FacebookAuthentication newAuthenticationWithDefaultPermissions];
[[A0SocialAuthenticator sharedInstance] registerSocialAuthenticatorProvider:facebook];
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


## Author

Auth0

## License

Auth0Client is available under the MIT license. See the LICENSE file for more info.
