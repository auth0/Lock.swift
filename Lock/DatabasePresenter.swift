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

class DatabasePresenter: Presentable, Loggable {

    let database: DatabaseConnection
    let options: Options

    var authenticator: DatabaseAuthenticatable
    var creator: DatabaseUserCreator
    var navigator: Navigable

    var messagePresenter: MessagePresenter? {
        didSet {
            self.authPresenter?.messagePresenter = self.messagePresenter
        }
    }

    var authPresenter: AuthPresenter?
    var enterpriseInteractor: EnterpriseDomainInteractor?

    var initialEmail: String? { return self.authenticator.validEmail ? self.authenticator.email : nil }
    var initialUsername: String? { return self.authenticator.validUsername ? self.authenticator.username : nil }

    weak var databaseView: DatabaseOnlyView?
    var currentScreen: DatabaseScreen?

    convenience init(interactor: DatabaseInteractor, connection: DatabaseConnection, navigator: Navigable, options: Options) {
        self.init(authenticator: interactor, creator: interactor, connection: connection, navigator: navigator, options: options)
    }

    init(authenticator: DatabaseAuthenticatable, creator: DatabaseUserCreator, connection: DatabaseConnection, navigator: Navigable, options: Options) {
        self.authenticator = authenticator
        self.creator = creator
        self.database = connection
        self.navigator = navigator
        self.options = options
    }

    var view: View {
        let initialScreen = self.options.initialScreen
        let allow = self.options.allow
        let database = DatabaseOnlyView(allowedModes: allow)
        database.navigator = self.navigator
        database.switcher?.onSelectionChange = { [unowned self, weak database] switcher in
            let selected = switcher.selected
            guard let view = database else { return }
            self.logger.debug("selected \(selected)")
            self.navigator.resetScroll(false)
            switch selected {
            case .signup:
                self.showSignup(inView: view, username: self.initialUsername, email: self.initialEmail)
            case .login:
                self.showLogin(inView: view, identifier: self.authenticator.identifier)
            }
        }

        if allow.contains(.Login) && initialScreen == .login {
            database.switcher?.selected = .login
            showLogin(inView: database, identifier: authenticator.identifier)
        } else if allow.contains(.Signup) && (initialScreen == .signup || !allow.contains(.Login)) {
            database.switcher?.selected = .signup
            showSignup(inView: database, username: initialUsername, email: initialEmail)
        }
        self.databaseView = database
        return database
    }

    private func showLogin(inView view: DatabaseView, identifier: String?) {
        self.messagePresenter?.hideCurrent()
        let authCollectionView = self.authPresenter?.newViewToEmbed(withInsets: UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18), isLogin: true)
        let style = self.database.requiresUsername ? self.options.usernameStyle : [.Email]
        view.showLogin(withIdentifierStyle: style, identifier: identifier, authCollectionView: authCollectionView)
        self.currentScreen = .login
        let form = view.form
        form?.onValueChange = self.handleInput

        let action = { [weak form] (button: PrimaryButton) in
            self.messagePresenter?.hideCurrent()
            self.logger.info("Perform login for email: \(self.authenticator.email)")
            button.inProgress = true

            let errorHandler: (LocalizableError?) -> Void = { error in
                Queue.main.async {
                    button.inProgress = false
                    guard let error = error else {
                        self.logger.debug("Logged in!")
                        let message = "You have logged in successfully.".i18n(key: "com.auth0.lock.database.login.success.message", comment: "User logged in")
                        if !self.options.autoClose {
                            self.messagePresenter?.showSuccess(message)
                        }
                        return
                    }
                    if case CredentialAuthError.multifactorRequired = error {
                        self.navigator.navigate(.multifactor)
                    } else {
                        form?.needsToUpdateState()
                        self.messagePresenter?.showError(error)
                        self.logger.error("Failed with error \(error)")
                    }
                }
            }

            if let connection = self.enterpriseInteractor?.connection, let domain = self.enterpriseInteractor?.domain {
                if self.options.enterpriseConnectionUsingActiveAuth.contains(connection.name) {
                    self.navigator.navigate(.enterpriseActiveAuth(connection: connection, domain: domain))
                } else {
                    self.enterpriseInteractor?.login(errorHandler)
                }
            } else {
                self.authenticator.login(errorHandler)
            }

        }

