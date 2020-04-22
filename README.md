# Lock.swift 

[![CircleCI](https://img.shields.io/circleci/project/github/auth0/Lock.swift.svg?style=flat-square)](https://circleci.com/gh/auth0/Lock.swift/tree/master)
[![Version](https://img.shields.io/cocoapods/v/Lock.svg?style=flat-square)](http://cocoadocs.org/docsets/Lock)
[![License](https://img.shields.io/cocoapods/l/Lock.svg?style=flat-square)](http://cocoadocs.org/docsets/Lock)
[![Platform](https://img.shields.io/cocoapods/p/Lock.svg?style=flat-square)](http://cocoadocs.org/docsets/Lock)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat-square)](https://github.com/Carthage/Carthage)
![Swift 5.0](https://img.shields.io/badge/Swift-5.0-orange.svg?style=flat-square)

[Auth0](https://auth0.com) is an authentication broker that supports social identity providers as well as enterprise identity providers such as Active Directory, LDAP, Google Apps and Salesforce.

Lock makes it easy to integrate SSO in your app. You won't have to worry about:

* Having a professional looking login dialog that displays well on any device.
* Finding the right icons for popular social providers.
* Solving the home realm discovery challenge with enterprise users (i.e.: asking the enterprise user the email, and redirecting to the right enterprise identity provider).
* Implementing a standard sign in protocol (OpenID Connect / OAuth2 Login)

Need help migrating from v1? Please check our [Migration Guide](MIGRATION.md)

## Requirements

- iOS 9+
- Xcode 10.x/11.x
- Swift 4.x/5.x

## Install

### CocoaPods

 Add the following line to your Podfile:

 ```ruby
 pod "Lock", "~> 2.17"
 ```

### Carthage

In your `Cartfile` add

```ruby
github "auth0/Lock.swift" ~> 2.17
```

## Usage

First import **Lock**

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

In order to use Lock you need to provide your Auth0 Client ID and Domain.

> The Auth0 Client ID & Domain can be found in your [Auth0 Dashboard](https://manage.auth0.com)

#### Auth0.plist file

In your application bundle you can add a `plist` file named `Auth0.plist` with the following information:

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

## Lock Classic

Lock Classic handles authentication using Database, Social & Enterprise connections.

### OIDC Conformant Mode

It is strongly encouraged that this SDK be used in OIDC Conformant mode. When this mode is enabled, it will force the SDK to use Auth0's current authentication pipeline and will prevent it from reaching legacy endpoints. By default this is `false`.

```swift
.withOptions {
    $0.oidcConformant = true
}
```

For more information, please see the [OIDC adoption guide](https://auth0.com/docs/api-auth/tutorials/adoption).

To show Lock, add the following snippet in your `UIViewController`

```swift
Lock
    .classic()
    .withOptions {
        $0.closable = false
        $0.oidcConformant = true
    }
    .withStyle {
      $0.title = "Welcome to my App!"
    }
    .onAuth {
      print("Obtained credentials \($0)")
    }
    .onError {
      print("Failed with \($0)")
    }
    .onCancel {
      print("User cancelled")
    }
    .present(from: self)
```

### Important: Database Connection Authentication

Since June 2017 new Clients no longer have the **Password Grant Type** enabled by default.
If you are using a Database Connection in Lock then you will need to enable the Password Grant Type, please follow [this guide](https://auth0.com/docs/clients/client-grant-types#how-to-edit-the-client-grant_types-property).

#### Specify Connections

Lock will automatically load your application configuration automatically, if you wish to override this behaviour you can manually specify which of your connections to use.  

Before presenting Lock you can tell it what connections it should display and use to authenticate an user. You can do that by calling the method and supply a closure that can specify the connections.

##### Adding a Database connection

```swift
.withConnections {
    $0.database(name: "Username-Password-Authentication", requiresUsername: true)
}
```

##### Adding Social connections

```swift
.withConnections { connections in
    connections.social(name: "facebook", style: .Facebook)
    connections.social(name: "google-oauth2", style: .Google)
}
```

##### Adding Enterprise connections

```swift
.withConnections { connections in
    connections.enterprise(name: "customAD", domains: ["domain1.com", "domain2.com"])
    connections.enterprise(name: "alternativeAD", domains: ["domain3.com"], style: .Microsoft)
}
```

### Custom Domains

If you are using [Custom Domains](https://auth0.com/docs/custom-domains), you will need to set the `configurationBaseURL` to your Auth0 Domain so the Lock configuration can 
be read correctly.

```swift
.withOptions {
   $0.configurationBase = "https://<YOUR DOMAIN>.auth0.com"
}
```

### Logging

You can easily turn on/off logging capabilities.

```swift
Lock
    .classic()
    .withOptions {
        $0.logLevel = .all
        $0.logHttpRequest = true
    }
```

## Styling Lock

Lock provides many styling options to help you apply your own brand identity to Lock.

### iPad Modal Presentation

iPad presentation is show in a modal popup, this can be disabled to use full screen as follows.

```swift
.withStyle {
  $0.modalPopup = false
}
```

### Customize your header and primary color

```swift
.withStyle {
  $0.title = "Company LLC"
  $0.logo = LazyImage(name: "company_logo")
  $0.primaryColor = UIColor(red: 0.6784, green: 0.5412, blue: 0.7333, alpha: 1.0)
}
```

> You can explore the full range of styling options in [Style.swift](https://github.com/auth0/Lock.swift/blob/master/Lock/Style.swift)

### Styling a custom OAuth2 connection

```swift
.withStyle {
  $0.oauth2["slack"] = AuthStyle(
      name: "Slack",
      color: UIColor(red: 0.4118, green: 0.8078, blue: 0.6588, alpha: 1.0),
      withImage: LazyImage(name: "ic_slack")
  )
}
```

## Lock Passwordless

Lock Passwordless handles authentication using Passwordless & Social Connections.

> The Passwordless feature requires your application to have the *Passwordless OTP* Grant Type enabled. Check [this article](https://auth0.com/docs/clients/client-grant-types) for more information.

To use Passwordless Authentication with Lock, you need to configure it with **OIDC Conformant Mode** set to `true`.

> OIDC Conformant Mode will force Lock to use Auth0's current authentication pipeline and will prevent it from reaching legacy endpoints. By default this mode is disabled. For more information, please see the [OIDC adoption guide](https://auth0.com/docs/api-auth/tutorials/adoption).

To show Lock, add the following snippet in your `UIViewController`

```swift
Lock
    .passwordless()
    .withOptions {
        $0.oidcConformant = true
    }
    .withStyle {
      $0.title = "Welcome to my App!"
    }
    .onAuth {
      print("Obtained credentials \($0)")
    }
    .onError {
      print("Failed with \($0)")
    }
    .onCancel {
      print("User cancelled")
    }
    .onPasswordless {
      print("Passwordless requested for \($0)")
    }
    .present(from: self)
```

**Notes:**
- Passwordless can only be used with a single connection and will prioritize the use of email connections over sms.  

#### Passwordless Method

When using Lock Passwordless the default `passwordlessMethod` is `.code` which sends the user a one time passcode to login. If you want to use [Universal Links](https://auth0.com/docs/clients/enable-universal-links) you can add the following:

```swift
.withOptions {
    $0.passwordlessMethod = .magicLink
}
```

#### Activity callback

If you are using Lock Passwordless and have specified the `.magicLink` option to send the user a universal link then you will need to add the following to your `AppDelegate.swift`:

```swift
func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
    return Lock.continueAuth(using: userActivity)
}
```

#### Adding a Passwordless connection

##### SMS

```swift
.withConnections {
    $0.sms(name: "sms")
}
```

##### Email

```swift
.withConnections {
    $0.email(name: "email")
}
```

## Customization options

Lock provides numerous options to customize the Lock experience.

#### Closable

Allows Lock to be dismissed by the user. By default this is `false`.

```swift
.withOptions {
    $0.closable = true
}
```

#### Terms of Service

By default Lock will use Auth0's [Terms of Service](https://auth0.com/terms) and [Privacy Policy](https://auth0.com/privacy)

```swift
.withOptions {
    $0.termsOfService = "https://mycompany.com/terms"
    $0.privacyPolicy = "https://mycompany.com/privacy"
}
```

#### Must accept Terms of Service

Database connection will require explicit acceptance of terms of service.

```swift
.withOptions {
    $0.mustAcceptTerms = true
}
```

#### Show Terms of Service

Database connection will display the Terms & Service dialog. Default is `true`.
Note: Terms will always be shown if the `mustAcceptTerms` flag has been enabled.

```swift
.withOptions {
    $0.showTerms = true
}
```

#### Logging

* **logLevel**: By default this is `.off`, *Syslog* logging levels are supported.
* **logHttpRequest**: Log Auth0.swift API requests. By default this is `false`
* **loggerOutput**: Specify output handler, by default this uses the `print` statement.

```swift
.withOptions {
    $0.logLevel = .all
    $0.logHttpRequest = true
    $0.loggerOutput = CleanroomLockLogger()
}
```

In the code above, the *loggerOutput* has been set to use [CleanroomLogger](https://github.com/emaloney/CleanroomLogger).
This can typically be achieved by implementing the *loggerOutput* protocol.  You can of course use your favorite logger library.

```swift
class CleanroomLockLogger: LoggerOutput {
  func message(_ message: String, level: LoggerLevel, filename: String, line: Int) {
    let channel: LogChannel?
    switch level {
    case .debug:
        channel = Log.debug
    case .error:
        channel = Log.error
    case .info:
        channel = Log.info
    case .verbose:
        channel = Log.verbose
    case .warn:
        channel = Log.warning
    default:
        channel = nil
    }
    channel?.message(message, filePath: filename, fileLine: line)
  }
}
```

#### Scope

Scope used for authentication. By default is `openid`. It will return not only the **access_token**, but also an **id_token** which is a [JSON Web Token (JWT)](https://jwt.io/) containing user information.

```swift
.withOptions {
  $0.scope = "openid name email picture"
}
```

#### Connection Scope

Allows you to set provider scopes for oauth2/social connections with a comma separated list. By default is empty.

```swift
.withOptions {
  $0.connectionScope = ["facebook": "user_friends,email"]
```

#### Database

- **allow**: Which database screens will be accessible, the default is enable all screens e.g. `.Login, .Signup, .ResetPassword`
- **initialScreen**: The first screen to present to the user, the default is `.login`.
- **usernameStyle**: Specify the type of identifier the login will require.  The default is either `[.Username, .Email]`.  However it's important to note that this option is only active if you have set the **requires_username** flag to `true` in your [Auth0 Dashboard](https://manage.auth0.com/#/)

```swift
.withOptions {
  $0.allow = [.Login, .ResetPassword]
  $0.initialScreen = .login
  $0.usernameStyle = [.Username]
}
```

#### Custom Signup Fields

When signing up the default information requirements are the user's *email* and *password*. You can expand your data capture requirements as needed.

If you want to save the value of the attribute in the root of a user's profile, ensure you set the  `storage` parameter to `.rootAttribute`. Only a subset of values can be stored this way. The list of attributes that can be added to your root profile is [here](https://auth0.com/docs/api/authentication#signup). By default, every additional sign up field is stored inside the user's `user_metadata` object.

When signing up, your app may need to assign values to the user's profile that are not entered by the user. The `hidden` property of `CustomTextField` prevents the signup field from being shown to the user, allowing your app to assign default values to the user profile.


```swift
.withOptions {
  $0.customSignupFields = [
    CustomTextField(name: "first_name", placeholder: "First Name", storage: .rootAttribute, icon: LazyImage(name: "ic_person", bundle: Lock.bundle), contentType: .givenName),
    CustomTextField(name: "last_name", placeholder: "Last Name", storage: .rootAttribute, icon: LazyImage(name: "ic_person", bundle: Lock.bundle), contentType: .familyName),
    CustomTextField(name: "referral_code", placeholder: "Referral Code", defaultValue: referralCode, hidden: true)
  ]
}
```

*Note: You must specify the icon to use with your custom text field and store it in your App's bundle.*

#### Password Manager

This functionality has been removed as of Release 2.18 due to the 1Password extension using deprecated methods, which can result in your app being rejected by the AppStore. This functionality was superseded in iOS 12 when Apple introduced the integration of password managers into login forms.

The following options are now deprecated:

```swift
.withOptions {
    $0.passwordManager.enabled = false
    $0.passwordManager.appIdentifier = "www.myapp.com"
    $0.passwordManager.displayName = "My App"
}
```

You may also safely remove the following entry from your app's `Info.plist`:

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>org-appextension-feature-password-management</string>
</array>
```

#### Show Password

By default a show password icon is shown in password fields to toggle visibility of the input text. You can disable this using the `allowShowPassword` option.

```swift
.withOptions {
    $0.allowShowPassword = false
}
```

**Note:** Show password will not be available if the [Password Manager](#Password Manager) is available.

#### Enterprise

* **enterpriseConnectionUsingActiveAuth**: By default Enterprise connections will use Web Authentication. However you can specify which connections will alternatively use credential authentication and prompt for a username and password.
* **activeDirectoryEmailAsUsername**: When Lock request your enterprise credentials after performing Home Realm Discovery (HRD), e.g. for Active Directory, it will try to prefill the username for you. By default it will parse the email's local part and use that as the username, e.g. `john.doe@auth0.com` will be `john.doe`. If you don't want that you can turn on this flag and it will just use the email address.

```swift
.withOptions {
  $0.activeDirectoryEmailAsUsername = true
  $0.enterpriseConnectionUsingActiveAuth = ["enterprisedomain.com"]
}
```

## What is Auth0?

Auth0 helps you to:

* Add authentication with [multiple authentication sources](https://docs.auth0.com/identityproviders), either social like **Google, Facebook, Microsoft Account, LinkedIn, GitHub, Twitter, Box, Salesforce, amongst others**, or enterprise identity systems like **Windows Azure AD, Google Apps, Active Directory, ADFS or any SAML Identity Provider**.
* Add support for [Custom OAuth2 Connections](https://auth0.com/docs/connections/social/oauth2).
* Add authentication through more traditional **[username/password databases](https://docs.auth0.com/mysql-connection-tutorial)**.
* Add support for **[linking different user accounts](https://docs.auth0.com/link-accounts)** with the same user.
* Support for generating signed [JSON Web Tokens](https://docs.auth0.com/jwt) to call your APIs and **flow the user identity** securely.
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
