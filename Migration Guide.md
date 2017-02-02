# Lock iOS 2.0 Migration Guide

Lock 2.0 is the latest major release of Lock iOS-OSX, Lock provides a simple way to integrate Auth0 into existing projects and provide the frictionless login and signup experience that you want for your app. Lock provides extensive authentication options and customizable UI for your users to use to authenticate with your app.

This guide is provided in order to ease the transition of existing applications using Lock 1.x to the latest APIs.

- [Requirements](#requirements)
- [Benefits of Upgrading](#benefits-of-upgrading)
- [Breaking Changes](#breaking-changes)
	- [Integrate with your Application](#integrate-with-your-Application)
	- [Usage](#usage)
- [New Features](#new-features)
- [Support](#support)
- [Author](#author)
- [License](#license)

## Requirements

- iOS 9.0+
- Xcode 8.0+
- Swift 3.0+

For those of you who require Objective-C support or iOS 8 support we recommend sticking with Lock 1.
At time of writing, SMS, Email and Touch ID support are not available but coming very soon.

## Benefits of Upgrading

- **Complete Swift 3 Compatibility:** includes the adoption of the new [API Design Guidelines](https://swift.org/documentation/api-design-guidelines/).
- **OIDC Compliance:** @TODO: Do we have a nice benefit snippet for this?
- **HRD Discovery:** solving the home realm discovery challenge with enterprise users.
- **Improved UI:** having a professional looking login dialog that displays well on any device.
- **Extensive configuration:** lock provides extensive configuration options to help customize the experience to your users needs.
- **Native web auth:** remove additional setup of `Lock/Safari` for some connections.
@TODO: More benefits?

## Breaking Changes

Lock 2.0 has adopted all the new Swift 3 changes and conventions, including the new [API Design Guidelines](https://swift.org/documentation/api-design-guidelines/). Because of this, almost every API in Lock has been modified in some way. So we're going to attempt to identify the most common usage and how they have changed to help you get started with Lock 2.0.

### Integrate with your Application

Lock needs to be notified for some of your application state changes and some events/notifications your application receives from the OS. You can do all these things in the `AppDelegate`

#### Application finished launching

```swift
// Lock 1
func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
	A0Lock.sharedLock().applicationLaunchedWithOptions(launchOptions)
	//Your code
	return true
}

// Lock 2 - No longer required.
```

#### Application is asked to open URL

```swift
// Lock 1
func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
	A0Lock.sharedLock().applicationLaunchedWithOptions(launchOptions)
	//Your code
	return true
}

// Lock 2
func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
  return Lock.resumeAuth(url, options: options)
}
```

#### Application is asked to continue a User Activity

```swift
// Lock 1
func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
	return A0Lock.sharedLock().continueUserActivity(userActivity, restorationHandler:restorationHandler)
}

// Lock 2 - No longer required.
```

### Usage

`Lock` by default will handle Email/Password, Enterprise & Social authentication based on your Application's connections enabled in your Auth0 Dashboard.

#### Email/Password, Enterprise & Social authentication

```swift
// Lock 1
let lock = A0Lock.sharedLock()
let controller = lock.newLockViewController()
controller.onAuthenticationBlock = {(profile, token) in
    // Do something with token & profile. e.g.: save them.
    // Lock will not save the Token and the profile for you.
    // And dismiss the UIViewController.
    self.dismissViewControllerAnimated(true, completion: nil)
}
lock.presentLockController(controller, fromController: self)

// Lock 2
Lock
    .classic()
    .onAuth { credentials in
      // Lock will no longer return the users profile upon authentication
      // Lock will not save the Credentials object for you.
      // Lock will dismiss itself upon successful authentication unless you disable this in your configuration.
    }
    .present(from: self)
```

## New Features

- [Lock Events](./README.md#classic)
- [Specify Connections](./README.md#specify-connections)
- [Logging](./README.md#logging)
- [Styling](./README.md#styling_lock)
- [Customization Options](./README.md#customization-options)

## Support

@TODO General support info?

## Author

[Auth0](auth0.com)

## License

This project is licensed under the MIT license. See the [LICENSE](LICENSE) file for more info.
