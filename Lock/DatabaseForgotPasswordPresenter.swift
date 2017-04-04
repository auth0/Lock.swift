// DatabaseForgotPasswordPresenter.swift
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

class DatabaseForgotPasswordPresenter: Presentable, Loggable {

    var interactor: PasswordRecoverable
    let database: DatabaseConnection
    var customLogger: Logger?
    var navigator: Navigable
    let options: Options

    init(interactor: PasswordRecoverable, connections: Connections, navigator: Navigable, options: Options) {
        self.interactor = interactor
        self.database = connections.database! // FIXME: Avoid the force unwrap
        self.navigator = navigator
        self.options = options
    }

    var messagePresenter: MessagePresenter?

    var view: View {
        let email = self.interactor.validEmail ? self.interactor.email : nil
        let view = DatabaseForgotPasswordView(email: email)
        let form = view.form

        view.form?.onValueChange = { input in
            self.messagePresenter?.hideCurrent()

            guard case .email = input.type else { return }

            do {
                try self.interactor.updateEmail(input.text)
                input.showValid()
            } catch let error as InputValidationError {
                input.showError(error.localizedMessage(withConnection: self.database))
            } catch {
                input.showError()
            }
        }
        let action = { [weak form] (button: PrimaryButton) in
            self.messagePresenter?.hideCurrent()
            self.logger.info("request forgot password for email \(String(describing: self.interactor.email))")
            let interactor = self.interactor
            button.inProgress = true
            interactor.requestEmail { error in
                Queue.main.async {
                    button.inProgress = false
                    form?.needsToUpdateState()
                    if let error = error {
                        self.messagePresenter?.showError(error)
                        self.logger.error("Failed with error \(error)")
                    } else {
                        let message = "We've just sent you an email to reset your password".i18n(key: "com.auth0.lock.database.forgot.success.message", comment: "forgot password email sent")
                        if self.options.allow.contains(.Login) || !self.options.autoClose {
                            self.messagePresenter?.showSuccess(message)
                        }
                        guard self.options.allow.contains(.Login) else { return }
                        self.navigator.navigate(.root)
                    }
                }
            }
        }
        view.primaryButton?.onPress = action
        view.form?.onReturn = { [unowned view] _ in
            guard let button = view.primaryButton else { return }
            action(button)
        }
        return view
    }
}
