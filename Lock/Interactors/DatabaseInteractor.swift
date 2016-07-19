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

struct DatabaseInteractor: DatabaseAuthenticatable {

    private var user: DatabaseUser

    var email: String? { return self.user.email }
    var username: String? { return self.user.username }
    var password: String? { return self.user.password }

    var validEmail: Bool { return self.user.validEmail }
    var validUsername: Bool { return self.user.validUsername }
    var validPassword: Bool { return self.user.validPassword }

    let authentication: Authentication
    let connections: Connections
    let emailValidator: InputValidator = EmailValidator()
    let usernameValidator: InputValidator = UsernameValidator()
    let passwordValidator: InputValidator = NonEmptyValidator()
    let onAuthentication: Credentials -> ()

    init(connections: Connections, authentication: Authentication, user: DatabaseUser, callback: Credentials -> ()) {
        self.authentication = authentication
        self.connections = connections
        self.onAuthentication = callback
        self.user = user
    }

    mutating func update(attribute: CredentialAttribute, value: String?) throws {
        let error: ErrorType?
        switch attribute {
        case .Email:
            self.user.email = value?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            error = self.emailValidator.validate(value)
            self.user.validEmail = error == nil
        case .Username:
            self.user.username = value?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            error = self.usernameValidator.validate(value)
            self.user.validUsername = error == nil
        case .Password:
            self.user.password = value
            error = self.passwordValidator.validate(value)
            self.user.validPassword = error == nil
        }

        if let error = error { throw error }
    }

    func login(callback: (DatabaseAuthenticatableError?) -> ()) {
        let identifier: String

        if let email = self.email where self.validEmail {
            identifier = email
        } else if let username = self.username where self.validUsername {
            identifier = username
        } else {
            return callback(.NonValidInput)
        }

        guard let password = self.password where self.validPassword else { return callback(.NonValidInput) }
        guard let databaseName = self.connections.database?.name else { return callback(.NoDatabaseConnection) }
        
        self.authentication
            .login(usernameOrEmail: identifier, password: password, connection: databaseName)
            .start { self.handleLoginResult($0, callback: callback) }
    }

    func create(callback: (DatabaseAuthenticatableError?) -> ()) {
        guard let connection = self.connections.database else { return callback(.NoDatabaseConnection) }
        let databaseName = connection.name

        guard
            let email = self.email where self.validEmail,
            let password = self.password where self.validPassword
            else { return callback(.NonValidInput) }

        guard !connection.requiresUsername || self.validUsername else { return callback(.NonValidInput) }

        let username = connection.requiresUsername ? self.username : nil

        let authentication = self.authentication
        let login = authentication.login(usernameOrEmail: email, password: password, connection: databaseName)
        authentication
            .createUser(email: email, username: username, password: password, connection: databaseName)
            .start {
                switch $0 {
                case .Success:
                    login.start { self.handleLoginResult($0, callback: callback) }
                case .Failure:
                    callback(.CouldNotCreateUser)
                }
            }
    }

    private func handleLoginResult(result: Auth0.Result<Credentials>, callback: DatabaseAuthenticatableError? -> ()) {
        switch result {
        case .Failure(let cause as AuthenticationError) where cause.isMultifactorRequired:
            callback(.MultifactorRequired)
        case .Failure:
            callback(.CouldNotLogin)
        case .Success(let credentials):
            callback(nil)
            self.onAuthentication(credentials)
        }
    }
}

protocol InputValidator {
    func validate(value: String?) -> InputValidationError?
}

struct NonEmptyValidator: InputValidator {
    func validate(value: String?) -> InputValidationError? {
        guard let value = value?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) where !value.isEmpty else { return .MustNotBeEmpty }
        return nil
    }
}

struct UsernameValidator: InputValidator {

    let set: NSCharacterSet

    init() {
        let set = NSMutableCharacterSet()
        set.formUnionWithCharacterSet(NSCharacterSet.alphanumericCharacterSet())
        set.addCharactersInString("_")
        self.set = set.invertedSet
    }

    func validate(value: String?) -> InputValidationError? {
        guard let username = value?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) where !username.isEmpty else { return .MustNotBeEmpty }
        guard username.characters.count <= 15 else { return .NotAUsername }
        guard username.rangeOfCharacterFromSet(self.set) == nil else { return .NotAUsername }
        return nil
    }
}

struct EmailValidator: InputValidator {
    let predicate: NSPredicate

    init() {
        let regex = "[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}"
        self.predicate = NSPredicate(format: "SELF MATCHES %@", regex)
    }

    func validate(value: String?) -> InputValidationError? {
        guard let email = value?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) where !email.isEmpty else { return .MustNotBeEmpty }
        guard self.predicate.evaluateWithObject(email) else { return .NotAnEmailAddress }
        return nil
    }
}