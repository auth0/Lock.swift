// CredentialView.swift
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

class CredentialView: UIView, Form {

    var identityField: InputField
    var passwordField: InputField

    var onValueChange: (InputField) -> Void = {_ in} {
        didSet {
            self.identityField.onTextChange = onValueChange
            self.passwordField.onTextChange = onValueChange
        }
    }

    var onReturn: (InputField) -> Void {
        get {
            return self.passwordField.onReturn
        }
        set {
            self.passwordField.onReturn = newValue
        }
    }

    func needsToUpdateState() {
        self.identityField.needsToUpdateState()
        self.passwordField.needsToUpdateState()
    }

    // MARK: - Initialisers

    convenience init() {
        self.init(frame: CGRect.zero)
    }

    required override init(frame: CGRect) {
        self.identityField = InputField()
        self.passwordField = InputField()
        super.init(frame: frame)
        self.layoutForm()
    }

    required init?(coder aDecoder: NSCoder) {
        self.identityField = InputField()
        self.passwordField = InputField()
        super.init(coder: aDecoder)
        self.layoutForm()
    }

    // MARK: - Layout

    private func layoutForm() {

        let identifier = self.identityField
        let password = self.passwordField

        self.addSubview(identifier)
        self.addSubview(password)

        constraintEqual(anchor: identifier.leftAnchor, toAnchor: self.leftAnchor, constant: 20)
        constraintEqual(anchor: identifier.topAnchor, toAnchor: self.topAnchor)
        constraintEqual(anchor: identifier.rightAnchor, toAnchor: self.rightAnchor, constant: -20)
        identifier.translatesAutoresizingMaskIntoConstraints = false

        constraintEqual(anchor: password.leftAnchor, toAnchor: self.leftAnchor, constant: 20)
        constraintEqual(anchor: password.topAnchor, toAnchor: identifier.bottomAnchor, constant: 16)
        constraintEqual(anchor: password.rightAnchor, toAnchor: self.rightAnchor, constant: -20)
        constraintEqual(anchor: password.bottomAnchor, toAnchor: self.bottomAnchor)
        password.translatesAutoresizingMaskIntoConstraints = false

        identifier.type = .email
        password.type = .password
    }
}
