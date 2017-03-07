// PasswordlessEmailView.swift
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

class PasswordlessView: UIView, View {

    weak var form: Form?
    weak var countrySelector: CountrySelectorView?
    weak var primaryButton: PrimaryButton?
    weak var secondaryButton: SecondaryButton?

    init() {
        super.init(frame: CGRect.zero)
    }

    func showForm(email: String?, screen: PasswordlessScreen, authCollectionView: AuthCollectionView?) {
        let primaryButton = PrimaryButton()
        let secondaryButton = SecondaryButton()
        let formView = SingleInputView()
        let container = UIStackView()
        let center = UILayoutGuide()

        self.primaryButton = primaryButton
        self.secondaryButton = secondaryButton
        self.form = formView

        self.addSubview(container)
        self.addSubview(primaryButton)
        self.addLayoutGuide(center)

        container.alignment = .fill
        container.axis = .vertical
        container.distribution = .equalSpacing
        container.spacing = 10

        constraintEqual(anchor: center.leftAnchor, toAnchor: self.leftAnchor)
        constraintEqual(anchor: center.topAnchor, toAnchor: self.topAnchor)
        constraintEqual(anchor: center.rightAnchor, toAnchor: self.rightAnchor)
        constraintEqual(anchor: center.bottomAnchor, toAnchor: primaryButton.topAnchor)

        constraintEqual(anchor: container.leftAnchor, toAnchor: center.leftAnchor)
        constraintEqual(anchor: container.rightAnchor, toAnchor: center.rightAnchor)
        constraintEqual(anchor: container.centerYAnchor, toAnchor: center.centerYAnchor)
        constraintGreaterOrEqual(anchor: container.topAnchor, toAnchor: center.topAnchor)
        container.translatesAutoresizingMaskIntoConstraints = false

        constraintEqual(anchor: primaryButton.leftAnchor, toAnchor: self.leftAnchor)
        constraintEqual(anchor: primaryButton.rightAnchor, toAnchor: self.rightAnchor)
        constraintEqual(anchor: primaryButton.bottomAnchor, toAnchor: self.bottomAnchor)
        primaryButton.translatesAutoresizingMaskIntoConstraints = false

        container.addArrangedSubview(strutView(withHeight: 25))
        if let authView = authCollectionView {
            container.addArrangedSubview(authView)
        }
        container.addArrangedSubview(formView)

        switch screen {
            case .request:
                formView.type = .email
                formView.returnKey = .done
                if authCollectionView != nil {
                    formView.message = "Otherwise, enter your email to sign in or create an account.".i18n(key: "com.auth0.passwordless.email.title.social", comment: "Passwordless email title with social")
                } else {
                    formView.message = "Enter your email to sign in or create an account.".i18n(key: "com.auth0.passwordless.email.title", comment: "Passwordless email title")
                }
                formView.value = email
                container.addArrangedSubview(strutView(withHeight: 25))
            case .code:
                formView.type = .oneTimePassword
                formView.returnKey = .done
                formView.message = String(
                    format: "An email with the code has been sent to %1$@".i18n(key: "com.auth0.passwordless.email.code.sent", comment: "Passwordless email code sent to %@{email}"),
                    email ?? "")
                secondaryButton.title = "Did not get the code?".i18n(key: "com.auth0.passwordless.code.reminder", comment: "Passwordless code reminder action")
                container.addArrangedSubview(secondaryButton)
        default:
            break
        }

    }

