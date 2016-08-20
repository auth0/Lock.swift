# Change Log

## [2.0.0-beta.1](https://github.com/auth0/Lock.iOS-OSX/tree/2.0.0-beta.1) (2016-08-19)
[Full Changelog](https://github.com/auth0/Lock.iOS-OSX/compare/f506b849083d9dc24c6d4236b3064d7cde7eac4e...2.0.0-beta.1)

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
