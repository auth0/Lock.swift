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
    var connections: ConnectionBuildable? = nil
    var options: OptionBuildable? = nil
    var callback: AuthenticationCallback = {_ in }

    override convenience init() {
        self.init(authentication: Auth0.authentication())
    }

    required public init(authentication: Authentication) {
        Auth0.using(inLibrary: "Lock.swift", version: "2.0.0-alpha.1") // FIXME: Use correct version from bundle
        self.authentication = authentication
    }

    public static func login() -> Lock {
        return Lock()
    }

    public static func login(clientId: String, domain: String) -> Lock {
        return Lock(authentication: Auth0.authentication(clientId: clientId, domain: domain))
    }

    var controller: LockViewController {
        return LockViewController(lock: self)
    }

    public func present(from controller: UIViewController) {
        controller.presentViewController(self.controller, animated: true, completion: nil)
    }

    public func connections(closure: (() -> ConnectionBuildable) -> ConnectionBuildable) -> Lock {
        self.connections = closure { return OfflineConnections() }
        return self
    }

    public func options(closure: (inout OptionBuildable) -> ()) -> Lock {
        var options: OptionBuildable = LockOptions()
        closure(&options)
        self.options = options
        return self
    }

    public func on(callback: AuthenticationCallback) -> Lock {
        self.callback = callback
        return self
    }
}

public protocol Connections {
    var database: DatabaseConnection? { get }
}

public protocol ConnectionBuildable: Connections {
    mutating func database(name name: String, requiresUsername: Bool) -> Self
}

struct OfflineConnections: ConnectionBuildable {

    var database: DatabaseConnection? = nil

    mutating func database(name name: String, requiresUsername: Bool) -> OfflineConnections {
        self.database = DatabaseConnection(name: name, requiresUsername: requiresUsername)
        return self
    }

}

public protocol Options {
    var closable: Bool { get }
}

public protocol OptionBuildable: Options {
    mutating func closable(closable: Bool) -> Self
}

struct LockOptions: OptionBuildable {
    var closable: Bool = false

    mutating func closable(closable: Bool) -> LockOptions {
        self.closable = closable
        return self
    }
}

public struct DatabaseConnection {
    public let name: String
    public let requiresUsername: Bool
}

public enum Result {
    case Success(Credentials)
    case Failure(ErrorType)
    case Cancelled
}
