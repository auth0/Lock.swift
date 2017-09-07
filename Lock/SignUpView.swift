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

class SignUpView: UIView, Form {
    var emailField: InputField
    var passwordField: InputField
    var usernameField: InputField?
    var stackView: UIStackView

    var showUsername: Bool = false {
        didSet {
            let field = inputField(withType: .username)
            field.onTextChange = onValueChange
            self.usernameField = field
            if showUsername {
                self.stackView.insertArrangedSubview(field, at: 1)
            } else {
                self.stackView.removeArrangedSubview(field)
            }
        }
    }

    var onValueChange: (InputField) -> Void = {_ in} {
        didSet {
            self.stackView.arrangedSubviews
                .map { $0 as? InputField }
                .forEach { $0?.onTextChange = onValueChange }
        }
    }

    var onReturn: (InputField) -> Void {
        get {
            guard let last = self.lastField else { return {_ in } } // FIXME: Track this somehow
            return last.onReturn
        }
        set {
            guard let last = self.lastField else { return }
            return last.onReturn = newValue
        }
    }

    var lastField: InputField? {
        return self.stackView.arrangedSubviews.last as? InputField
    }

    func needsToUpdateState() {
        self.stackView.arrangedSubviews
            .map { $0 as? InputField }
            .forEach { $0?.needsToUpdateState() }
    }

    // MARK: - Initialisers

    init(additionalFields: [CustomTextField]) {
        self.emailField = inputField(withType: .email)
        self.passwordField = inputField(withType: .password)
        var fields = [emailField, passwordField]
        fields.append(contentsOf: additionalFields.map { return inputField(withType: $0.type) })
        self.stackView = UIStackView(arrangedSubviews: fields)
        super.init(frame: CGRect.zero)
        self.layoutForm()
    }

    required override init(frame: CGRect) {
        self.emailField = inputField(withType: .email)
        self.passwordField = inputField(withType: .password)
        self.stackView = UIStackView(arrangedSubviews: [emailField, passwordField])
        super.init(frame: frame)
        self.layoutForm()
    }

    required init?(coder aDecoder: NSCoder) {
        self.emailField = inputField(withType: .email)
        self.passwordField = inputField(withType: .password)
        self.stackView = UIStackView(arrangedSubviews: [emailField, passwordField])
        super.init(coder: aDecoder)
        self.layoutForm()
    }

    // MARK: - Layout

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

        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .fillProportionally
        stackView.alignment = .fill

        email.type = .email
        password.type = .password

        let fields = self.stackView.arrangedSubviews.map { $0 as? InputField }.filter { $0 != nil }.map { $0! }
        fields.indices.dropLast().forEach {
            fields[$0].returnKey = .next
            fields[$0].nextField = fields[$0+1]
        }
        fields.last?.returnKey = .done
    }
}

private func inputField(withType type: InputField.InputType) -> InputField {
    let field = InputField()
    field.type = type
    return field
}
