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

struct DatabaseChangePasswordInteractor {

    private var user: DatabaseUser
    private let dispatcher: Dispatcher

    var newPassword: String = ""
    var validPassword: Bool = false

    let authentication: Authentication
    let connection: DatabaseConnection
    var passwordValidator: InputValidator { return self.connection.passwordValidator }
    var requiredValidator = NonEmptyValidator()

    init(connection: DatabaseConnection, authentication: Authentication, user: DatabaseUser, dispatcher: Dispatcher) {
        self.authentication = authentication
        self.connection = connection
        self.user = user
        self.dispatcher = dispatcher
    }

    mutating func update(_ attribute: UserAttribute, value: String) throws {
        if case .password(let enforcingPolicy) = attribute {
            self.newPassword = value.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            let error = enforcingPolicy ? self.passwordValidator.validate(self.newPassword) : self.requiredValidator.validate(self.newPassword)
            self.validPassword = error == nil
            if let error = error { throw error }
        }
    }

    func changePassword(_ callback: @escaping (PasswordChangeableError?) -> Void) {
        guard let email = self.user.email, self.user.validEmail else { return callback(.invalidEmail) }
        guard let oldPassword = self.user.password, self.user.validPassword else { return callback(.invalidPassword) }

        self.authentication
            .changePassword(email: email, oldPassword: oldPassword, newPassword: self.newPassword, connection: self.connection.name)
            .start {
                guard case .success = $0 else {
                    callback(.changeFailed)
                    return self.dispatcher.dispatch(result: .error(PasswordChangeableError.changeFailed))
                }
                //self.dispatcher.dispatch(result: .forgotPassword(email))
                callback(nil)
        }
    }
}
