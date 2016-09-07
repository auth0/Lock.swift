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

    private weak var container: UIStackView?

    let allowedModes: DatabaseMode

    init(allowedModes: DatabaseMode = [.Login, .Signup, .ResetPassword]) {
        let primaryButton = PrimaryButton()
        let container = UIStackView()

        self.allowedModes = allowedModes
        self.primaryButton = primaryButton
        self.container = container

        super.init(frame: CGRectZero)

        self.addSubview(container)
        self.addSubview(primaryButton)

        container.alignment = .Fill
        container.axis = .Vertical
        container.distribution = .EqualSpacing
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

    // MARK:- Layout

    private let switcherIndex = 0
    private let formOnlyIndex = 1
    private let formBelowSocialIndex = 3
    private let separatorIndex = 2
    private let socialIndex = 1

    func showLogin(withUsername allowUsername: Bool, identifier: String? = nil, authCollectionView: AuthCollectionView? = nil) {
        let form = CredentialView()
        form.identityField.text = identifier
        form.identityField.type = allowUsername ? .EmailOrUsername : .Email
        form.identityField.returnKey = .Next
        form.identityField.nextField = form.passwordField
        form.passwordField.returnKey = .Done
        layoutInStack(form, authCollectionView: authCollectionView)
        self.layoutSecondaryButton(self.allowedModes.contains(.ResetPassword))
        self.form = form
    }

    func showSignUp(withUsername showUsername: Bool, username: String?, email: String?, authCollectionView: AuthCollectionView? = nil) {
        let form = SignUpView()
        form.showUsername = showUsername
        form.emailField.text = email
        form.emailField.returnKey = .Next
        form.emailField.nextField = form.usernameField ?? form.passwordField
        form.usernameField?.text = username
        form.usernameField?.returnKey = .Next
        form.usernameField?.nextField = form.passwordField
        form.passwordField.returnKey = .Done
        layoutInStack(form, authCollectionView: authCollectionView)
        self.layoutSecondaryButton(true)
        self.form = form
    }

    private func layoutSecondaryButton(enabled: Bool) {
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

    private func layoutSwitcher(enabled: Bool) {
        self.container?.arrangedSubviews.first?.removeFromSuperview()
        if enabled {
            let switcher = DatabaseModeSwitcher()
            self.container?.insertArrangedSubview(switcher, atIndex: switcherIndex)
            self.switcher = switcher
        } else {
            let view = strutView()
            self.container?.insertArrangedSubview(view, atIndex: switcherIndex)
        }
    }

    private func layoutInStack(view: UIView, authCollectionView: AuthCollectionView?) {
        if let current = self.form as? UIView {
            current.removeFromSuperview()
        }
        self.authCollectionView?.removeFromSuperview()
        self.separator?.removeFromSuperview()

        if let social = authCollectionView {
            let label = UILabel()
            label.text = "or".i18n(key: "com.auth0.lock.database.separator", comment: "Social separator")
            label.font = mediumSystemFont(size: 13.75)
            label.textColor = UIColor ( red: 0.0, green: 0.0, blue: 0.0, alpha: 0.54 )
            label.textAlignment = .Center
            self.container?.insertArrangedSubview(social, atIndex: socialIndex)
            self.container?.insertArrangedSubview(label, atIndex: separatorIndex)
            self.container?.insertArrangedSubview(view, atIndex: formBelowSocialIndex)
            self.authCollectionView = social
            self.separator = label
        } else {
            self.container?.insertArrangedSubview(view, atIndex: formOnlyIndex)
        }
    }

    // MARK:- Styling

    func apply(style style: Style) {
        primaryButton?.apply(style: style)
    }
}

private func strutView(withHeight height: CGFloat = 50) -> UIView {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    dimension(view.heightAnchor, withValue: height)
    return view
}
