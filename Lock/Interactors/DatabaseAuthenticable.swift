// DatabaseAuthenticatable.swift
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

protocol DatabaseAuthenticatable {
    var identifier: String? { get }
    var email: String? { get }
    var username: String? { get }
    var password: String? { get }

    var validEmail: Bool { get }
    var validUsername: Bool { get }
    mutating func update(attribute: CredentialAttribute, value: String?) throws

    func login(callback: (DatabaseAuthenticatableError?) -> ())
    func create(callback: (DatabaseAuthenticatableError?) -> ())
}

enum DatabaseAuthenticatableError: ErrorType, LocalizableError {
    case NonValidInput
    case CouldNotLogin
    case CouldNotCreateUser
    case NoDatabaseConnection
    case MultifactorRequired
    case MultifactorInvalid

    var localizableMessage: String {
        switch self {
        case .CouldNotCreateUser:
            return "We're sorry, something went wrong when attempting to sign up.".i18n(key: "com.auth0.lock.error.signup.fallback", comment: "Generic sign up error")
        case .CouldNotLogin:
            return "We're sorry, something went wrong when attempting to log in.".i18n(key: "com.auth0.lock.error.authentication.fallback", comment: "Generic login error")
        default:
            return "Something went wrong.\nPlease contact technical support.".i18n(key: "com.auth0.lock.error.fallback", comment: "Generic error")
        }
    }

    var userVisible: Bool {
        switch self {
        case .CouldNotCreateUser, .CouldNotLogin, .NoDatabaseConnection:
            return true
        default:
            return false
        }
    }
}

enum InputValidationError: ErrorType {
    case MustNotBeEmpty
    case NotAnEmailAddress
    case NotAUsername
    case NotAOneTimePassword

    var localizedMessage: String {
        switch self {
        case .NotAUsername:
            return "Can only contain between 1 to 15 alphanumeric characters and \'_\'.".i18n(key: "com.auth0.lock.input.username.error", comment: "invalid username")
        case .NotAnEmailAddress:
            return "Must be a valid email address".i18n(key: "com.auth0.lock.input.email.error", comment: "invalid email")
        case .MustNotBeEmpty:
            return "Must not be empty".i18n(key: "com.auth0.lock.input.empty.error", comment: "empty input")
        case .NotAOneTimePassword:
            return "Must be a valid numeric code".i18n(key: "com.auth0.lock.input.otp.error", comment: "invalid otp")
        }
    }
}

enum CredentialAttribute {
    case Email
    case Username
    case Password
    case EmailOrUsername
}
