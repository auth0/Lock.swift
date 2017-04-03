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

protocol Router: Navigable {
    var observerStore: ObserverStore { get }
    var controller: LockViewController? { get }
    var root: Presentable? { get }
}

extension Router {
    func present(_ controller: UIViewController) {
        self.controller?.present(controller, animated: true, completion: nil)
    }

    func resetScroll(_ animated: Bool) {
        self.controller?.scrollView.setContentOffset(CGPoint.zero, animated: animated)
    }

    func scroll(toPosition: CGPoint, animated: Bool) {
        self.controller?.scrollView.setContentOffset(toPosition, animated: animated)
    }

    func exit(withError error: Error) {
        let controller = self.controller?.presentingViewController
        let observerStore = self.observerStore
        Queue.main.async {
            controller?.dismiss(animated: true, completion: { _ in
                observerStore.onFailure(error)
            })
        }
    }

    func reload(with connections: Connections) {
        self.controller?.reload(connections: connections)
    }

    func unrecoverableError(for error: UnrecoverableError) -> Presentable? {
        guard let options = self.controller?.lock.options else { return nil }
        let presenter = UnrecoverableErrorPresenter(error: error, navigator: self, options: options)
        return presenter
    }
}
