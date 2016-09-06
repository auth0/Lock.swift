// DatabaseForgotPasswordView.swift
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

class DatabaseForgotPasswordView: UIView, View {

    weak var form: Form?
    weak var primaryButton: PrimaryButton?

    init(email: String?) {
        let primaryButton = PrimaryButton()
        let forgotView = SingleInputView()
        let center = UILayoutGuide()

        self.primaryButton = primaryButton
        self.form = forgotView

        super.init(frame: CGRectZero)

        self.addSubview(forgotView)
        self.addSubview(primaryButton)
        self.addLayoutGuide(center)

        constraintEqual(anchor: center.leftAnchor, toAnchor: self.leftAnchor, constant: 20)
        constraintEqual(anchor: center.topAnchor, toAnchor: self.topAnchor)
        constraintEqual(anchor: center.rightAnchor, toAnchor: self.rightAnchor, constant: -20)
        constraintEqual(anchor: center.bottomAnchor, toAnchor: primaryButton.topAnchor)

        constraintEqual(anchor: forgotView.leftAnchor, toAnchor: center.leftAnchor)
        constraintEqual(anchor: forgotView.rightAnchor, toAnchor: center.rightAnchor)
        constraintEqual(anchor: forgotView.centerYAnchor, toAnchor: center.centerYAnchor)
        constraintGreaterOrEqual(anchor: forgotView.topAnchor, toAnchor: center.topAnchor, constant: 10, priority: UILayoutPriorityDefaultLow - 1)
        constraintGreaterOrEqual(anchor: forgotView.bottomAnchor, toAnchor: center.bottomAnchor, constant: -10, priority: UILayoutPriorityDefaultLow - 1)
        forgotView.translatesAutoresizingMaskIntoConstraints = false

        constraintEqual(anchor: primaryButton.leftAnchor, toAnchor: self.leftAnchor)
        constraintEqual(anchor: primaryButton.rightAnchor, toAnchor: self.rightAnchor)
        constraintEqual(anchor: primaryButton.bottomAnchor, toAnchor: self.bottomAnchor)
        primaryButton.translatesAutoresizingMaskIntoConstraints = false

        forgotView.type = .Email
        forgotView.returnKey = .Done
        forgotView.title = "Reset Password".i18n(key: "com.auth0.lock.forgot.title", comment: "Forgot Password title")
        forgotView.message = "Please enter your email and the new password. We will send you an email to confirm the password change.".i18n(key: "com.auth0.lock.forgot.message", comment: "Forgot Password message")
        forgotView.value = email
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func apply(style style: Style) {
        self.primaryButton?.apply(style: style)
    }
}
