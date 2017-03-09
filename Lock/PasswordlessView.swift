// PasswordlessView.swift
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
    weak var primaryButton: PrimaryButton?
    weak var secondaryButton: SecondaryButton?

    private weak var container: UIStackView?
    private weak var centerGuide: UILayoutGuide?

    init() {
        let container = UIStackView()
        let centerGuide = UILayoutGuide()
        let primaryButton = PrimaryButton()

        self.container = container
        self.centerGuide = centerGuide
        self.primaryButton = primaryButton
        super.init(frame: CGRect.zero)

        self.addSubview(container)
        self.addSubview(primaryButton)
        self.addLayoutGuide(centerGuide)

        container.alignment = .fill
        container.axis = .vertical
        container.distribution = .equalSpacing
        container.spacing = 10

        constraintEqual(anchor: centerGuide.leftAnchor, toAnchor: self.leftAnchor)
        constraintEqual(anchor: centerGuide.topAnchor, toAnchor: self.topAnchor)
        constraintEqual(anchor: centerGuide.rightAnchor, toAnchor: self.rightAnchor)
        constraintEqual(anchor: centerGuide.bottomAnchor, toAnchor: primaryButton.topAnchor)

        constraintEqual(anchor: container.leftAnchor, toAnchor: centerGuide.leftAnchor)
        constraintEqual(anchor: container.rightAnchor, toAnchor: centerGuide.rightAnchor)
        constraintEqual(anchor: container.centerYAnchor, toAnchor: centerGuide.centerYAnchor)
        constraintGreaterOrEqual(anchor: container.topAnchor, toAnchor: centerGuide.topAnchor)
        container.translatesAutoresizingMaskIntoConstraints = false

        constraintEqual(anchor: primaryButton.leftAnchor, toAnchor: self.leftAnchor)
        constraintEqual(anchor: primaryButton.rightAnchor, toAnchor: self.rightAnchor)
        constraintEqual(anchor: primaryButton.bottomAnchor, toAnchor: self.bottomAnchor)
        primaryButton.translatesAutoresizingMaskIntoConstraints = false
    }

    func showForm(withEmail email: String?, authCollectionView: AuthCollectionView?) {
        let formView = SingleInputView()

        self.form = formView

        self.container?.addArrangedSubview(strutView(withHeight: 25))
        if let authView = authCollectionView {
            self.container?.addArrangedSubview(authView)
            formView.message = "Otherwise, enter your email to sign in or create an account.".i18n(key: "com.auth0.passwordless.email.title.social", comment: "Passwordless email title with social")
        } else {
            formView.message = "Enter your email to sign in or create an account.".i18n(key: "com.auth0.passwordless.email.title", comment: "Passwordless email title")
        }
        self.container?.addArrangedSubview(formView)

        formView.type = .email
        formView.returnKey = .done
        formView.value = email
                    email ?? "")

        self.container?.addArrangedSubview(strutView(withHeight: 25))
    }

    func showForm(withPhone phone: String?, countryCode: CountryCode?, authCollectionView: AuthCollectionView?) {
        let countryData = CountryCodeStore()
        let phoneInput = InternationalPhoneInputView(withCountryData: countryData)
        let messageView = UILabel()

        self.form = phoneInput

        self.container?.addArrangedSubview(strutView(withHeight: 25))
        if let authView = authCollectionView {
            self.container?.addArrangedSubview(authView)
        }
        self.container?.addArrangedSubview(strutView(withHeight: 10))
        self.container?.addArrangedSubview(messageView)
        self.container?.addArrangedSubview(strutView(withHeight: 10))
        self.container?.addArrangedSubview(phoneInput)

        messageView.numberOfLines = 2
        messageView.textAlignment = .center
        messageView.font = regularSystemFont(size: 15)

        let selectedCountry = countryCode ?? countryData.countryCode(forId: "US")

        phoneInput.updateCountry(selectedCountry)
        phoneInput.inputField.type = .phone
        phoneInput.inputField.returnKey = .done

        if authCollectionView != nil {
            messageView.text = "Otherwise, enter your phone to sign in or create an account.".i18n(key: "com.auth0.passwordless.sms.title.social", comment: "Passwordless sms title with social")
        } else {
            messageView.text  = "Enter your phone to sign in or create an account.".i18n(key: "com.auth0.passwordless.sms.title", comment: "Passwordless sms title")
        }
        phoneInput.inputField.text = phone
        self.container?.addArrangedSubview(strutView(withHeight: 25))
    }

    func showCodeForm(sentTo identifier: String?, mode: String) {
        let secondaryButton = SecondaryButton()
        let formView = SingleInputView()

        self.form = formView
        self.secondaryButton = secondaryButton

        self.container?.addArrangedSubview(strutView(withHeight: 20))
        self.container?.addArrangedSubview(formView)

        formView.type = .oneTimePassword
        formView.returnKey = .done
        if mode == "email" {
            formView.message = String(format: "An email with the code has been sent to %1$@".i18n(key: "com.auth0.passwordless.email.code.sent", comment: "Passwordless code sent by email to %@{identifier}"),
                                      identifier ?? "")
        } else {
            formView.message = String(format: "An sms with the code has been sent to %1$@".i18n(key: "com.auth0.passwordless.sms.code.sent", comment: "Passwordless code sent by sms to %@{identifier}"),
                                      identifier ?? "")
        }
        secondaryButton.title = "Did not get the code?".i18n(key: "com.auth0.passwordless.code.reminder", comment: "Passwordless code reminder action")
        self.container?.addArrangedSubview(secondaryButton)
    }

    func showLinkSent(identifier: String?) {
        let secondaryButton = SecondaryButton()
        let imageView = UIImageView()
        let messageLabel = UILabel()

        self.secondaryButton = secondaryButton
        self.primaryButton?.isHidden = true

        self.container?.addArrangedSubview(strutView(withHeight: 75))
        self.container?.addArrangedSubview(imageView)
        self.container?.addArrangedSubview(messageLabel)
        self.container?.addArrangedSubview(secondaryButton)
        self.container?.addArrangedSubview(strutView(withHeight: 50))

        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.image = LazyImage(name: "ic_email_sent", bundle: bundleForLock()).image(compatibleWithTraits: self.traitCollection)

        messageLabel.numberOfLines = 2
        messageLabel.textAlignment = .center
        messageLabel.font = .systemFont(ofSize: 16, weight: UIFontWeightSemibold)
        messageLabel.textColor = .black
        messageLabel.text = String(format: "We sent you a link to sign in to %1$@".i18n(key: "com.auth0.passwordless.link.sent", comment: "Passwordless link sent to %@{identifier}"),
                                   identifier ?? "")

        secondaryButton.title = "Did not receive the link?".i18n(key: "com.auth0.passwordless.link.reminder", comment: "Passwordless link reminder action")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func apply(style: Style) {
        self.primaryButton?.apply(style: style)
    }
}
