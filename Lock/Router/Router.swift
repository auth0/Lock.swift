// Router.swift
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

protocol Navigable {
    func navigate(route: Route)
}

struct Router: Navigable {
    weak var controller: LockViewController?

    let user = User()
    let lock: Lock
    let onDismiss: () -> ()
    let onAuthentication: (Credentials) -> ()

    init(lock: Lock, controller: LockViewController) {
        self.controller = controller
        self.lock = lock
        self.onDismiss = { [weak controller] in
            Queue.main.async {
                controller?.dismissViewControllerAnimated(true, completion: { _ in
                    lock.callback(.Cancelled)
                })
            }
        }
        self.onAuthentication = { [weak controller] credentials in
            Queue.main.async {
                controller?.dismissViewControllerAnimated(true, completion: { _ in
                    lock.callback(.Success(credentials))
                })
            }
        }

        self.onBack = {
            guard let current = self.controller?.routes.back() else { return }

            self.user.reset()

            switch current {
            case .ForgotPassword:
                self.controller?.present(self.forgotPassword)
            case .Root:
                self.controller?.present(self.root)
            default:
                break
            }
        }
    }

    var root: Presentable? {
        guard let connections = self.lock.connections else { return nil } // FIXME: show error screen

        if connections.database != nil {
            let authentication = self.lock.authentication
            let interactor = DatabaseInteractor(connections: connections, authentication: authentication, user: self.user, callback: self.onAuthentication)
            let presenter = DatabasePresenter(interactor: interactor, connections: connections, navigator: self, options: self.lock.options)
            return presenter
        }

        if !connections.social.isEmpty {
            let interactor = Auth0OAuth2Interactor(webAuth: self.lock.webAuth, onCredentials: self.onAuthentication)
            return SocialPresenter(connections: connections, interactor: interactor)
        }
        return nil
    }

    var forgotPassword: Presentable? {
        guard let connections = self.lock.connections else { return nil } // FIXME: show error screen
        let interactor = DatabasePasswordInteractor(connections: connections, authentication: self.lock.authentication, user: self.user)
        return DatabaseForgotPasswordPresenter(interactor: interactor, connections: connections)
    }

    var multifactor: Presentable? {
        guard let connections = self.lock.connections, let database = connections.database else { return nil } // FIXME: show error screen
        let authentication = self.lock.authentication
        let interactor = MultifactorInteractor(user: self.user, authentication: authentication, connection: database, callback: self.onAuthentication)
        return MultifactorPresenter(interactor: interactor, connection: database)
    }

    var showBack: Bool {
        guard let routes = self.controller?.routes else { return false }
        return !routes.history.isEmpty
    }

    var onBack: () -> () = {}

    func navigate(route: Route) {
        let presentable: Presentable?
        switch route {
        case .Root:
            presentable = self.root
        case .ForgotPassword:
            presentable = self.forgotPassword
        case .Multifactor:
            presentable = self.multifactor
        }
        self.controller?.routes.go(route)
        self.controller?.present(presentable)
    }
}