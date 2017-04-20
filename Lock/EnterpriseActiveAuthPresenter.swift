// EnterpriseActiveAuthPresenter.swift
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

class EnterpriseActiveAuthPresenter: Presentable, Loggable {

    var interactor: EnterpriseActiveAuthInteractor
    var customLogger: Logger?
    let options: Options
    let domain: String?

    init(interactor: EnterpriseActiveAuthInteractor, options: Options, domain: String? = nil) {
        self.interactor = interactor
        self.options = options
        self.domain = domain
    }

    var messagePresenter: MessagePresenter?

    var view: View {
        var identifier: String?

        if let email = self.interactor.email, self.interactor.validEmail {
            identifier = email
        } else if let username = self.interactor.username, self.interactor.validUsername {
            identifier = username
        }

        let view = EnterpriseActiveAuthView(identifier: identifier, identifierAttribute: self.interactor.identifierAttribute, domain: self.domain)
        let form = view.form

        view.form?.onValueChange = { input in
            self.messagePresenter?.hideCurrent()

            do {
                switch input.type {
                case .email, .username:
                    try self.interactor.update(self.interactor.identifierAttribute, value: input.text)
                    input.showValid()
                case .password:
                    try self.interactor.update(.password(enforcePolicy: false), value: input.text)
                    input.showValid()
                default:
                    self.logger.warn("Invalid user attribute")
                }
            } catch {
                input.showError()
            }
        }

        let action = { [weak form] (button: PrimaryButton) in
            self.messagePresenter?.hideCurrent()
            self.logger.info("Enterprise password connection started: \(self.interactor.identifier.verbatim()), \(self.interactor.connection)")
            let interactor = self.interactor

            button.inProgress = true
            interactor.login { error in
                Queue.main.async {
                    button.inProgress = false
                    form?.needsToUpdateState()
                    if let error = error {
                        self.messagePresenter?.showError(error)
                        self.logger.error("Enterprise connection failed: \(error)")
                    } else {
                        self.logger.debug("Enterprise connection success")
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
