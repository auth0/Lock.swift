// PasswordlessInteractor.swift
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
import UIKit
import Auth0

struct PasswordlessInteractor: PasswordlessAuthenticatable, Loggable {

    let authentication: Authentication
    let dispatcher: Dispatcher
    let user: User
    let options: Options
    let passwordlessActivity: PasswordlessUserActivity

    let emailValidator: InputValidator = EmailValidator()
    let codeValidator: InputValidator = OneTimePasswordValidator()
    let phoneValidator: InputValidator = PhoneValidator()

    var identifier: String? { return self.user.email }
    var validIdentifier: Bool { return self.user.validEmail }
    var code: String?
    var validCode: Bool = false

    init(authentication: Authentication, dispatcher: Dispatcher, user: User, options: Options, passwordlessActivity: PasswordlessUserActivity) {
        self.authentication = authentication
        self.dispatcher = dispatcher
        self.user = user
        self.options = options
        self.passwordlessActivity = passwordlessActivity
    }

    func request(_ connection: String, callback: @escaping (PasswordlessAuthenticatableError?) -> Void) {
        guard let identifier = self.identifier, self.validIdentifier else { return callback(.nonValidInput) }

        let type = (self.options.passwordlessMethod == .emailCode || self.options.passwordlessMethod == .smsCode) ? PasswordlessType.Code : PasswordlessType.iOSLink

        var authenticator: Auth0.Request<Swift.Void, Auth0.AuthenticationError>
        if self.options.passwordlessMethod.mode == "email" {
            authenticator =  self.authentication.startPasswordless(email: identifier, type: type, connection: connection, parameters: self.options.parameters)
        } else {
            authenticator =  self.authentication.startPasswordless(phoneNumber: identifier, type: type, connection: connection)
        }

        authenticator.start {
            switch $0 {
            case .success:
                callback(nil)
                self.dispatcher.dispatch(result: .passwordless(identifier))

                if type == .iOSLink {

                    self.passwordlessActivity.onActivity { password, messagePresenter in
                        guard self.codeValidator.validate(password) == nil else {
                            messagePresenter?.showError(PasswordlessAuthenticatableError.invalidLink)
                            return self.dispatcher.dispatch(result: .error(PasswordlessAuthenticatableError.invalidLink))
                        }

                        CredentialAuth(oidc: self.options.oidcConformant, realm: connection, authentication: self.authentication)
                            .request(withIdentifier: identifier, password: password, options: self.options)
                            .start { result in
                                self.handle(identifier: identifier, result: result) { error in
                                    if let error = error {
                                         messagePresenter?.showError(error)
                                    }
                                }
                        }
                    }
                }
            case .failure(let cause as AuthenticationError) where cause.code == "bad.connection":
                callback(.noSignup)
                self.dispatcher.dispatch(result: .error(PasswordlessAuthenticatableError.noSignup))
            case .failure:
                callback(.codeNotSent)
                return self.dispatcher.dispatch(result: .error(PasswordlessAuthenticatableError.codeNotSent))
            }
        }
    }

    func login(_ connection: String, callback: @escaping (CredentialAuthError?) -> Void) {
        guard let password = self.code, self.validCode, let identifier = self.identifier, self.validIdentifier
            else { return callback(.nonValidInput) }

        CredentialAuth(oidc: options.oidcConformant, realm: connection, authentication: authentication)
            .request(withIdentifier: identifier, password: password, options: self.options)
            .start { result in
                self.handle(identifier: identifier, result: result, callback: callback)
        }

    }

    mutating func update(_ type: InputField.InputType, value: String?) throws {
        let error: Error?
        switch type {
        case .email:
            error = self.update(email: value)
        case .oneTimePassword:
            error = self.update(code: value)
        case .phone:
            error = self.update(phone: value)
        default:
            error = InputValidationError.mustNotBeEmpty
        }
        if let error = error { throw error }
    }

    private mutating func update(email: String?) -> Error? {
        self.user.email = email?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let error = self.emailValidator.validate(email)
        self.user.validEmail = error == nil
        return error
    }

    private mutating func update(code: String?) -> Error? {
        self.code = code?.trimmingCharacters(in: CharacterSet.whitespaces)
        let error = self.codeValidator.validate(code)
        self.validCode = error == nil
        return error
    }

    private mutating func update(phone: String?) -> Error? {
        self.user.email = phone?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let error = self.phoneValidator.validate(phone)
        self.user.validEmail = error == nil
        return error
    }
}
