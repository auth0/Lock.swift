// MultifactorInteractor.swift
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

struct MultifactorInteractor: MultifactorAuthenticatable, Loggable {

    private var connection: DatabaseConnection
    private var user: DatabaseUser
    private var authentication: Authentication

    private(set) var code: String?
    private(set) var validCode: Bool = false
    let dispatcher: Dispatcher

    private let validator = OneTimePasswordValidator()

    private let options: Options

    init(user: DatabaseUser, authentication: Authentication, connection: DatabaseConnection, options: Options, dispatcher: Dispatcher) {
        self.user = user
        self.authentication = authentication
        self.connection = connection
        self.dispatcher = dispatcher
        self.options = options
    }

    mutating func setMultifactorCode(_ code: String?) throws {
        self.validCode = false
        self.code = code?.trimmingCharacters(in: CharacterSet.whitespaces)
        if let error = self.validator.validate(code) {
            throw error
        }
        self.validCode = true
    }

    func login(_ callback: @escaping (CredentialAuthError?) -> Void) {
        let identifier: String

        if let email = self.user.email, self.user.validEmail {
            identifier = email
        } else if let username = self.user.username, self.user.validUsername {
            identifier = username
        } else {
            return callback(.nonValidInput)
        }

        guard let password = self.user.password, self.user.validPassword else { return callback(.nonValidInput) }
        guard let code = self.code, self.validCode else { return callback(.nonValidInput) }
        let database = self.connection.name

        // FIXME: MFA support for password-realm
        guard !self.options.oidcConformant else { return callback(.couldNotLogin) }
        authentication.login(
                usernameOrEmail: identifier,
                password: password,
                multifactorCode: code,
                connection: database,
                scope: self.options.scope,
                parameters: self.options.parameters
            ).start { self.handle(identifier: identifier, result: $0, callback: callback) }
    }
}
