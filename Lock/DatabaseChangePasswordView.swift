// DatabaseChangePasswordView.swift
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

import UIKit

class DatabaseChangePasswordView: UIView, View {

    weak var form: Form?
    weak var primaryButton: PrimaryButton?
    weak var showPasswordButton: IconButton?

    init(passwordPolicyValidator: PasswordPolicyValidator?, showPassword: Bool) {
        let primaryButton = PrimaryButton()
        let form = ChangeInputView()
        let center = UILayoutGuide()

        self.primaryButton = primaryButton
        self.form = form

        super.init(frame: CGRect.zero)

        self.addSubview(form)
        self.addSubview(primaryButton)
        self.addLayoutGuide(center)

        constraintEqual(anchor: center.leftAnchor, toAnchor: self.leftAnchor)
        constraintEqual(anchor: center.topAnchor, toAnchor: self.topAnchor, constant: 20)
        constraintEqual(anchor: center.rightAnchor, toAnchor: self.rightAnchor)
        constraintEqual(anchor: center.bottomAnchor, toAnchor: primaryButton.topAnchor)

        constraintEqual(anchor: form.leftAnchor, toAnchor: center.leftAnchor)
        constraintEqual(anchor: form.rightAnchor, toAnchor: center.rightAnchor)
        constraintEqual(anchor: form.centerYAnchor, toAnchor: center.centerYAnchor, constant: -20)
        constraintGreaterOrEqual(anchor: form.topAnchor, toAnchor: center.topAnchor)
        form.translatesAutoresizingMaskIntoConstraints = false

        constraintEqual(anchor: primaryButton.leftAnchor, toAnchor: self.leftAnchor)
        constraintEqual(anchor: primaryButton.rightAnchor, toAnchor: self.rightAnchor)
        constraintEqual(anchor: primaryButton.bottomAnchor, toAnchor: self.bottomAnchor)
        primaryButton.translatesAutoresizingMaskIntoConstraints = false

        primaryButton.title = "CHANGE PASSWORD".i18n(key: "com.auth0.lock.submit.change_password.title", comment: "Change Password button title")
        form.message = "Your password has expired. Please change your password to continue logging in.".i18n(key: "com.auth0.lock.change_password.message", comment: "Change Password message")

        form.newValueField.type = .password
        form.confirmValueField.type = .custom(name: "match", placeholder: "Confirm password", icon: InputField.InputType.password.icon, keyboardType: InputField.InputType.password.keyboardType, autocorrectionType: InputField.InputType.password.autocorrectionType, secure: InputField.InputType.password.secure)

        if let passwordPolicyValidator = passwordPolicyValidator {
            let passwordPolicyView = PolicyView(rules: passwordPolicyValidator.policy.rules)
            passwordPolicyValidator.delegate = passwordPolicyView
            let passwordIndex = form.stackView.arrangedSubviews.index(of: form.newValueField)
            form.stackView.insertArrangedSubview(passwordPolicyView, at:passwordIndex!)

            passwordPolicyView.isHidden = true
            form.newValueField.errorLabel?.removeFromSuperview()
            form.newValueField.onBeginEditing = { [weak passwordPolicyView] _ in
                guard let view = passwordPolicyView else { return }
                Queue.main.async {
                    view.isHidden = false
                }
            }

            form.newValueField.onEndEditing = { [weak passwordPolicyView] _ in
                guard let view = passwordPolicyView else { return }
                view.isHidden = true
            }
        }

        if showPassword, let passwordInput = form.newValueField.textField {
            self.showPasswordButton = form.newValueField.addFieldButton(withIcon: "ic_show_password_hidden", color: Style.Auth0.inputIconColor)
            self.showPasswordButton?.onPress = { button in
                passwordInput.isSecureTextEntry = !passwordInput.isSecureTextEntry
                button.icon = LazyImage(name: passwordInput.isSecureTextEntry ? "ic_show_password_hidden" : "ic_show_password_visible", bundle: Lock.bundle).image(compatibleWithTraits: self.traitCollection)
            }
            form.confirmValueField.removeFromSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func apply(style: Style) {
    }
}
