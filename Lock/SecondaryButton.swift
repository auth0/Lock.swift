// SecondaryButton.swift
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

class SecondaryButton: UIView {

    weak var button: UIButton?

    var onPress: (SecondaryButton) -> Void = {_ in }

    var color: UIColor = .clear {
        didSet {
            self.backgroundColor = self.color
        }
    }

    var title: String? {
        get {
            return self.button?.currentTitle
        }
        set {
            self.button?.setTitle(newValue, for: UIControlState())
        }
    }

    // MARK: - Initialisers
    convenience init() {
        self.init(frame: CGRect.zero)
    }

    required override init(frame: CGRect) {
        super.init(frame: frame)
        self.layoutButton()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layoutButton()
    }

    // MARK: - Layout

    private func layoutButton() {
        let button = UIButton(type: .system)

        self.addSubview(button)

        constraintEqual(anchor: button.centerXAnchor, toAnchor: self.centerXAnchor)
        constraintGreaterOrEqual(anchor: button.leftAnchor, toAnchor: self.leftAnchor)
        constraintGreaterOrEqual(anchor: button.rightAnchor, toAnchor: self.rightAnchor)
        constraintEqual(anchor: button.centerYAnchor, toAnchor: self.centerYAnchor)
        button.translatesAutoresizingMaskIntoConstraints = false

        button.tintColor = Style.Auth0.secondaryButtonColor
        button.titleLabel?.font = regularSystemFont(size: 15)
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.titleLabel?.textAlignment = .center
        button.addTarget(self, action: #selector(pressed), for: .touchUpInside)

        self.button = button
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: 76)
    }

    func pressed(_ sender: Any) {
        self.onPress(self)
    }
}

extension SecondaryButton: Stylable {

    func apply(style: Style) {
        self.button?.tintColor = style.secondaryButtonColor
    }
}
