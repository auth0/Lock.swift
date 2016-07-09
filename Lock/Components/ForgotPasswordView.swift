// ForgotPasswordView.swift
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

public class ForgotPasswordView: UIView, Form {
    public var emailField: InputField
    var titleView: UILabel
    var messageView: UILabel
    var stackView: UIStackView

    var onValueChange: (InputField) -> () = { _ in } {
        didSet {
            self.emailField.onTextChange = self.onValueChange
        }
    }

    func needsToUpdateState() {
        self.emailField.needsToUpdateState()
    }

    // MARK:- Initialisers

    required override public init(frame: CGRect) {
        self.emailField = InputField()
        self.titleView = UILabel()
        self.messageView = UILabel()
        self.stackView = UIStackView(arrangedSubviews: [titleView, messageView, emailField])
        super.init(frame: frame)
        self.layoutForm()
    }

    public convenience init() {
        self.init(frame: CGRectZero)
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        self.init(frame: CGRectZero)
    }

    // MARK:- Layout

    private func layoutForm() {
        self.addSubview(self.stackView)

        constraintEqual(anchor: self.stackView.leftAnchor, toAnchor: self.leftAnchor)
        constraintEqual(anchor: self.stackView.topAnchor, toAnchor: self.topAnchor)
        constraintEqual(anchor: self.stackView.rightAnchor, toAnchor: self.rightAnchor)
        constraintEqual(anchor: self.stackView.bottomAnchor, toAnchor: self.bottomAnchor)
        self.stackView.translatesAutoresizingMaskIntoConstraints = false

        self.stackView.alignment = .Fill
        self.stackView.axis = .Vertical
        self.stackView.distribution = .EqualCentering

        titleView.text = "Reset Password".i18n(key: "com.auth0.lock.forgot.title", comment: "Forgot Password title")
        titleView.textAlignment = .Center
        messageView.text = "Please enter your email and the new password. We will send you an email to confirm the password change.".i18n(key: "com.auth0.lock.forgot.message", comment: "Forgot Password message")
        messageView.numberOfLines = 4
        messageView.textAlignment = .Center
        emailField.type = .Email
    }

    public override func intrinsicContentSize() -> CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: 244)
    }
}
