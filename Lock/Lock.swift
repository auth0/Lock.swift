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

        /// Callback used to notify lock authentication outcome
    public typealias AuthenticationCallback = Result -> ()

    static let sharedInstance = Lock()

    let authentication: Authentication
    let webAuth: WebAuth

    private var connectionBuilder: ConnectionBuildable? = nil
    var connections: Connections? { return self.connectionBuilder }

    private var optionsBuilder: OptionBuildable = LockOptions()
    var options: Options { return self.optionsBuilder }

    var callback: AuthenticationCallback = {_ in }

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
        var authentication = authentication
        var webAuth = webAuth
        let name = "Lock.swift"
        // FIXME:- Uncomment when stable is ready
//        let bundle = _BundleHack.bundle
//        let version = bundle.infoDictionary?["CFBundleShortVersionString"] as? String ?? "2.0.0-alpha.0"
        let version = "2.0.0-beta.1"
        authentication.using(inLibrary: name, version: version)
        webAuth.using(inLibrary: name, version: version)
        self.authentication = authentication
        self.webAuth = webAuth
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
    public static func classic(clientId clientId: String, domain: String) -> Lock {
        return Lock(authentication: Auth0.authentication(clientId: clientId, domain: domain), webAuth: Auth0.webAuth(clientId: clientId, domain: domain))
    }

    var controller: LockViewController {
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
        controller.presentViewController(self.controller, animated: true, completion: nil)
    }

    /**
     Specify what connections Lock should use programatically

     - parameter closure: closure that will specify the connections to be used by Lock

     - returns: Lock itself for chaining
     */
    public func connections(closure: (inout ConnectionBuildable) -> ()) -> Lock {
        var connections: ConnectionBuildable = OfflineConnections()
        closure(&connections)
        self.connectionBuilder = connections
        return self
    }

    /**
     Configure Lock options

     - parameter closure: closure that will configure Lock options

     - returns: Lock itself for chaining
     */
    public func options(closure: (inout OptionBuildable) -> ()) -> Lock {
        var options: OptionBuildable = LockOptions()
        closure(&options)
        self.optionsBuilder = options
        return self
    }

    /**
     Register a callback for the outcome of the Authentication

     - parameter callback: callback called when the user is authenticated, lock is dismissed or an unrecoverable error ocurrs

     - returns: Lock itself for chaining
     */
    public func on(callback: AuthenticationCallback) -> Lock {
        self.callback = callback
        return self
    }

    /**
     Resumes an Auth session from Safari, e.g. when authenticating with Facebook.
     
     This method should be called from your `AppDelegate`
     
     ```
     func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        return Lock.resumeAuth(url, options: options)
     }

     ```

     - parameter url:     url of the Auth session received in `AppDelegate`
     - parameter options: options used to open the app with the given URL

     - returns: true if the url matched an ongoing Auth session, false otherwise
     */
    public static func resumeAuth(url: NSURL, options: [String: AnyObject]) -> Bool {
        return Auth0.resumeAuth(url, options: options)
    }
}

public protocol Connections {
    var database: DatabaseConnection? { get }
    var oauth2: [OAuth2Connection] { get }
}

/**
 *  Allows to specify Lock connections
 */
public protocol ConnectionBuildable: Connections {

    /**
     Configure a database connection

     - parameter name:             name of the database connection
     - parameter requiresUsername: if the database connection requires username
     - important: Only **ONE** database connection can be used so subsequent calls will override the previous value
     */
    mutating func database(name name: String, requiresUsername: Bool)

    /**
     Adds a new social connection

     - parameter name:  name of the connection
     - parameter style: style used for the button used to trigger authentication
     - seeAlso: AuthStyle
     */
    mutating func social(name name: String, style: AuthStyle)
}

struct OfflineConnections: ConnectionBuildable {

    var database: DatabaseConnection? = nil
    var oauth2: [OAuth2Connection] = []

    mutating func database(name name: String, requiresUsername: Bool) {
        self.database = DatabaseConnection(name: name, requiresUsername: requiresUsername)
    }

    mutating func social(name name: String, style: AuthStyle) {
        let social = SocialConnection(name: name, style: style)
        self.oauth2.append(social)
    }
}

public protocol Options {
    var closable: Bool { get }
    var termsOfServiceURL: NSURL { get }
    var privacyPolicyURL: NSURL { get }
    var logLevel: LoggerLevel { get }
    var loggerOutput: LoggerOutput? { get }
    var logHttpRequest: Bool { get }
}

/**
 *  Lock options
 */
public protocol OptionBuildable: Options {

        /// Allows Lock to be dismissed. By default is false
    var closable: Bool { get set }

        /// ToS URL. By default is Auth0's
    var termsOfServiceURL: NSURL { get set }

        /// Privacy Policy URL. By default is Auth0's
    var privacyPolicyURL: NSURL { get set }

        /// Log level for Lock. By default is `Off`
    var logLevel: LoggerLevel { get set }

        /// Log output used when Log is enabled. By default a simple `print` statement is used.
    var loggerOutput: LoggerOutput? { get set }

        /// If request from Auth0.swift should be logged or not
    var logHttpRequest: Bool { get set }
}

extension OptionBuildable {

        /// ToS URL. By default is Auth0's
    var termsOfService: String {
        get {
            return self.termsOfServiceURL.absoluteString
        }
        set {
            guard let url = NSURL(string: newValue) else { return } // FIXME: log error
            self.termsOfServiceURL = url
        }
    }

        /// Privacy Policy URL. By default is Auth0's
    var privacyPolicy: String {
        get {
            return self.privacyPolicyURL.absoluteString
        }
        set {
            guard let url = NSURL(string: newValue) else { return } // FIXME: log error
            self.privacyPolicyURL = url
        }
    }
}

struct LockOptions: OptionBuildable {
    var closable: Bool = false
    var termsOfServiceURL: NSURL = NSURL(string: "https://auth0.com/terms")!
    var privacyPolicyURL: NSURL = NSURL(string: "https://auth0.com/privacy")!
    var logLevel: LoggerLevel = .Off
    var loggerOutput: LoggerOutput? = nil
    var logHttpRequest: Bool = false {
        didSet {
            Auth0.enableLogging(enabled: self.logHttpRequest)
        }
    }
}

public struct DatabaseConnection {
    public let name: String
    public let requiresUsername: Bool
}

public protocol OAuth2Connection {
    var name: String { get }
    var style: AuthStyle { get }
}

public struct SocialConnection: OAuth2Connection {
    public let name: String
    public let style: AuthStyle
}

public enum Result {
    case Success(Credentials)
    case Failure(ErrorType)
    case Cancelled
}
