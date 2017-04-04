// EnterpriseDomainInteractor.swift
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

struct EnterpriseDomainInteractor: HRDAuthenticatable {

    var email: String? {
        return self.user.email
    }

    var validEmail: Bool {
        return self.user.validEmail
    }

    var connection: EnterpriseConnection?
    var domain: String?

    let user: User
    let connections: [EnterpriseConnection]
    let emailValidator: InputValidator = EmailValidator()
    let authenticator: OAuth2Authenticatable

    init(connections: Connections, user: User, authentication: OAuth2Authenticatable) {
        self.connections = connections.enterprise
        self.authenticator = authentication

        if self.connections.count == 1 && connections.oauth2.isEmpty && connections.database == nil {
            self.connection = self.connections.first
        }
        self.user = user
    }

    func match(domain: String) -> EnterpriseConnection? {
        return connections.filter { $0.domains.contains(domain) }.first
    }

    mutating func updateEmail(_ value: String?) throws {
        self.connection = nil
        self.user.email = value?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let error = emailValidator.validate(self.email)
        self.user.validEmail = error == nil
        if let error = error {
            throw error
        }

        self.connection = nil
        if let domain = value?.components(separatedBy: "@").last {
            self.connection = match(domain: domain)
            self.domain = domain
        }
    }

    func login(_ callback: @escaping (OAuth2AuthenticatableError?) -> Void) {
        guard let connection = self.connection else { return callback(.noConnectionAvailable) }
        authenticator.login(connection.name, loginHint: self.email, callback: callback)
    }

}