    func showForm(phone: String?, screen: PasswordlessScreen, authCollectionView: AuthCollectionView?) {
        let primaryButton = PrimaryButton()
        let secondaryButton = SecondaryButton()
        let countrySelector = CountrySelectorView()
        let formView = InputField()
        let messageView = UILabel()
        let container = UIStackView()
        let center = UILayoutGuide()

        self.primaryButton = primaryButton
        self.secondaryButton = secondaryButton
        self.form = formView

        self.addSubview(container)
        self.addSubview(primaryButton)
        self.addLayoutGuide(center)

        container.alignment = .fill
        container.axis = .vertical
        container.distribution = .equalSpacing
        container.spacing = 10

        constraintEqual(anchor: center.leftAnchor, toAnchor: self.leftAnchor, constant: 20)
        constraintEqual(anchor: center.topAnchor, toAnchor: self.topAnchor)
        constraintEqual(anchor: center.rightAnchor, toAnchor: self.rightAnchor, constant: -20)
        constraintEqual(anchor: center.bottomAnchor, toAnchor: primaryButton.topAnchor)

        constraintEqual(anchor: container.leftAnchor, toAnchor: center.leftAnchor)
        constraintEqual(anchor: container.rightAnchor, toAnchor: center.rightAnchor)
        constraintEqual(anchor: container.centerYAnchor, toAnchor: center.centerYAnchor)
        constraintGreaterOrEqual(anchor: container.topAnchor, toAnchor: center.topAnchor)
        container.translatesAutoresizingMaskIntoConstraints = false

        constraintEqual(anchor: primaryButton.leftAnchor, toAnchor: self.leftAnchor)
        constraintEqual(anchor: primaryButton.rightAnchor, toAnchor: self.rightAnchor)
        constraintEqual(anchor: primaryButton.bottomAnchor, toAnchor: self.bottomAnchor)
        primaryButton.translatesAutoresizingMaskIntoConstraints = false

        container.addArrangedSubview(strutView(withHeight: 25))
        if let authView = authCollectionView {
            container.addArrangedSubview(authView)
        }
        container.addArrangedSubview(strutView(withHeight: 10))
        container.addArrangedSubview(messageView)
        container.addArrangedSubview(strutView(withHeight: 10))
        container.addArrangedSubview(countrySelector)
        container.addArrangedSubview(formView)

        messageView.numberOfLines = 2
        messageView.textAlignment = .center
        messageView.font = regularSystemFont(size: 15)

        countrySelector.country = ("United States", "+1")

        formView.type = .phone
        formView.returnKey = .done
        if authCollectionView != nil {
            messageView.text = "Otherwise, enter your phone to sign in or create an account.".i18n(key: "com.auth0.passwordless.sms.title.social", comment: "Passwordless sms title with social")
        } else {
            messageView.text  = "Enter your phone to sign in or create an account.".i18n(key: "com.auth0.passwordless.sms.title", comment: "Passwordless sms title")
        }
        formView.text = phone
        container.addArrangedSubview(strutView(withHeight: 25))
    }

    func showLinkSent(email: String?) {
        let secondaryButton = SecondaryButton()
        let center = UILayoutGuide()
        let imageView = UIImageView()
        let messageLabel = UILabel()

        self.secondaryButton = secondaryButton

        self.addSubview(imageView)
        self.addSubview(messageLabel)
        self.addSubview(secondaryButton)
        self.addLayoutGuide(center)

        constraintEqual(anchor: center.leftAnchor, toAnchor: self.leftAnchor, constant: 20)
        constraintEqual(anchor: center.topAnchor, toAnchor: self.topAnchor)
        constraintEqual(anchor: center.rightAnchor, toAnchor: self.rightAnchor, constant: -20)
        constraintEqual(anchor: center.bottomAnchor, toAnchor: self.bottomAnchor)

        constraintEqual(anchor: imageView.centerXAnchor, toAnchor: center.centerXAnchor)
        constraintEqual(anchor: imageView.centerYAnchor, toAnchor: center.centerYAnchor, constant: -60)
        imageView.translatesAutoresizingMaskIntoConstraints = false

        constraintEqual(anchor: messageLabel.leftAnchor, toAnchor: center.leftAnchor)
        constraintEqual(anchor: messageLabel.rightAnchor, toAnchor: center.rightAnchor)
        constraintEqual(anchor: messageLabel.topAnchor, toAnchor: imageView.bottomAnchor, constant: 20)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false

        constraintEqual(anchor: secondaryButton.leftAnchor, toAnchor: center.leftAnchor)
        constraintEqual(anchor: secondaryButton.rightAnchor, toAnchor: center.rightAnchor)
        constraintEqual(anchor: secondaryButton.topAnchor, toAnchor: messageLabel.bottomAnchor, constant: 10)
        secondaryButton.translatesAutoresizingMaskIntoConstraints = false

        imageView.image = LazyImage(name: "ic_email_sent", bundle: bundleForLock()).image(compatibleWithTraits: self.traitCollection)

        messageLabel.numberOfLines = 2
        messageLabel.textAlignment = .center
        messageLabel.font = .systemFont(ofSize: 16, weight: UIFontWeightSemibold)
        messageLabel.textColor = .black
        messageLabel.text = String(format: "We sent you a link to sign in to %1$@".i18n(key: "com.auth0.passwordless.email.link.sent", comment: "Passwordless email link sent to %@{email}"),
                                   email ?? "")
        secondaryButton.title = "Did not receive the link?".i18n(key: "com.auth0.passwordless.link.reminder", comment: "Passwordless link reminder action")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func apply(style: Style) {
        self.primaryButton?.apply(style: style)
    }
}
