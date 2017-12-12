# Migrating from Lock iOS 1 to 2

Lock 2.0 is the latest major release of Lock iOS-OSX, Lock provides a simple way to integrate Auth0 into existing projects and provide the frictionless login and signup experience that you want for your app. Lock provides extensive authentication options and customizable UI for your users to use to authenticate with your app.

This guide is provided in order to ease the transition of existing applications using Lock 1.x to the latest APIs.

## Requirements

- iOS 9.0+
- Xcode 9.0+
- Swift 4.0+

### Objective-C Support

Lock v2 cannot be used from Objective-C since it's public API relies in Swift features and that makes them unavailable in ObjC codebase.

If you are willing to have some Swift code in your existing application you can follow this [guide](https://developer.apple.com/library/content/documentation/Swift/Conceptual/BuildingCocoaApps/MixandMatch.html) on how to mix Objective-C and Swift and then use Lock v2 from the Swift files.

If that's not an option we recommend sticking with Lock v1 or using [Auth0.swift](https://github.com/auth0/Auth0.swift) to build your own Lock

## Benefits of Upgrading

- **Complete Swift 3 Compatibility:** The new version includes the adoption of the new [API Design Guidelines](https://swift.org/documentation/api-design-guidelines/).
- **Improved UI:** having a professional looking login box that displays well on any device.
- **Extensive configuration:** lock provides improved configuration options to help customize the experience to your users needs.
- **Safari controller for web-based Auth:** Following Google's recent ban of WebView based auth, Lock (and Auth0.swift) will always use `SFSafariViewController` when web auth is needed.
- **API Authorization support:** Adds support for Auth0 [API Authorization](https://auth0.com/docs/api-auth)

## Changes from v1

Lock 2.0 has adopted all the new Swift 3 changes and conventions, including the new [API Design Guidelines](https://swift.org/documentation/api-design-guidelines/). Because of this, almost every API in Lock has been modified in some way. So we're going to attempt to identify the most common usage and how they have changed to help you get started with Lock 2.0.

### Integration with your Application

Lock needs to be notified for some of your application state changes and some events/notifications your application receives from the OS. You can do all these things in the `AppDelegate`

#### Application finished launching

In Lock v1 you'd add the following

```swift
func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
	A0Lock.sharedLock().applicationLaunchedWithOptions(launchOptions)
	//Your code
	return true
}
```

but in Lock v2 is no longer required.

#### Application is asked to open URL

In Lock v1 you'd add the following

```swift
func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
    return A0Lock.shared().handle(url, sourceApplication: sourceApplication)
}
```

and in Lock v2 you need to

```swift
func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
  return Lock.resumeAuth(url, options: options)
}
```

#### Application is asked to continue a User Activity

If you are using Lock passwordless and have specified the `.magicLink` option to send the user a universal link then you will need to add the following to your `AppDelegate.swift`:

```swift
func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
    return Lock.continueAuth(using: userActivity)
}
```

### Usage

`Lock` by default will handle Email/Password, Enterprise & Social authentication based on your Application's connections enabled in your Auth0 Dashboard.

#### Auth0 credentials

Like in v1, in your application bundle you can add a `plist` file named `Auth0.plist` with the following format

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

and it will load your Auth0 credentials, and if you prefer you can specify your credentials when showing Lock v2 like

```swift
Lock
    .classic(clientId: "{YOUR_CLIENT_ID}", domain: "{YOUR_DOMAIN}")
```

#### Classic mode (Database, Enterprise & Social authentication)

In v1 to show Lock from a `UIViewController` you'd add the following code

```swift
let lock = A0Lock.shared()
let controller = lock.newLockViewController()
controller.onAuthenticationBlock = {(profile, token) in
    // Do something with token & profile. e.g.: save them.
    // Lock will not save the Token and the profile for you.
    // And dismiss the UIViewController.
    self.dismissViewController(animated: true, completion: nil)
}
lock.present(controller, from: self)
```

and in v2 it can be changed for the following

```swift
Lock
    .classic()
    .onAuth { credentials in
      print("Authenticated!")
    }
    .present(from: self)
```

so in the `onAuth` callback you'd only receive the credentials of the user when the authentication is successful.
> In contrast with Lock v1, now Lock will dismiss itself so there is no need to call `dismissViewController(animated:, completion:)` in any of the callbacks.

In the case you need to know about the errors or signup there are the corresponding `onError` and `onSignUp` callbacks to be notified.

```swift
Lock
    .classic()
    .onAuth { credentials in
      print("Authenticated!")
    }
    .onSignUp { email, attributes in
      print("New user with email \(email)!")
    }
    .onError { error in
      print("Failed with error \(error.localizedString)")
    }
    .present(from: self)
```

> The callback `onSignUp` is only called when the login after signup is disabled

#### Passwordless mode (Email & SMS connections)

In v1 to show Lock Passwordless from a `UIViewController` you'd need to use either:

**Email**

```swift
let lock = A0Lock.shared()
let controller: A0EmailLockViewController = lock.newEmailViewController()
controller.useMagicLink = true
controller.onAuthenticationBlock = { (profile, token) in
    // Do something with token & profile. e.g.: save them.
    // Lock will not save the Token and the profile for you.
    // And dismiss the UIViewController.
    self.dismiss(animated: true, completion: nil)
}
lock.presentEmailController(controller, from: self)
```

**SMS**

```swift
let lock = A0Lock.shared()
let controller: A0SMSLockViewController = lock.newSMSViewController()
controller.useMagicLink = true
controller.onAuthenticationBlock = { (profile, token) in
    // Do something with token & profile. e.g.: save them.
    // Lock will not save the Token and the profile for you.
    // And dismiss the UIViewController.
    self.dismiss(animated: true, completion: nil)
}
lock.presentSMSController(controller, from: self)
```

In V2 both email and sms now use the same method:

```swift
Lock
    .passwordless()
    .onAuth { credentials in
      print("Authenticated!")
    }
    .present(from: self)
```

**Notes:**
- Passwordless can only be used with a single connection and will prioritize the use of email connections over sms.  
- The `audience` option is not available in Passwordless.

#### Configuration Options

If you needed to tweak Lock behaviour using it's options in v1 you'd do something like

```swift
let controller = A0Lock.shared().newLockViewController()
controller?.closable = true
controller?.connections = ["facebook", "github", "my-database"]
```

in Lock v2 you can do it all before presenting Lock by calling

```swift
Lock
    .withOptions { options in
      options.closable = true
      options.allowedConnections = ["facebook", "github", "my-database"]
    }
    // continue configuring and then present Lock
```


#### UI Customizations

In v1 all UI customizations were performed using the `A0Theme` object where you'd do something like

```swift
let theme = A0Theme()
theme.register(.blue, forKey: A0ThemeTitleTextColor)
A0Theme.sharedInstance().register(theme)
```

in Lock v2 the UI customization is done using the `withStyle` function

```swift
Lock
    .classic()
    .withStyle { style in
      style.titleColor = .blue
    }
    // other customizations
    .present(from: self)
```

## In the Roadmap

- [ ] Native Authentication with third party SDKs (Facebook, Google, Twitter)
- [ ] 1Password support
- [ ] Secure Token storage and automatic token refresh
- [ ] Remember me like feature using TouchID
- [ ] Universal Link support for browser based Auth
- [ ] Improved UI Styling
- [ ] Bundle more i18n translation in Lock.framework
