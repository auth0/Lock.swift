// SignUpView.swift
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

public class SignUpView: UIView, Form {
    public var emailField: InputField
    public var passwordField: InputField
    public weak var usernameField: InputField?
    var stackView: UIStackView

    public var showUsername: Bool = false {
        didSet {
            let field = InputField()
            field.type = .Username
            field.onTextChange = onValueChange
            self.usernameField = field
            if showUsername {
                self.stackView.insertArrangedSubview(field, atIndex: 1)
            } else {
                self.stackView.removeArrangedSubview(field)
            }
        }
    }

    public var onValueChange: (InputField) -> () = {_ in} {
        didSet {
            self.emailField.onTextChange = onValueChange
            self.usernameField?.onTextChange = onValueChange
            self.passwordField.onTextChange = onValueChange
        }
    }

    var onReturn: (InputField) -> () {
        get {
            return self.passwordField.onReturn
        }
        set {
            self.passwordField.onReturn = newValue
        }
    }

    func needsToUpdateState() {
        self.usernameField?.needsToUpdateState()
        self.emailField.needsToUpdateState()
        self.passwordField.needsToUpdateState()
    }

    // MARK:- Initialisers

    public convenience init() {
        self.init(frame: CGRectZero)
    }

    required override public init(frame: CGRect) {
        self.emailField = InputField()
        self.passwordField = InputField()
        self.stackView = UIStackView(arrangedSubviews: [emailField, passwordField])
        super.init(frame: frame)
        self.layoutForm()
    }

    public required init?(coder aDecoder: NSCoder) {
        self.emailField = InputField()
        self.passwordField = InputField()
        self.stackView = UIStackView(arrangedSubviews: [emailField, passwordField])
        super.init(coder: aDecoder)
        self.layoutForm()
    }

    // MARK:- Layout

    private func layoutForm() {

        let email = self.emailField
        let password = self.passwordField
        let stackView = self.stackView

        self.addSubview(stackView)

        constraintEqual(anchor: stackView.leftAnchor, toAnchor: self.leftAnchor, constant: 20)
        constraintEqual(anchor: stackView.topAnchor, toAnchor: self.topAnchor)
        constraintEqual(anchor: stackView.rightAnchor, toAnchor: self.rightAnchor, constant: -20)
        constraintEqual(anchor: stackView.bottomAnchor, toAnchor: self.bottomAnchor)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        stackView.axis = .Vertical
        stackView.spacing = 16
        stackView.distribution = .EqualCentering
        stackView.alignment = .Fill

        email.type = .Email
        password.type = .Password

        email.returnKey = .Next
        password.returnKey = .Done
    }
}
