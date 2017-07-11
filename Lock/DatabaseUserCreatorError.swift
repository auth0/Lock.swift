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
    case userExists

    var localizableMessage: String {
        switch self {
        case .passwordTooCommon:
            return "PASSWORD IS TOO COMMON.".i18n(key: "com.auth0.lock.error.signup.password_dictionary_error", comment: "password_dictionary_error")
        case .passwordTooWeak:
            return "PASSWORD IS TOO WEAK.".i18n(key: "com.auth0.lock.error.signup.password_strength_error", comment: "password_strength_error")
        case .passwordHasUserInfo:
            return "PASSWORD IS BASED ON USER INFORMATION.".i18n(key: "com.auth0.lock.error.signup.password_no_user_info_error", comment: "password_no_user_info_error")
        case .passwordAlreadyUsed:
            return "PASSWORD HAS PREVIOUSLY BEEN USED.".i18n(key: "com.auth0.lock.error.signup.password_history", comment: "password_history")
        case .passwordInvalid:
            return "PASSWORD IS INVALID.".i18n(key: "com.auth0.lock.error.signup.invalid_password", comment: "invalid_password")
        case .userExists:
            return "THE USER ALREADY EXISTS.".i18n(key: "com.auth0.lock.error.signup.user_exists", comment: "user_exists")
        default:
            return "WE'RE SORRY, SOMETHING WENT WRONG WHEN ATTEMPTING TO SIGN UP.".i18n(key: "com.auth0.lock.error.signup.fallback", comment: "Generic sign up error")
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
