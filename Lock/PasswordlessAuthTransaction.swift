// PasswordlessAuthTransaction.swift
//
// Copyright (c) 2017 Auth0 (http://auth0.com)
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

protocol PasswordlessAuthTransaction: CredentialAuthenticatable, Loggable {
    var connection: String { get }
    var options: Options { get }
    var identifier: String { get }
    var authentication: Authentication { get }
    var dispatcher: Dispatcher { get }
}

struct PasswordlessLinkTransaction: PasswordlessAuthTransaction {
    let connection: String
    let options: Options
    let identifier: String
    let authentication: Authentication
    let dispatcher: Dispatcher
}

extension PasswordlessAuthTransaction {

    func auth(withPasscode passcode: String, callback: @escaping (CredentialAuthError?) -> Void) {
        CredentialAuth(oidc: self.options.oidcConformant, realm: connection, authentication: self.authentication)
            .request(withIdentifier: identifier, password: passcode, options: self.options)
            .start { self.handle(identifier: self.identifier, result: $0, callback: callback) }
    }
}
