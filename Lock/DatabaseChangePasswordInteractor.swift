// DatabaseChangePasswordInteractor.swift
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

struct DatabaseChangePasswordInteractor: PasswordChangeable, Loggable {

    private var user: DatabaseUser
    let dispatcher: Dispatcher

    var newPassword: String?
    var validPassword: Bool = false
    var confirmed: Bool = false
    var email: String? { return self.user.email }

    let authentication: Authentication
    let connection: DatabaseConnection
    let options: Options
    let credentialAuth: CredentialAuth
    var passwordValidator: InputValidator { return self.connection.passwordValidator }

    init(connection: DatabaseConnection, authentication: Authentication, user: DatabaseUser, options: Options, dispatcher: Dispatcher) {
        self.authentication = authentication
        self.connection = connection
        self.user = user
        self.dispatcher = dispatcher
        self.options = options
        self.credentialAuth = CredentialAuth(oidc: options.oidcConformant, realm: connection.name, authentication: authentication)

        if self.options.allowShowPassword { self.confirmed = true }
    }

    mutating func update(_ input: InputField) throws {
        if case .password = input.type {
            self.newPassword = input.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            let error = self.passwordValidator.validate(self.newPassword)
            self.validPassword = error == nil
            if let error = error { throw error }
        } else if case .custom = input.type {
            confirmed = input.text == newPassword
            if !confirmed { throw PasswordChangeableError.noConfirmation }
        }
    }

    func changePassword(_ callback: @escaping (PasswordChangeableError?) -> Void) {
        guard
            let email = self.user.email, self.user.validEmail,
            let oldPassword = self.user.password, self.user.validPassword,
            let newPassword = self.newPassword, self.validPassword, self.confirmed
            else { return callback(.nonValidInput) }

        self.authentication
            .changePassword(email: email, oldPassword: oldPassword, newPassword: newPassword, connection: self.connection.name)
            .start {
                switch $0 {
                case .failure(let cause as AuthenticationError) where cause.code == "change_password_error":
                    callback(.policyFail(cause.description.uppercased()))
                    self.dispatcher.dispatch(result: .error(PasswordChangeableError.policyFail(cause.description)))
                case .failure:
                    callback(.changeFailed)
                    self.dispatcher.dispatch(result: .error(PasswordChangeableError.changeFailed))
                case .success:
                    self.dispatcher.dispatch(result: .changePassword(email))
                    callback(nil)
                    self.credentialAuth
                        .request(withIdentifier: email, password: newPassword, options: self.options)
                        .start { self.handle(identifier: email, result: $0, callback: { _ in }) }
                }
        }
    }
}
