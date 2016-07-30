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

    public var color: UIColor = UIColor ( red: 0.9176, green: 0.3255, blue: 0.1373, alpha: 1.0 ) {
        didSet {
            let normal = image(withColor: self.color)
            self.button?.setBackgroundImage(normal, forState: .Normal)
            let highlighted = image(withColor: self.color.a0_darker(0.3))
            self.button?.setBackgroundImage(highlighted, forState: .Highlighted)
        }
    }

    public var titleColor: UIColor = .whiteColor() {
        didSet {
            self.iconView?.tintColor = self.titleColor
            self.button?.setTitleColor(self.titleColor, forState: .Normal)
        }
    }

    public var title: String? {
        get {
            return self.button?.titleForState(.Normal)
        }
        set {
            self.button?.setTitle(newValue, forState: .Normal)
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

    // MARK:- Initialisers

    public convenience init() {
        self.init(frame: CGRectZero)
    }

    required override public init(frame: CGRect) {
        super.init(frame: frame)
        self.layoutButton()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layoutButton()
    }

    // MARK:- Layout

    private func layoutButton() {
        let button = UIButton(type: .Custom)
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
        button.translatesAutoresizingMaskIntoConstraints = false

        button.layer.cornerRadius = 3
        button.layer.masksToBounds = true

        iconView.backgroundColor = UIColor ( red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3 )
        iconView.image = image(named: "ic_auth_auth0", compatibleWithTraitCollection: self.traitCollection)
        iconView.contentMode = .Center
        iconView.tintColor = self.titleColor

        button.setBackgroundImage(image(withColor: self.color), forState: .Normal)
        button.setTitleColor(self.titleColor, forState: .Normal)
        button.titleLabel?.font = .systemFontOfSize(13.33, weight: UIFontWeightMedium)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.5
        button.contentVerticalAlignment = .Center
        button.contentHorizontalAlignment = .Left
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: self.frame.size.height + 18, bottom: 0, right: 18)

        self.button = button
        self.iconView = iconView
    }
}

extension UIColor {
    func a0_darker(percentage: CGFloat) -> UIColor {
        guard percentage >= 0 && percentage <= 1 else { return self }
        var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, alpha: CGFloat = 0
        guard self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) else { return self }
        return UIColor(hue: hue, saturation: saturation, brightness: (brightness - percentage), alpha: alpha)
    }
}