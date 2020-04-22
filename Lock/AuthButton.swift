// AuthButton.swift
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

public class AuthButton: UIView {

    weak var button: UIButton?
    weak var iconView: UIImageView?

    public var color: UIColor {
        get {
            return self.normalColor
        }
        set {
            self.normalColor = newValue
        }
    }

    public var normalColor: UIColor = UIColor.a0_orange {
        didSet {
            let normal = image(withColor: self.normalColor)
            self.button?.setBackgroundImage(normal, for: .normal)
        }
    }

    public var highlightedColor: UIColor = UIColor.a0_orange.a0_darker(0.3) {
        didSet {
            let highlighted = image(withColor: self.highlightedColor)
            self.button?.setBackgroundImage(highlighted, for: .highlighted)
        }
    }

    public var borderColor: UIColor? {
        didSet {
            if let borderColor = self.borderColor {
                self.layer.borderWidth = 1
                self.layer.borderColor = borderColor.cgColor
            } else {
                self.layer.borderWidth = 0
                self.layer.borderColor = UIColor.clear.cgColor
            }
        }
    }

    public var titleColor: UIColor = .white {
        didSet {
            self.iconView?.tintColor = self.titleColor
            self.button?.setTitleColor(self.titleColor, for: .normal)
            self.button?.tintColor = self.titleColor
        }
    }

    public var title: String? {
        didSet {
            guard case .big = self.size else { return }
            self.button?.setTitle(self.title, for: .normal)
        }
    }

    public var icon: UIImage? {
        get {
            return self.iconView?.image
        }
        set {
            self.iconView?.image = newValue
        }
    }

    public var onPress: (AuthButton) -> Void = { _ in }

    // MARK: - Style

    public var size: Size {
        didSet {
            self.subviews.forEach { $0.removeFromSuperview() }
            self.layout(size: self.size)
        }
    }

    public enum Size {
        case small
        case big
    }

    // MARK: - Initialisers

    public init(size: Size) {
        self.size = size
        super.init(frame: .zero)
        self.layout(size: self.size)
    }

    required override public init(frame: CGRect) {
        self.size = .big
        super.init(frame: frame)
        self.layout(size: self.size)
    }

    public required init?(coder aDecoder: NSCoder) {
        self.size = .big
        super.init(coder: aDecoder)
        self.layout(size: self.size)
    }

    // MARK: - Layout

    private func layout(size: Size) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.layer.cornerRadius = 3
        self.layer.masksToBounds = true

        let button = UIButton(type: .custom)
        let iconView = UIImageView()

        self.addSubview(button)
        button.addSubview(iconView)

        constraintEqual(anchor: iconView.leftAnchor, toAnchor: button.leftAnchor)
        constraintEqual(anchor: iconView.topAnchor, toAnchor: button.topAnchor)
        constraintEqual(anchor: iconView.bottomAnchor, toAnchor: button.bottomAnchor)
        constraintEqual(anchor: iconView.widthAnchor, toAnchor: iconView.heightAnchor)
        iconView.translatesAutoresizingMaskIntoConstraints = false

        constraintEqual(anchor: button.leftAnchor, toAnchor: self.leftAnchor)
        constraintEqual(anchor: button.topAnchor, toAnchor: self.topAnchor)
        constraintEqual(anchor: button.rightAnchor, toAnchor: self.rightAnchor)
        constraintEqual(anchor: button.bottomAnchor, toAnchor: self.bottomAnchor)

        if case .small = size {
            constraintEqual(anchor: button.widthAnchor, toAnchor: button.heightAnchor)
        }

        dimension(dimension: button.heightAnchor, greaterThanOrEqual: 50)
        button.translatesAutoresizingMaskIntoConstraints = false

        iconView.image = self.icon ?? image(named: "ic_auth_auth0", compatibleWithTraitCollection: self.traitCollection)
        iconView.contentMode = .center
        iconView.tintColor = self.titleColor

        button.setBackgroundImage(image(withColor: self.color), for: .normal)
        button.setBackgroundImage(image(withColor: self.highlightedColor), for: .highlighted)
        button.setTitleColor(self.titleColor, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: UIFont.weightMedium)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.5
        button.contentVerticalAlignment = .center
        button.contentHorizontalAlignment = .left
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)

        if case .big = self.size {
            button.setTitle(self.title, for: .normal)
        }

        self.button = button
        self.iconView = iconView
    }

    public override func updateConstraints() {
        super.updateConstraints()
        self.button?.titleEdgeInsets = UIEdgeInsets(top: 0, left: max(self.frame.size.height, 50) + 12, bottom: 0, right: 12)
    }

    public override var intrinsicContentSize: CGSize {
        switch self.size {
        case .big:
            return CGSize(width: 280, height: 50)
        case .small:
            return CGSize(width: 50, height: 50)
        }
    }

    // MARK: - Event

    @objc func buttonPressed(_ sender: Any) {
        self.onPress(self)
    }
}

// MARK: - Color Util
extension UIColor {
    func a0_darker(_ percentage: CGFloat) -> UIColor {
        guard percentage >= 0 && percentage <= 1 else { return self }
        var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, alpha: CGFloat = 0
        guard self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) else { return self }
        return UIColor(hue: hue, saturation: saturation, brightness: (brightness - percentage), alpha: alpha)
    }

    func a0_lighter(_ percentage: CGFloat) -> UIColor {
        guard percentage >= 0 && percentage <= 1 else { return self }
        var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, alpha: CGFloat = 0
        guard self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) else { return self }
        return UIColor(hue: hue, saturation: saturation, brightness: (brightness + percentage), alpha: alpha)
    }
}
