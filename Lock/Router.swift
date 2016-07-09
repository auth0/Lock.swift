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

struct Router: ForgotPasswordDisplayable {
    weak var controller: LockViewController?

    let lock: Lock
    let onDismiss: () -> ()
    let onAuthentication: (Credentials) -> ()

    init(lock: Lock, controller: LockViewController) {
        self.controller = controller
        self.lock = lock
        self.onDismiss = { [weak controller] in
            dispatch_async(dispatch_get_main_queue()) {
                controller?.dismissViewControllerAnimated(true, completion: { _ in
                    lock.callback(.Cancelled)
                })
            }
        }
        self.onAuthentication = { [weak controller] credentials in
            dispatch_async(dispatch_get_main_queue()) {
                controller?.dismissViewControllerAnimated(true, completion: { _ in
                    lock.callback(.Success(credentials))
                })
            }
        }

        self.onBack = {
            switch self.controller?.state ?? .Root {
            case .ForgotPassword:
                self.showRoot()
            default:
                break
            }
        }
    }

    var root: Presentable? {
        guard let connections = self.lock.connections else { return nil } // FIXME: show error screen
        let authentication = self.lock.authentication
        let interactor = DatabaseInteractor(connections: connections, authentication: authentication, callback: self.onAuthentication)
        let presenter = DatabasePresenter(interactor: interactor, connections: connections, forgotDisplayable: self)
        return presenter
    }

    var showBack: Bool {
        if case .ForgotPassword = self.controller?.state ?? .Root { return true }
        return false
    }

    var onBack: () -> () = {}

    mutating func showRoot() {
        let root = self.root
        self.controller?.present(root, state: .Root)
    }

    func showForgotPassword() {
        guard let connections = self.lock.connections else { return } // FIXME: show error screen
        let interactor = DatabasePasswordInteractor(connections: connections, authentication: self.lock.authentication)
        self.controller?.present(DatabaseForgotPasswordPresenter(interactor: interactor, connections: connections), state: .ForgotPassword)
    }
}