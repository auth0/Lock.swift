# Change Log

## [2.1.0](https://github.com/auth0/Lock.swift/tree/2.1.0) (2017-03-13)
[Full Changelog](https://github.com/auth0/Lock.swift/compare/2.0.0...2.1.0)

**Added**
- Added Connection Scope support for OAuth2 connections [\#386](https://github.com/auth0/Lock.swift/pull/386) ([cocojoe](https://github.com/cocojoe))
- Native authentication handler support [\#377](https://github.com/auth0/Lock.swift/pull/377) ([cocojoe](https://github.com/cocojoe))

**Changed**
- Update evernote color to match branding [\#411](https://github.com/auth0/Lock.swift/pull/411) ([hzalaz](https://github.com/hzalaz))

## [2.0.0](https://github.com/auth0/Lock.swift/tree/2.0.0) (2017-02-16)
[Full Changelog](https://github.com/auth0/Lock.swift/compare/2.0.0-rc.2...2.0.0)

**Added**
- Show error when using audience in non OIDC mode [\#391](https://github.com/auth0/Lock.swift/pull/391) ([hzalaz](https://github.com/hzalaz))
- Add centralized error processing to Dispatcher [\#374](https://github.com/auth0/Lock.swift/pull/374) ([cocojoe](https://github.com/cocojoe))
- Add Fatal Erorrs to UnrecoverableError for Debug Builds [\#373](https://github.com/auth0/Lock.swift/pull/373) ([cocojoe](https://github.com/cocojoe))
- Auto close on success event behaviour and customization [\#370](https://github.com/auth0/Lock.swift/pull/370) ([cocojoe](https://github.com/cocojoe))
- Critical error handling and presentation [\#367](https://github.com/auth0/Lock.swift/pull/367) ([cocojoe](https://github.com/cocojoe))

**Changed**
- i18n strings file for Base language in Lock [\#393](https://github.com/auth0/Lock.swift/pull/393) ([hzalaz](https://github.com/hzalaz))
- Change AD screens styling [\#384](https://github.com/auth0/Lock.swift/pull/384) ([hzalaz](https://github.com/hzalaz))
- Navigate to Login screen after ResetPassword and Signup events [\#369](https://github.com/auth0/Lock.swift/pull/369) ([cocojoe](https://github.com/cocojoe))

**Fixed**
- Fixed single connection behaviour for enterprise  [\#387](https://github.com/auth0/Lock.swift/pull/387) ([hzalaz](https://github.com/hzalaz))
- Fixed crash when loading any enterprise connection with no name [\#385](https://github.com/auth0/Lock.swift/pull/385) ([hzalaz](https://github.com/hzalaz))
- Fix signup password policy view enforcement on single screen [\#371](https://github.com/auth0/Lock.swift/pull/371) ([cocojoe](https://github.com/cocojoe))

## [2.0.0-rc.2](https://github.com/auth0/Lock.swift/tree/2.0.0-rc.2) (2017-01-10)
[Full Changelog](https://github.com/auth0/Lock.swift/compare/2.0.0-rc.1...2.0.0-rc.2)

**Added**
- Disable log in after sign up [\#365](https://github.com/auth0/Lock.swift/pull/365) ([cocojoe](https://github.com/cocojoe))
- Allow to hide main screen title [\#362](https://github.com/auth0/Lock.swift/pull/362) ([cocojoe](https://github.com/cocojoe))
- OIDC Conformant toggle [\#361](https://github.com/auth0/Lock.swift/pull/361) ([cocojoe](https://github.com/cocojoe))

**Fixed**
- Clean memory leaks [\#364](https://github.com/auth0/Lock.swift/pull/364) ([hzalaz](https://github.com/hzalaz))

## [2.0.0-rc.1](https://github.com/auth0/Lock.swift/tree/2.0.0-rc.1) (2016-12-16)
[Full Changelog](https://github.com/auth0/Lock.swift/compare/2.0.0-beta.2...2.0.0-rc.1)

**Added**
- Feature password policy [\#354](https://github.com/auth0/Lock.swift/pull/354) ([cocojoe](https://github.com/cocojoe))
- Enterprise single domain support [\#343](https://github.com/auth0/Lock.swift/pull/343) ([cocojoe](https://github.com/cocojoe))
- Enterprise Active Auth [\#342](https://github.com/auth0/Lock.swift/pull/342) ([cocojoe](https://github.com/cocojoe))
- Enterprise support with db [\#340](https://github.com/auth0/Lock.swift/pull/340) ([cocojoe](https://github.com/cocojoe))
- Enterprise support with social [\#339](https://github.com/auth0/Lock.swift/pull/339) ([cocojoe](https://github.com/cocojoe))
- Enterprise Connection only authentication [\#336](https://github.com/auth0/Lock.swift/pull/336) ([cocojoe](https://github.com/cocojoe))

**Changed**
- Compatibility updates against latest Auth0.Swift [\#356](https://github.com/auth0/Lock.swift/pull/356) ([cocojoe](https://github.com/cocojoe))
- Allow developer to get controller to show lock. [\#349](https://github.com/auth0/Lock.swift/pull/349) ([hzalaz](https://github.com/hzalaz))
- Migrate codebase to Swift 3.0 [\#345](https://github.com/auth0/Lock.swift/pull/345) ([cocojoe](https://github.com/cocojoe))

**Fixed**
- Fixed retain issues between presenter and views [\#355](https://github.com/auth0/Lock.swift/pull/355) ([cocojoe](https://github.com/cocojoe))

## [2.0.0-beta.2](https://github.com/auth0/Lock.swift/tree/2.0.0-beta.2) (2016-09-20)
[Full Changelog](https://github.com/auth0/Lock.swift/compare/2.0.0-beta.1...2.0.0-beta.2)

**Added**
- Username validation improvements [\#324](https://github.com/auth0/Lock.swift/pull/324) ([hzalaz](https://github.com/hzalaz))
- Custom oauth2 style [\#318](https://github.com/auth0/Lock.swift/pull/318) ([hzalaz](https://github.com/hzalaz))
- Custom Sign up fields [\#316](https://github.com/auth0/Lock.swift/pull/316) ([hzalaz](https://github.com/hzalaz))
- Include more lock options [\#313](https://github.com/auth0/Lock.swift/pull/313) ([hzalaz](https://github.com/hzalaz))
- Introduce Lock Style [\#312](https://github.com/auth0/Lock.swift/pull/312) ([hzalaz](https://github.com/hzalaz))
- Blur Header background [\#311](https://github.com/auth0/Lock.swift/pull/311) ([hzalaz](https://github.com/hzalaz))
- Load connections from Auth0 [\#310](https://github.com/auth0/Lock.swift/pull/310) ([hzalaz](https://github.com/hzalaz))

## [2.0.0-beta.1](https://github.com/auth0/Lock.swift/tree/2.0.0-beta.1) (2016-08-19)
[Full Changelog](https://github.com/auth0/Lock.swift/compare/f506b849083d9dc24c6d4236b3064d7cde7eac4e...2.0.0-beta.1)

Lock for iOS rewritten in *Swift*

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

### Configuration

In order to use Lock you need to provide your Auth0 Client Id and Domain, either with a *Property List* file

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
