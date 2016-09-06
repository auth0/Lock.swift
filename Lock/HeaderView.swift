// Header.swift
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

public class HeaderView: UIView {

    weak var logoView: UIImageView?
    weak var titleView: UILabel?
    weak var closeButton: UIButton?
    weak var backButton: UIButton?
    weak var mask: UIImageView?
    weak var blurView: UIVisualEffectView?

    public var onClosePressed: () -> () = {}

    public var showClose: Bool {
        get {
            return !(self.closeButton?.hidden ?? true)
        }
        set {
            self.closeButton?.hidden = !newValue
        }
    }

    public var onBackPressed: () -> () = {}

    public var showBack: Bool {
        get {
            return !(self.backButton?.hidden ?? true)
        }
        set {
            self.backButton?.hidden = !newValue
        }
    }

    public var title: String? {
        get {
            return self.titleView?.text
        }
        set {
            self.titleView?.text = newValue
            self.setNeedsUpdateConstraints()
        }
    }

    public var logo: UIImage? {
        get {
            return self.logoView?.image
        }
        set {
            self.logoView?.image = newValue
            self.setNeedsUpdateConstraints()
        }
    }

    public var blurred: Bool = true {
        didSet {
            self.applyBackground()
            self.setNeedsDisplay()
        }
    }

    public var maskColor: UIColor = UIColor ( red: 0.8745, green: 0.8745, blue: 0.8745, alpha: 1.0 ) {
        didSet {
            self.mask?.tintColor = self.maskColor
        }
    }

    public convenience init() {
        self.init(frame: CGRectZero)
    }

    required override public init(frame: CGRect) {
        super.init(frame: frame)
        self.layoutHeader()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layoutHeader()
    }

    private func layoutHeader() {
        let titleView = UILabel()
        let logoView = UIImageView()
        let closeButton = UIButton(type: .System)
        let backButton = UIButton(type: .System)
        let centerGuide = UILayoutGuide()

        self.addLayoutGuide(centerGuide)
        self.addSubview(titleView)
        self.addSubview(logoView)
        self.addSubview(closeButton)
        self.addSubview(backButton)

        constraintEqual(anchor: centerGuide.centerYAnchor, toAnchor: self.centerYAnchor, constant: 10)
        constraintEqual(anchor: centerGuide.centerXAnchor, toAnchor: self.centerXAnchor)

        constraintEqual(anchor: titleView.bottomAnchor, toAnchor: centerGuide.bottomAnchor)
        constraintEqual(anchor: titleView.leftAnchor, toAnchor: centerGuide.leftAnchor)
        constraintEqual(anchor: titleView.rightAnchor, toAnchor: centerGuide.rightAnchor)
        titleView.setContentCompressionResistancePriority(UILayoutPriorityRequired, forAxis: .Horizontal)
        titleView.setContentHuggingPriority(UILayoutPriorityRequired, forAxis: .Horizontal)
        titleView.translatesAutoresizingMaskIntoConstraints = false

        constraintEqual(anchor: logoView.centerXAnchor, toAnchor: self.centerXAnchor)
        constraintEqual(anchor: logoView.bottomAnchor, toAnchor: titleView.topAnchor, constant: -15)
        constraintEqual(anchor: logoView.topAnchor, toAnchor: centerGuide.topAnchor)
        logoView.translatesAutoresizingMaskIntoConstraints = false

        constraintEqual(anchor: closeButton.centerYAnchor, toAnchor: self.topAnchor, constant: 45)
        constraintEqual(anchor: closeButton.rightAnchor, toAnchor: self.rightAnchor)
        closeButton.widthAnchor.constraintEqualToConstant(50).active = true
        closeButton.heightAnchor.constraintEqualToConstant(50).active = true
        closeButton.translatesAutoresizingMaskIntoConstraints = false

        constraintEqual(anchor: backButton.centerYAnchor, toAnchor: self.topAnchor, constant: 45)
        constraintEqual(anchor: backButton.leftAnchor, toAnchor: self.leftAnchor)
        backButton.widthAnchor.constraintEqualToConstant(50).active = true
        backButton.heightAnchor.constraintEqualToConstant(50).active = true
        backButton.translatesAutoresizingMaskIntoConstraints = false

        self.applyBackground()

        titleView.text = "Auth0".i18n(key: "com.auth0.lock.header.default-title", comment: "Header Title")
        titleView.font = regularSystemFont(size: 20)
        logoView.image = image(named: "ic_auth0", compatibleWithTraitCollection: self.traitCollection)
        closeButton.setImage(image(named: "ic_close", compatibleWithTraitCollection: self.traitCollection)?.imageWithRenderingMode(.AlwaysOriginal), forState: .Normal)
        closeButton.addTarget(self, action: #selector(buttonPressed), forControlEvents: .TouchUpInside)
        backButton.setImage(image(named: "ic_back", compatibleWithTraitCollection: self.traitCollection)?.imageWithRenderingMode(.AlwaysOriginal), forState: .Normal)
        backButton.addTarget(self, action: #selector(buttonPressed), forControlEvents: .TouchUpInside)

        self.titleView = titleView
        self.logoView = logoView
        self.closeButton = closeButton
        self.backButton = backButton

        self.showBack = false
        self.backgroundColor = self.canBlur ? .whiteColor() : UIColor ( red: 0.9451, green: 0.9451, blue: 0.9451, alpha: 1.0 )
        self.clipsToBounds = true
    }

    public override func intrinsicContentSize() -> CGSize {
        return CGSize(width: 200, height: 154)
    }

    func buttonPressed(sender: UIButton) {
        if sender == self.backButton {
            self.onBackPressed()
        }

        if sender == self.closeButton {
            self.onClosePressed()
        }
    }

    // MARK:- Blur

    private var canBlur: Bool {
        return self.blurred && !UIAccessibilityIsReduceTransparencyEnabled()
    }

    private func applyBackground() {
        self.mask?.removeFromSuperview()
        self.blurView?.removeFromSuperview()

        self.backgroundColor = self.canBlur ? .whiteColor() : UIColor ( red: 0.9451, green: 0.9451, blue: 0.9451, alpha: 1.0 )

        guard self.canBlur else { return }

        let maskView = UIImageView()
        let blur = UIBlurEffect(style: .Light)
        let blurView = UIVisualEffectView(effect: blur)

        self.insertSubview(maskView, atIndex: 0)
        self.insertSubview(blurView, atIndex: 1)

        constraintEqual(anchor: blurView.leftAnchor, toAnchor: self.leftAnchor)
        constraintEqual(anchor: blurView.topAnchor, toAnchor: self.topAnchor)
        constraintEqual(anchor: blurView.rightAnchor, toAnchor: self.rightAnchor)
        constraintEqual(anchor: blurView.bottomAnchor, toAnchor: self.bottomAnchor)
        blurView.translatesAutoresizingMaskIntoConstraints = false

        maskView.translatesAutoresizingMaskIntoConstraints = false
        dimension(maskView.widthAnchor, withValue: 400)
        dimension(maskView.heightAnchor, withValue: 400)
        constraintEqual(anchor: maskView.centerYAnchor, toAnchor: self.centerYAnchor)
        constraintEqual(anchor: maskView.centerXAnchor, toAnchor: self.centerXAnchor)

        maskView.contentMode = .ScaleToFill
        maskView.image = image(named: "ic_auth0", compatibleWithTraitCollection: self.traitCollection)?.imageWithRenderingMode(.AlwaysTemplate)
        maskView.tintColor = self.maskColor

        self.mask = maskView
        self.blurView = blurView
    }
}