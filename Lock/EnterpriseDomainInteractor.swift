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

struct EnterpriseDomainInteractor: EnterpriseDomain {

    var email: String? = nil
    var validEmail: Bool = false

    let connections: Connections
    let connection: EnterpriseConnection? = nil
    let emailValidator: InputValidator = EmailValidator()
    let authenticator: OAuth2Authenticatable

    init(connections: Connections, auth: OAuth2Authenticatable) {
        self.connections = connections
        self.authenticator = auth
    }
    
    func validateDomain(connections: Connections, value: String?) -> EnterpriseConnection? {
        
        guard let domain = value?.componentsSeparatedByString("@").last else { return nil }
        
        return connections.enterprise.filter { $0.domain.contains(domain) }.first
    }
    
    mutating func updateEmail(value: String?) throws {
        
        validEmail = false
        
        // Validate email
        email = value?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if let error = emailValidator.validate(value) {
            throw error
        }
        validEmail = true
    }
    
    func requestConnection(callback: (OAuth2AuthenticatableError?) -> ()) {
        if self.email == nil { return callback(.NoConnectionAvailable) }
        
        guard let connection = validateDomain(connections, value: email) else { return callback(.NoConnectionAvailable) }

        authenticator.login(connection.name, callback: callback)
        
    }
}
