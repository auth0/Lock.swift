// MultifactorPresenter.swift
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

class MultifactorPresenter: Presentable, Loggable {

    var interactor: MultifactorAuthenticatable
    let database: DatabaseConnection
    var customLogger: Logger?
    var navigator: Navigable

    init(interactor: MultifactorAuthenticatable, connection: DatabaseConnection, navigator: Navigable) {
        self.interactor = interactor
        self.database = connection
        self.navigator = navigator
    }

    var messagePresenter: MessagePresenter?

    var view: View {
        let view = MultifactorCodeView()
        let form = view.form

        view.form?.onValueChange = { input in
            self.messagePresenter?.hideCurrent()
            guard case .oneTimePassword = input.type else { return }
            do {
                try self.interactor.setMultifactorCode(input.text)
                input.showValid()
            } catch let error as InputValidationError {
                input.showError(error.localizedMessage(withConnection: self.database))
            } catch {
                input.showError()
            }
        }
        let action = { [weak form] (button: PrimaryButton) in
            self.messagePresenter?.hideCurrent()
            self.logger.debug("resuming with mutifactor code \(String(describing: self.interactor.code))")
            let interactor = self.interactor
            button.inProgress = true
            interactor.login { error in
                Queue.main.async {
                    button.inProgress = false
                    form?.needsToUpdateState()
                    if let error = error {
                        self.messagePresenter?.showError(error)
                        self.logger.error("Failed with error \(error)")
                    }
                }
            }
        }
        view.form?.onReturn = { [unowned view]_ in
            guard let button = view.primaryButton else { return }
            action(button)
        }
        view.primaryButton?.onPress = action
        return view
    }
}
