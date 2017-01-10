// Lock.swift
//
// Copyright (c) 2016 Auth0 (http://auth0.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import Auth0

/// Lock main class to configure and show the native widget
public class Lock: NSObject {

    static let sharedInstance = Lock()

    private(set) var authentication: Authentication
    private(set) var webAuth: WebAuth

    var connectionProvider: ConnectionProvider = ConnectionProvider(local: OfflineConnections(), allowed: [])
    var connections: Connections { return self.connectionProvider.connections }

    var optionsBuilder: OptionBuildable = LockOptions()
    var options: Options { return self.optionsBuilder }

    var observerStore = ObserverStore()

    var style: Style = Style()

    override convenience init() {
        self.init(authentication: Auth0.authentication(), webAuth: Auth0.webAuth())
    }

    /**
     Creates a new Lock instance

     - parameter authentication: Auth0 authentication API client
     - parameter webAuth:        Auth0 webAuth client

     - returns: a newly created Lock instance
     */
    required public init(authentication: Authentication, webAuth: WebAuth) {
        let (authenticationWithTelemetry, webAuthWithTelemetry) = telemetryFor(authentication: authentication, webAuth: webAuth)
        self.authentication = authenticationWithTelemetry
        self.webAuth = webAuthWithTelemetry
    }

    /**
     Creates a new Lock instance loading Auth0 client info from `Auth0.plist` file in main bundle

     - returns: a newly created Lock instance
     */
    public static func classic() -> Lock {
        return Lock()
    }

    /**
     Creates a new Lock instance using clientId and domain

     - parameter clientId: Auth0 clientId of your application
     - parameter domain:   Your Auth0 account domain

     - returns: a newly created Lock instance
     */
    public static func classic(clientId: String, domain: String) -> Lock {
        return Lock(authentication: Auth0.authentication(clientId: clientId, domain: domain), webAuth: Auth0.webAuth(clientId: clientId, domain: domain))
    }

    public var controller: LockViewController {
        return LockViewController(lock: self)
    }

    var logger: Logger {
        let logger = Logger.sharedInstance
        if let output = options.loggerOutput {
            logger.output = output
        }
        logger.level = options.logLevel
        return logger
    }

    /**
     Presents Lock from the given controller

     - parameter controller: controller from where Lock is presented
     */
    public func present(from controller: UIViewController) {
        if let error = self.optionsBuilder.validate() {
            self.observerStore.onFailure(error)
            // FIXME: Fail violently
        } else {
            controller.present(self.controller, animated: true, completion: nil)
        }
    }

    /**
     Specify what connections Lock should use programatically

     - parameter closure: closure that will specify the connections to be used by Lock

     - returns: Lock itself for chaining
     */
    public func withConnections(_ closure: (inout ConnectionBuildable) -> ()) -> Lock {
        var connections: ConnectionBuildable = OfflineConnections()
        closure(&connections)
        let allowed = self.connectionProvider.allowed
        self.connectionProvider = ConnectionProvider(local: connections, allowed: allowed)
        return self
    }

    /**
     Specify what connections should be used by Lock. 
     By default it will use all connections enabled or if an empty list is used

     - parameter allowedConnections: list of connection names to use

     - returns: Lock itself for chaining
     */
    public func allowedConnections(_ allowedConnections: [String]) -> Lock {
        let connections = self.connectionProvider.connections
        self.connectionProvider = ConnectionProvider(local: connections, allowed: allowedConnections)
        return self
    }

    /**
     Configure Lock options

     - parameter closure: closure that will configure Lock options

     - returns: Lock itself for chaining
     */
    public func withOptions(_ closure: (inout OptionBuildable) -> ()) -> Lock {
        var builder: OptionBuildable = self.optionsBuilder
        closure(&builder)
        self.optionsBuilder = builder
        _ = self.authentication.logging(enabled: self.options.logHttpRequest)
        _ = self.webAuth.logging(enabled: self.options.logHttpRequest)
        return self
    }

    /**
     Customise Lock style

     ```
     Lock
        .classic()
        .style {
            $0.title = "Auth0 Inc."
            $0.primaryColor = UIColor.orangeColor()
            $0.logo = LazyImage(name: "icn_auth0")
        }
     ```

     - parameter closure: closure used to customize Lock style

     - returns: Lock itself for chaining
     */
    public func withStyle(_ closure: (inout Style) -> ()) -> Lock {
        var style = self.style
        closure(&style)
        self.style = style
        return self
    }

    /**
     Register a callback to recieve the result of a successful AuthN/AuthZ.
     
     - parameter callback: called on successful AuthN/AuthZ
     
     - returns: Lock itself for chaining
    */
    public func onAuth(callback: @escaping (Credentials) -> ()) -> Lock {
        self.observerStore.onAuth = callback
        return self
    }

    /**
     Register a callback to recieve Lock unrecoverable errors

     - parameter callback: called on every unrecoverable error

     - returns: Lock itself for chaining
     */
    public func onError(callback: @escaping (Error) -> ()) -> Lock {
        self.observerStore.onFailure = callback
        return self
    }

    /**
     Register a callback to be notified when the user closes Lock when `closable` option is `true`

     - parameter callback: called when the user closes Lock

     - returns: Lock itself for chaining
     */
    public func onCancel(callback: @escaping () -> ()) -> Lock {
        self.observerStore.onCancel = callback
        return self
    }

    /**
     Register a callback to be notified when a user signs up when login after signup is disabled.
     The callback will yield the new user email and additional attributes like username.
     
     - parameter callback: called when a user signs up
     
     - returns: Lock itself for chaining
    */
    public func onSignUp(callback: @escaping (String, [String: Any]) -> ()) -> Lock {
        self.observerStore.onSignUp = callback
        return self
    }

        /// Lock's Bundle. Useful for getting bundled resources like images.
    public static var bundle: Bundle {
        return bundleForLock()
    }

    /**
     Resumes an Auth session from Safari, e.g. when authenticating with Facebook.
     
     This method should be called from your `AppDelegate`
     
     ```
     func application(app: UIApplication, openURL url: NSURL, options: [String : Any]) -> Bool {
        return Lock.resumeAuth(url, options: options)
     }

     ```

     - parameter url:     url of the Auth session received in `AppDelegate`
     - parameter options: options used to open the app with the given URL

     - returns: true if the url matched an ongoing Auth session, false otherwise
     */
    public static func resumeAuth(_ url: URL, options: [UIApplicationOpenURLOptionsKey: Any]) -> Bool {
        return Auth0.resumeAuth(url, options: options)
    }
}

struct ConnectionProvider {
    let local: Connections
    let allowed: [String]

    var connections: Connections { return local.select(byNames: allowed) }
}

public enum UnrecoverableError: Error {
    case invalidClientOrDomain
    case clientWithNoConnections
    case missingDatabaseConnection
    case invalidOptions(cause: String)
}

private func telemetryFor(authentication: Authentication, webAuth: WebAuth) -> (Authentication, WebAuth) {
    var authentication = authentication
    var webAuth = webAuth
    let name = "Lock.swift"
    // FIXME:- Uncomment when stable is ready since XCode wont' accept a tag in the version
    //        let bundle = _BundleHack.bundle
    //        let version = bundle.infoDictionary?["CFBundleShortVersionString"] as? String ?? "2.0.0-alpha.0"
    let version = "2.0.0-rc.2"
    authentication.using(inLibrary: name, version: version)
    webAuth.using(inLibrary: name, version: version)
    return (authentication, webAuth)
}
