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
    private weak var container: UIStackView?

    init() {
        let secondaryButton = SecondaryButton()
        let primaryButton = PrimaryButton()
        let container = UIStackView()
        let switcher = DatabaseModeSwitcher()

        self.secondaryButton = secondaryButton
        self.primaryButton = primaryButton
        self.switcher = switcher
        self.container = container

        super.init(frame: CGRectZero)

        self.addSubview(container)
        self.addSubview(primaryButton)

        container.alignment = .Fill
        container.axis = .Vertical
        container.distribution = .EqualCentering
        container.spacing = 10

        constraintEqual(anchor: container.leftAnchor, toAnchor: self.leftAnchor, constant: 20)
        constraintEqual(anchor: container.topAnchor, toAnchor: self.topAnchor)
        constraintEqual(anchor: container.rightAnchor, toAnchor: self.rightAnchor, constant: -20)
        constraintEqual(anchor: container.bottomAnchor, toAnchor: primaryButton.topAnchor)
        container.translatesAutoresizingMaskIntoConstraints = false

        container.addArrangedSubview(switcher)
        container.addArrangedSubview(secondaryButton)

        constraintEqual(anchor: primaryButton.leftAnchor, toAnchor: self.leftAnchor)
        constraintEqual(anchor: primaryButton.rightAnchor, toAnchor: self.rightAnchor)
        constraintEqual(anchor: primaryButton.bottomAnchor, toAnchor: self.bottomAnchor)
        primaryButton.translatesAutoresizingMaskIntoConstraints = false
    }

    func showLogin(withUsername allowUsername: Bool) {
        let form = CredentialView()
        form.identityField.type = allowUsername ? .EmailOrUsername : .Email
        layoutInStack(form)
        self.form = form
    }

    func showSignUp(withUsername showUsername: Bool) {
        let form = SignUpView()
        form.showUsername = showUsername
        layoutInStack(form)
        self.form = form
    }

    private func layoutInStack(view: UIView) {
        if let current = self.form as? UIView {
            current.removeFromSuperview()
        }
        self.container?.insertArrangedSubview(view, atIndex: 1)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}