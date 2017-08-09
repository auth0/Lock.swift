// DatabaseChangePasswordPresenter.swift
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

class DatabaseChangePasswordPresenter: Presentable, Loggable {

    var interactor: PasswordChangeable
    let database: DatabaseConnection
    var customLogger: Logger?
    var navigator: Navigable
    let options: Options

    init(interactor: PasswordChangeable, connection: DatabaseConnection, navigator: Navigable, options: Options) {
        self.interactor = interactor
        self.database = connection
        self.navigator = navigator
        self.options = options
    }

    var messagePresenter: MessagePresenter?

    var view: View {
        let view = DatabaseChangePasswordView(passwordPolicyValidator: database.passwordValidator, showPassword: self.options.allowShowPassword)
        let form = view.form

        view.form?.onValueChange = { input in
            self.messagePresenter?.hideCurrent()
            do {
                try self.interactor.update(input)
                input.showValid()
            } catch let error as InputValidationError {
                input.showError(error.localizedMessage(withConnection: self.database))
            } catch {
                input.showError()
            }
        }

        let action = { [weak form] (button: PrimaryButton) in
            self.messagePresenter?.hideCurrent()
            self.logger.info("change password for email: \(self.interactor.email.verbatim())")
            let interactor = self.interactor
            button.inProgress = true
            interactor.changePassword { error in
                Queue.main.async {
                    button.inProgress = false
                    form?.needsToUpdateState()
                    if let error = error {
                        self.messagePresenter?.showError(error)
                        self.logger.error("Failed with error \(error)")
                    } else {
                        let message = "Your password was successfully changed.".i18n(key: "com.auth0.lock.database.change_password.success.message", comment: "change password success")
                        if !self.options.autoClose {
                            self.messagePresenter?.showSuccess(message)
                        }
                        self.navigator.navigate(.root)
                    }
                }
            }
        }
        view.primaryButton?.onPress = action
        view.form?.onReturn = { [weak view] field in
            guard let button = view?.primaryButton, field.returnKey == .done else { return } // FIXME: Log warn
            action(button)
        }
        return view
    }
}
