// AuthPresenter.swift
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

class AuthPresenter: Presentable, Loggable {

    let compactModeThreshold = 3
    let connections: [OAuth2Connection]
    let interactor: OAuth2Authenticatable
    let nativeInteractor: NativeAuthenticatable
    let customStyle: [String: AuthStyle]
    let nativeHandlers: [NativeAuthHandler]

    var messagePresenter: MessagePresenter?

    init(connections: Connections, interactor: OAuth2Authenticatable, nativeInteractor: NativeAuthenticatable, nativeHandlers: [NativeAuthHandler], customStyle: [String: AuthStyle]) {
        self.connections = connections.oauth2
        self.interactor = interactor
        self.customStyle = customStyle
        self.nativeInteractor = nativeInteractor
        self.nativeHandlers = nativeHandlers
    }

    var view: View {
        return self.newView(withInsets: UIEdgeInsets(top: 18, left: 18, bottom: 18, right: 18), mode: .expanded(isLogin: true))
    }

    func newViewToEmbed(withInsets insets: UIEdgeInsets, isLogin: Bool = true) -> AuthCollectionView {
        let mode: AuthCollectionView.Mode
        if (self.connections.count < compactModeThreshold) {
            mode = .expanded(isLogin: isLogin)
        } else {
            mode = .compact
        }
        return self.newView(withInsets: insets, mode: mode)
    }

    private func newView(withInsets insets: UIEdgeInsets, mode: AuthCollectionView.Mode) -> AuthCollectionView {

        let connections = assignNativeHandlers(self.nativeHandlers, connections: self.connections)

        let view = AuthCollectionView(connections: connections, mode: mode, insets: insets, customStyle: self.customStyle) { name, handler in
            if let handler = handler {
                self.nativeInteractor.login(name, nativeAuth: handler) { error in
                    guard let error = error else { return }
                    self.messagePresenter?.showError(error)
                }
            } else {
                self.interactor.login(name) { error in
                    guard let error = error else { return }
                    self.messagePresenter?.showError(error)
                }
            }
        }
        return view
    }

    private func assignNativeHandlers(_ nativeHandlers: [NativeAuthHandler], connections: [OAuth2Connection]) -> [OAuth2Connection] {
        var socialConnections: [SocialConnection] = []

        for connection in self.connections {
            if let authHandler = self.nativeHandlers.filter({ $0.name == connection.name }).first {
                socialConnections.append(SocialConnection(name: connection.name, style: connection.style, handler: authHandler.handler))
            } else {
                socialConnections.append(SocialConnection(name: connection.name, style: connection.style))
            }
        }
        return socialConnections
    }
}
