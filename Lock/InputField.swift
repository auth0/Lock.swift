// InputField.swift
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

public class InputField: UIView {

    weak var textField: UITextField?
    weak var iconView: UIImageView?

    public convenience init() {
        self.init(frame: CGRectZero)
    }

    required override public init(frame: CGRect) {
        super.init(frame: frame)
        self.layoutField()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.layoutField()
    }

    public var text: String? {
        get {
            return self.textField?.text
        }
        set {
            self.textField?.text = newValue
        }
    }

    public var type: Type = .Email {
        didSet {
            self.textField?.placeholder = type.placeholder
            self.textField?.secureTextEntry = type.secure
            self.textField?.autocorrectionType = .Default
            self.textField?.autocapitalizationType = .None
            self.textField?.keyboardType = type.keyboardType
            self.iconView?.image = image(named: type.iconName, compatibleWithTraitCollection: self.traitCollection)
        }
    }

    public var returnKey: UIReturnKeyType {
        get {
            return self.textField?.returnKeyType ?? .Default
        }
        set {
            self.textField?.returnKeyType = newValue
        }
    }

    private func layoutField() {
        let iconContainer = UIView()
        let textField = UITextField()
        let iconView = UIImageView()

        iconContainer.addSubview(iconView)
        self.addSubview(iconContainer)
        self.addSubview(textField)

        constraintEqual(anchor: iconContainer.leftAnchor, toAnchor: self.leftAnchor)
        constraintEqual(anchor: iconContainer.topAnchor, toAnchor: self.topAnchor)
        constraintEqual(anchor: iconContainer.bottomAnchor, toAnchor: self.bottomAnchor)
        constraintEqual(anchor: iconContainer.heightAnchor, toAnchor: iconContainer.widthAnchor)
        iconContainer.translatesAutoresizingMaskIntoConstraints = false

        constraintEqual(anchor: textField.leftAnchor, toAnchor: iconContainer.rightAnchor, constant: 16)
        constraintEqual(anchor: textField.topAnchor, toAnchor: self.topAnchor, constant: 13)
        constraintEqual(anchor: textField.rightAnchor, toAnchor: self.rightAnchor, constant: -16)
        constraintEqual(anchor: textField.bottomAnchor, toAnchor: self.bottomAnchor, constant: -13)
        textField.translatesAutoresizingMaskIntoConstraints = false

        constraintEqual(anchor: iconView.centerXAnchor, toAnchor: iconContainer.centerXAnchor)
        constraintEqual(anchor: iconView.centerYAnchor, toAnchor: iconContainer.centerYAnchor)
        iconView.translatesAutoresizingMaskIntoConstraints = false

        iconContainer.backgroundColor = UIColor ( red: 0.9333, green: 0.9333, blue: 0.9333, alpha: 1.0 )
        iconView.tintColor = UIColor ( red: 0.5725, green: 0.5804, blue: 0.5843, alpha: 1.0 )

        self.textField = textField
        self.iconView = iconView

        self.backgroundColor = .whiteColor()
        self.layer.cornerRadius = 3.67
        self.layer.masksToBounds = true
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor ( red: 0.9333, green: 0.9333, blue: 0.9333, alpha: 1.0 ).CGColor
        self.type = .Email
    }

    public override func intrinsicContentSize() -> CGSize {
        return CGSize(width: 230, height: 49)
    }

    public enum Type {
        case Email
        case Username
        case EmailOrUsername
        case Password
        case Phone
        case OneTimePassword

        var placeholder: String? {
            switch self {
            case .Email:
                return i18n(key: "com.auth0.lock.input.placeholder.email", value: "Email", comment: "Email placeholder")
            case .Username:
                return i18n(key: "com.auth0.lock.input.placeholder.username", value: "Username", comment: "Email placeholder")
            case .EmailOrUsername:
                return i18n(key: "com.auth0.lock.input.placeholder.email-username", value: "Username/Email", comment: "Username or Email placeholder")
            case .Password:
                return i18n(key: "com.auth0.lock.input.placeholder.password", value: "Password", comment: "Password placeholder")
            case .Phone:
                return i18n(key: "com.auth0.lock.input.placeholder.phone", value: "Phone Number", comment: "Phone placeholder")
            case .OneTimePassword:
                return i18n(key: "com.auth0.lock.input.placeholder.otp", value: "Code", comment: "OTP placeholder")
            }
        }

        var secure: Bool {
            if case .Password = self {
                return true
            }

            return false
        }

        var iconName: String {
            switch self {
            case .Email:
                return "ic_mail"
            case .Username:
                return "ic_person"
            case .EmailOrUsername:
                return "ic_mail"
            case .Password:
                return "ic_lock"
            case .Phone:
                return "ic_phone"
            case .OneTimePassword:
                return "ic_lock"
            }
        }

        var keyboardType: UIKeyboardType {
            switch self {
            case .Email:
                return .EmailAddress
            case .Username:
                return .Default
            case .EmailOrUsername:
                return .Default
            case .Password:
                return .Default
            case .Phone:
                return .PhonePad
            case .OneTimePassword:
                return .DecimalPad
            }
        }
    }
}
