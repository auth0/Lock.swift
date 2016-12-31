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
    weak var ssoBar: InfoBarView?
    weak var primaryButton: PrimaryButton?

    private weak var container: UIStackView?

    init(identifer: String?, identifierAttribute:UserAttribute, options: Options) {
        let primaryButton = PrimaryButton()
        let credentialView = CredentialView()
        let container = UIStackView()
        let ssoBar = InfoBarView()

        self.primaryButton = primaryButton
        self.form = credentialView

        super.init(frame: CGRect.zero)

        self.addSubview(ssoBar)
        self.addSubview(primaryButton)
        self.addSubview(container)

        ssoBar.title = "Single Sign-On Enabled".i18n(key: "com.auth0.lock.enterprise.sso", comment: "SSO Header").uppercased()
        ssoBar.setIcon("ic_lock")
        self.ssoBar = ssoBar

        container.alignment = .fill
        container.axis = .vertical
        container.distribution = .equalSpacing
        container.spacing = 10

        constraintEqual(anchor: ssoBar.topAnchor, toAnchor: self.topAnchor)
        constraintEqual(anchor: ssoBar.leftAnchor, toAnchor: self.leftAnchor)
        constraintEqual(anchor: ssoBar.rightAnchor, toAnchor: self.rightAnchor)
        constraintEqual(anchor: ssoBar.bottomAnchor, toAnchor: container.topAnchor)
        ssoBar.translatesAutoresizingMaskIntoConstraints = false

        constraintEqual(anchor: container.topAnchor, toAnchor: ssoBar.bottomAnchor)
        constraintEqual(anchor: container.leftAnchor, toAnchor: self.leftAnchor)
        constraintEqual(anchor: container.rightAnchor, toAnchor: self.rightAnchor)
        constraintEqual(anchor: container.bottomAnchor, toAnchor: primaryButton.topAnchor)
        container.translatesAutoresizingMaskIntoConstraints = false

        constraintEqual(anchor: primaryButton.topAnchor, toAnchor: container.bottomAnchor)
        constraintEqual(anchor: primaryButton.leftAnchor, toAnchor: self.leftAnchor)
        constraintEqual(anchor: primaryButton.rightAnchor, toAnchor: self.rightAnchor)
        constraintEqual(anchor: primaryButton.bottomAnchor, toAnchor: self.bottomAnchor)
        primaryButton.translatesAutoresizingMaskIntoConstraints = false

        primaryButton.title = "Log in".i18n(key: "com.auth0.lock.submit.login.title", comment: "Login Button title")
        credentialView.identityField.text = identifer
        switch identifierAttribute {
        case .username:
            credentialView.identityField.type = .username
        default:
            credentialView.identityField.type = .email
        }

        credentialView.identityField.returnKey = .next
        credentialView.identityField.nextField = credentialView.passwordField
        credentialView.passwordField.returnKey = .done

        container.addArrangedSubview(strutView())
        container.addArrangedSubview(credentialView)
        container.addArrangedSubview(strutView())
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func apply(style: Style) {
        self.primaryButton?.apply(style: style)
    }

}

private func strutView(withHeight height: CGFloat = 50) -> UIView {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    dimension(dimension: view.heightAnchor, withValue: height)
    return view
}
