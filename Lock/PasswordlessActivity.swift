// PasswordlessActivity.swift
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

protocol PasswordlessUserActivity {
    func store(_ transaction: PasswordlessAuthTransaction)
    func continueAuth(withActivity userActivity: NSUserActivity) -> Bool
}

class PasswordlessActivity: PasswordlessUserActivity, Loggable {

    static let shared = PasswordlessActivity()

    var messagePresenter: MessagePresenter?
    var dispatcher: Dispatcher?

    private(set) var current: PasswordlessAuthTransaction?

    private init() {}

    func store(_ transaction: PasswordlessAuthTransaction) {
        self.current = transaction
    }

    func continueAuth(withActivity userActivity: NSUserActivity) -> Bool {

        self.logger.verbose("Processing userActivity")

        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb, let url = userActivity.webpageURL,
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                self.logger.error("The userActivity does not contain a valid passwordless URL")
                return false
        }

        guard let bundlerIdentifier = Bundle.main.bundleIdentifier, components.path.lowercased().contains(bundlerIdentifier.lowercased()), let items = components.queryItems else {
            self.logger.error("Passwordless URL does not match our bundle identifier")
            return false
        }

        guard let key = items.filter({ $0.name == "code" }).first, let passcode = key.value, Int(passcode) != nil else {
            self.logger.error("No valid passcode was found in the URL")
            messagePresenter?.showError(PasswordlessAuthenticatableError.invalidLink)
            self.dispatcher?.dispatch(result: .error(PasswordlessAuthenticatableError.invalidLink))
            return false
        }

        guard let passwordlessAuth = self.current else {
            self.logger.error("No passworldess authenticator is currently stored")
            return true
        }

        passwordlessAuth.auth(withPasscode: passcode) {
            if let error = $0 { self.messagePresenter?.showError(error) }
        }
        self.current = nil
        return true

    }
}
