// DatabaseUserCreatorError.swift
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

enum DatabaseUserCreatorError: Error, LocalizableError {
    case nonValidInput
    case couldNotCreateUser
    case passwordTooCommon
    case passwordTooWeak
    case passwordHasUserInfo
    case passwordInvalid
    case passwordAlreadyUsed

    var localizableMessage: String {
        switch self {
        case .passwordTooCommon:
            return "Password is too common.".i18n(key: "com.auth0.lock.error.signup.password_dictionary_error", comment: "password_dictionary_error")
        case .passwordTooWeak:
            return "Password is too weak.".i18n(key: "com.auth0.lock.error.signup.password_strength_error", comment: "password_strength_error")
        case .passwordHasUserInfo:
            return "Password is based on user information.".i18n(key: "com.auth0.lock.error.signup.password_no_user_info_error", comment: "password_no_user_info_error")
        case .passwordAlreadyUsed:
            return "Password has previously been used.".i18n(key: "com.auth0.lock.error.signup.password_history", comment: "password_history")
        case .passwordInvalid:
            return "Password is invalid.".i18n(key: "com.auth0.lock.error.signup.invalid_password", comment: "invalid_password")
        default:
            return "We're sorry, something went wrong when attempting to sign up.".i18n(key: "com.auth0.lock.error.signup.fallback", comment: "Generic sign up error")
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
