// InternationalPhoneInputView.swift
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

class InternationalPhoneInputView: UIView, Form, Stylable {

    var container: UIView
    var countryLabel: UILabel
    var codeLabel: UILabel
    var inputField: InputField
    var stackView: UIStackView
    var countryStore: CountryCodes
    var onPresent: (UIViewController) -> Void = { _ in }
    var style: Style?

    private var iconContainer: UIView?
    private var iconView: UIImageView?
    private var actionIconView: UIImageView?

    init(withCountryData data: CountryCodes) {
        self.container = UIView()
        self.countryLabel = UILabel()
        self.codeLabel = UILabel()
        self.inputField = InputField()
        self.stackView = UIStackView()
        self.countryStore = data
        super.init(frame: CGRect.zero)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.launchCountryTable(_:)))
        self.container.addGestureRecognizer(tapGesture)
        self.layoutForm()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var type: InputField.InputType = .phone {
        didSet {
            self.inputField.type = self.type
        }
    }

    var returnKey: UIReturnKeyType = .done {
        didSet {
            self.inputField.returnKey = self.returnKey
        }
    }

    var value: String? {
        get {
            return self.inputField.text
        }
        set {
            self.inputField.text = newValue
        }
    }

    func updateCountry(_ countryCode: CountryCode) {
        self.countryLabel.text = countryCode.localizedName
        self.codeLabel.text = countryCode.phoneCode
        self.onCountryChange(countryCode)
    }

    // MARK: - PasswordlessForm

    var onCountryChange: (CountryCode) -> Void = { _ in }

    // MARK: - Form

    var onValueChange: (InputField) -> Void = { _ in } {
        didSet {
            self.inputField.onTextChange = self.onValueChange
        }
    }

    var onReturn: (InputField) -> Void {
        get {
            return self.inputField.onReturn
        }
        set {
            self.inputField.onReturn = newValue
        }
    }

    func needsToUpdateState() {
        self.inputField.needsToUpdateState()
    }

    // MARK: - Layout

    private func layoutForm() {

        let iconContainer = UIView()
        let iconView = UIImageView()
        let actionIconContainer = UIImageView()
        let actionIconView = UIImageView()

        iconContainer.addSubview(iconView)
        container.addSubview(iconContainer)
        container.addSubview(countryLabel)
        container.addSubview(codeLabel)
        container.addSubview(actionIconContainer)
        actionIconContainer.addSubview(actionIconView)
        self.addSubview(stackView)

        self.iconView = iconView
        self.actionIconView = actionIconView
        self.iconContainer = iconContainer

        stackView.addArrangedSubview(container)
        stackView.addArrangedSubview(inputField)

        constraintEqual(anchor: stackView.leftAnchor, toAnchor: self.leftAnchor, constant: 20)
        constraintEqual(anchor: stackView.topAnchor, toAnchor: self.topAnchor)
        constraintEqual(anchor: stackView.rightAnchor, toAnchor: self.rightAnchor, constant: -20)
        constraintEqual(anchor: stackView.bottomAnchor, toAnchor: self.bottomAnchor)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        dimension(dimension: container.heightAnchor, withValue: 50)
        container.translatesAutoresizingMaskIntoConstraints = false

        constraintEqual(anchor: iconContainer.leftAnchor, toAnchor: container.leftAnchor)
        constraintEqual(anchor: iconContainer.topAnchor, toAnchor: container.topAnchor)
        constraintEqual(anchor: iconContainer.bottomAnchor, toAnchor: container.bottomAnchor)
        constraintEqual(anchor: iconContainer.heightAnchor, toAnchor: iconContainer.widthAnchor)
        iconContainer.translatesAutoresizingMaskIntoConstraints = false

        constraintEqual(anchor: countryLabel.leftAnchor, toAnchor: iconContainer.rightAnchor, constant: 16)
        constraintEqual(anchor: countryLabel.topAnchor, toAnchor: container.topAnchor)
        constraintEqual(anchor: countryLabel.rightAnchor, toAnchor: codeLabel.leftAnchor, priority: UILayoutPriority.priorityDefaultHigh)
        constraintEqual(anchor: countryLabel.bottomAnchor, toAnchor: container.bottomAnchor)
        countryLabel.translatesAutoresizingMaskIntoConstraints = false

        constraintEqual(anchor: codeLabel.leftAnchor, toAnchor: countryLabel.rightAnchor)
        constraintEqual(anchor: codeLabel.topAnchor, toAnchor: container.topAnchor)
        constraintEqual(anchor: codeLabel.rightAnchor, toAnchor: actionIconContainer.leftAnchor)
        constraintEqual(anchor: codeLabel.bottomAnchor, toAnchor: container.bottomAnchor)
        dimension(dimension: codeLabel.widthAnchor, withValue: 60.0)
        codeLabel.setContentCompressionResistancePriority(UILayoutPriority.priorityRequired, for: .horizontal)
        codeLabel.translatesAutoresizingMaskIntoConstraints = false

        constraintGreaterOrEqual(anchor: actionIconContainer.leftAnchor, toAnchor: codeLabel.rightAnchor)
        constraintEqual(anchor: actionIconContainer.topAnchor, toAnchor: container.topAnchor)
        constraintEqual(anchor: actionIconContainer.rightAnchor, toAnchor: container.rightAnchor)
        constraintEqual(anchor: actionIconContainer.bottomAnchor, toAnchor: container.bottomAnchor)
        constraintEqual(anchor: actionIconContainer.widthAnchor, toAnchor: actionIconContainer.heightAnchor)
        actionIconContainer.translatesAutoresizingMaskIntoConstraints = false

        constraintEqual(anchor: actionIconView.centerXAnchor, toAnchor: actionIconContainer.centerXAnchor)
        constraintEqual(anchor: actionIconView.centerYAnchor, toAnchor: actionIconContainer.centerYAnchor)
        actionIconView.translatesAutoresizingMaskIntoConstraints = false

        constraintEqual(anchor: iconView.centerXAnchor, toAnchor: iconContainer.centerXAnchor)
        constraintEqual(anchor: iconView.centerYAnchor, toAnchor: iconContainer.centerYAnchor)
        iconView.translatesAutoresizingMaskIntoConstraints = false

        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 10

        iconView.image = lazyImage(named: "ic_globe").image()
        actionIconView.image = lazyImage(named: "ic_chevron_right").image()

        countryLabel.textColor = Style.Auth0.inputPlaceholderTextColor
        codeLabel.textColor = Style.Auth0.inputPlaceholderTextColor
        codeLabel.textAlignment = .right
        iconContainer.backgroundColor = Style.Auth0.inputIconBackgroundColor
        iconView.tintColor = Style.Auth0.inputIconColor
        actionIconView.tintColor = Style.Auth0.inputIconBackgroundColor

        container.backgroundColor = Style.Auth0.inputBackgroundColor
        container.layer.cornerRadius = 3.67
        container.layer.masksToBounds = true
        container.layer.borderWidth = 1
        container.layer.borderColor = Style.Auth0.inputBorderColor.cgColor
    }

    @objc func launchCountryTable(_ sender: UITapGestureRecognizer) {
        let countryTableView = CountryTableViewController(withData: self.countryStore) {
            self.updateCountry($0)
        }
        let navigationController = CustomNagivationController(rootViewController: countryTableView)
        if let style = self.style {
            countryTableView.apply(style: style)
            navigationController.modalPresentationStyle = style.modalPopup ? .formSheet : .overFullScreen
        }
        self.onPresent(navigationController)
    }

    func apply(style: Style) {
        self.style = style
        self.countryLabel.textColor = style.inputPlaceholderTextColor
        self.codeLabel.textColor = style.inputPlaceholderTextColor
        self.iconContainer?.backgroundColor = style.inputIconBackgroundColor
        self.iconView?.tintColor = style.inputIconColor
        self.actionIconView?.tintColor = style.inputIconBackgroundColor
        self.container.backgroundColor = style.inputBackgroundColor
        self.container.layer.borderColor = style.inputBorderColor.cgColor
    }
}

class CustomNagivationController: UINavigationController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let superview = self.view.superview {
            superview.layer.cornerRadius  = 4.0
        }
    }
}
