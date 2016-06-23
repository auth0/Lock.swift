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

public class CredentialView: UIView {

    weak var identityField: InputField?
    weak var passwordField: InputField?

    public var onValueChange: (InputField) -> () = {_ in} {
        didSet {
            self.identityField?.onTextChange = onValueChange
            self.passwordField?.onTextChange = onValueChange
        }
    }

    public var identifier: String? {
        get {
            return self.identityField?.text
        }
        set {
            self.identityField?.text = newValue
        }
    }

    public var password: String? {
        get {
            return self.passwordField?.text
        }
        set {
            self.passwordField?.text = newValue
        }
    }

    // MARK:- Initialisers

    public convenience init() {
        self.init(frame: CGRectZero)
    }

    required override public init(frame: CGRect) {
        super.init(frame: frame)
        self.layoutForm()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layoutForm()
    }

    // MARK:- Layout

    private func layoutForm() {

        let identifier = InputField()
        let password = InputField()

        self.addSubview(identifier)
        self.addSubview(password)

        constraintEqual(anchor: identifier.leftAnchor, toAnchor: self.leftAnchor)
        constraintEqual(anchor: identifier.topAnchor, toAnchor: self.topAnchor)
        constraintEqual(anchor: identifier.rightAnchor, toAnchor: self.rightAnchor)
        identifier.translatesAutoresizingMaskIntoConstraints = false

        constraintEqual(anchor: password.leftAnchor, toAnchor: self.leftAnchor)
        constraintEqual(anchor: password.topAnchor, toAnchor: identifier.bottomAnchor, constant: 14)
        constraintEqual(anchor: password.rightAnchor, toAnchor: self.rightAnchor)
        constraintEqual(anchor: password.bottomAnchor, toAnchor: self.bottomAnchor)
        password.translatesAutoresizingMaskIntoConstraints = false

        identifier.type = .Email
        password.type = .Password

        self.identityField = identifier
        self.passwordField = password
    }
}
