// DatabasePasswordInteractor.swift
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

struct DatabasePasswordInteractor: PasswordRecoverable {

    private var user: DatabaseUser
    private let dispatcher: Dispatcher

    var email: String? { return self.user.email }
    var validEmail: Bool { return self.user.validEmail }

    let authentication: Authentication
    let connections: Connections
    let emailValidator: InputValidator = EmailValidator()

    init(connections: Connections, authentication: Authentication, user: DatabaseUser, dispatcher: Dispatcher) {
        self.authentication = authentication
        self.connections = connections
        self.user = user
        self.dispatcher = dispatcher
    }

    mutating func updateEmail(_ value: String?) throws {
        self.user.email = value?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let error = self.emailValidator.validate(value)
        self.user.validEmail = error == nil
        if let error = error { throw error }
    }

    func requestEmail(_ callback: @escaping (PasswordRecoverableError?) -> Void) {
        guard let email = self.email else { return callback(.nonValidInput) }
        guard let connection = self.connections.database?.name else { return callback(.noDatabaseConnection) }

        self.authentication
            .resetPassword(email: email, connection: connection)
            .start {
                guard case .success = $0 else {
                    callback(.emailNotSent)
                    return self.dispatcher.dispatch(result: .error(PasswordRecoverableError.emailNotSent))
                }
                self.dispatcher.dispatch(result: .forgotPassword(email))
                callback(nil)
        }
    }
}
