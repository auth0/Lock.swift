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

class InputField: UIView, Stylable {

    weak var containerView: UIView?
    weak var textField: UITextField?
    weak var iconView: UIImageView?
    weak var iconContainer: UIView?
    weak var errorLabel: UILabel?
    weak var nextField: InputField?

    private weak var errorLabelTopPadding: NSLayoutConstraint?
    private weak var textFieldLeftAnchor: NSLayoutConstraint?
    private weak var textFieldRightPadding: NSLayoutConstraint?
    private(set) var state: State = .invalid(nil)
    private weak var borderColor: UIColor?
    private weak var borderColorError: UIColor?

    private lazy var debounceShowError: () -> Void = debounce(0.8, queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated), action: { [weak self] in self?.needsToUpdateState() })

    var text: String? {
        get {
            return self.textField?.text
        }
        set {
            self.textField?.text = newValue
        }
    }

    var type: InputType = .email {
        didSet {
            self.textField?.placeholder = type.placeholder
            if self.textField?.text?.isEmpty ?? true {
                self.textField?.text = type.defaultValue
            }
            self.textField?.isSecureTextEntry = type.secure
            self.textField?.autocorrectionType = type.autocorrectionType
            self.textField?.autocapitalizationType = type.autocapitalizationType
            self.textField?.keyboardType = type.keyboardType
            if #available(iOS 10.0, *) {
                self.textField?.textContentType = type.contentType
            }
            if let icon = type.icon {
                self.iconView?.image = icon.image(compatibleWithTraits: self.traitCollection)
            } else if let textField = self.textField, let container = self.containerView {
                self.iconContainer?.removeFromSuperview()
                textFieldLeftAnchor = constraintEqual(anchor: textField.leftAnchor, toAnchor: container.leftAnchor, constant: 16)
            }
            isHidden = type.hidden
            if isHidden {
                showValid()
            }
        }
    }

    var returnKey: UIReturnKeyType {
        get {
            return self.textField?.returnKeyType ?? .default
        }
        set {
            self.textField?.returnKeyType = newValue
            self.textField?.reloadInputViews()
        }
    }

    var onTextChange: (InputField) -> Void = {_ in}

    var onReturn: (InputField) -> Void = {_ in}

    var onBeginEditing: (InputField) -> Void = {_ in}

    var onEndEditing: (InputField) -> Void = {_ in}

    // MARK: - Initialisers

    convenience init() {
        self.init(frame: CGRect.zero)
    }

    required override init(frame: CGRect) {
        super.init(frame: frame)
        self.layoutField()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layoutField()
    }

    // MARK: - Error

    func showError(_ message: String? = nil, noDelay: Bool = false) {
        self.state = .invalid(message)
        if noDelay {
            self.needsToUpdateState()
        } else {
            self.debounceShowError()
        }
    }

    func showValid() {
        self.state = .valid
        self.needsToUpdateState()
    }

    func needsToUpdateState() {
        Queue.main.async {
            self.errorLabel?.text = self.state.text
            self.errorLabelTopPadding?.constant = self.state.padding
            switch self.state {
            case .valid:
                self.containerView?.layer.borderColor = self.borderColor?.cgColor
            case .invalid:
                self.containerView?.layer.borderColor = self.borderColorError?.cgColor
            }
        }
    }

    // MARK: - Layout

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
        errorLabel.setContentHuggingPriority(UILayoutPriority.priorityDefaultHigh, for: .vertical)
        errorLabel.setContentCompressionResistancePriority(UILayoutPriority.priorityDefaultHigh, for: .vertical)
        errorLabel.translatesAutoresizingMaskIntoConstraints = false

        constraintEqual(anchor: iconContainer.leftAnchor, toAnchor: container.leftAnchor)
        constraintEqual(anchor: iconContainer.topAnchor, toAnchor: container.topAnchor)
        constraintEqual(anchor: iconContainer.bottomAnchor, toAnchor: container.bottomAnchor)
        constraintEqual(anchor: iconContainer.heightAnchor, toAnchor: iconContainer.widthAnchor)
        iconContainer.translatesAutoresizingMaskIntoConstraints = false

        self.textFieldLeftAnchor = constraintEqual(anchor: textField.leftAnchor, toAnchor: iconContainer.rightAnchor, constant: 16)
        constraintEqual(anchor: textField.topAnchor, toAnchor: container.topAnchor)
        self.textFieldRightPadding = constraintEqual(anchor: textField.rightAnchor, toAnchor: container.rightAnchor, constant: -16)
        constraintEqual(anchor: textField.bottomAnchor, toAnchor: container.bottomAnchor)
        dimension(dimension: textField.heightAnchor, withValue: 50)
        textField.translatesAutoresizingMaskIntoConstraints = false

        constraintEqual(anchor: iconView.centerXAnchor, toAnchor: iconContainer.centerXAnchor)
        constraintEqual(anchor: iconView.centerYAnchor, toAnchor: iconContainer.centerYAnchor)
        iconView.translatesAutoresizingMaskIntoConstraints = false

        iconContainer.backgroundColor = Style.Auth0.inputIconBackgroundColor
        iconView.tintColor = Style.Auth0.inputIconColor
        textField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        textField.delegate = self
        textField.font = UIFont.systemFont(ofSize: 17)
        errorLabel.text = nil
        errorLabel.numberOfLines = 0

        self.textField = textField
        self.iconView = iconView
        self.iconContainer = iconContainer
        self.containerView = container
        self.errorLabel = errorLabel

        self.containerView?.backgroundColor = .white
        self.containerView?.layer.cornerRadius = 3.67
        self.containerView?.layer.masksToBounds = true
        self.containerView?.layer.borderWidth = 1
        self.type = .email
        self.errorLabel?.text = State.valid.text
        self.containerView?.layer.borderColor = Style.Auth0.inputBorderColor.cgColor
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: 230, height: 50)
    }

    // MARK: - Password Manager

    func addFieldButton(withIcon name: String, color: UIColor = .black) -> IconButton? {
        guard let container = self.containerView, let textField = self.textField else { return nil }

        let button = IconButton()
        button.icon = LazyImage(name: name, bundle: Lock.bundle).image(compatibleWithTraits: self.traitCollection)
        button.color = color
        container.addSubview(button)

        self.textFieldRightPadding?.isActive = false
        constraintEqual(anchor: textField.rightAnchor, toAnchor: button.leftAnchor)
        constraintEqual(anchor: button.leftAnchor, toAnchor: textField.rightAnchor)
        constraintEqual(anchor: button.topAnchor, toAnchor: textField.topAnchor)
        constraintEqual(anchor: button.bottomAnchor, toAnchor: textField.bottomAnchor)
        constraintEqual(anchor: button.rightAnchor, toAnchor: container.rightAnchor)
        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }

    // MARK: - Internal

    enum State {
        case valid
        case invalid(String?)

        var text: String? {
            switch self {
            case .valid:
                return nil
            case .invalid(let error):
                return error
            }
        }

        var padding: CGFloat {
            switch self {
            case .invalid where self.text != nil:
                return -10
            default:
                return 0
            }
        }

        var isValid: Bool {
            switch self {
            case .valid:
                return true
            case .invalid:
                return false
            }
        }
    }

    @objc func textChanged(_ field: UITextField) {
        self.onTextChange(self)
    }

    // MARK: - Types
    enum InputType {
        case email
        case username
        case emailOrUsername
        case password
        case phone
        case oneTimePassword
        case custom(name: String, placeholder: String, defaultValue: String?, storage: UserStorage, icon: LazyImage?, keyboardType: UIKeyboardType, autocorrectionType: UITextAutocorrectionType, autocapitalizationType: UITextAutocapitalizationType, secure: Bool, hidden: Bool, contentType: UITextContentType?)

        var placeholder: String? {
            switch self {
            case .email:
                return "Email".i18n(key: "com.auth0.lock.input.email.placeholder", comment: "Email placeholder")
            case .username:
                return "Username".i18n(key: "com.auth0.lock.input.username.placeholder", comment: "Username placeholder")
            case .emailOrUsername:
                return "Username/Email".i18n(key: "com.auth0.lock.input.email_username.placeholder", comment: "Username or Email placeholder")
            case .password:
                return "Password".i18n(key: "com.auth0.lock.input.password.placeholder", comment: "Password placeholder")
            case .phone:
                return "Phone Number".i18n(key: "com.auth0.lock.input.phone.placeholder", comment: "Phone placeholder")
            case .oneTimePassword:
                return "Code".i18n(key: "com.auth0.lock.input.otp.placeholder", comment: "OTP placeholder")
            case .custom(_, let placeholder, _, _, _, _, _, _, _, _, _):
                return placeholder
            }
        }

        var defaultValue: String? {
            switch self {
            case .custom(_, _, let defaultValue, _, _, _, _, _, _, _, _):
                return defaultValue
            default:
                return nil
            }
        }

        var secure: Bool {
            switch self {
            case .password:
                return true
            case .custom(_, _, _, _, _, _, _, _, let secure, _, _):
                return secure
            default:
                return false
            }
        }

        var hidden: Bool {
            switch self {
            case .custom(_, _, _, _, _, _, _, _, _, let hidden, _):
                return hidden
            default:
                return false
            }
        }

        var icon: LazyImage? {
            switch self {
            case .email:
                return lazyImage(named: "ic_mail")
            case .username:
                return lazyImage(named: "ic_person")
            case .emailOrUsername:
                return lazyImage(named: "ic_mail")
            case .password:
                return lazyImage(named: "ic_lock")
            case .phone:
                return lazyImage(named: "ic_phone")
            case .oneTimePassword:
                return lazyImage(named: "ic_lock")
            case .custom(_, _, _, _, let icon, _, _, _, _, _, _):
                return icon
            }
        }

        var keyboardType: UIKeyboardType {
            switch self {
            case .email:
                return .emailAddress
            case .username:
                return .default
            case .emailOrUsername:
                return .emailAddress
            case .password:
                return .default
            case .phone:
                return .phonePad
            case .oneTimePassword:
                return .decimalPad
            case .custom(_, _, _, _, _, let keyboardType, _, _, _, _, _):
                return keyboardType
            }
        }

        var contentType: UITextContentType? {
            switch self {
            case .email, .emailOrUsername:
                if #available(iOS 10.0, *) {
                    return .emailAddress
                }
                return nil
            case .username:
                if #available(iOS 11.0, *) {
                    return .username
                }
                return nil
            case .password:
                if #available(iOS 11.0, *) {
                    return .password
                }
                return nil
            case .phone:
                if #available(iOS 10.0, *) {
                    return .telephoneNumber
                }
                return nil
            case .oneTimePassword:
                #if swift(>=4.0)
                    if #available(iOS 12.0, *) {
                        return .oneTimeCode
                    }
                #endif
                return nil
            case .custom(_, _, _, _, _, _, _, _, _, _, let contentType):
                return contentType
            }
        }

        var autocorrectionType: UITextAutocorrectionType {
            switch self {
            case .custom(_, _, _, _, _, _, let autocorrectionType, _, _, _, _):
                return autocorrectionType
            default:
                return .no
            }
        }

        var autocapitalizationType: UITextAutocapitalizationType {
            switch self {
            case .custom(_, _, _, _, _, _, _, let autocapitalizationType, _, _, _):
                return autocapitalizationType
            default:
                return .none
            }
        }
    }

    // MARK: - Styable
    func apply(style: Style) {
        self.borderColor = style.inputBorderColor
        self.borderColorError = style.inputBorderColorError
        self.textField?.textColor = style.inputTextColor
        self.textField?.attributedPlaceholder = NSAttributedString(string: self.textField?.placeholder ?? "",
                                                                   attributes: [NSAttributedString.attributedKeyColor: style.inputPlaceholderTextColor])
        self.containerView?.backgroundColor = style.inputBackgroundColor
        self.containerView?.layer.borderColor = style.inputBorderColor.cgColor
        self.errorLabel?.textColor = style.inputBorderColorError
        self.iconContainer?.backgroundColor = style.inputIconBackgroundColor
        self.iconView?.tintColor = style.inputIconColor
    }
}

// MARK: - UITextFieldDelegate
extension InputField: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.onBeginEditing(self)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        self.onEndEditing(self)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.onTextChange(self)
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

}
