// PasswordlessRouter.swift
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

struct PasswordlessRouter: Router {

    weak var controller: LockViewController?

    let user = User()
    let lock: Lock

    var observerStore: ObserverStore { return self.lock.observerStore }

    init(lock: Lock, controller: LockViewController) {
        self.controller = controller
        self.lock = lock
    }

    var root: Presentable? {
        let connections = self.lock.connections
        guard !connections.isEmpty else {
            self.lock.logger.debug("No connections configured. Loading client info from Auth0...")
            let interactor = CDNLoaderInteractor(baseURL: self.lock.authentication.url, clientId: self.lock.authentication.clientId)
            return ConnectionLoadingPresenter(loader: interactor, navigator: self, dispatcher: observerStore, options: self.lock.options)
        }

        // Passwordless Email
        if let connection = connections.passwordless.filter({ $0.strategy == "email" }).first ?? connections.passwordless.filter({ $0.strategy == "sms" }).first {
            let passwordlessActivity = PasswordlessActivity.shared
            passwordlessActivity.dispatcher = self.lock.observerStore
            passwordlessActivity.messagePresenter = self.controller?.messagePresenter
            let interactor = PasswordlessInteractor(connection: connection, authentication: self.lock.authentication, dispatcher: observerStore, user: self.user, options: self.lock.options, passwordlessActivity: passwordlessActivity)
            let presenter = PasswordlessPresenter(interactor: interactor, connection: connection, navigator: self, options: self.lock.options)
            // +Social
            if !connections.oauth2.isEmpty {
                let interactor = Auth0OAuth2Interactor(authentication: self.lock.authentication, dispatcher: observerStore, options: self.lock.options, nativeHandlers: self.lock.nativeHandlers)
                presenter.authPresenter = AuthPresenter(connections: connections.oauth2, interactor: interactor, customStyle: self.lock.style.oauth2)
            }
            return presenter
        }
        // Social Only
        if !connections.oauth2.isEmpty {
            let interactor = Auth0OAuth2Interactor(authentication: self.lock.authentication, dispatcher: observerStore, options: self.lock.options, nativeHandlers: self.lock.nativeHandlers)
            let presenter = AuthPresenter(connections: connections.oauth2, interactor: interactor, customStyle: self.lock.style.oauth2)
            return presenter
        }

        return nil
    }

    func passwordless(withScreen screen: PasswordlessScreen, connection: PasswordlessConnection) -> Presentable? {
        let passwordlessActivity = PasswordlessActivity.shared
        passwordlessActivity.dispatcher = self.lock.observerStore
        passwordlessActivity.messagePresenter = self.controller?.messagePresenter
        let interactor = PasswordlessInteractor(connection: connection, authentication: self.lock.authentication, dispatcher: observerStore, user: self.user, options: self.lock.options, passwordlessActivity: passwordlessActivity)
        let presenter = PasswordlessPresenter(interactor: interactor, connection: connection, navigator: self, options: self.lock.options, screen: screen)
        return presenter
    }

    func onBack() {
        guard let current = self.controller?.routes.back() else { return }

        self.user.reset()

        let style = self.lock.style

        self.lock.logger.debug("Back pressed. Showing \(current)")
        switch current {
        case .root:
            self.controller?.present(self.root, title: style.hideTitle ? nil : style.title)
        default:
            break
        }
    }

    func navigate(_ route: Route) {
        let presentable: Presentable?
        switch route {
        case .root where self.controller?.routes.current != .root:
            presentable = self.root
        case .unrecoverableError(let error):
            presentable = self.unrecoverableError(for: error)
        case .passwordless(let screen, let connection):
            presentable = self.passwordless(withScreen: screen, connection: connection)
        default:
            self.lock.logger.warn("Ignoring navigation \(route)")
            return
        }
        self.lock.logger.debug("Navigating to \(route)")
        self.controller?.routes.go(route)
        self.controller?.present(presentable, title: route.title(withStyle: self.lock.style))
    }
}
