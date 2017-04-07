// User.swift
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

protocol DatabaseUser {
    var email: String? { get set }
    var username: String? { get set }
    var password: String? { get set }
    var identifier: String? { get }
    var additionalAttributes: [String: String] { get set }

    var validEmail: Bool { get set }
    var validUsername: Bool { get set }
    var validPassword: Bool { get set }

    func validAdditionaAttribute(_ name: String) -> Bool
    func validAdditionaAttribute(_ name: String, valid: Bool)
}

protocol PasswordlessUser {
    var email: String? { get set }
    var validEmail: Bool { get set }
    var countryCode: CountryCode? { get set }
}

class User: DatabaseUser, PasswordlessUser {
    var email: String?
    var username: String?
    var password: String?
    var additionalAttributes: [String : String] = [:]
    var additionalAttributesStatus: [String: Bool] = [:]
    var countryCode: CountryCode?

    var validEmail: Bool = false
    var validUsername: Bool = false
    var validPassword: Bool = false

    var identifier: String? {
        guard self.validEmail || self.validUsername else { return nil }
        return self.validEmail ? self.email : self.username
    }

    func reset() {
        if !self.validUsername { self.username = nil }
        if !self.validEmail {
            self.email = nil
            self.countryCode = nil
        }
        self.password = nil
        self.additionalAttributesStatus = [:]
        self.additionalAttributes = [:]
    }

    func validAdditionaAttribute(_ name: String) -> Bool {
        return self.additionalAttributesStatus[name] ?? false
    }

    func validAdditionaAttribute(_ name: String, valid: Bool) {
        self.additionalAttributesStatus[name] = valid
    }
}
