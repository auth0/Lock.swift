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

class InternationalPhoneInputView: UIView, Form {

    var container: UIView
    var countryLabel: UILabel
    var codeLabel: UILabel
    var inputField: InputField
    var stackView: UIStackView
    var countryStore: CountryCodeStore

    init(withCountryData data: CountryCodeStore) {
        self.container = UIView()
        self.countryLabel = UILabel()
        self.codeLabel = UILabel()
        self.inputField = InputField()
        self.stackView = UIStackView()
        self.countryStore = data
        super.init(frame: CGRect.zero)
        self.isUserInteractionEnabled = true
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
        self.countryLabel.text = countryCode.name
        self.codeLabel.text = countryCode.prefix
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
        constraintEqual(anchor: countryLabel.rightAnchor, toAnchor: codeLabel.leftAnchor, priority: UILayoutPriorityDefaultHigh)
        constraintEqual(anchor: countryLabel.bottomAnchor, toAnchor: container.bottomAnchor)
        countryLabel.translatesAutoresizingMaskIntoConstraints = false

        constraintEqual(anchor: codeLabel.leftAnchor, toAnchor: countryLabel.rightAnchor)
        constraintEqual(anchor: codeLabel.topAnchor, toAnchor: container.topAnchor)
        constraintEqual(anchor: codeLabel.rightAnchor, toAnchor: actionIconContainer.leftAnchor)
        constraintEqual(anchor: codeLabel.bottomAnchor, toAnchor: container.bottomAnchor)
        dimension(dimension: codeLabel.widthAnchor, withValue: 60.0)
        codeLabel.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .horizontal)
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

        countryLabel.textColor = UIColor(red:0.73, green:0.73, blue:0.73, alpha:1.0)
        codeLabel.textColor = countryLabel.textColor
        codeLabel.textAlignment = .right
        iconContainer.backgroundColor = UIColor ( red: 0.9333, green: 0.9333, blue: 0.9333, alpha: 1.0 )
        iconView.tintColor = UIColor ( red: 0.5725, green: 0.5804, blue: 0.5843, alpha: 1.0 )
        actionIconView.tintColor = UIColor.black

        container.backgroundColor = UIColor(red:0.98, green:0.98, blue:0.98, alpha:1.0)
        container.layer.cornerRadius = 3.67
        container.layer.masksToBounds = true
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor ( red: 0.9333, green: 0.9333, blue: 0.9333, alpha: 1.0 ).cgColor
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let countryTableView = CountryTableViewController(withData: self.countryStore)
        countryTableView.onDidSelect = {
            self.updateCountry($0)
            self.onCountryChange($0)
        }
        let navigationModal = ModalNavigationController(rootViewController: countryTableView)
        navigationModal.header = "Calling codes".i18n(key: "com.auth0.lock.passwordless.sms.country.header", comment: "Country tableview navigation header")
        navigationModal.addBackButton {
            navigationModal.dismiss(animated: true, completion: nil)
        }
        navigationModal.present()
    }

}
