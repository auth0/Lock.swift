// CredentialAuthError.swift
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

enum CredentialAuthError: Error, LocalizableError {
    case nonValidInput
    case userBlocked
    case invalidEmailPassword
    case couldNotLogin
    case passwordChangeRequired
    case passwordLeaked
    case tooManyAttempts
    case multifactorRequired
    case multifactorInvalid
    case customRuleFailure(cause: String)

    var localizableMessage: String {
        switch self {
        case .userBlocked:
            return "THE USER IS BLOCKED.".i18n(key: "com.auth0.lock.error.authentication.blocked_user", comment: "user is blocked")
        case .invalidEmailPassword:
            return "WRONG EMAIL OR PASSWORD.".i18n(key: "com.auth0.lock.error.authentication.invalid_user_password", comment: "invalid_user_password")
        case .passwordChangeRequired:
            return "YOU NEED TO UPDATE YOUR PASSWORD BECAUSE THIS IS THE FIRST TIME YOU ARE LOGGING IN, OR BECAUSE YOUR PASSWORD HAS EXPIRED.".i18n(key: "com.auth0.lock.error.authentication.password_change_required", comment: "password_change_required")
        case .passwordLeaked:
            return "THIS LOGIN HAS BEEN BLOCKED BECAUSE YOUR PASSWORD HAS BEEN LEAKED IN ANOTHER WEBSITE. WE’VE SENT YOU AN EMAIL WITH INSTRUCTIONS ON HOW TO UNBLOCK IT.".i18n(key: "com.auth0.lock.error.authentication.password_leaked", comment: "password_leaked")
        case .tooManyAttempts:
            return "YOUR ACCOUNT HAS BEEN BLOCKED AFTER MULTIPLE CONSECUTIVE LOGIN ATTEMPTS.".i18n(key: "com.auth0.lock.error.authentication.too_many_attempts", comment: "too_many_attempts")
        case .multifactorInvalid:
            return "WRONG CODE.".i18n(key: "com.auth0.lock.error.authentication.mfa_invalid_code", comment: "a0.mfa_invalid_code")
        case .customRuleFailure(let cause):
            return cause
        default:
            return "WE'RE SORRY, SOMETHING WENT WRONG WHEN ATTEMPTING TO LOG IN.".i18n(key: "com.auth0.lock.error.authentication.fallback", comment: "Generic login error")
        }
    }

    var userVisible: Bool {
        switch self {
        case .multifactorRequired, .nonValidInput:
            return false
        default:
            return true
        }
    }
}
