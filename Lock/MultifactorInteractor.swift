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

struct MultifactorInteractor: MultifactorAuthenticatable {

    private var connection: DatabaseConnection
    private var user: DatabaseUser
    private var authentication: Authentication
    private var onAuthentication: Credentials -> ()

    private(set) var code: String? = nil
    private(set) var validCode: Bool = false

    private let validator = OneTimePasswordValidator()

    init(user: DatabaseUser, authentication: Authentication, connection: DatabaseConnection, callback: Credentials -> ()) {
        self.user = user
        self.authentication = authentication
        self.connection = connection
        self.onAuthentication = callback
    }

    mutating func setMultifactorCode(code: String?) throws {
        self.validCode = false
        self.code = code?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        if let error = self.validator.validate(code) {
            throw error
        }
        self.validCode = true
    }

    func login(callback: (DatabaseAuthenticatableError?) -> ()) {
        let identifier: String

        if let email = self.user.email where self.user.validEmail {
            identifier = email
        } else if let username = self.user.username where self.user.validUsername {
            identifier = username
        } else {
            return callback(.NonValidInput)
        }

        guard let password = self.user.password where self.user.validPassword else { return callback(.NonValidInput) }
        guard let code = self.code where self.validCode else { return callback(.NonValidInput) }
        let database = self.connection.name
        self.authentication
            .login(usernameOrEmail: identifier, password: password, multifactorCode: code, connection: database)
            .start { result in
                switch result {
                case .Failure(let cause as AuthenticationError) where cause.isMultifactorCodeInvalid:
                    callback(.MultifactorInvalid)
                case .Failure:
                    callback(.CouldNotLogin)
                case .Success(let credentials):
                    callback(nil)
                    self.onAuthentication(credentials)
                }
            }

    }
}
