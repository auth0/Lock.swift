# Lock.swift (BETA)

[![Build Status](https://travis-ci.org/auth0/Lock.iOS-OSX.svg?branch=v2)](https://travis-ci.org/auth0/Lock.iOS-OSX)
[![Version](https://img.shields.io/cocoapods/v/Lock.svg?style=flat)](http://cocoadocs.org/docsets/Lock)
[![License](https://img.shields.io/cocoapods/l/Lock.svg?style=flat)](http://cocoadocs.org/docsets/Lock)
[![Platform](https://img.shields.io/cocoapods/p/Lock.svg?style=flat)](http://cocoadocs.org/docsets/Lock)

[Auth0](https://auth0.com) is an authentication broker that supports social identity providers as well as enterprise identity providers such as Active Directory, LDAP, Google Apps and Salesforce.

Lock makes it easy to integrate SSO in your app. You won't have to worry about:

* Having a professional looking login dialog that displays well on any device.
* Finding the right icons for popular social providers.
* Solving the home realm discovery challenge with enterprise users (i.e.: asking the enterprise user the email, and redirecting to the right enterprise identity provider).
* Implementing a standard sign in protocol (OpenID Connect / OAuth2 Login)

## Requirements

- iOS 9 or later

## Install

### CocoaPods

The **Lock.swift** is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod "Lock", "~> 2.0.0-beta.1"
```

### Carthage

In your cartfile add

```
github "auth0/Lock.iOS-OSX"
```

## Condiguration


## Usage

First to import **Lock.swift**

```swift
import Lock
```

then in your `AppDelegate.swift` add the following

```swift
func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
    return Lock.resumeAuth(url, options: options)
}
```

### Classic 

Lock Classic handles authentication using Database, Social & Enterprise connections.

> Currenty Lock.swift only supports Database & Social authentication and you need to tell Lock what connections it should use

To show **Lock.swift**, add the following snippet in any of your `UIViewController`

```swift
Lock
    .classic()
    .connections {
        $0.database(name: "Username-Password-Authentication", requiresUsername: true)
    }
    .options {
        $0.closable = false
    }
    .on { result in
        switch result {
        case .Success(let credentials):
            print("Obtained credentials \(credentials)")
        case .Failure(let cause):
            print("Failed with \(cause)")
        case .Cancelled:
            print("User cancelled")
        }
    }
    .present(from: self)
```

#### Specify Connections

> Eventually **Lock.swift** will be able to load your client configuration automatically, but until then you should describe what connections it should use.

Before presenting **Lock.swift** you can tell it what connections it should display and use to authenticate an user. You can do that by calling the method and supply a closure that can specify the connections

```swift
.connections { connections in
    // Your connections
}
```

So if you need a database connection you can call

```swift
connections.database(name: "{CONNECTION_NAME}", requiresUsername: true)
```

Or a social connection

```swift
connections.social(name: "{CONNECTION_NAME}", style: .Facebook)
```

### Logging

In **Lock.swift** options you can turn on/off logging capabilities

```swift
Lock
    .classic()
    .options {
        $0.logLevel = .All
        $0.logHttpRequest = true
    }
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

## Issue Reporting

If you have found a bug or if you have a feature request, please report them at this repository issues section. Please do not report security vulnerabilities on the public GitHub issue tracker. The [Responsible Disclosure Program](https://auth0.com/whitehat) details the procedure for disclosing security issues.

## Author

[Auth0](auth0.com)

## License

This project is licensed under the MIT license. See the [LICENSE](LICENSE) file for more info.
