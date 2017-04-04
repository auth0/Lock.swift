// PasswordlessPresenter.swift
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

class PasswordlessPresenter: Presentable, Loggable {

    var interactor: PasswordlessAuthenticatable
    let connection: PasswordlessConnection
    let navigator: Navigable
    let options: Options
    let screen: PasswordlessScreen
    var authPresenter: AuthPresenter?

    init(interactor: PasswordlessAuthenticatable, connection: PasswordlessConnection, navigator: Navigable, options: Options, screen: PasswordlessScreen = .request) {
        self.interactor = interactor
        self.connection = connection
        self.navigator = navigator
        self.options = options
        self.screen = screen
    }

    var messagePresenter: MessagePresenter?

    var view: View {
        switch self.screen {
        case .request, .code:
            return self.showForm(screen: self.screen)
        case .linkSent:
            return self.showLinkSent()
        }
    }

    private func showForm(screen: PasswordlessScreen) -> View {
        let authCollectionView = self.authPresenter?.newViewToEmbed(withInsets: UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18), isLogin: true)

        let view = PasswordlessEmailView()
        view.showForm(email: self.interactor.identifier, screen: screen, authCollectionView: authCollectionView)
        let form = view.form

        let inputMode = screen == .request ? InputField.InputType.email : InputField.InputType.oneTimePassword

        view.form?.onValueChange = { input in
            self.messagePresenter?.hideCurrent()
            do {
                try self.interactor.update(inputMode, value: input.text)
                input.showValid()
            } catch {
                input.showError()
            }
        }

        let action = { [weak form] (button: PrimaryButton) in
            self.messagePresenter?.hideCurrent()
            let interactor = self.interactor
            let connection = self.connection
            button.inProgress = true
            if screen == .request {
                self.logger.info("Request passwordless \(String(describing: self.interactor.identifier))")
                interactor.request(connection.name) { error in
                    Queue.main.async {
                        button.inProgress = false
                        form?.needsToUpdateState()
                        if let error = error {
                            self.messagePresenter?.showError(error)
                            self.logger.error("Failed with error \(error)")
                        } else {
                            if self.options.passwordlessMethod == .emailCode {
                                self.navigator.navigate(Route.passwordlessEmail(screen: .code, connection: connection))
                            } else {
                                self.navigator.navigate(Route.passwordlessEmail(screen: .linkSent, connection: connection))
                            }
                        }
                    }
                }
            } else {
                self.logger.info("Login passwordless \(String(describing: self.interactor.identifier))")
                interactor.login(connection.name) { error in
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
        }

        view.primaryButton?.onPress = action
        view.form?.onReturn = { [unowned view] _ in
            guard let button = view.primaryButton else { return }
            action(button)
        }

        if screen == .code {
            view.secondaryButton?.onPress = { button in
                self.navigator.onBack()
            }
        }
        return view
    }

    private func showLinkSent() -> View {
        let view = PasswordlessEmailView()
        view.showLinkSent(email: self.interactor.identifier)
        view.secondaryButton?.onPress = { button in
            self.navigator.onBack()
        }
        return view
    }
}
