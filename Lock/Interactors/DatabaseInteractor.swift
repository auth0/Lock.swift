// DatabaseInteractor.swift
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

struct DatabaseInteractor: CredentialAuthenticatable {

    private(set) var email: String? = nil
    private(set) var username: String? = nil
    private(set) var password: String? = nil

    private(set) var validEmail: Bool = false
    private(set) var validUsername: Bool = false
    private(set) var validPassword: Bool = false

    let authentication: Authentication

    init(authentication: Authentication) {
        self.authentication = authentication
    }

    mutating func update(attribute: CredentialAttribute, value: String?) throws {
        switch attribute {
        case .Email:
            self.email = value
        case .Username:
            self.username = value
        case .Password:
            self.password = value
        }
    }

    func login(callback: (AuthenticatableError?) -> ()) {
        guard
            let identifier = self.email ?? self.username,
            let password = self.password
            else { return callback(.NonValidInput) }
        self.authentication
            .login(usernameOrEmail: identifier, password: password, connection: "Username-Password-Authentication")
            .start { result in
                var error: AuthenticatableError? = nil
                if case .Failure = result {
                    error = .CouldNotLogin
                }
                callback(error)
            }
    }
}