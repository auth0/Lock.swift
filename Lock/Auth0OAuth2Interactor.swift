// Auth0OAuth2Interactor.swift
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

struct Auth0OAuth2Interactor: OAuth2Authenticatable {

    let webAuth: Auth0.WebAuth
    let dispatcher: Dispatcher
    let options: Options

    func login(_ connection: String, callback: @escaping (OAuth2AuthenticatableError?) -> ()) {
        var parameters: [String: String] = [:]
        self.options.parameters.forEach { parameters[$0] = "\($1)" }
        var auth = self.webAuth
            .connection(connection)
            .scope(self.options.scope)
            .parameters(parameters)

        if let audience = self.options.audience {
            auth = auth.audience(audience)
        }

        auth
            .start { result in
                switch result {
                case .success(let credentials):
                    callback(nil)
                    self.dispatcher.dispatch(result: .auth(credentials))
                case .failure(WebAuthError.userCancelled):
                    callback(.cancelled)
                    self.dispatcher.dispatch(result: .error(WebAuthError.userCancelled))
                case .failure:
                    callback(.couldNotAuthenticate)
                    self.dispatcher.dispatch(result: .error(OAuth2AuthenticatableError.couldNotAuthenticate))
                }
            }
    }
}
