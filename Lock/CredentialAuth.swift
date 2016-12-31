// CredentialAuth.swift
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

struct CredentialAuth {

    let oidc: Bool
    let realm: String
    let authentication: Authentication

    func request(withIdentifier identifier: String, password: String, options: Options) -> Request<Credentials, AuthenticationError> {
        if oidc {
            return self.authentication.login(
                usernameOrEmail: identifier,
                password: password,
                realm: realm,
                audience: options.audience,
                scope: options.scope
            )
        } else {
            return self.authentication.login(
                usernameOrEmail: identifier,
                password: password,
                connection: realm,
                scope: options.scope,
                parameters: options.parameters
            )
        }
    }
}
