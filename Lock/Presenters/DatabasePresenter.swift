// DatabasePresenter.swift
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
import SafariServices

class DatabasePresenter: Presentable {

    let database: DatabaseConnection
    let options: Options

    var interactor: DatabaseAuthenticatable
    var navigator: Navigable

    var messagePresenter: MessagePresenter?
    var authPresenter: AuthPresenter?

    var initialEmail: String? { return self.interactor.validEmail ? self.interactor.email : nil }
    var initialUsername: String? { return self.interactor.validUsername ? self.interactor.username : nil }

    init(interactor: DatabaseAuthenticatable, connection: DatabaseConnection, navigator: Navigable, options: Options) {
        self.interactor = interactor
        self.database = connection
        self.navigator = navigator
        self.options = options
    }

    var view: View {
        let database = DatabaseOnlyView()
        database.switcher?.onSelectionChange = { [weak database] switcher in
            let selected = switcher.selected
            guard let view = database else { return }
            print("selected \(selected)")
            switch selected {
            case .Signup:
                self.showSignup(inView: view, username: self.initialUsername, email: self.initialEmail)
            case .Login:
                self.showLogin(inView: view, identifier: self.interactor.identifier)
            default:
                print("invalid db mode")
            }
        }
        showLogin(inView: database, identifier: interactor.identifier)
        return database
    }

    private func showLogin(inView view: DatabaseView, identifier: String?) {
        self.messagePresenter?.hideCurrent()
        let authCollectionView = self.authPresenter?.newViewToEmbed(withInsets: UIEdgeInsetsMake(0, 18, 0, 18), isLogin: true)
        view.showLogin(withUsername: self.database.requiresUsername, identifier: identifier, authCollectionView: authCollectionView)
        let form = view.form
        form?.onValueChange = self.handleInput

        let action = { [weak form] (button: PrimaryButton) in
            self.messagePresenter?.hideCurrent()
            print("perform login for email \(self.interactor.email)")
            let interactor = self.interactor
            button.inProgress = true
            interactor.login { error in
                Queue.main.async {
                    button.inProgress = false
                    guard let error = error else {
                        print("Logged in!")
                        return
                    }
                    if case .MultifactorRequired = error {
                        self.navigator.navigate(.Multifactor)
                    } else {
                        form?.needsToUpdateState()
                        self.messagePresenter?.showError("\(error)")
                        print("Failed with error \(error)")
                    }
                }
            }
        }
        view.form?.onReturn = { field in
            guard let button = view.primaryButton where field.returnKey == .Done else { return } // FIXME: Log warn
            action(button)
        }
        view.primaryButton?.onPress = action
        view.secondaryButton?.title = DatabaseModes.ForgotPassword.title
        view.secondaryButton?.color = .clearColor()
        view.secondaryButton?.onPress = { button in
            self.navigator.navigate(.ForgotPassword)
        }
    }

    private func showSignup(inView view: DatabaseView, username: String?, email: String?) {
        self.messagePresenter?.hideCurrent()
        let authCollectionView = self.authPresenter?.newViewToEmbed(withInsets: UIEdgeInsetsMake(0, 18, 0, 18), isLogin: false)
        view.showSignUp(withUsername: self.database.requiresUsername, username: username, email: email, authCollectionView: authCollectionView)
        let form = view.form
        view.form?.onValueChange = self.handleInput
        let action = { [weak form] (button: PrimaryButton) in
            self.messagePresenter?.hideCurrent()
            print("perform sign up for email \(self.interactor.email)")
            let interactor = self.interactor
            button.inProgress = true
            interactor.create { error in
                Queue.main.async {
                    button.inProgress = false
                    guard let error = error else {
                        print("Logged in!")
                        return
                    }
                    if case .MultifactorRequired = error {
                        self.navigator.navigate(.Multifactor)
                    } else {
                        form?.needsToUpdateState()
                        self.messagePresenter?.showError("\(error)")
                        print("Failed with error \(error)")
                    }
                }
            }
        }

        view.form?.onReturn = { field in
            guard let button = view.primaryButton where field.returnKey == .Done else { return } // FIXME: Log warn
            action(button)
        }
        view.primaryButton?.onPress = action
        view.secondaryButton?.title = "By signing up, you agree to our terms of\n service and privacy policy".i18n(key: "com.auth0.lock.database.tos.button.title", comment: "tos & privacy")
        view.secondaryButton?.color = UIColor ( red: 0.9333, green: 0.9333, blue: 0.9333, alpha: 1.0 )
        view.secondaryButton?.onPress = { button in
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            let cancel = UIAlertAction(title: "Cancel".i18n(key: "com.auth0.lock.database.tos.sheet.cancel.title", comment: "Cancel"), style: .Cancel, handler: nil)
            let tos = UIAlertAction(title: "Terms of Service".i18n(key: "com.auth0.lock.database.tos.sheet.tos.title", comment: "ToS"), style: .Default, handler: safariBuilder(forURL: self.options.termsOfServiceURL, presenter: self.messagePresenter))
            let privacy = UIAlertAction(title: "Privacy Policy".i18n(key: "com.auth0.lock.database.tos.sheet.privacy.title", comment: "Privacy"), style: .Default, handler: safariBuilder(forURL: self.options.privacyPolicyURL, presenter: self.messagePresenter))
            [cancel, tos, privacy].forEach { alert.addAction($0) }
            self.messagePresenter?.present(alert)
        }
    }

    private func handleInput(input: InputField) {
        self.messagePresenter?.hideCurrent()
        print("new value: \(input.text) for type: \(input.type)")
        let attribute: CredentialAttribute?
        switch input.type {
        case .Email:
            attribute = .Email
        case .EmailOrUsername:
            attribute = .EmailOrUsername
        case .Password:
            attribute = .Password
        case .Username:
            attribute = .Username
        default:
            attribute = nil
        }

        guard let attr = attribute else { return }
        do {
            try self.interactor.update(attr, value: input.text)
            input.showValid()
        } catch let error as InputValidationError {
            input.showError(error.localizedMessage)
        } catch {
            input.showError()
        }
    }
}

private func safariBuilder(forURL url: NSURL, presenter: MessagePresenter?) -> (UIAlertAction) -> () {
    return { _ in
        let safari = SFSafariViewController(URL: url)
        presenter?.present(safari)
    }
}