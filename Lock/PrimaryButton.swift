// PrimaryButton.swift
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

class PrimaryButton: UIView, Stylable {

    weak var button: UIButton?
    weak var indicator: UIActivityIndicatorView?

    private weak var textColor: UIColor?

    var hideTitle: Bool = false {
        didSet {
            guard let button = self.button else { return }
            self.layout(title: self.title, inButton: button)
        }
    }

    var title: String? = nil {
        didSet {
            guard let button = self.button else { return }
            self.layout(title: self.title, inButton: button)
        }
    }

    var onPress: (PrimaryButton) -> Void = {_ in }

    var inProgress: Bool {
        get {
            return !(self.button?.isEnabled ?? true)
        }
        set {
            self.button?.isEnabled = !newValue
            if newValue {
                self.indicator?.startAnimating()
            } else {
                self.indicator?.stopAnimating()
            }
        }
    }

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

    private func layoutButton() {
        let button = UIButton(type: .custom)
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)

        self.addSubview(button)
        self.addSubview(indicator)

        constraintEqual(anchor: button.leftAnchor, toAnchor: self.leftAnchor)
        constraintEqual(anchor: button.topAnchor, toAnchor: self.topAnchor)
        constraintEqual(anchor: button.rightAnchor, toAnchor: self.rightAnchor)
        constraintEqual(anchor: button.bottomAnchor, toAnchor: self.bottomAnchor)
        button.translatesAutoresizingMaskIntoConstraints = false

        constraintEqual(anchor: indicator.centerXAnchor, toAnchor: self.centerXAnchor)
        constraintEqual(anchor: indicator.centerYAnchor, toAnchor: self.centerYAnchor)
        indicator.translatesAutoresizingMaskIntoConstraints = false

        layout(title: self.title, inButton: button)
        button.addTarget(self, action: #selector(pressed), for: .touchUpInside)

        indicator.hidesWhenStopped = true

        apply(style: Style.Auth0)
        self.button = button
        self.indicator = indicator
    }

    private func layout(title: String?, inButton button: UIButton) {
        button.setImage(nil, for: .normal)
        button.setImage(nil, for: .disabled)
        button.setAttributedTitle(nil, for: .normal)
        button.setAttributedTitle(nil, for: .disabled)
        guard let title = title, !self.hideTitle else {
            button.setImage(image(named: "ic_submit", compatibleWithTraitCollection: self.traitCollection), for: UIControlState())
            button.setImage(UIImage(), for: .disabled)
            return
        }

        let font = mediumSystemFont(size: 16)
        let attachment = NSTextAttachment()
        attachment.image = image(named: "ic_chevron_right", compatibleWithTraitCollection: self.traitCollection)
        attachment.bounds = CGRect(x: 0.0, y: font.descender / 2.0, width: attachment.image!.size.width, height: attachment.image!.size.height)

        let attributedText = NSMutableAttributedString()
        attributedText.append(NSAttributedString(
            string: "\(title)  ",
            attributes: [
                NSForegroundColorAttributeName: self.textColor ?? Style.Auth0.buttonTintColor,
                NSFontAttributeName: font
            ]
        ))
        attributedText.append(NSAttributedString(attachment: attachment))
        button.setAttributedTitle(attributedText, for: .normal)
        button.setAttributedTitle(NSAttributedString(), for: .disabled)
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: 95)
    }

    func pressed(_ sender: Any) {
        self.onPress(self)
    }

    func apply(style: Style) {
        self.button?.setBackgroundImage(image(withColor: style.primaryColor), for: UIControlState())
        self.button?.setBackgroundImage(image(withColor: style.primaryColor.a0_darker(0.20)), for: .highlighted)
        self.button?.setBackgroundImage(image(withColor: style.disabledColor), for: .disabled)
        self.textColor = style.buttonTintColor
        self.button?.tintColor = style.buttonTintColor
        self.indicator?.color = style.disabledTextColor
        self.hideTitle = style.hideButtonTitle
    }
}
