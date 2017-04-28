// UnrecoverableErrorView.swift
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

class UnrecoverableErrorView: UIView, View {

    weak var secondaryButton: SecondaryButton?
    weak var messageLabel: UILabel?

    private weak var titleLabel: UILabel?

    init(canRetry: Bool) {
        let center = UILayoutGuide()
        let titleLabel = UILabel()
        let messageLabel = UILabel()
        let imageView = UIImageView()
        let actionButton = SecondaryButton()
        self.secondaryButton = actionButton
        self.messageLabel = messageLabel
        self.titleLabel = titleLabel

        super.init(frame: CGRect.zero)

        self.addSubview(imageView)
        self.addSubview(titleLabel)
        self.addSubview(messageLabel)
        self.addSubview(actionButton)
        self.addLayoutGuide(center)

        constraintEqual(anchor: center.leftAnchor, toAnchor: self.leftAnchor)
        constraintEqual(anchor: center.topAnchor, toAnchor: self.topAnchor)
        constraintEqual(anchor: center.rightAnchor, toAnchor: self.rightAnchor)
        constraintEqual(anchor: center.bottomAnchor, toAnchor: self.bottomAnchor)

        constraintEqual(anchor: imageView.centerXAnchor, toAnchor: center.centerXAnchor)
        constraintEqual(anchor: imageView.centerYAnchor, toAnchor: center.centerYAnchor, constant: -90)
        imageView.translatesAutoresizingMaskIntoConstraints = false

        constraintEqual(anchor: titleLabel.leftAnchor, toAnchor: self.leftAnchor, constant: 20)
        constraintEqual(anchor: titleLabel.rightAnchor, toAnchor: self.rightAnchor, constant: -20)
        constraintEqual(anchor: titleLabel.centerYAnchor, toAnchor: center.centerYAnchor, constant: -15)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        constraintEqual(anchor: messageLabel.leftAnchor, toAnchor: self.leftAnchor, constant: 20)
        constraintEqual(anchor: messageLabel.rightAnchor, toAnchor: self.rightAnchor, constant: -20)
        constraintEqual(anchor: messageLabel.topAnchor, toAnchor: titleLabel.bottomAnchor, constant: 15)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false

        constraintEqual(anchor: actionButton.centerXAnchor, toAnchor: center.centerXAnchor)
        constraintEqual(anchor: actionButton.topAnchor, toAnchor: messageLabel.bottomAnchor, constant: 10)
        actionButton.translatesAutoresizingMaskIntoConstraints = false

        imageView.image = LazyImage(name: "ic_connection_error", bundle: bundleForLock()).image(compatibleWithTraits: self.traitCollection)
        titleLabel.textAlignment = .center
        titleLabel.font = lightSystemFont(size: 22)
        titleLabel.numberOfLines = 1
        titleLabel.textColor = Style.Auth0.textColor
        messageLabel.textAlignment = .center
        messageLabel.font = regularSystemFont(size: 15)
        messageLabel.textColor = Style.Auth0.textColor.withAlphaComponent(0.50)
        messageLabel.numberOfLines = 3

        actionButton.button?.setTitleColor(UIColor(red:0.04, green:0.53, blue:0.69, alpha:1.0), for: .normal)
        actionButton.button?.titleLabel?.font = regularSystemFont(size: 16)

        if canRetry {
            titleLabel.text = "Can't load the login box".i18n(key: "com.auth0.lock.error.recoverable.title", comment: "Recoverable error title")
            messageLabel.text = "Please check your internet connection.".i18n(key: "com.auth0.lock.error.recoverable.message", comment: "Recoverable error message")
            actionButton.title = "Retry".i18n(key: "com.auth0.lock.error.recoverable.button", comment: "Recoverable error button")
        } else {
            titleLabel.text = "Can't resolve your request".i18n(key: "com.auth0.lock.error.unrecoverable.title", comment: "Unrecoverable error title")
            messageLabel.text = "There was an unexpected error while resolving the login box configuration, please contact support.".i18n(key: "com.auth0.lock.error.unrecoverable.message.no_action", comment: "Unrecoverable error message")
            actionButton.title = "Contact support".i18n(key: "com.auth0.lock.error.unrecoverable.button", comment: "Unrecoverable error button")
            actionButton.isHidden = true
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func apply(style: Style) {
        self.titleLabel?.textColor = style.textColor
        self.messageLabel?.textColor = style.textColor.withAlphaComponent(0.50)
    }
}
