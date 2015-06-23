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

* **Integrates** your iOS app with **Auth0** (OS X coming soon).
* Provides a **beautiful native UI** to log your users in.
* Provides support for **Social Providers** (Facebook, Twitter, etc.), **Enterprise Providers** (AD, LDAP, etc.) and **Username & Password**.
* Provides the ability to do **SSO** with 2 or more mobile apps similar to Facebook and Messenger apps.
* [1Password](https://agilebits.com/onepassword) integration using **iOS 8** [Extension](https://github.com/AgileBits/onepassword-app-extension).
* Passwordless authentication using **TouchID** and **SMS**.

## Requierements

iOS 7+. If you need to use our SDK in an earlier version please use our previous SDK pod `Auth0Client` or check the branch [old-sdk](https://github.com/auth0/Lock.iOS-OSX/tree/old-sdk) of this repo.

## Install

The Lock is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod "Lock", "~> 1.12"
```

Then in your project's `Info.plist` file add the following entries:

* __Auth0ClientId__: The client ID of your application in __Auth0__.
* __Auth0Domain__: Your account's domain in __Auth0__.

> You can find these values in your app's settings in [Auth0 dashboard](https://app.auth0.com/#/applications).

## Documentation
You can find the full documentation for this library on that [Auth0 doc site](https://auth0.com/docs/libraries/lock-ios). Additionally, you can browse the full API on [CocoaDocs](http://cocoadocs.org/docsets/Lock).

## Issue Reporting

If you have found a bug or if you have a feature request, please report them at this repository issues section. Please do not report security vulnerabilities on the public GitHub issue tracker. The [Responsible Disclosure Program](https://auth0.com/whitehat) details the procedure for disclosing security issues.

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
