# Lock

[![Build Status](https://travis-ci.org/auth0/Lock.iOS-OSX.svg?branch=master)](https://travis-ci.org/auth0/Lock.iOS-OSX)
[![Version](https://img.shields.io/cocoapods/v/Lock.svg?style=flat)](http://cocoadocs.org/docsets/Lock)
[![License](https://img.shields.io/cocoapods/l/Lock.svg?style=flat)](http://cocoadocs.org/docsets/Lock)
[![Platform](https://img.shields.io/cocoapods/p/Lock.svg?style=flat)](http://cocoadocs.org/docsets/Lock)

[Auth0](https://auth0.com) is an authentication broker that supports social identity providers as well as enterprise identity providers such as Active Directory, LDAP, Google Apps and Salesforce.

Lock makes it easy to integrate SSO in your app. You won't have to worry about:

* Having a professional looking login dialog that displays well on any device.
* Finding the right icons for popular social providers.
* Solving the home realm discovery challenge with enterprise users (i.e.: asking the enterprise user the email, and redirecting to the right enterprise identity provider).
* Implementing a standard sign in protocol (OpenID Connect / OAuth2 Login)

![iOS Gif](https://cloudup.com/cnccuUlFiYI+)

## Key features

* **Integrates** your iOS app with **Auth0**
* Provides a **beautiful native UI** to log your users in.
* Provides support for **Social Providers** (Facebook, Twitter, etc.), **Enterprise Providers** (AD, LDAP, etc.) and **Username & Password**.
* Provides the ability to do **SSO** with 2 or more mobile apps similar to Facebook and Messenger apps.
* [1Password](https://agilebits.com/onepassword) integration using [iOS Extension](https://github.com/AgileBits/onepassword-app-extension).
* Passwordless authentication using **TouchID**, **Email** and **SMS**.

## Requirements

You'll need iOS 7 or later, if you need to use it with an older version please use our previous SDK pod `Auth0Client` or check the branch [old-sdk](https://github.com/auth0/Lock.iOS-OSX/tree/old-sdk) of this repository.

## Install

The Lock is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod "Lock", "~> 1.27"
```

## Before Getting Started

Create a file named `Auth0.plist` and add it to your Application Target, this file should have your Auth0 ClientId and Domain that you can get from [our dashboard](https://app.auth0.com/#/applications)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>ClientId</key>
  <string>{YOUR_CLIENT_ID}</string>
  <key>Domain</key>
  <string>{YOUR_DOMAIN}</string>
</dict>
</plist>
```

Whenever you need to use Lock, you'll have to import either the ObjC header or a Swift module in your source code, the differents ways to do it are detailed next:

### Objective-C
Just import in your source file Lock's header:

```objc
#import <Lock/Lock.h>
```

### Swift & Lock Static Library
In your target's _Objective-C Bridging Header_ just import Lock's header

```objc
#import <Lock/Lock.h>
```

> If you need help creating the Objective-C Bridging Header, please check the [wiki](https://developer.apple.com/library/ios/documentation/swift/conceptual/buildingcocoaapps/MixandMatch.html)

### Swift & Lock Framework
Import Lock module in your swift file:

```swift
import Lock
```

> Make sure you have the flag `use_frameworks!` added in your `Podfile` so that Lock is build as a Framework, otherwise Xcode wont find it.

### Integrate with your Application

Lock needs to be notified for some of your application state changes and some events/notifications your application receives from the OS. You can do all these things in the `AppDelegate`

#### Application finished launching

```objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	[[A0Lock sharedLock] applicationLaunchedWithOptions:launchOptions];
	//Your code
	return YES;
}
```

```swift
func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
	A0Lock.sharedLock().applicationLaunchedWithOptions(launchOptions)
	//Your code
	return true
}
```

#### Application is asked to open URL

```objc
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [[A0Lock sharedLock] handleURL:url sourceApplication:sourceApplication];
}
```
```swift
func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
    return A0Lock.sharedLock().handleURL(url, sourceApplication: sourceApplication)
}
```

#### Application is asked to continue a User Activity

```objc
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler {
    return [[A0Lock sharedLock] continueUserActivity:userActivity restorationHandler:restorationHandler];
}
```

```swift
func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
	return A0Lock.sharedLock().continueUserActivity(userActivity, restorationHandler:restorationHandler)
}
```

## Usage

### Email/Password, Enterprise & Social authentication

`A0LockViewController` will handle Email/Password, Enterprise & Social authentication based on your Application's connections enabled in your Auth0's Dashboard.

First instantiate `A0LockViewController` and register the authentication callback that will receive the authenticated user's credentials. Finally present it as a modal view controller:

```objc
A0Lock *lock = [A0Lock sharedLock];
A0LockViewController *controller = [lock newLockViewController];
controller.onAuthenticationBlock = ^(A0UserProfile *profile, A0Token *token) {
    // Do something with token & profile. e.g.: save them.
    // Lock will not save the Token and the profile for you.
    // And dismiss the UIViewController.
    [self dismissViewControllerAnimated:YES completion:nil];
};
[lock presentLockController:controller fromController:self];
```
```swift
let lock = A0Lock.sharedLock()
let controller = lock.newLockViewController()
controller.onAuthenticationBlock = {(profile, token) in
    // Do something with token & profile. e.g.: save them.
    // Lock will not save the Token and the profile for you.
    // And dismiss the UIViewController.
    self.dismissViewControllerAnimated(true, completion: nil)
}
lock.presentLockController(controller, fromController: self)
```
And you'll see our native login screen

[![Lock.png](http://blog.auth0.com.s3.amazonaws.com/Lock-Widget-Screenshot.png)](https://auth0.com)

> By default all social authentication will be done using Safari, if you want native integration please check this [docs page](https://auth0.com/docs/libraries/lock-ios/native-social-authentication).

Also you can check our [Swift](https://github.com/auth0/Lock.iOS-OSX/tree/master/Examples/basic-sample-swift) and [Objective-C](https://github.com/auth0/Lock.iOS-OSX/tree/master/Examples/basic-sample) example apps. For more information on how to use **Lock** with Swift please check [this guide](https://github.com/auth0/Lock.iOS-OSX/wiki/Lock-&-Swift)

### TouchID

`A0TouchIDLockViewController` authenticates without using a password with TouchID. In order to be able to authenticate the user, your application must have a Database connection enabled.

Add the following line to your Podfile:

```ruby
pod "Lock/TouchID", "~> 1.27"
```

First instantiate `A0TouchIDLockViewController` and register the authentication callback that will receive the authenticated user's credentials. Finally present it to the user:

```objc
A0Lock *lock = [A0Lock sharedLock];
A0TouchIDLockViewController *controller = [lock newTouchIDViewController];
controller.onAuthenticationBlock = ^(A0UserProfile *profile, A0Token *token) {
    // Do something with token & profile. e.g.: save them.
    // Lock will not save the Token and the profile for you.
    // And dismiss the UIViewController.
    [self dismissViewControllerAnimated:YES completion:nil];
};
[lock presentTouchIDController:controller fromController:self];
```

```swift
let lock = A0Lock.sharedLock()
let controller = lock.newTouchIDViewController()
controller.onAuthenticationBlock = {(profile, token) in
    // Do something with token & profile. e.g.: save them.
    // Lock will not save the Token and the profile for you.
    // And dismiss the UIViewController.
    self.dismissViewControllerAnimated(true, completion: nil)
}
lock.presentTouchIDController(controller, fromController: self)
```
And you'll see TouchID login screen

[![Lock.png](http://blog.auth0.com.s3.amazonaws.com/Lock-TouchID-Screenshot.png)](https://auth0.com)

> Because it uses a Database connection, the user can change it's password and authenticate using email/password whenever needed. For example when you change your device.

### SMS

`A0SMSLockViewController` authenticates without using a password with SMS. In order to be able to authenticate the user, your application must have the SMS connection enabled and configured in your [dashboard](https://app.auth0.com/#/connections/passwordless).

Add the following line to your Podfile:

```ruby
pod "Lock/SMS", "~> 1.27"
```

First instantiate `A0SMSLockViewController` and register the authentication callback that will receive the authenticated user's credentials.

Finally present it to the user:

```objc
A0Lock *lock = [A0Lock sharedLock];
A0SMSLockViewController *controller = [lock newSMSViewController];
controller.useMagicLink = YES;
controller.onAuthenticationBlock = ^(A0UserProfile *profile, A0Token *token) {
    // Do something with token & profile. e.g.: save them.
    // Lock will not save the Token and the profile for you.
    // And dismiss the UIViewController.
    [self dismissViewControllerAnimated:YES completion:nil];
};
[lock presentSMSController:controller fromController:self];
```

```swift
let lock = A0Lock.sharedLock()
let controller = lock.newSMSViewController()
controller.useMagicLink = true
controller.onAuthenticationBlock = {(profile, token) in
    // Do something with token & profile. e.g.: save them.
    // Lock will not save the Token and the profile for you.
    // And dismiss the UIViewController.
    self.dismissViewControllerAnimated(true, completion: nil)
}
lock.presentSMSController(controller, fromController: self)
```
And you'll see SMS login screen

[![Lock.png](http://blog.auth0.com.s3.amazonaws.com/Lock-SMS-Screenshot.png)](https://auth0.com)

### Email

`A0EmailLockViewController` authenticates without using a password with Email. In order to be able to authenticate the user, your application must have the Email connection enabled and configured in your [dashboard](https://app.auth0.com/#/connections/passwordless).

Add the following line to your Podfile:

```ruby
pod "Lock/Email", "~> 1.27"
```

First instantiate `A0EmailLockViewController` and register the authentication callback that will receive the authenticated user's credentials.

Finally present it to the user:

```objc
A0Lock *lock = [A0Lock sharedLock];
A0EmailLockViewController *controller = [lock newEmailViewController];
controller.useMagicLink = YES;
controller.onAuthenticationBlock = ^(A0UserProfile *profile, A0Token *token) {
    // Do something with token & profile. e.g.: save them.
    // Lock will not save the Token and the profile for you.
    // And dismiss the UIViewController.
    [self dismissViewControllerAnimated:YES completion:nil];
};
[lock presentEmailController:controller fromController:self];
```

```swift
let lock = A0Lock.sharedLock()
let controller = lock.newEmailViewController()
controller.useMagicLink = true
lock.onAuthenticationBlock = {(profile, token) in
    // Do something with token & profile. e.g.: save them.
    // Lock will not save the Token and the profile for you.
    // And dismiss the UIViewController.
    self.dismissViewControllerAnimated(true, completion: nil)
}
lock.presentEmailController(controller, fromController: self)
```

## SSO

A very cool thing you can do with Lock is use SSO. Imagine you want to create 2 apps. However, you want that if the user is logged in in app A, he will be already logged in in app B as well. Something similar to what happens with Messenger and Facebook as well as Foursquare and Swarm.

Read [this guide](https://auth0.com/docs/libraries/lock-ios/sso-on-mobile-apps) to learn how to accomplish this with this library.

## Documentation
You can find the full documentation for this library on that [Auth0 doc site](https://auth0.com/docs/libraries/lock-ios). Additionally, you can browse the full API on [CocoaDocs](http://cocoadocs.org/docsets/Lock).

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

## Issue Reporting

If you have found a bug or if you have a feature request, please report them at this repository issues section. Please do not report security vulnerabilities on the public GitHub issue tracker. The [Responsible Disclosure Program](https://auth0.com/whitehat) details the procedure for disclosing security issues.

## Author

[Auth0](auth0.com)

## License

This project is licensed under the MIT license. See the [LICENSE](LICENSE) file for more info.
