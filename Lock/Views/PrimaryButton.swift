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
        let button = UIButton(type: .System)
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

        button.setBackgroundImage(image(withColor: UIColor ( red: 0.9176, green: 0.3255, blue: 0.1373, alpha: 1.0 )), forState: .Normal)
        button.setBackgroundImage(image(withColor: UIColor ( red: 0.8902, green: 0.898, blue: 0.9059, alpha: 1.0 )), forState: .Disabled)
        button.setImage(image(named: "ic_submit", compatibleWithTraitCollection: self.traitCollection), forState: .Normal)
        button.setImage(UIImage(), forState: .Disabled)
        button.tintColor = .whiteColor()
        button.addTarget(self, action: #selector(pressed), forControlEvents: .TouchUpInside)

        indicator.color = UIColor ( red: 0.5725, green: 0.5804, blue: 0.5843, alpha: 1.0 )
        indicator.hidesWhenStopped = true

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