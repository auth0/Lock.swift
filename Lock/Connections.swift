// Connections.swift
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

public protocol Connections {
    var database: DatabaseConnection? { get }
    var oauth2: [OAuth2Connection] { get }
    var enterprise: [EnterpriseConnection] {get}
    var passwordless: [PasswordlessConnection] { get }

    var isEmpty: Bool { get }

    /**
     Select only the connections whose names are in the array

     - parameter names: names of the connections to keep

     - returns: filtered connections
     */
    func select(byNames names: [String]) -> Self
}

public struct DatabaseConnection {
    public let name: String
    public let requiresUsername: Bool
    public let usernameValidator: UsernameValidator
    public let passwordValidator: PasswordPolicyValidator

    public init(name: String, requiresUsername: Bool, usernameValidator: UsernameValidator = UsernameValidator(), passwordValidator: PasswordPolicyValidator = PasswordPolicyValidator(policy: .none)) {
        self.name = name
        self.requiresUsername =  requiresUsername
        self.usernameValidator = usernameValidator
        self.passwordValidator = passwordValidator
    }
}

public protocol OAuth2Connection {
    var name: String { get }
    var style: AuthStyle { get }
}

public struct SocialConnection: OAuth2Connection {
    public let name: String
    public let style: AuthStyle
}

public struct EnterpriseConnection: OAuth2Connection {
    public let name: String
    public let domains: [String]
    public let style: AuthStyle

    init(name: String, domains: [String], style: AuthStyle? = nil) {
        self.name = name
        self.domains = domains
        self.style = style ?? AuthStyle(name: name)
    }
}

public struct PasswordlessConnection {
    public let name: String
    public let strategy: String

    public init(name: String, strategy: String) {
        self.name = name
        self.strategy = strategy
    }
}
