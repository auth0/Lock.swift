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
    
    var messagePresenter: MessagePresenter?
    var authPresenter: AuthPresenter?
    var enterpriseInteractor: EnterpriseDomainInteractor?
    
    var initialEmail: String? { return self.authenticator.validEmail ? self.authenticator.email : nil }
    var initialUsername: String? { return self.authenticator.validUsername ? self.authenticator.username : nil }
    
    weak var databaseView:DatabaseOnlyView?
    
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
        database.switcher?.onSelectionChange = { [weak database] switcher in
            let selected = switcher.selected
            guard let view = database else { return }
            self.logger.debug("selected \(selected)")
            self.navigator.resetScroll(false)
            switch selected {
            case .Signup:
                self.showSignup(inView: view, username: self.initialUsername, email: self.initialEmail)
            case .Login:
                self.showLogin(inView: view, identifier: self.authenticator.identifier)
            }
        }
        
        if allow.contains(.Login) && initialScreen == .Login {
            database.switcher?.selected = .Login
            showLogin(inView: database, identifier: authenticator.identifier)
        } else if allow.contains(.Signup) && (initialScreen == .Signup || !allow.contains(.Login)) {
            database.switcher?.selected = .Signup
            showSignup(inView: database, username: initialUsername, email: initialEmail)
        }
        self.databaseView = database
        return database
    }
    
    private func showLogin(inView view: DatabaseView, identifier: String?) {
        self.messagePresenter?.hideCurrent()
        let authCollectionView = self.authPresenter?.newViewToEmbed(withInsets: UIEdgeInsetsMake(0, 18, 0, 18), isLogin: true)
        let style = self.database.requiresUsername ? self.options.usernameStyle : [.Email]
        view.showLogin(withIdentifierStyle: style, identifier: identifier, authCollectionView: authCollectionView)
        let form = view.form
        form?.onValueChange = self.handleInput
        
        let action = { [weak form] (button: PrimaryButton) in
            self.messagePresenter?.hideCurrent()
            self.logger.info("Perform login for email: \(self.authenticator.email)")
            button.inProgress = true
            
            // Enterprise Authentication
            if self.enterpriseInteractor?.isEnterprise(self.authenticator.email) == true {
                self.enterpriseInteractor?.login { error in
                    Queue.main.async {
                        button.inProgress = false
                        form?.needsToUpdateState()
                        if let error = error {
                            self.messagePresenter?.showError(error)
                            self.logger.error("Enterprise connection failed: \(error)")
                        } else {
                            self.logger.debug("Enterprise authenticator launched")
                        }
                    }
                    
                }
                
            } else {
                // Database Authentication
                let interactor = self.authenticator
                interactor.login { error in
                    Queue.main.async {
                        button.inProgress = false
                        guard let error = error else {
                            self.logger.debug("Logged in!")
                            return
                        }
                        if case .MultifactorRequired = error {
                            self.navigator.navigate(.Multifactor)
                        } else {
                            form?.needsToUpdateState()
                            self.messagePresenter?.showError(error)
                            self.logger.error("Failed with error \(error)")
                        }
                    }
                }
            }
        }
        
        view.form?.onReturn = { field in
            guard let button = view.primaryButton where field.returnKey == .Done else { return } // FIXME: Log warn
            action(button)
        }
        view.primaryButton?.onPress = action
        view.secondaryButton?.title = "Don’t remember your password?".i18n(key: "com.auth0.lock.database.button.forgot-password", comment: "Forgot password")
        view.secondaryButton?.color = .clearColor()
        view.secondaryButton?.onPress = { button in
            self.navigator.navigate(.ForgotPassword)
        }
    }
    
    private func showSignup(inView view: DatabaseView, username: String?, email: String?) {
        self.messagePresenter?.hideCurrent()
        let authCollectionView = self.authPresenter?.newViewToEmbed(withInsets: UIEdgeInsetsMake(0, 18, 0, 18), isLogin: false)
        view.showSignUp(withUsername: self.database.requiresUsername, username: username, email: email, authCollectionView: authCollectionView, additionalFields: self.options.customSignupFields)
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
                        self.logger.debug("Logged in!")
                        return
                    }
                    if let error = loginError, case .MultifactorRequired = error {
                        self.navigator.navigate(.Multifactor)
                        return
                    }
                    
                    let error: LocalizableError = createError ?? loginError!
                    form?.needsToUpdateState()
                    self.messagePresenter?.showError(error)
                    self.logger.error("Failed with error \(error)")
                    
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
            let tos = UIAlertAction(title: "Terms of Service".i18n(key: "com.auth0.lock.database.tos.sheet.tos.title", comment: "ToS"), style: .Default, handler: safariBuilder(forURL: self.options.termsOfServiceURL, navigator: self.navigator))
            let privacy = UIAlertAction(title: "Privacy Policy".i18n(key: "com.auth0.lock.database.tos.sheet.privacy.title", comment: "Privacy"), style: .Default, handler: safariBuilder(forURL: self.options.privacyPolicyURL, navigator: self.navigator))
            [cancel, tos, privacy].forEach { alert.addAction($0) }
            self.navigator.present(alert)
        }
    }
    
    private func handleInput(input: InputField) {
        self.messagePresenter?.hideCurrent()
        self.databaseView?.removeEnterprise()
        
        self.logger.verbose("new value: \(input.text) for type: \(input.type)")
        let attribute: UserAttribute?
        switch input.type {
        case .Email:
            attribute = .Email
        case .EmailOrUsername:
            attribute = .EmailOrUsername
        case .Password:
            attribute = .Password
        case .Username:
            attribute = .Username
        case .Custom(let name, _, _, _, _, _):
            attribute = .Custom(name: name)
        default:
            attribute = nil
        }
        
        guard let attr = attribute else { return }
        do {
            try self.authenticator.update(attr, value: input.text)
            // Check for Entperise domain match in login view
            if var enterpriseInteractor = self.enterpriseInteractor, let mode = self.databaseView?.switcher?.selected {
                if enterpriseInteractor.isEnterprise(input.text) && mode == .Login {
                    logger.debug("Enterprise connection detected: \(enterpriseInteractor.connection)")
                    self.databaseView?.presentEnterprise()
                }
            }
            input.showValid()
        } catch let error as InputValidationError {
            input.showError(error.localizedMessage(withConnection: self.database))
        } catch {
            input.showError()
        }
    }
    
}

private func safariBuilder(forURL url: NSURL, navigator: Navigable) -> (UIAlertAction) -> () {
    return { _ in
        let safari = SFSafariViewController(URL: url)
        navigator.present(safari)
    }
}