        let primaryButton = view.primaryButton
        view.form?.onReturn = { [weak primaryButton] field in
            guard let button = primaryButton, field.returnKey == .done else { return } // FIXME: Log warn
            action(button)
        }
        view.primaryButton?.onPress = action
        view.secondaryButton?.title = "Don’t remember your password?".i18n(key: "com.auth0.lock.database.button.forgot_password", comment: "Forgot password")
        view.secondaryButton?.color = .clear
        view.secondaryButton?.onPress = { button in
            self.navigator.navigate(.forgotPassword)
        }
    }

    private func showSignup(inView view: DatabaseView, username: String?, email: String?) {
        self.messagePresenter?.hideCurrent()
        let authCollectionView = self.authPresenter?.newViewToEmbed(withInsets: UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18), isLogin: false)
        let interactor = self.authenticator as? DatabaseInteractor
        let passwordPolicyValidator = interactor?.passwordValidator as? PasswordPolicyValidator
        self.currentScreen = .signup

        view.showSignUp(withUsername: self.database.requiresUsername, username: username, email: email, authCollectionView: authCollectionView, additionalFields: self.options.customSignupFields, passwordPolicyValidator: passwordPolicyValidator)
        let form = view.form
        view.form?.onValueChange = self.handleInput
        let action = { [weak form] (button: PrimaryButton) in
            self.messagePresenter?.hideCurrent()
            self.logger.info("perform sign up for email \(self.creator.email)")
            let interactor = self.creator
            button.inProgress = true
            interactor.create { createError, loginError in
                Queue.main.async {
                    button.inProgress = false
                    guard createError != nil || loginError != nil else {
                        if !self.options.loginAfterSignup {
                            let message = "Thanks for signing up.".i18n(key: "com.auth0.lock.database.signup.success.message", comment: "User signed up")
                            if let databaseView = self.databaseView, self.options.allow.contains(.Login) {
                                self.showLogin(inView: databaseView, identifier: self.creator.identifier)
                            }
                            if self.options.allow.contains(.Login) || !self.options.autoClose {
                                self.messagePresenter?.showSuccess(message)
                            }
                        }
                        return
                    }
                    if let error = loginError, case .multifactorRequired = error {
                        self.navigator.navigate(.multifactor)
                        return
                    }
                    let error: LocalizableError = createError ?? loginError!
                    form?.needsToUpdateState()
                    self.messagePresenter?.showError(error)
                    self.logger.error("Failed with error \(error)")

                }
            }
        }

        view.form?.onReturn = { [weak view] field in
            guard let button = view?.primaryButton, field.returnKey == .done else { return } // FIXME: Log warn
            action(button)
        }
        view.primaryButton?.onPress = action
        view.secondaryButton?.title = "By signing up, you agree to our terms of\n service and privacy policy".i18n(key: "com.auth0.lock.database.button.tos", comment: "tos & privacy")
        view.secondaryButton?.color = UIColor ( red: 0.9333, green: 0.9333, blue: 0.9333, alpha: 1.0 )
        view.secondaryButton?.onPress = { button in
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let cancel = UIAlertAction(title: "Cancel".i18n(key: "com.auth0.lock.database.tos.sheet.cancel", comment: "Cancel"), style: .cancel, handler: nil)
            let tos = UIAlertAction(title: "Terms of Service".i18n(key: "com.auth0.lock.database.tos.sheet.title", comment: "ToS"), style: .default, handler: safariBuilder(forURL: self.options.termsOfServiceURL as URL, navigator: self.navigator))
            let privacy = UIAlertAction(title: "Privacy Policy".i18n(key: "com.auth0.lock.database.tos.sheet.privacy", comment: "Privacy"), style: .default, handler: safariBuilder(forURL: self.options.privacyPolicyURL as URL, navigator: self.navigator))
            [cancel, tos, privacy].forEach { alert.addAction($0) }
            self.navigator.present(alert)
        }
    }

    private func handleInput(_ input: InputField) {
        self.messagePresenter?.hideCurrent()

        self.logger.verbose("new value: \(input.text) for type: \(input.type)")
        var updateHRD: Bool = false

        // FIXME: enum mapping outlived its usefulness
        let attribute: UserAttribute
        switch input.type {
        case .email:
            attribute = .email
            updateHRD = true
        case .emailOrUsername:
            attribute = .emailOrUsername
            updateHRD = true
        case .password:
            attribute = .password(enforcePolicy: self.currentScreen == .signup)
        case .username:
            attribute = .username
        case .custom(let name, _, _, _, _, _):
            attribute = .custom(name: name)
        default:
            return
        }

        do {
            try self.authenticator.update(attribute, value: input.text)
            input.showValid()

            guard
                    let mode = self.databaseView?.switcher?.selected,
                    mode == .login && updateHRD
                    else { return }
            try? self.enterpriseInteractor?.updateEmail(input.text)
            if let connection = self.enterpriseInteractor?.connection {
                self.logger.verbose("Enterprise connection detected: \(connection)")
                if self.databaseView?.ssoBar == nil { self.databaseView?.presentEnterprise() }
            } else {
                self.databaseView?.removeEnterprise()
            }
        } catch let error as InputValidationError {
            input.showError(error.localizedMessage(withConnection: self.database))
        } catch {
            input.showError()
        }
    }
}

private func safariBuilder(forURL url: URL, navigator: Navigable) -> (UIAlertAction) -> Void {
    return { _ in
        let safari = SFSafariViewController(url: url)
        navigator.present(safari)
    }
}
