// Options.swift
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

public protocol Options {
    var closable: Bool { get }

    var termsOfServiceURL: URL { get }
    var privacyPolicyURL: URL { get }
    var supportURL: URL? { get }

    var logLevel: LoggerLevel { get }
    var loggerOutput: LoggerOutput? { get }
    var logHttpRequest: Bool { get }

    var scope: String { get }
    var connectionScope: [String: String] { get }
    var parameters: [String: Any] { get }
    var allow: DatabaseMode { get }
    var autoClose: Bool { get }
    var initialScreen: DatabaseScreen { get }
    var usernameStyle: DatabaseIdentifierStyle { get }
    var customSignupFields: [CustomTextField] { get }
    var loginAfterSignup: Bool { get }

    var activeDirectoryEmailAsUsername: Bool { get }
    var enterpriseConnectionUsingActiveAuth: [String] { get }

    var oidcConformant: Bool { get }
    var audience: String? { get }

    var passwordlessMethod: PasswordlessMethod { get }
    var passwordManager: OnePassword { get }
    var allowShowPassword: Bool { get }
}
