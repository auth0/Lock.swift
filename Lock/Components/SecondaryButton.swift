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

public class SecondaryButton: UIView {

    weak var button: UIButton?

    public var onPress: (SecondaryButton) -> () = {_ in }

    public var color: UIColor = .clearColor() {
        didSet {
            self.backgroundColor = self.color
        }
    }

    public var title: String? {
        get {
            return self.button?.currentTitle
        }
        set {
            self.button?.setTitle(newValue, forState: .Normal)
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
        let button = UIButton(type: .System)

        self.addSubview(button)

        constraintEqual(anchor: button.centerXAnchor, toAnchor: self.centerXAnchor)
        constraintGreaterOrEqual(anchor: button.leftAnchor, toAnchor: self.leftAnchor)
        constraintGreaterOrEqual(anchor: button.rightAnchor, toAnchor: self.rightAnchor)
        constraintEqual(anchor: button.firstBaselineAnchor, toAnchor: self.centerYAnchor)
        button.translatesAutoresizingMaskIntoConstraints = false

        button.tintColor = .blackColor()
        button.titleLabel?.lineBreakMode = .ByWordWrapping
        button.titleLabel?.textAlignment = .Center
        button.addTarget(self, action: #selector(pressed), forControlEvents: .TouchUpInside)

        self.button = button
    }

    public override func intrinsicContentSize() -> CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: 86)
    }
    
    func pressed(sender: AnyObject) {
        self.onPress(self)
    }
}
