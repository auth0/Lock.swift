![Lock.swift](https://cdn.auth0.com/website/sdks/banners/lock-swift-banner.png)

![Version](https://img.shields.io/cocoapods/v/Lock.svg?style=flat)
[![CircleCI](https://img.shields.io/circleci/project/github/auth0/Lock.swift.svg?style=flat)](https://circleci.com/gh/auth0/Lock.swift/tree/master)
[![Coverage Status](https://img.shields.io/codecov/c/github/auth0/Lock.swift/master.svg?style=flat)](https://codecov.io/github/auth0/Lock.swift)
![License](https://img.shields.io/github/license/auth0/Lock.swift.svg?style=flat)

📚 [**Documentation**](#documentation) • 🚀 [**Getting Started**](#getting-started) • 💬 [**Feedback**](#feedback)

Migrating from v1? Check the [Migration Guide](MIGRATION.md).

## Documentation

- [**Examples**](EXAMPLES.md) - explains how to use Lock.swift.
- [**Auth0 Documentation**](https://auth0.com/docs) - explore our docs site and learn more about Auth0.

## Getting Started

### Requirements

- iOS 9+
- Xcode 13.x / 14.x
- Swift 4.x / 5.x

**Lock.swift uses Auth0.swift 1.x**.

### Installation

#### Cocoapods

Add the following line to your `Podfile`:

```ruby
pod "Lock", "~> 2.24"
```

Then, run `pod install`.

#### Carthage

Add the following line to your `Cartfile`:

```ruby
github "auth0/Lock.swift" ~> 2.24
```

Then, run `carthage bootstrap --use-xcframeworks --platform iOS`.

#### Swift Package Manager

Open the following menu item in Xcode:

**File > Add Packages...**

In the **Search or Enter Package URL** search box enter this URL: 

```text
https://github.com/auth0/Lock.swift
```

Then, select the dependency rule and press **Add Package**.

### Configure the SDK

Head to the [Auth0 Dashboard](https://manage.auth0.com/#/applications/) and create a new **Native** application.

Lock.swift needs the **Client ID** and **Domain** of the Auth0 application to communicate with Auth0. You can find these details in the settings page of your Auth0 application. If you are using a [custom domain](https://auth0.com/docs/brand-and-customize/custom-domains), use the value of your custom domain instead of the value from the settings page.

#### Configure Client ID and Domain with a plist

Create a `plist` file named `Auth0.plist` in your app bundle with the following content:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>ClientId</key>
    <string>YOUR_AUTH0_CLIENT_ID</string>
    <key>Domain</key>
    <string>YOUR_AUTH0_DOMAIN</string>
</dict>
</plist>
```

#### Configure Client ID and Domain programmatically

<details>
  <summary>For Classic Lock</summary>

```swift
Lock
    .classic(clientId: "YOUR_AUTH0_CLIENT_ID", domain: "YOUR_AUTH0_DOMAIN")
    // ...
```
</details>

<details>
  <summary>For Passwordless Lock</summary>

```swift
Lock
    .passwordless(clientId: "YOUR_AUTH0_CLIENT_ID", domain: "YOUR_AUTH0_DOMAIN")
    // ...
```
</details>

### Configure your app

Make sure Lock.swift can receive callback URLs.

<details>
  <summary>Using the UIKit app lifecycle</summary>

```swift
// AppDelegate.swift

import Lock

// ...

func application(_ app: UIApplication,
                 open url: URL,
                 options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
    return Lock.resumeAuth(url, options: options)
}
```
</details>

<details>
  <summary>Using the UIKit app lifecycle with Scenes</summary>

```swift
// SceneDelegate.swift

import Lock

// ...

func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    guard let url = URLContexts.first?.url else { return }
    Lock.resumeAuth(url, options: [:])
}
```
</details>

### Next steps

**Learn how to use Lock.swift in [Examples ↗](EXAMPLES.md)**

- [**Lock Classic**](EXAMPLES.md#lock-classic) - handles authentication using Database, Social, and Enterprise connections.
- [**Lock Passwordless**](EXAMPLES.md#lock-passwordless) - handles authentication using Passwordless and Social connections.

## Feedback

### Contributing

We appreciate feedback and contribution to this repo! Before you get started, please see the following:

- [Auth0's general contribution guidelines](https://github.com/auth0/open-source-template/blob/master/GENERAL-CONTRIBUTING.md)
- [Auth0's code of conduct guidelines](https://github.com/auth0/open-source-template/blob/master/CODE-OF-CONDUCT.md)
- [Lock.swift's contribution guide](CONTRIBUTING.md)

### Raise an issue

To provide feedback or report a bug, please [raise an issue on our issue tracker](https://github.com/auth0/Lock.swift/issues).

### Vulnerability reporting

Please do not report security vulnerabilities on the public GitHub issue tracker. The [Responsible Disclosure Program](https://auth0.com/responsible-disclosure-policy) details the procedure for disclosing security issues.

---

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: light)" srcset="https://cdn.auth0.com/website/sdks/logos/auth0_light_mode.png" width="150">
    <source media="(prefers-color-scheme: dark)" srcset="https://cdn.auth0.com/website/sdks/logos/auth0_dark_mode.png" width="150">
    <img alt="Auth0 Logo" src="https://cdn.auth0.com/website/sdks/logos/auth0_light_mode.png" width="150">
  </picture>
</p>

<p align="center">Auth0 is an easy to implement, adaptable authentication and authorization platform. To learn more checkout <a href="https://auth0.com/why-auth0">Why Auth0?</a></p>

<p align="center">This project is licensed under the MIT license. See the <a href="./LICENSE"> LICENSE</a> file for more info.</p>
