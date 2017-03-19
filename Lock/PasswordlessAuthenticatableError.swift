// PasswordlessAuthenticatableError.swift
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

enum PasswordlessAuthenticatableError: Error, LocalizableError {
    case nonValidInput
    case codeNotSent
    case noSignup
    case invalidLink

    var localizableMessage: String {
        switch self {
        case .invalidLink:
            return "WE'RE SORRY, THERE WAS A PROBLEM WITH YOUR LINK. PLEASE REQUEST A NEW ONE.".i18n(key: "com.auth0.lock.error.passwordless.invalid_link", comment: "Passwordless link invalid.")
        case .noSignup:
            return "NEW SIGN UPS ARE DISABLED FOR THIS ACCOUNT, PLEASE CONTACT YOUR ADMINISTRATOR.".i18n(key: "com.auth0.lock.error.passwordless.signup_disabled", comment: "Passwordless sign ups disabled.")
        default:
            return "WE'RE SORRY, SOMETHING WENT WRONG WHEN ATTEMPTING TO LOG IN.".i18n(key: "com.auth0.lock.error.authentication.fallback", comment: "Generic login error")
        }
    }

    var userVisible: Bool {
        switch self {
        case .nonValidInput:
            return false
        default:
            return true
        }
    }
}
