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
    let emailValidator: InputValidator = EmailValidator()
    let usernameValidator: InputValidator = UsernameValidator()
    let passwordValidator: InputValidator = NonEmptyValidator()

    init(authentication: Authentication) {
        self.authentication = authentication
    }

    mutating func update(attribute: CredentialAttribute, value: String?) throws {
        let error: ErrorType?
        switch attribute {
        case .Email:
            self.email = value?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            error = self.emailValidator.validate(value)
            self.validEmail = error == nil
        case .Username:
            self.username = value?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            error = self.usernameValidator.validate(value)
            self.validUsername = error == nil
        case .Password:
            self.password = value
            error = self.passwordValidator.validate(value)
            self.validPassword = error == nil
        }

        if let error = error { throw error }
    }

    func login(callback: (AuthenticatableError?) -> ()) {
        let identifier: String

        if let email = self.email where self.validEmail {
            identifier = email
        } else if let username = self.username where self.validUsername {
            identifier = username
        } else {
            return callback(.NonValidInput)
        }

        guard let password = self.password where self.validPassword else { return callback(.NonValidInput) }
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