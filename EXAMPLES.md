# Examples

- [Lock Classic](#lock-classic)
- [Lock Passwordless](#lock-passwordless)
- [Styling Lock](#styling-lock)
- [Customization Options](#customization-options)

---

## Lock Classic

Lock Classic handles authentication using Database, Social, and Enterprise connections.

### OIDC conformant mode

It is strongly encouraged that this SDK be used in OIDC Conformant mode. When this mode is enabled, it will force the SDK to use Auth0's current authentication pipeline and will prevent it from reaching legacy endpoints. Defaults to `false`.

```swift
.withOptions {
    $0.oidcConformant = true
}
```

For more information, please see the [OIDC adoption guide](https://auth0.com/docs/authenticate/login/oidc-conformant-authentication).

To show Lock, add the following snippet in your `UIViewController`:

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

### Important: Database connection authentication

If you are using a Database connection in Lock then you will need to enable the Password Grant Type, please follow the [Update Grant Types](https://auth0.com/docs/get-started/applications/update-grant-types) guide.

#### Specify connections

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
    connections.social(name: "google-oauth2", style: .Google)
    connections.social(name: "github", style: .Github)
}
```

##### Adding Enterprise connections

```swift
.withConnections { connections in
    connections.enterprise(name: "customAD", domains: ["domain1.com", "domain2.com"])
    connections.enterprise(name: "alternativeAD", domains: ["domain3.com"], style: .Microsoft)
}
```

### Custom domains

If you are using [Custom Domains](https://auth0.com/docs/customize/custom-domains), you will need to set the `configurationBaseURL` to your Auth0 Domain so the Lock configuration can 
be read correctly:

```swift
.withOptions {
   $0.configurationBase = "https://YOUR_DOMAIN.auth0.com"
}
```

### Logging

You can easily turn on/off logging capabilities:

```swift
Lock
    .classic()
    .withOptions {
        $0.logLevel = .all
        $0.logHttpRequest = true
    }
```

[Go up ⤴](#examples)

## Lock Passwordless

Lock Passwordless handles authentication using Passwordless and Social connections.

> 💡 The Passwordless feature requires your application to have the *Passwordless OTP* Grant Type enabled. Check [this article](https://auth0.com/docs/get-started/applications/application-grant-types) for more information.

To use Passwordless Authentication with Lock, you need to configure it with **OIDC Conformant Mode** set to `true`.

> 💡 OIDC Conformant Mode will force Lock to use Auth0's current authentication pipeline and will prevent it from reaching legacy endpoints. By default this mode is disabled. For more information, please see the [OIDC adoption guide](https://auth0.com/docs/authenticate/login/oidc-conformant-authentication).

To show Lock, add the following snippet in your `UIViewController`:

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

> ⚠️ Passwordless can only be used with a single connection and will prioritize the use of email connections over sms.

#### Passwordless method

When using Lock Passwordless the default `passwordlessMethod` is `.code` which sends the user a one time passcode to login. If you want to use [Universal Links](https://auth0.com/docs/get-started/applications/enable-universal-links-support-in-apple-xcode) you can add the following:

```swift
.withOptions {
    $0.passwordlessMethod = .magicLink
}
```

#### Activity callback

If you are using Lock Passwordless and have specified the `.magicLink` option to send the user a universal link then you will need to add the following to your `AppDelegate.swift`:

```swift
func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
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

[Go up ⤴](#examples)

## Styling Lock

Lock.swift provides many styling options to help you apply your own brand identity to Lock.

### iPad modal presentation

iPad presentation is show in a modal popup, this can be disabled to use full screen as follows:

```swift
.withStyle {
  $0.modalPopup = false
}
```

### Customize your header and primary color

```swift
.withStyle {
  $0.title = "Company LLC"
  $0.logo = UIImage(named: "company_logo")
  $0.primaryColor = UIColor(red: 0.6784, green: 0.5412, blue: 0.7333, alpha: 1.0)
}
```

> 💡 You can explore the full range of styling options in [Style.swift](https://github.com/auth0/Lock.swift/blob/master/Lock/Style.swift).

### Styling a custom OAuth2 connection

```swift
.withStyle {
  $0.oauth2["slack"] = AuthStyle(
      name: "Slack",
      color: UIColor(red: 0.4118, green: 0.8078, blue: 0.6588, alpha: 1.0),
      withImage: UIImage(named: "ic_slack")
  )
}
```

[Go up ⤴](#examples)

## Customization options

Lock.swift provides numerous options to customize the Lock experience.

#### Closable

Allows Lock to be dismissed by the user. Defaults to `false`.

```swift
.withOptions {
    $0.closable = true
}
```

#### Terms of Service

By default Lock will use Auth0's [Terms of Service](https://auth0.com/web-terms) and [Privacy Policy](https://auth0.com/privacy):

```swift
.withOptions {
    $0.termsOfService = "https://example.com/terms"
    $0.privacyPolicy = "https://example.com/privacy"
}
```

#### Must accept Terms of Service

Database connection will require explicit acceptance of Terms of Service:

```swift
.withOptions {
    $0.mustAcceptTerms = true
}
```

#### Show Terms of Service

Database connection will display the Terms of Service dialog. Defaults to `true`.

```swift
.withOptions {
    $0.showTerms = true
}
```

> ⚠️ Terms will always be shown if the `mustAcceptTerms` flag has been enabled.

#### Logging

* **logLevel**: Defaults to `.off`. *Syslog* logging levels are supported.
* **logHttpRequest**: Log Auth0.swift API requests. Defaults to `false`.
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
  $0.scope = "openid profile email offline_access"
}
```

#### Connection scope

Allows you to set provider scopes for OAuth2/Social connections with a comma separated list. By default is empty.

```swift
.withOptions {
  $0.connectionScope = ["github": "public_repo read:user"]
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

#### Custom signup fields

When signing up the default information requirements are the user's *email* and *password*. You can expand your data capture requirements as needed.

If you want to save the value of the attribute in the root of a user's profile, ensure you set the  `storage` parameter to `.rootAttribute`. Only a subset of values can be stored this way. The list of attributes that can be added to your root profile is [here](https://auth0.com/docs/api/authentication#signup). By default, every additional sign up field is stored inside the user's `user_metadata` object.

When signing up, your app may need to assign values to the user's profile that are not entered by the user. The `hidden` property of `CustomTextField` prevents the signup field from being shown to the user, allowing your app to assign default values to the user profile.

```swift
.withOptions {
  $0.customSignupFields = [
    CustomTextField(name: "first_name", placeholder: "First Name", storage: .rootAttribute, icon: UIImage(named: "ic_person", bundle: Lock.bundle), contentType: .givenName),
    CustomTextField(name: "last_name", placeholder: "Last Name", storage: .rootAttribute, icon: UIImage(named: "ic_person", bundle: Lock.bundle), contentType: .familyName),
    CustomTextField(name: "referral_code", placeholder: "Referral Code", defaultValue: referralCode, hidden: true)
  ]
}
```

> ⚠️ You must specify the icon to use with your custom text field and store it in your App's bundle.

#### Password manager

This functionality has been removed as of Release 2.18 due to the 1Password extension using deprecated methods, which can result in your app being rejected by the AppStore. This functionality was superseded in iOS 12 when Apple introduced the integration of password managers into login forms.

The following options are now deprecated:

```swift
.withOptions {
    $0.passwordManager.enabled = false
    $0.passwordManager.appIdentifier = "www.example.com"
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

#### Show password

By default a show password icon is shown in password fields to toggle visibility of the input text. You can disable this using the `allowShowPassword` option:

```swift
.withOptions {
    $0.allowShowPassword = false
}
```

> ⚠️ Show password will not be available if the **Password Manager** is available.

#### Enterprise

* **enterpriseConnectionUsingActiveAuth**: By default Enterprise connections will use Web Authentication. However you can specify which connections will alternatively use credential authentication and prompt for a username and password.
* **activeDirectoryEmailAsUsername**: When Lock request your enterprise credentials after performing Home Realm Discovery (HRD), e.g. for Active Directory, it will try to prefill the username for you. By default it will parse the email's local part and use that as the username, e.g. `john.doe@auth0.com` will be `john.doe`. If you don't want that you can turn on this flag and it will just use the email address.

```swift
.withOptions {
  $0.activeDirectoryEmailAsUsername = true
  $0.enterpriseConnectionUsingActiveAuth = ["example.com"]
}
```

---

[Go up ⤴](#examples)
