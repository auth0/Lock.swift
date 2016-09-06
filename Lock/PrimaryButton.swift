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

public class PrimaryButton: UIView {

    weak var button: UIButton?
    weak var indicator: UIActivityIndicatorView?

    public var onPress: (PrimaryButton) -> () = {_ in }

    public var inProgress: Bool {
        get {
            return !(self.button?.enabled ?? true)
        }
        set {
            self.button?.enabled = !newValue
            if newValue {
                self.indicator?.startAnimating()
            } else {
                self.indicator?.stopAnimating()
            }
        }
    }

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

    private func layoutButton() {
        let button = UIButton(type: .Custom)
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)

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

        button.setImage(image(named: "ic_submit", compatibleWithTraitCollection: self.traitCollection), forState: .Normal)
        button.setImage(UIImage(), forState: .Disabled)
        button.addTarget(self, action: #selector(pressed), forControlEvents: .TouchUpInside)

        indicator.hidesWhenStopped = true

        apply(style: Style.Auth0)
        self.button = button
        self.indicator = indicator
    }

    public override func intrinsicContentSize() -> CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: 95)
    }

    func pressed(sender: AnyObject) {
        self.onPress(self)
    }
}

extension PrimaryButton: Stylable {

    func apply(style style: Style) {
        self.button?.setBackgroundImage(image(withColor: style.primaryColor), forState: .Normal)
        self.button?.setBackgroundImage(image(withColor: style.primaryColor.a0_darker(0.20)), forState: .Highlighted)
        self.button?.setBackgroundImage(image(withColor: style.disabledColor), forState: .Disabled)
        self.button?.tintColor = style.buttonTintColor
        self.indicator?.color = style.disabledTextColor
    }
}