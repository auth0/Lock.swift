// LockOptions.swift
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

struct LockOptions: OptionBuildable {
    var closable: Bool = false
    var termsOfServiceURL: URL = URL(string: "https://auth0.com/terms")!
    var privacyPolicyURL: URL = URL(string: "https://auth0.com/privacy")!
    var supportURL: URL?
    var logLevel: LoggerLevel = .off
    var loggerOutput: LoggerOutput?
    var logHttpRequest: Bool = false
    var scope: String = "openid"
    var connectionScope: [String: String] = [:]
    var parameters: [String : Any] = [:]
    var allow: DatabaseMode = [.Login, .Signup, .ResetPassword]
    var autoClose: Bool = true
    var initialScreen: DatabaseScreen = .login
    var usernameStyle: DatabaseIdentifierStyle = [.Username, .Email]
    var customSignupFields: [CustomTextField] = []
    var loginAfterSignup: Bool = true

    var activeDirectoryEmailAsUsername: Bool = false
    var enterpriseConnectionUsingActiveAuth: [String] = []

    var oidcConformant: Bool = false
    var audience: String?

    var passwordlessMethod: PasswordlessMethod = .code
    var passwordManager: OnePassword = OnePassword()
    var allowShowPassword: Bool = true
}
