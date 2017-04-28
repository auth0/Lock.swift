// EnterpriseActiveAuthView.swift
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

class EnterpriseActiveAuthView: UIView, View {

    weak var form: Form?
    weak var primaryButton: PrimaryButton?

    private weak var container: UIStackView?
    private weak var titleView: UILabel?

    init(identifier: String?, identifierAttribute: UserAttribute, domain: String? = nil) {
        let primaryButton = PrimaryButton()
        let credentialView = CredentialView()
        let titleView = UILabel()
        let container = UIStackView()

        self.primaryButton = primaryButton
        self.form = credentialView
        self.titleView = titleView

        super.init(frame: CGRect.zero)

        self.addSubview(container)
        self.addSubview(primaryButton)

        constraintEqual(anchor: container.leftAnchor, toAnchor: self.leftAnchor)
        constraintEqual(anchor: container.topAnchor, toAnchor: self.topAnchor)
        constraintEqual(anchor: container.rightAnchor, toAnchor: self.rightAnchor)
        constraintEqual(anchor: container.bottomAnchor, toAnchor: primaryButton.topAnchor)
        container.translatesAutoresizingMaskIntoConstraints = false

        constraintEqual(anchor: primaryButton.leftAnchor, toAnchor: self.leftAnchor)
        constraintEqual(anchor: primaryButton.rightAnchor, toAnchor: self.rightAnchor)
        constraintEqual(anchor: primaryButton.bottomAnchor, toAnchor: self.bottomAnchor)
        primaryButton.translatesAutoresizingMaskIntoConstraints = false

        container.alignment = .fill
        container.axis = .vertical
        container.distribution = .equalSpacing
        container.spacing = 10

        primaryButton.title = "LOG IN".i18n(key: "com.auth0.lock.submit.login.title", comment: "Login Button title")
        credentialView.identityField.text = identifier
        switch identifierAttribute {
        case .username:
            credentialView.identityField.type = .username
        default:
            credentialView.identityField.type = .email
        }

        credentialView.identityField.returnKey = .next
        credentialView.identityField.nextField = credentialView.passwordField
        credentialView.passwordField.returnKey = .done

        if let domain = domain {
            titleView.text = String(
                    format: "Please enter your corporate credentials at %1$@".i18n(key: "com.auth0.lock.enterprise.sso.message_at", comment: "enter corporate credentials of domain %@{email domain}"),
                    domain
            )
        } else {
            titleView.text = "Please enter your corporate credentials".i18n(key: "com.auth0.lock.enterprise.sso.message", comment: "enter corporate credentials")
        }

        titleView.numberOfLines = 4
        titleView.textAlignment = .center
        titleView.font = regularSystemFont(size: 15)

        container.addArrangedSubview(strutView(withHeight: 10))
        container.addArrangedSubview(titleView)
        container.addArrangedSubview(credentialView)
        container.addArrangedSubview(strutView())
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func apply(style: Style) {
        self.titleView?.textColor = style.textColor
    }

}
