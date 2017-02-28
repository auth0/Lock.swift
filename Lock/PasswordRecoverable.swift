// PasswordRecoverable.swift
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

protocol PasswordRecoverable {
    var email: String? { get }
    var validEmail: Bool { get }

    mutating func updateEmail(_ value: String?) throws

    func requestEmail(_ callback: @escaping (PasswordRecoverableError?) -> Void)
}

enum PasswordRecoverableError: Error, LocalizableError {
    case nonValidInput
    case noDatabaseConnection
    case emailNotSent

    var localizableMessage: String {
        switch self {
        case .emailNotSent:
            return "WE'RE SORRY, SOMETHING WENT WRONG WHEN REQUESTING THE PASSWORD CHANGE.".i18n(key: "com.auth0.lock.error.forgot.fallback", comment: "Generic password error")
        default:
            return "SOMETHING WENT WRONG.\nPLEASE CONTACT TECHNICAL SUPPORT.".i18n(key: "com.auth0.lock.error.fallback", comment: "Generic error")
        }
    }

    var userVisible: Bool {
        switch self {
        case .emailNotSent:
            return true
        default:
            return false
        }
    }
}
