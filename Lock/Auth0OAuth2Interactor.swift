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

struct Auth0OAuth2Interactor: OAuth2Authenticatable, Loggable {

    let authentication: Authentication
    let dispatcher: Dispatcher
    let options: Options
    let nativeHandlers: [String: AuthProvider]

    func login(_ connection: String, loginHint: String?, callback: @escaping (OAuth2AuthenticatableError?) -> Void) {
        if let nativeHandler = self.nativeHandlers[connection], type(of: nativeHandler).isAvailable() {
            self.nativeAuth(withConnection: connection, nativeAuth: nativeHandler, callback: callback)
        } else {
            self.webAuth(withConnection: connection, loginHint: loginHint, callback: callback)
        }
    }

    private func webAuth(withConnection connection: String, loginHint: String?, callback: @escaping (OAuth2AuthenticatableError?) -> Void) {

        var parameters: [String: String] = [:]
        self.options.parameters.forEach { parameters[$0] = "\($1)" }
        parameters["login_hint"] = loginHint

        var auth = authentication
            .webAuth(withConnection: connection)
            .scope(self.options.scope)
            .parameters(parameters)

        auth = auth.logging(enabled: self.options.logHttpRequest)

        if let audience = self.options.audience {
            auth = auth.audience(audience)
        }

        if let connectionScope = self.options.connectionScope[connection] {
            auth = auth.connectionScope(connectionScope)
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

    private func nativeAuth(withConnection connection: String, nativeAuth: AuthProvider, callback: @escaping (OAuth2AuthenticatableError?) -> Void) {

        nativeAuth.login(withConnection: connection, scope: self.options.scope, parameters: self.options.parameters)
            .start { result in
                Queue.main.async {
                    switch result {
                    case .success(let credentials):
                        callback(nil)
                        self.dispatcher.dispatch(result: .auth(credentials))
                    case .failure(let error):
                        callback(.couldNotAuthenticate)
                        self.dispatcher.dispatch(result: .error(error))
                    }
                }
            }
    }
}
