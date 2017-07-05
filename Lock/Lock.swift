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

    static let shared = Lock()

    private(set) var authentication: Authentication
    private(set) var webAuth: WebAuth

    private(set) var allowedConnectionNames: [String] = []
    var clientConnections: Connections = OfflineConnections()
    var connections: Connections { return self.clientConnections.select(byNames: self.allowedConnectionNames) }

    var optionsBuilder: OptionBuildable = LockOptions()
    var options: Options { return self.optionsBuilder }

    var classicMode: Bool

    var observerStore = ObserverStore()

    var nativeHandlers: [String: AuthProvider] = [:]

    var style: Style = Style()

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

    override convenience init() {
        self.init(authentication: Auth0.authentication(), webAuth: Auth0.webAuth())
    }

    /**
     Creates a new Lock classic instance

     - parameter authentication: Auth0 authentication API client
     - parameter webAuth:        Auth0 webAuth client

     - returns: a newly created Lock instance
     */
    required public init(authentication: Authentication, webAuth: WebAuth, classic: Bool = true) {
        let (authenticationWithTelemetry, webAuthWithTelemetry) = telemetryFor(authentication: authentication, webAuth: webAuth)
        self.authentication = authenticationWithTelemetry
        self.webAuth = webAuthWithTelemetry
        self.classicMode = classic
    }

    /**
     Creates a new Classic Lock instance loading Auth0 client info from `Auth0.plist` file in main bundle.

     The property list file should contain the following sections:

     - CliendId: your Auth0 client identifier
     - Domain: your Auth0 domain

     - returns: a newly created Lock instance
     */
    public static func classic() -> Lock {
        return Lock()
    }

    /**
     Creates a new Lock passwordless instance loading Auth0 client info from `Auth0.plist` file in main bundle.

     The property list file should contain the following sections:

     - CliendId: your Auth0 client identifier
     - Domain: your Auth0 domain

     - returns: a newly created Lock Passwordless instance
     - requires: Legacy Grant `http://auth0.com/oauth/legacy/grant-type/ro`. Check [our documentation](https://auth0.com/docs/clients/client-grant-types) for more info and how to enable it.
     */
    public static func passwordless() -> Lock {
        return self.init(authentication: Auth0.authentication(), webAuth: Auth0.webAuth(), classic: false)
    }

    /**
     Creates a new Lock passwordless instance using clientId and domain

     - parameter clientId: Auth0 clientId of your application
     - parameter domain:   Your Auth0 account domain

     - returns: a newly created Lock passwordless instance
     - requires: Legacy Grant `http://auth0.com/oauth/legacy/grant-type/ro`. Check [our documentation](https://auth0.com/docs/clients/client-grant-types) for more info and how to enable it.
     */
    public static func passwordless(clientId: String, domain: String) -> Lock {
        return Lock(authentication: Auth0.authentication(clientId: clientId, domain: domain), webAuth: Auth0.webAuth(clientId: clientId, domain: domain), classic: false)
    }

    /**
     Creates a new Lock classic instance using clientId and domain

     - parameter clientId: Auth0 clientId of your application
     - parameter domain:   Your Auth0 account domain

     - returns: a newly created Lock classic instance
     */
    public static func classic(clientId: String, domain: String) -> Lock {
        return Lock(authentication: Auth0.authentication(clientId: clientId, domain: domain), webAuth: Auth0.webAuth(clientId: clientId, domain: domain))
    }

    /**
     Specify what connections Lock should use programatically

     - parameter closure: closure that will specify the connections to be used by Lock

     - returns: Lock itself for chaining
     */
    public func withConnections(_ closure: (inout ConnectionBuildable) -> Void) -> Lock {
        var connections: ConnectionBuildable = OfflineConnections()
        closure(&connections)
        self.clientConnections = connections
        return self
    }

    /**
     Specify what connections should be used by Lock.
     By default it will use all connections enabled or if an empty list is used

     - parameter allowedConnections: list of connection names to use

     - returns: Lock itself for chaining
     */
    public func allowedConnections(_ allowedConnections: [String]) -> Lock {
        self.allowedConnectionNames = allowedConnections
        return self
    }

    /**
     Configure Lock options

     - parameter closure: closure that will configure Lock options

     - returns: Lock itself for chaining
     */
    public func withOptions(_ closure: (inout OptionBuildable) -> Void) -> Lock {
        var builder: OptionBuildable = self.optionsBuilder
        closure(&builder)
        self.optionsBuilder = builder
        self.observerStore.options = self.options
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
            $0.primaryColor = .orange
            $0.logo = LazyImage(name: "icn_auth0")
        }
     ```

     - parameter closure: closure used to customize Lock style

     - returns: Lock itself for chaining
     */
    public func withStyle(_ closure: (inout Style) -> Void) -> Lock {
        var style = self.style
        closure(&style)
        self.style = style
        return self
    }

    /**
     Register a callback to receive the result of a successful AuthN/AuthZ.

     - parameter callback: called on successful AuthN/AuthZ

     - returns: Lock itself for chaining
    */
    public func onAuth(callback: @escaping (Credentials) -> Void) -> Lock {
        self.observerStore.onAuth = callback
        return self
    }

    /**
     Register a callback to receive Lock unrecoverable errors

     - parameter callback: called on every unrecoverable error

     - returns: Lock itself for chaining
     */
    public func onError(callback: @escaping (Error) -> Void) -> Lock {
        self.observerStore.onFailure = callback
        return self
    }

    /**
     Register a callback to be notified when the user closes Lock when `closable` option is `true`

     - parameter callback: called when the user closes Lock

     - returns: Lock itself for chaining
     */
    public func onCancel(callback: @escaping () -> Void) -> Lock {
        self.observerStore.onCancel = callback
        return self
    }

    /**
     Register a callback to be notified when a user signs up when login after signup is disabled.
     The callback will yield the new user email and additional attributes like username.

     - parameter callback: called when a user signs up with the email and user attributes.

     - returns: Lock itself for chaining
    */
    public func onSignUp(callback: @escaping (String, [String: Any]) -> Void) -> Lock {
        self.observerStore.onSignUp = callback
        return self
    }

    /**
     Presents Lock from the given controller

     - parameter controller: controller from where Lock is presented
     */
    public func present(from controller: UIViewController) {
        if let error = self.optionsBuilder.validate(classic: self.classicMode) {
            self.observerStore.onFailure(error)
            // FIXME: Fail violently
        } else {
            controller.present(self.controller, animated: true, completion: nil)
        }
    }

    /**
     Register a callback to be notified when a user requests passwordless authentication.
     The callback will yield the user identifier.

     - parameter callback: called when a user attempts passwordless authentication

     - returns: Lock itself for chaining
     */
    public func onPasswordless(callback: @escaping (String) -> Void) -> Lock {
        self.observerStore.onPasswordless = callback
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

    /**
     Register an AuthProvider to be used for connection, e.g. When using native social integration plugins such as
     Lock-Facebook to provide native authentication.

     - parameter name: connection name that will use the specified auth provider
     - parameter handler: the auth provider to use
     
     - returns: Lock itself for chaining
     */
    public func nativeAuthentication(forConnection name: String, handler: AuthProvider) -> Lock {
        self.nativeHandlers[name] = handler
        return self
    }

    /**
     Continues an activity from a universal link.

     This method should be called from your `AppDelegate`

     ```
     func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        return return Lock.continueAuth(using: userActivity)
     }

     ```

     - parameter userActivity: the NSUserActivity to handle.

     - returns: true if the link is of the appropriate format, false otherwise
     */
    public static func continueAuth(using userActivity: NSUserActivity) -> Bool {
        return PasswordlessActivity.shared.continueAuth(withActivity: userActivity)
    }
}

private func telemetryFor(authentication: Authentication, webAuth: WebAuth) -> (Authentication, WebAuth) {
    var authentication = authentication
    var webAuth = webAuth
    let name = "Lock.swift"
    let version = bundleForLock().infoDictionary?["CFBundleShortVersionString"] as? String ?? "2.0.0"
    authentication.using(inLibrary: name, version: version)
    webAuth.using(inLibrary: name, version: version)
    return (authentication, webAuth)
}
