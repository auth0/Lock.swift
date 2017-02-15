// MessageView.swift
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

class MessageView: UIView {

    weak var messageLabel: UILabel?

    var message: String? {
        get {
            return self.messageLabel?.text
        }
        set {
            self.messageLabel?.text = newValue
        }
    }

    var type: Flavor = .success {
        didSet {
            self.backgroundColor = self.type.color
            self.messageLabel?.textColor = self.type.textColor
        }
    }

    enum Flavor {
        case success
        case failure

        var textColor: UIColor {
            return .white
        }

        var color: UIColor {
            switch self {
            case .success:
                return UIColor ( red: 0.4941, green: 0.8275, blue: 0.1294, alpha: 1.0 )
            case .failure:
                return UIColor ( red: 1.0, green: 0.2431, blue: 0.0, alpha: 1.0 )
            }
        }
    }

    required override init(frame: CGRect) {
        super.init(frame: frame)
        self.layoutMessage()
    }

    convenience init() {
        self.init(frame: CGRect.zero)
    }

    required convenience init?(coder aDecoder: NSCoder) {
        self.init(frame: CGRect.zero)
    }

    // MARK: - Layout

    private func layoutMessage() {
        let guide = UILayoutGuide()

        self.addLayoutGuide(guide)

        constraintEqual(anchor: guide.leftAnchor, toAnchor: self.leftAnchor, constant: 20)
        constraintEqual(anchor: guide.rightAnchor, toAnchor: self.rightAnchor, constant: -20)
        constraintEqual(anchor: guide.topAnchor, toAnchor: self.topAnchor, constant: 30)
        constraintEqual(anchor: guide.bottomAnchor, toAnchor: self.bottomAnchor, constant: -10)

        let messageLabel = UILabel()
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = .systemFont(ofSize: 11, weight: UIFontWeightMedium)
        messageLabel.textColor = self.type.textColor

        self.addSubview(messageLabel)

        constraintEqual(anchor: messageLabel.leftAnchor, toAnchor: guide.leftAnchor)
        constraintEqual(anchor: messageLabel.rightAnchor, toAnchor: guide.rightAnchor)
        constraintEqual(anchor: messageLabel.topAnchor, toAnchor: guide.topAnchor)
        constraintEqual(anchor: messageLabel.bottomAnchor, toAnchor: guide.bottomAnchor)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false

        self.messageLabel = messageLabel
        self.backgroundColor = self.type.color
    }
}
