// ConnectionBuildable.swift
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

/**
 *  Allows to specify Lock connections
 */
public protocol ConnectionBuildable: Connections {

    /**
     Configure a database connection

     - parameter name:              name of the database connection
     - parameter requiresUsername:  if the database connection requires username
     - parameter usernameValidator: custom validator for username. Connection must allow username
     - parameter passwordValidator: password validator for the connection.
     - important: Only **ONE** database connection can be used so subsequent calls will override the previous value
     */
    mutating func database(name: String, requiresUsername: Bool, usernameValidator: UsernameValidator, passwordValidator: PasswordPolicyValidator)

    /**
     Adds a new social connection

     - parameter name:  name of the connection
     - parameter style: style used for the button used to trigger authentication
     - seeAlso: AuthStyle
     */
    mutating func social(name: String, style: AuthStyle)

    /**
     Adds a new oauth2 connection

     - parameter name:  name of the connection
     - parameter style: style used for the button used to trigger authentication
     - seeAlso: AuthStyle
     */
    mutating func oauth2(name: String, style: AuthStyle)

    /**
     Adds a new enterprise connection

     - parameter name:  name of the connection
     - parameter domain: array of enterprise domains
     - paramater style: style used when displayed as button
     */
    mutating func enterprise(name: String, domains: [String], style: AuthStyle)

    /**
     Adds a new enterprise connection

     - parameter name:  name of the connection
     - parameter domain: array of enterprise domains
     */
    mutating func enterprise(name: String, domains: [String])

    /**
     Adds a new passwordless connection

     - parameter name:  name of the connection
     - paramater strategy: name of the strategy, "sms" or "email"
     */
    mutating func passwordless(name: String, strategy: String)
}

public extension ConnectionBuildable {

    /**
     Configure a database connection

     - parameter name:              name of the database connection
     - parameter requiresUsername:  if the database connection requires username
     - parameter usernameValidator: custom validator for username. Connection must allow username and defaults to 1..15 characters
     - parameter passwordPolicy:    password policy for the database
     - important: Only **ONE** database connection can be used so subsequent calls will override the previous value
     */
    public mutating func database(name: String, requiresUsername: Bool, usernameValidator: UsernameValidator = UsernameValidator(), passwordPolicy: PasswordPolicy = .none) {
        self.database(name: name, requiresUsername: requiresUsername, usernameValidator: usernameValidator, passwordValidator: PasswordPolicyValidator(policy: passwordPolicy))
    }
}
