// NotificationView.swift
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

class NotificationView: UIView, View {

    init(withStatus status: NotificationStatus) {
        super.init(frame: CGRect.zero)

        let center = UILayoutGuide()
        let imageView = UIImageView()
        let messageLabel = UILabel()

        self.addSubview(imageView)
        self.addSubview(messageLabel)
        self.addLayoutGuide(center)

        constraintEqual(anchor: center.leftAnchor, toAnchor: self.leftAnchor)
        constraintEqual(anchor: center.topAnchor, toAnchor: self.topAnchor)
        constraintEqual(anchor: center.rightAnchor, toAnchor: self.rightAnchor)
        constraintEqual(anchor: center.bottomAnchor, toAnchor: self.bottomAnchor)

        constraintEqual(anchor: imageView.centerYAnchor, toAnchor: center.centerYAnchor, constant: -20)
        constraintEqual(anchor: imageView.centerXAnchor, toAnchor: center.centerXAnchor)
        imageView.translatesAutoresizingMaskIntoConstraints = false

        constraintEqual(anchor: imageView.bottomAnchor, toAnchor: messageLabel.topAnchor, constant: -20)
        constraintEqual(anchor: center.centerXAnchor, toAnchor: messageLabel.centerXAnchor)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false

        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = regularSystemFont(size: 15)

        switch(status) {
        case .signedup:
            messageLabel.text = "Thanks for signing up.".i18n(key: "com.auth0.lock.notification.signup", comment: "Signed Up")
            imageView.image = LazyImage(name: "ic_email_sent", bundle: bundleForLock()).image()
        }

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func apply(style: Style) {
    }
}
