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

    var email: String? = nil
    var validEmail: Bool = false
    var connection: EnterpriseConnection? = nil

    let connections: [EnterpriseConnection]
    let emailValidator: InputValidator = EmailValidator()
    let authenticator: OAuth2Authenticatable

    init(connections: [EnterpriseConnection], authentication: OAuth2Authenticatable) {
        self.connections = connections
        self.authenticator = authentication
    }
    
    func matchDomain(value: String?) -> EnterpriseConnection? {
        guard let domain = value?.componentsSeparatedByString("@").last else { return nil }
        return connections.filter { $0.domains.contains(domain) }.first
    }
    
    mutating func updateEmail(value: String?) throws {
        validEmail = false
        connection = nil

        email = value?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if let error = emailValidator.validate(value) {
            throw error
        }
        validEmail = true
        
        connection = matchDomain(value)
    }
    
    func login(callback: (OAuth2AuthenticatableError?) -> ()) {
        guard let connection = self.connection else { return callback(.NoConnectionAvailable) }
        authenticator.login(connection.name, callback: callback)
    }
    
}
