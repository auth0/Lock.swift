// ObserverStore.swift
//
// Copyright (c) 2017 Auth0 (http://auth0.com)
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

struct ObserverStore: Dispatcher {
    var onAuth: (Credentials) -> () = { _ in }
    var onFailure: (Error) -> () = { _ in }
    var onCancel: () -> () = {  }
    var onSignUp: (String, [String: Any]) -> () = { _ in }

    weak var controller: UIViewController?

    func dispatch(result: Result) {
        let closure: () -> ()
        switch result {
        case .auth(let credentials):
            closure = dismiss(from: controller?.presentingViewController, completion: { self.onAuth(credentials) })
        case .error(let error):
            closure = { self.onFailure(error) }
        case .cancel:
            closure = dismiss(from: controller?.presentingViewController, completion: { self.onCancel() })
        case .signUp(let email, let attributes):
            closure = { self.onSignUp(email, attributes) }
        default:
            closure = {}
        }
        Queue.main.async(closure)
    }

    private func dismiss(from controller: UIViewController?, completion: @escaping () -> ()) -> () -> () {
        guard let controller = controller else { return completion }
        return { controller.dismiss(animated: true, completion: completion) }
    }
}

enum Result {
    case auth(Credentials)
    case error(Error)
    case cancel
    case signUp(String, [String: Any])
    case forgotPassword(String)
}

protocol Dispatcher {
    func dispatch(result: Result)
}
