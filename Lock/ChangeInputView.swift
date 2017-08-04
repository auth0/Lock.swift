// ChangeInputView.swift
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

class ChangeInputView: UIView, Form, Stylable {
    var newValueField: InputField
    var confirmValueField: InputField
    private var messageView: UILabel
    private var stackView: UIStackView

    var onValueChange: (InputField) -> Void = {_ in} {
        didSet {
            self.newValueField.onTextChange = onValueChange
            self.confirmValueField.onTextChange = onValueChange
        }
    }

    var onReturn: (InputField) -> Void {
        get {
            return self.newValueField.onReturn
        }
        set {
            self.newValueField.onReturn = newValue
        }
    }

    func needsToUpdateState() {
        self.newValueField.needsToUpdateState()
        self.confirmValueField.needsToUpdateState()
    }

    var message: String? {
        get {
            return self.messageView.text
        }
        set {
            self.messageView.text = newValue
        }
    }

    // MARK: - Initialisers

    required override init(frame: CGRect) {
        self.newValueField = InputField()
        self.confirmValueField = InputField()
        self.messageView = UILabel()
        self.stackView = UIStackView(arrangedSubviews: [messageView, newValueField, confirmValueField])
        super.init(frame: frame)
        self.layoutForm()
    }

    convenience init() {
        self.init(frame: CGRect.zero)
    }

    required convenience init?(coder aDecoder: NSCoder) {
        self.init(frame: CGRect.zero)
    }

    // MARK: - Layout

    private func layoutForm() {
        self.addSubview(self.stackView)

        constraintEqual(anchor: self.stackView.leftAnchor, toAnchor: self.leftAnchor, constant: 20)
        constraintEqual(anchor: self.stackView.topAnchor, toAnchor: self.topAnchor)
        constraintEqual(anchor: self.stackView.rightAnchor, toAnchor: self.rightAnchor, constant: -20)
        constraintEqual(anchor: self.stackView.bottomAnchor, toAnchor: self.bottomAnchor)
        self.stackView.translatesAutoresizingMaskIntoConstraints = false

        self.stackView.alignment = .fill
        self.stackView.axis = .vertical
        self.stackView.distribution = .equalSpacing
        self.stackView.spacing = 16

        messageView.numberOfLines = 4
        messageView.textAlignment = .center
        messageView.font = regularSystemFont(size: 15)
        messageView.textColor = Style.Auth0.textColor

        self.newValueField.returnKey = .next
        self.newValueField.nextField = self.confirmValueField
        self.confirmValueField.returnKey = .done
    }

    func apply(style: Style) {
        self.messageView.textColor = style.textColor
    }
}
