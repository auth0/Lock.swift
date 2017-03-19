// ConnectionLoadingPresenter.swift
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

class ConnectionLoadingPresenter: Presentable, Loggable {
    var messagePresenter: MessagePresenter?
    let loader: RemoteConnectionLoader
    let navigator: Navigable
    let options: Options
    let dispatcher: Dispatcher

    init(loader: RemoteConnectionLoader, navigator: Navigable, dispatcher: Dispatcher, options: Options) {
        self.loader = loader
        self.navigator = navigator
        self.options = options
        self.dispatcher = dispatcher
    }

    var view: View {
        self.loader.load { error, connections in
            guard error == nil else {
                #if DEBUG
                    if let error = error {
                        assertionFailure(error.localizableMessage)
                    }
                #endif
                return Queue.main.async {
                    self.navigator.navigate(.unrecoverableError(error: error!))
                    self.dispatcher.dispatch(result: .error(error!))
                }
            }
            guard let connections = connections, !connections.isEmpty else {
                return self.navigator.exit(withError: UnrecoverableError.clientWithNoConnections)
            }
            Queue.main.async {
                self.logger.debug("Loaded connections. Moving to root view")
                self.navigator.reload(with: connections)
            }
        }
        return LoadingView()
    }
}
