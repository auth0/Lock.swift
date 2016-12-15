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
- Xcode 8
- Swift 3.0

## Install

### Carthage

In your `Cartfile` add

```
github "auth0/Lock.iOS-OSX" "2.0.0-beta.3"
```

## Usage

First import **Lock.swift**

```swift
import Lock
```

Next in your `AppDelegate.swift` add the following:

```swift
func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
  return Lock.resumeAuth(url, options: options)
}
```

### Configuration

In order to use Lock you need to provide your Auth0 Client Id and Domain.

> Auth0 ClientId & Domain can be found in your [Auth0 Dashboard](https://manage.auth0.com)

#### Auth0.plist file

In your application bundle you can add a `plist` file named `Auth0.plist` with the following format

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

### Classic

Lock Classic handles authentication using Database, Social & Enterprise connections.

To show **Lock.swift**, add the following snippet in any of your `UIViewController`

```swift
Lock
    .classic()
    .withOptions {
        $0.closable = false
    }
    .on { result in
        switch result {
        case .success(let credentials):
            print("Obtained credentials \(credentials)")
        case .failure(let cause):
            print("Failed with \(cause)")
        case .cancelled:
            print("User cancelled")
        }
    }
    .present(from: self)
```

#### Specify Connections

**Lock.swift** will automatically load your client configuration automatically, if you wish to override this you can manually specify which of your connections to use.

Before presenting **Lock.swift** you can tell it what connections it should display and use to authenticate an user. You can do that by calling the method and supply a closure that can specify the connections.

Adding a database connection:

```swift
.withConnections {
    $0.database(name: "Username-Password-Authentication", requiresUsername: true)
}
```

Adding multiple social connections:

```swift
connections.database(name: "{CONNECTION_NAME}", requiresUsername: true)
```

```swift
.withConnections { connections in
    connections.social(name: "facebook", style: .Facebook)
    connections.social(name: "google-oauth2", style: .Google)
}
```

### Logging

In **Lock.swift** options you can turn on/off logging capabilities

```swift
Lock
    .classic()
    .withOptions {
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
