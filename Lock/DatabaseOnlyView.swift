// DatabaseOnlyView.swift
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

import UIKit

class DatabaseOnlyView: UIView, DatabaseView {

    weak var form: Form?
    weak var secondaryButton: SecondaryButton?
    weak var primaryButton: PrimaryButton?
    weak var switcher: DatabaseModeSwitcher?
    weak var authCollectionView: AuthCollectionView?
    weak var separator: UILabel?
    weak var secondaryStrut: UIView?
    weak var ssoBar: InfoBarView?
    weak var spacer: UIView?
    private var style: Style?
    weak var passwordManagerButton: IconButton?
    weak var showPasswordButton: IconButton?

    weak var identityField: InputField?
    weak var passwordField: InputField?
    var allFields: [InputField]?

    // FIXME: Remove this from the view since it should not even know it exists
    var navigator: Navigable?

    private weak var container: UIStackView?

    let allowedModes: DatabaseMode

    init(allowedModes: DatabaseMode = [.Login, .Signup, .ResetPassword]) {
        let primaryButton = PrimaryButton()
        let container = UIStackView()

        self.allowedModes = allowedModes
        self.primaryButton = primaryButton
        self.container = container

        super.init(frame: CGRect.zero)

        self.addSubview(container)
        self.addSubview(primaryButton)

        container.alignment = .fill
        container.axis = .vertical
        container.distribution = .equalSpacing
        container.spacing = 10

        constraintEqual(anchor: container.leftAnchor, toAnchor: self.leftAnchor)
        constraintEqual(anchor: container.topAnchor, toAnchor: self.topAnchor)
        constraintEqual(anchor: container.rightAnchor, toAnchor: self.rightAnchor)
        constraintEqual(anchor: container.bottomAnchor, toAnchor: primaryButton.topAnchor)
        container.translatesAutoresizingMaskIntoConstraints = false

        self.layoutSwitcher(allowedModes.contains(.Login) && allowedModes.contains(.Signup))

        constraintEqual(anchor: primaryButton.leftAnchor, toAnchor: self.leftAnchor)
        constraintEqual(anchor: primaryButton.rightAnchor, toAnchor: self.rightAnchor)
        constraintEqual(anchor: primaryButton.bottomAnchor, toAnchor: self.bottomAnchor)
        primaryButton.translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    private let switcherIndex = 0
    private let formOnlyIndex = 1
    private let formBelowSocialIndex = 3
    private let separatorIndex = 2
    private let socialIndex = 1

    func showLogin(withIdentifierStyle style: DatabaseIdentifierStyle, identifier: String? = nil, authCollectionView: AuthCollectionView? = nil, showPassswordManager: Bool, showPassword: Bool) {
        let form = CredentialView()

        let type: InputField.InputType
        switch style {
        case [.Email, .Username]:
            type = .emailOrUsername
        case [.Username]:
            type = .username
        default:
            type = .email
        }

        form.identityField.text = identifier
        form.identityField.type = type
        form.identityField.returnKey = .next
        form.identityField.nextField = form.passwordField
        form.passwordField.returnKey = .done
        primaryButton?.title = "LOG IN".i18n(key: "com.auth0.lock.submit.login.title", comment: "Login Button title")
        layoutInStack(form, authCollectionView: authCollectionView)
        self.layoutSecondaryButton(self.allowedModes.contains(.ResetPassword))
        self.form = form
        self.identityField = form.identityField
        self.passwordField = form.passwordField

        if showPassswordManager {
            self.passwordManagerButton = form.passwordField.addFieldButton(withIcon: "ic_onepassword", color: Style.Auth0.onePasswordIconColor)
        } else if showPassword, let passwordInput = form.passwordField.textField {
            self.showPasswordButton = form.passwordField.addFieldButton(withIcon: "ic_show_password_hidden", color: Style.Auth0.inputIconColor)
            self.showPasswordButton?.onPress = { [unowned self] button in
                passwordInput.isSecureTextEntry = !passwordInput.isSecureTextEntry
                button.icon = LazyImage(name: passwordInput.isSecureTextEntry ? "ic_show_password_hidden" : "ic_show_password_visible", bundle: Lock.bundle).image(compatibleWithTraits: self.traitCollection)
            }
        }
    }

    // swiftlint:disable:next function_parameter_count
    func showSignUp(withUsername showUsername: Bool, username: String?, email: String?, authCollectionView: AuthCollectionView? = nil, additionalFields: [CustomTextField], passwordPolicyValidator: PasswordPolicyValidator? = nil, showPassswordManager: Bool, showPassword: Bool) {
        let form = SignUpView(additionalFields: additionalFields)
        form.showUsername = showUsername
        form.emailField.text = email
        form.emailField.nextField = showUsername ? form.usernameField : form.passwordField
        form.usernameField?.text = username
        form.usernameField?.nextField = form.passwordField

        primaryButton?.title = "SIGN UP".i18n(key: "com.auth0.lock.submit.signup.title", comment: "Signup Button title")
        layoutInStack(form, authCollectionView: authCollectionView)
        self.layoutSecondaryButton(true)
        self.form = form

        self.identityField = showUsername ? form.usernameField : form.emailField
        self.passwordField = form.passwordField
        self.allFields = form.stackView.arrangedSubviews.map { $0 as? InputField }.filter { $0 != nil }.map { $0! }

        if let passwordPolicyValidator = passwordPolicyValidator {
            let passwordPolicyView = PolicyView(rules: passwordPolicyValidator.policy.rules)
            passwordPolicyValidator.delegate = passwordPolicyView
            let passwordIndex = form.stackView.arrangedSubviews.index(of: form.passwordField)
            form.stackView.insertArrangedSubview(passwordPolicyView, at:passwordIndex!)
            passwordPolicyView.isHidden = true
            form.passwordField.errorLabel?.removeFromSuperview()
            form.passwordField.onBeginEditing = { [weak self, weak passwordPolicyView] _ in
                guard let view = passwordPolicyView else { return }
                Queue.main.async {
                    view.isHidden = false
                    self?.navigator?.scroll(toPosition: CGPoint(x: 0, y: view.intrinsicContentSize.height), animated: false)
                }
            }

            form.passwordField.onEndEditing = { [weak passwordPolicyView] _ in
                guard let view = passwordPolicyView else { return }
                view.isHidden = true
            }
        }

        if showPassswordManager {
            self.passwordManagerButton = form.passwordField.addFieldButton(withIcon: "ic_onepassword", color: Style.Auth0.onePasswordIconColor)
        } else if showPassword, let passwordInput = form.passwordField.textField {
            self.showPasswordButton = form.passwordField.addFieldButton(withIcon: "ic_show_password_hidden", color: Style.Auth0.inputIconColor)
            self.showPasswordButton?.onPress = { [unowned self] button in
                passwordInput.isSecureTextEntry = !passwordInput.isSecureTextEntry
                button.icon = LazyImage(name: passwordInput.isSecureTextEntry ? "ic_show_password_hidden" : "ic_show_password_visible", bundle: Lock.bundle).image(compatibleWithTraits: self.traitCollection)
            }
        }
    }

    func presentEnterprise() {
        guard let form = self.form as? CredentialView else { return }

        let ssoBar = InfoBarView.ssoInfoBar
        let viewCount = self.container?.subviews.count ?? 0
        let spacer = strutView(withHeight: 125 - CGFloat(viewCount) * 25)

        ssoBar.isHidden = false

        self.container?.insertArrangedSubview(ssoBar, at: 0)
        self.container?.addArrangedSubview(spacer)

        self.ssoBar = ssoBar
        self.spacer = spacer

        form.passwordField.isHidden = true
        form.identityField.nextField = nil
        form.identityField.returnKey = .done
        form.identityField.onReturn = form.passwordField.onReturn

        self.switcher?.isHidden = true
        self.secondaryButton?.isHidden = true
    }

    func removeEnterprise() {
        guard let ssoBar = self.ssoBar, let spacer = self.spacer, let form = self.form as? CredentialView else { return }

        ssoBar.removeFromSuperview()
        spacer.removeFromSuperview()

        form.passwordField.isHidden = false
        form.identityField.nextField = form.passwordField
        form.identityField.returnKey = .next

        self.switcher?.isHidden = false
        self.secondaryButton?.isHidden = false

        self.ssoBar = nil
        self.spacer = nil
    }

    private func layoutSecondaryButton(_ enabled: Bool) {
        self.secondaryStrut?.removeFromSuperview()
        self.secondaryButton?.removeFromSuperview()
        if enabled {
            let secondaryButton = SecondaryButton()
            self.secondaryButton = secondaryButton
            self.container?.addArrangedSubview(secondaryButton)
        } else {
            let view = strutView()
            self.secondaryStrut = view
            self.container?.addArrangedSubview(view)
        }
    }

    private func layoutSwitcher(_ enabled: Bool) {
        self.container?.arrangedSubviews.first?.removeFromSuperview()
        if enabled {
            let switcher = DatabaseModeSwitcher()
            self.container?.insertArrangedSubview(switcher, at: switcherIndex)
            self.switcher = switcher
        } else {
            let view = strutView()
            self.container?.insertArrangedSubview(view, at: switcherIndex)
        }
    }

    private func layoutInStack(_ view: UIView, authCollectionView: AuthCollectionView?) {
        if let current = self.form as? UIView {
            current.removeFromSuperview()
        }
        self.authCollectionView?.removeFromSuperview()
        self.separator?.removeFromSuperview()

        if let social = authCollectionView {
            let label = UILabel()
            label.text = "or".i18n(key: "com.auth0.lock.database.separator", comment: "Social separator")
            label.font = mediumSystemFont(size: 13.75)
            label.textAlignment = .center
            self.container?.insertArrangedSubview(social, at: socialIndex)
            self.container?.insertArrangedSubview(label, at: separatorIndex)
            self.container?.insertArrangedSubview(view, at: formBelowSocialIndex)
            self.authCollectionView = social
            self.separator = label
        } else {
            self.container?.insertArrangedSubview(view, at: formOnlyIndex)
        }
        if let style = self.style {
            self.separator?.textColor = style.seperatorTextColor
            self.container?.styleSubViews(style: style)
        }
    }

    func apply(style: Style) {
        self.style = style
        self.separator?.textColor = style.seperatorTextColor
        self.passwordManagerButton?.color = style.onePasswordIconColor
    }
}
