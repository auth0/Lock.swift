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
import Auth0

protocol DatabaseAuthenticatable: CredentialAuthenticatable {

    var identifier: String? { get }
    var email: String? { get }
    var username: String? { get }
    var password: String? { get }

    var validEmail: Bool { get }
    var validUsername: Bool { get }
    mutating func update(_ attribute: UserAttribute, value: String?) throws

    func login(_ callback: @escaping (CredentialAuthError?) -> Void)
}

protocol CredentialAuthenticatable {
    var logger: Logger { get }
    var dispatcher: Dispatcher { get }
}

extension CredentialAuthenticatable {

    func handle(identifier: String, result: Auth0.Result<Credentials>, callback: (CredentialAuthError?) -> Void) {
        switch result {
        case .failure(let cause as AuthenticationError) where cause.isMultifactorRequired || cause.isMultifactorEnrollRequired:
            self.logger.error("Multifactor is required for user <\(identifier)>")
            callback(.multifactorRequired)
            self.dispatcher.dispatch(result: .error(CredentialAuthError.multifactorRequired))
        case .failure(let cause as AuthenticationError) where cause.isTooManyAttempts:
            self.logger.error("Blocked user <\(identifier)> for too many login attempts")
            callback(.tooManyAttempts)
            self.dispatcher.dispatch(result: .error(CredentialAuthError.tooManyAttempts))
        case .failure(let cause as AuthenticationError) where cause.isInvalidCredentials:
            self.logger.error("Invalid credentials of user <\(identifier)>")
            callback(.invalidEmailPassword)
            self.dispatcher.dispatch(result: .error(CredentialAuthError.invalidEmailPassword))
        case .failure(let cause as AuthenticationError) where cause.isMultifactorCodeInvalid:
            self.logger.error("Multifactor code is invalid for user <\(identifier)>")
            callback(.multifactorInvalid)
            self.dispatcher.dispatch(result: .error(CredentialAuthError.multifactorInvalid))
        case .failure(let cause as AuthenticationError) where cause.isRuleError && cause.description.lowercased() == "user is blocked":
            self.logger.error("Blocked user <\(identifier)>")
            callback(.userBlocked)
            self.dispatcher.dispatch(result: .error(CredentialAuthError.userBlocked))
        case .failure(let cause as AuthenticationError) where cause.isRuleError:
            self.logger.error("Failed login of user <\(identifier)> by custom rule")
            callback(.customRuleFailure(cause: cause.description))
            self.dispatcher.dispatch(result: .error(CredentialAuthError.customRuleFailure(cause: cause.description)))
        case .failure(let cause as AuthenticationError) where cause.code == "password_change_required":
            self.logger.error("Change password required for user <\(identifier)>")
            callback(.passwordChangeRequired)
            self.dispatcher.dispatch(result: .error(CredentialAuthError.passwordChangeRequired))
        case .failure(let cause as AuthenticationError) where cause.code == "password_leaked":
            self.logger.error("The password of user <\(identifier)> was leaked")
            callback(.passwordLeaked)
            self.dispatcher.dispatch(result: .error(CredentialAuthError.passwordLeaked))
        case .failure(let cause):
            self.logger.error("Failed login of user <\(identifier)> with error \(cause)")
            callback(.couldNotLogin)
            self.dispatcher.dispatch(result: .error(CredentialAuthError.couldNotLogin))
        case .success(let credentials):
            self.logger.info("Authenticated user <\(identifier)>")
            callback(nil)
            self.dispatcher.dispatch(result: .auth(credentials))
        }
    }
}
