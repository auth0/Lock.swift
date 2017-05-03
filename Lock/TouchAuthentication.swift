// TouchAuth.swift
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
import LocalAuthentication

struct TouchAuthentication {

    let storage = Storage()
    let authentication: Authentication
    let options: Options
    let context = LAContext()
    let storeKey = "credentials"

    var available: Bool {
        return self.context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }

    init(authentication: Authentication, options: Options) {
        self.authentication = authentication
        self.options = options
    }

    func store(credentials: Credentials, callback: @escaping (Error?) -> Void) {
        guard credentials.refreshToken != nil, credentials.expiresIn != nil else { return callback(nil) }
        let touchMessage = "Touch to remeber me".i18n(key: "com.auth0.lock.touch.rememberme.title", comment: "Touch prompt to remeber me title")

        if #available(iOS 10, *) {
            context.localizedCancelTitle = "Don't remeber me".i18n(key: "com.auth0.lock.touch.rememberme.cancel", comment: "Touch prompt to cancel remeber me")
        }
        context.localizedFallbackTitle = nil
        context.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: touchMessage) { (success, error) in
            guard error == nil else {
                self.storage.deleteEntry(forKey: self.storeKey)
                return callback(error)
            }
            if success {
                _ = self.storage.archive(object: credentials, forKey: self.storeKey)
            }
        }
    }

    func renewAuth(callback: @escaping (Error?, Credentials?) -> Void) {
        guard let storedCredentials = self.storage.unarchive(objectWithKey: self.storeKey) as? Credentials else {
            return callback(nil, nil)
        }
        let touchMessage = "Touch to authenticate".i18n(key: "com.auth0.lock.touch.authenticate.title", comment: "Touch prompt to login message")

        if #available(iOS 10, *) {
            context.localizedCancelTitle = "Login with another user".i18n(key: "com.auth0.lock.touch.authenticate.cancel", comment: "Touch prompt to cancel login")
        }

        context.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: touchMessage) { (success, error) in
            guard error == nil else {
                self.storage.deleteEntry(forKey: self.storeKey)
                return callback(error, nil)
            }

            if success {
                self.authentication.renewExpired(storedCredentials, scope: self.options.scope) { authError, credentials in
                    guard authError == nil else {
                        return callback(authError, nil)
                    }
                    callback(nil, credentials)
                }
            }
        }
    }
}
