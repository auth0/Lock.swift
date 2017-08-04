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

    init() {
        let primaryButton = PrimaryButton()
        let changePasswordView = ChangeInputView()
        let center = UILayoutGuide()

        self.primaryButton = primaryButton
        self.form = changePasswordView

        super.init(frame: CGRect.zero)

        self.addSubview(changePasswordView)
        self.addSubview(primaryButton)
        self.addLayoutGuide(center)

        constraintEqual(anchor: center.leftAnchor, toAnchor: self.leftAnchor)
        constraintEqual(anchor: center.topAnchor, toAnchor: self.topAnchor)
        constraintEqual(anchor: center.rightAnchor, toAnchor: self.rightAnchor)
        constraintEqual(anchor: center.bottomAnchor, toAnchor: primaryButton.topAnchor)

        constraintEqual(anchor: changePasswordView.leftAnchor, toAnchor: center.leftAnchor)
        constraintEqual(anchor: changePasswordView.rightAnchor, toAnchor: center.rightAnchor)
        constraintEqual(anchor: changePasswordView.centerYAnchor, toAnchor: center.centerYAnchor, constant: -20)
        constraintGreaterOrEqual(anchor: changePasswordView.topAnchor, toAnchor: center.topAnchor)
        changePasswordView.translatesAutoresizingMaskIntoConstraints = false

        constraintEqual(anchor: primaryButton.leftAnchor, toAnchor: self.leftAnchor)
        constraintEqual(anchor: primaryButton.rightAnchor, toAnchor: self.rightAnchor)
        constraintEqual(anchor: primaryButton.bottomAnchor, toAnchor: self.bottomAnchor)
        primaryButton.translatesAutoresizingMaskIntoConstraints = false

        primaryButton.title = "CHANGE PASSWORD".i18n(key: "com.auth0.lock.submit.change_password.title", comment: "Change Password button title")
        changePasswordView.message = "Your password has expired. Please change your password to continue logging in.".i18n(key: "com.auth0.lock.change_password.message", comment: "Change Password message")

        changePasswordView.newValueField.type = .password
        changePasswordView.confirmValueField.type = .password
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func apply(style: Style) {
    }
}
