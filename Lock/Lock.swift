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

public class Lock: NSObject {

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

    required public init(authentication: Authentication, webAuth: WebAuth) {
        var authentication = authentication
        var webAuth = webAuth
        let name = "Lock.swift"
        let bundle = _BundleHack.bundle
        let version = bundle.infoDictionary?["CFBundleShortVersionString"] as? String ?? "2.0.0-alpha.0"
        authentication.using(inLibrary: name, version: version)
        webAuth.using(inLibrary: name, version: version)
        self.authentication = authentication
        self.webAuth = webAuth
    }

    public static func login() -> Lock {
        return Lock()
    }

    public static func login(clientId: String, domain: String) -> Lock {
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

    public func present(from controller: UIViewController) {
        controller.presentViewController(self.controller, animated: true, completion: nil)
    }

    public func connections(closure: (inout ConnectionBuildable) -> ()) -> Lock {
        var connections: ConnectionBuildable = OfflineConnections()
        closure(&connections)
        self.connectionBuilder = connections
        return self
    }

    public func options(closure: (inout OptionBuildable) -> ()) -> Lock {
        var options: OptionBuildable = LockOptions()
        closure(&options)
        self.optionsBuilder = options
        return self
    }

    public func on(callback: AuthenticationCallback) -> Lock {
        self.callback = callback
        return self
    }

    public static func resumeAuth(url: NSURL, options: [String: AnyObject]) -> Bool {
        return Auth0.resumeAuth(url, options: options)
    }
}

public protocol Connections {
    var database: DatabaseConnection? { get }
    var oauth2: [OAuth2Connection] { get }
}

public protocol ConnectionBuildable: Connections {
    mutating func database(name name: String, requiresUsername: Bool)
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

public protocol OptionBuildable: Options {
    var closable: Bool { get set }
    var termsOfServiceURL: NSURL { get set }
    var privacyPolicyURL: NSURL { get set }
    var logLevel: LoggerLevel { get set }
    var loggerOutput: LoggerOutput? { get set }
    var logHttpRequest: Bool { get set }
}

extension OptionBuildable {
    var termsOfService: String {
        get {
            return self.termsOfServiceURL.absoluteString
        }
        set {
            guard let url = NSURL(string: newValue) else { return } // FIXME: log error
            self.termsOfServiceURL = url
        }
    }

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
