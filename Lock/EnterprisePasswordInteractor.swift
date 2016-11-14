// EnterprisePasswordInteractor.swift
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

struct EnterprisePasswordInteractor: DatabaseAuthenticatable, Loggable {
    
    var identifier: String? = nil
    var email: String? = nil
    var username: String? = nil
    var password: String? = nil
    
    var validEmail: Bool = false
    var validUsername: Bool = false
    var validPassword: Bool = false
    
    var usernameValidator: InputValidator = UsernameValidator()
    let emailValidator: InputValidator = EmailValidator()
    let passwordValidator: InputValidator = NonEmptyValidator()
    
    let authentication: Authentication
    let onAuthentication: Credentials -> ()
    let options: Options
    let user: User
    let connection: EnterpriseConnection
    
    init(connection: EnterpriseConnection, authentication: Authentication, user: User, options: Options, callback: Credentials -> ()) {
        self.authentication = authentication
        self.connection = connection
        self.onAuthentication = callback
        self.user = user
        self.options = options
        
        updateEmail(user.email)
    }


    mutating func update(attribute: UserAttribute, value: String?) throws {
        let error: ErrorType?
        
        switch attribute {
        case .Email:
            error = updateEmail(value)
        case .Username:
            error = updateUsername(value)
        case .Password:
            error = updatePassword(value)
        default:
            self.logger.warn("Ignoring unknown input type: \(attribute)")
            return
        }
        
        if let error = error { throw error }
    }
    
    private mutating func updateEmail(value: String?) -> ErrorType? {
        email = value?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        let error = emailValidator.validate(value)
        validEmail = error == nil
        return error
    }
    
    private mutating func updateUsername(value: String?) -> ErrorType? {
        username = value?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        let error = usernameValidator.validate(value)
        validUsername = error == nil
        return error
    }
    
    private mutating func updatePassword(value: String?) -> ErrorType? {
        password = value
        let error = passwordValidator.validate(value)
        validPassword = error == nil
        return error
    }
    
    func login(callback: (DatabaseAuthenticatableError?) -> ()) {
        let identifier: String
        
        if let email = self.email where self.validEmail {
            identifier = email
        } else if let username = self.username where self.validUsername {
            identifier = username
        } else {
            return callback(.NonValidInput)
        }
        
        guard let password = self.password where self.validPassword else { return callback(.NonValidInput) }
        
        self.authentication
            .login(
                usernameOrEmail: identifier,
                password: password,
                connection: self.connection.name,
                scope: self.options.scope,
                parameters: self.options.parameters
            )
            .start { self.handleLoginResult($0, callback: callback) }
    }
    
    private func handleLoginResult(result: Auth0.Result<Credentials>, callback: DatabaseAuthenticatableError? -> ()) {
        switch result {
        case .Failure(let cause as AuthenticationError) where cause.isMultifactorRequired || cause.isMultifactorEnrollRequired:
            self.logger.error("Multifactor is required for user <\(self.identifier)>")
            callback(.MultifactorRequired)
        case .Failure(let cause as AuthenticationError) where cause.isTooManyAttempts:
            self.logger.error("Blocked user <\(self.identifier)> for too many login attempts")
            callback(.TooManyAttempts)
        case .Failure(let cause as AuthenticationError) where cause.isInvalidCredentials:
            self.logger.error("Invalid credentials of user <\(self.identifier)>")
            callback(.InvalidEmailPassword)
        case .Failure(let cause as AuthenticationError) where cause.isMultifactorCodeInvalid:
            self.logger.error("Multifactor code is invalid for user <\(self.identifier)>")
            callback(.MultifactorInvalid)
        case .Failure(let cause as AuthenticationError) where cause.isRuleError && cause.description.lowercaseString == "user is blocked":
            self.logger.error("Blocked user <\(self.identifier)>")
            callback(.UserBlocked)
        case .Failure(let cause as AuthenticationError) where cause.code == "password_change_required":
            self.logger.error("Change password required for user <\(self.identifier)>")
            callback(.PasswordChangeRequired)
        case .Failure(let cause as AuthenticationError) where cause.code == "password_leaked":
            self.logger.error("The password of user <\(self.identifier)> was leaked")
            callback(.PasswordLeaked)
        case .Failure(let cause):
            self.logger.error("Failed login of user <\(self.identifier)> with error \(cause)")
            callback(.CouldNotLogin)
        case .Success(let credentials):
            self.logger.info("Authenticated user <\(self.identifier)>")
            callback(nil)
            self.onAuthentication(credentials)
        }
    }

}
