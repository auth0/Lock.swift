// DatabaseInteractor.swift
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

struct DatabaseInteractor: DatabaseAuthenticatable, DatabaseUserCreator, Loggable {

    var user: DatabaseUser

    var identifier: String? { return self.user.identifier }
    var email: String? { return self.user.email }
    var username: String? { return self.user.username }
    var password: String? { return self.user.password }

    var validEmail: Bool { return self.user.validEmail }
    var validUsername: Bool { return self.user.validUsername }
    var validPassword: Bool { return self.user.validPassword }
    var usernameValidator: InputValidator { return self.connection.usernameValidator }
    var passwordValidator: InputValidator { return self.connection.passwordValidator }
    var requiredValidator = NonEmptyValidator()

    let credentialAuth: CredentialAuth
    let connection: DatabaseConnection
    let emailValidator: InputValidator = EmailValidator()
    let dispatcher: Dispatcher
    let options: Options
    let customFields: [String: CustomTextField]

    init(connection: DatabaseConnection, authentication: Authentication, user: DatabaseUser, options: Options, dispatcher: Dispatcher) {
        self.credentialAuth = CredentialAuth(oidc: options.oidcConformant, realm: connection.name, authentication: authentication)
        self.connection = connection
        self.dispatcher = dispatcher
        self.user = user
        self.options = options
        var fields: [String: CustomTextField] = [:]
        options.customSignupFields.forEach { fields[$0.name] = $0 }
        self.customFields = fields
    }

    mutating func update(_ attribute: UserAttribute, value: String?) throws {
        let error: Error?
        switch attribute {
        case .email:
            error = self.update(email: value)
        case .username:
            error = self.update(username: value)
        case .password(let enforcePolicy):
            error = self.update(password: value, enforcingPolicy: enforcePolicy)
        case .emailOrUsername:
            let emailError = self.update(email: value)
            let usernameError = self.update(username: value)
            if emailError != nil && usernameError != nil {
                error = emailError
            } else {
                error = nil
            }
        case .custom(let name):
            let field = self.customFields[name]
            error = field?.validation(value)
            self.user.additionalAttributes[name] = value
            self.user.validAdditionalAttribute(name, valid: error == nil)
        }

        if let error = error { throw error }
    }

    func login(_ callback: @escaping (CredentialAuthError?) -> Void) {
        let identifier: String

        if let email = self.email, self.validEmail {
            identifier = email
        } else if let username = self.username, self.validUsername {
            identifier = username
        } else {
            return callback(.nonValidInput)
        }

        guard let password = self.password, self.validPassword else { return callback(.nonValidInput) }

        self.credentialAuth
            .request(withIdentifier: identifier, password: password, options: self.options)
            .start { self.handle(identifier: identifier, result: $0, callback: callback) }
    }

    func create(_ callback: @escaping (DatabaseUserCreatorError?, CredentialAuthError?) -> Void) {
        let databaseName = connection.name

        guard
            let email = self.email, self.validEmail,
            let password = self.password, self.validPassword
            else { return callback(.nonValidInput, nil) }

        guard !connection.requiresUsername || self.validUsername else { return callback(.nonValidInput, nil) }

        for (fieldName, _) in customFields {
            guard self.user.validAdditionalAttribute(fieldName) else { return callback(.nonValidInput, nil) }
        }

        let username = connection.requiresUsername ? self.username : nil
        let metadata: [String: String]? = self.user.additionalAttributes.isEmpty ? nil : self.user.additionalAttributes

        let login = self.credentialAuth.request(withIdentifier: email, password: password, options: self.options)
        self.credentialAuth
            .authentication
            .createUser(
                email: email,
                username: username,
                password: password,
                connection: databaseName,
                userMetadata: metadata
            )
            .start {
                switch $0 {
                case .success(let user):
                    if self.options.loginAfterSignup {
                        login.start { self.handle(identifier: email, result: $0, callback: { callback(nil, $0) }) }
                    } else {
                        var extra: [String: Any] = [
                            "verified": user.verified
                        ]
                        extra["username"] = user.username
                        self.dispatcher.dispatch(result: .signUp(user.email, extra))
                        callback(nil, nil)
                    }
                case .failure(let cause as AuthenticationError) where cause.isPasswordNotStrongEnough:
                    callback(.passwordTooWeak, nil)
                    self.dispatcher.dispatch(result: .error(DatabaseUserCreatorError.passwordTooWeak))
                case .failure(let cause as AuthenticationError) where cause.isPasswordAlreadyUsed:
                    callback(.passwordAlreadyUsed, nil)
                    self.dispatcher.dispatch(result: .error(DatabaseUserCreatorError.passwordAlreadyUsed))
                case .failure(let cause as AuthenticationError) where cause.code == "invalid_password" && cause.value("name") == "PasswordDictionaryError":
                    callback(.passwordTooCommon, nil)
                    self.dispatcher.dispatch(result: .error(DatabaseUserCreatorError.passwordTooCommon))
                case .failure(let cause as AuthenticationError) where cause.code == "invalid_password" && cause.value("name") == "PasswordNoUserInfoError":
                    callback(.passwordHasUserInfo, nil)
                    self.dispatcher.dispatch(result: .error(DatabaseUserCreatorError.passwordHasUserInfo))
                case .failure(let cause as AuthenticationError) where cause.code == "invalid_password":
                    callback(.passwordInvalid, nil)
                    self.dispatcher.dispatch(result: .error(DatabaseUserCreatorError.passwordInvalid))
                case .failure(let cause as AuthenticationError) where cause.code == "user_exists":
                    callback(.userExists, nil)
                    self.dispatcher.dispatch(result: .error(DatabaseUserCreatorError.userExists))
                case .failure:
                    callback(.couldNotCreateUser, nil)
                    self.dispatcher.dispatch(result: .error(DatabaseUserCreatorError.couldNotCreateUser))
                }
        }
    }

    private mutating func update(email: String?) -> Error? {
        self.user.email = email?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let error = self.emailValidator.validate(email)
        self.user.validEmail = error == nil
        return error
    }

    private mutating func update(username: String?) -> Error? {
        self.user.username = username?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let error = self.usernameValidator.validate(username)
        self.user.validUsername = error == nil
        return error
    }

    private mutating func update(password: String?, enforcingPolicy: Bool) -> Error? {
        self.user.password = password
        let error = enforcingPolicy ? self.passwordValidator.validate(password) : self.requiredValidator.validate(password)
        self.user.validPassword = error == nil
        return error
    }
}
