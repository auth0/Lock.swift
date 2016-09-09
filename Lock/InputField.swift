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

public class InputField: UIView, UITextFieldDelegate {

    weak var containerView: UIView?
    weak var textField: UITextField?
    weak var iconView: UIImageView?
    weak var errorLabel: UILabel?

    weak var nextField: InputField?

    private weak var errorLabelTopPadding: NSLayoutConstraint?

    private(set) var state: State = .Invalid(nil)

    private lazy var debounceShowError: () -> () = debounce(0.8, queue: dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), action: self.needsToUpdateState)

    public var text: String? {
        get {
            return self.textField?.text
        }
        set {
            self.textField?.text = newValue
        }
    }

    public var type: InputType = .Email {
        didSet {
            self.textField?.placeholder = type.placeholder
            self.textField?.secureTextEntry = type.secure
            self.textField?.autocorrectionType = .Default
            self.textField?.autocapitalizationType = .None
            self.textField?.keyboardType = type.keyboardType
            self.iconView?.image = type.icon.image(compatibleWithTraits: self.traitCollection)
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

    public var onTextChange: InputField -> () = {_ in}

    public var onReturn: InputField -> () = {_ in}

    // MARK:- Initialisers

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

    // MARK:- Error

    public func showError(message: String? = nil, noDelay: Bool = false) {
        self.state = .Invalid(message)
        if noDelay {
            self.needsToUpdateState()
        } else {
            self.debounceShowError()
        }
    }

    public func showValid() {
        self.state = .Valid
        self.needsToUpdateState()
    }

    public func needsToUpdateState() {
        Queue.main.async {
            self.errorLabel?.text = self.state.text
            self.containerView?.layer.borderColor = self.state.color.CGColor
            self.errorLabelTopPadding?.constant = self.state.padding
        }
    }

    // MARK:- Layout

    private func layoutField() {
        let container = UIView()
        let iconContainer = UIView()
        let textField = UITextField()
        let iconView = UIImageView()
        let errorLabel = UILabel()

        iconContainer.addSubview(iconView)
        container.addSubview(iconContainer)
        container.addSubview(textField)
        self.addSubview(container)
        self.addSubview(errorLabel)

        constraintEqual(anchor: container.leftAnchor, toAnchor: self.leftAnchor)
        constraintEqual(anchor: container.topAnchor, toAnchor: self.topAnchor)
        constraintEqual(anchor: container.rightAnchor, toAnchor: self.rightAnchor)
        self.errorLabelTopPadding = constraintEqual(anchor: container.bottomAnchor, toAnchor: errorLabel.topAnchor)
        container.translatesAutoresizingMaskIntoConstraints = false

        constraintEqual(anchor: errorLabel.leftAnchor, toAnchor: self.leftAnchor)
        constraintEqual(anchor: errorLabel.rightAnchor, toAnchor: self.rightAnchor)
        constraintEqual(anchor: errorLabel.bottomAnchor, toAnchor: self.bottomAnchor)
        errorLabel.setContentHuggingPriority(UILayoutPriorityDefaultHigh, forAxis: .Vertical)
        errorLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh, forAxis: .Vertical)
        errorLabel.translatesAutoresizingMaskIntoConstraints = false

        constraintEqual(anchor: iconContainer.leftAnchor, toAnchor: container.leftAnchor)
        constraintEqual(anchor: iconContainer.topAnchor, toAnchor: container.topAnchor)
        constraintEqual(anchor: iconContainer.bottomAnchor, toAnchor: container.bottomAnchor)
        constraintEqual(anchor: iconContainer.heightAnchor, toAnchor: iconContainer.widthAnchor)
        iconContainer.translatesAutoresizingMaskIntoConstraints = false

        constraintEqual(anchor: textField.leftAnchor, toAnchor: iconContainer.rightAnchor, constant: 16)
        constraintEqual(anchor: textField.topAnchor, toAnchor: container.topAnchor)
        constraintEqual(anchor: textField.rightAnchor, toAnchor: container.rightAnchor, constant: -16)
        constraintEqual(anchor: textField.bottomAnchor, toAnchor: container.bottomAnchor)
        dimension(textField.heightAnchor, withValue: 50)
        textField.translatesAutoresizingMaskIntoConstraints = false

        constraintEqual(anchor: iconView.centerXAnchor, toAnchor: iconContainer.centerXAnchor)
        constraintEqual(anchor: iconView.centerYAnchor, toAnchor: iconContainer.centerYAnchor)
        iconView.translatesAutoresizingMaskIntoConstraints = false

        iconContainer.backgroundColor = UIColor ( red: 0.9333, green: 0.9333, blue: 0.9333, alpha: 1.0 )
        iconView.tintColor = UIColor ( red: 0.5725, green: 0.5804, blue: 0.5843, alpha: 1.0 )
        textField.addTarget(self, action: #selector(textChanged), forControlEvents: .EditingChanged)
        textField.delegate = self
        textField.font = UIFont.systemFontOfSize(17)
        errorLabel.textColor = .redColor()
        errorLabel.text = nil
        errorLabel.numberOfLines = 0

        self.textField = textField
        self.iconView = iconView
        self.containerView = container
        self.errorLabel = errorLabel

        self.containerView?.backgroundColor = .whiteColor()
        self.containerView?.layer.cornerRadius = 3.67
        self.containerView?.layer.masksToBounds = true
        self.containerView?.layer.borderWidth = 1
        self.type = .Email
        self.errorLabel?.text = State.Valid.text
        self.containerView?.layer.borderColor = State.Valid.color.CGColor
    }

    public override func intrinsicContentSize() -> CGSize {
        return CGSize(width: 230, height: 50)
    }

    // MARK:- Internal

    enum State {
        case Valid
        case Invalid(String?)

        var text: String? {
            switch self {
            case .Valid:
                return nil
            case .Invalid(let error):
                return error
            }
        }

        var color: UIColor {
            switch self {
            case .Valid:
                return UIColor ( red: 0.9333, green: 0.9333, blue: 0.9333, alpha: 1.0 )
            case .Invalid:
                return UIColor.redColor()
            }
        }

        var padding: CGFloat {
            switch self {
            case .Invalid where self.text != nil:
                return -10
            default:
                return 0
            }
        }
    }

    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.onReturn(self)
        if let field = self.nextField?.textField {
            Queue.main.async {
                field.becomeFirstResponder()
            }
        } else {
            Queue.main.async {
                textField.resignFirstResponder()
            }
        }
        return true
    }

    func textChanged(field: UITextField) {
        self.onTextChange(self)
    }

    // MARK:- Types
    public enum InputType {
        case Email
        case Username
        case EmailOrUsername
        case Password
        case Phone
        case OneTimePassword
        case Custom(placeholder: String, icon: LazyImage, keyboardType: UIKeyboardType, secure: Bool)

        var placeholder: String? {
            switch self {
            case .Email:
                return "Email".i18n(key: "com.auth0.lock.input.placeholder.email", comment: "Email placeholder")
            case .Username:
                return "Username".i18n(key: "com.auth0.lock.input.placeholder.username", comment: "Email placeholder")
            case .EmailOrUsername:
                return "Username/Email".i18n(key: "com.auth0.lock.input.placeholder.email-username", comment: "Username or Email placeholder")
            case .Password:
                return "Password".i18n(key: "com.auth0.lock.input.placeholder.password", comment: "Password placeholder")
            case .Phone:
                return "Phone Number".i18n(key: "com.auth0.lock.input.placeholder.phone", comment: "Phone placeholder")
            case .OneTimePassword:
                return "Code".i18n(key: "com.auth0.lock.input.placeholder.otp", comment: "OTP placeholder")
            case .Custom(let placeholder, _, _, _):
                return placeholder
            }
        }

        var secure: Bool {
            if case .Password = self {
                return true
            }

            if case .Custom(_, _, _, let secure) = self {
                return secure
            }
            return false
        }

        var icon: LazyImage {
            switch self {
            case .Email:
                return lazyImage(named: "ic_mail")
            case .Username:
                return lazyImage(named: "ic_person")
            case .EmailOrUsername:
                return lazyImage(named: "ic_mail")
            case .Password:
                return lazyImage(named: "ic_lock")
            case .Phone:
                return lazyImage(named: "ic_phone")
            case .OneTimePassword:
                return lazyImage(named: "ic_lock")
            case Custom(_, let icon, _, _):
                return icon
            }
        }

        var keyboardType: UIKeyboardType {
            switch self {
            case .Email:
                return .EmailAddress
            case .Username:
                return .Default
            case .EmailOrUsername:
                return .EmailAddress
            case .Password:
                return .Default
            case .Phone:
                return .PhonePad
            case .OneTimePassword:
                return .DecimalPad
            case Custom(_, _, let keyboardType, _):
                return keyboardType
            }
        }
    }
}
