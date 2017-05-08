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
    weak var maskImageView: UIImageView?
    weak var blurView: UIVisualEffectView?

    public var onClosePressed: () -> Void = {}

    public var showClose: Bool {
        get {
            return !(self.closeButton?.isHidden ?? true)
        }
        set {
            self.closeButton?.isHidden = !newValue
        }
    }

    public var onBackPressed: () -> Void = {}

    public var showBack: Bool {
        get {
            return !(self.backButton?.isHidden ?? true)
        }
        set {
            self.backButton?.isHidden = !newValue
        }
    }

    public var title: String? {
        get {
            return self.titleView?.text
        }
        set {
            self.titleView?.text = newValue
        }
    }

    public var titleColor: UIColor = Style.Auth0.titleColor {
        didSet {
            self.titleView?.textColor = titleColor
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

    public var maskImage: UIImage? {
        get {
            return self.maskImageView?.image
        }
        set {
            self.maskImageView?.image = newValue
            self.setNeedsUpdateConstraints()
        }
    }

    public var blurred: Bool = Style.Auth0.headerColor == nil {
        didSet {
            self.applyBackground()
            self.setNeedsDisplay()
        }
    }

    public var blurStyle: UIBlurEffectStyle = .light {
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
        self.init(frame: CGRect.zero)
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
        let closeButton = UIButton(type: .system)
        let backButton = UIButton(type: .system)
        let centerGuide = UILayoutGuide()

        self.addLayoutGuide(centerGuide)
        self.addSubview(titleView)
        self.addSubview(logoView)
        self.addSubview(closeButton)
        self.addSubview(backButton)

        constraintEqual(anchor: centerGuide.centerYAnchor, toAnchor: self.centerYAnchor, constant: 10)
        constraintEqual(anchor: centerGuide.centerXAnchor, toAnchor: self.centerXAnchor)

        constraintEqual(anchor: titleView.bottomAnchor, toAnchor: centerGuide.bottomAnchor)
        constraintEqual(anchor: titleView.centerXAnchor, toAnchor: centerGuide.centerXAnchor)
        titleView.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .horizontal)
        titleView.setContentHuggingPriority(UILayoutPriorityRequired, for: .horizontal)
        titleView.translatesAutoresizingMaskIntoConstraints = false

        constraintEqual(anchor: logoView.centerXAnchor, toAnchor: self.centerXAnchor)
        constraintEqual(anchor: logoView.bottomAnchor, toAnchor: titleView.topAnchor, constant: -15)
        constraintEqual(anchor: logoView.topAnchor, toAnchor: centerGuide.topAnchor)
        logoView.translatesAutoresizingMaskIntoConstraints = false

        constraintEqual(anchor: closeButton.centerYAnchor, toAnchor: self.topAnchor, constant: 45)
        constraintEqual(anchor: closeButton.rightAnchor, toAnchor: self.rightAnchor, constant: -10)
        closeButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        closeButton.translatesAutoresizingMaskIntoConstraints = false

        constraintEqual(anchor: backButton.centerYAnchor, toAnchor: self.topAnchor, constant: 45)
        constraintEqual(anchor: backButton.leftAnchor, toAnchor: self.leftAnchor, constant: 10)
        backButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        backButton.translatesAutoresizingMaskIntoConstraints = false

        self.applyBackground()
        self.apply(style: Style.Auth0)
        titleView.font = regularSystemFont(size: 20)
        logoView.image = image(named: "ic_auth0", compatibleWithTraitCollection: self.traitCollection)
        closeButton.setBackgroundImage(image(named: "ic_close", compatibleWithTraitCollection: self.traitCollection)?.withRenderingMode(.alwaysOriginal), for: UIControlState())
        closeButton.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        backButton.setBackgroundImage(image(named: "ic_back", compatibleWithTraitCollection: self.traitCollection)?.withRenderingMode(.alwaysOriginal), for: UIControlState())
        backButton.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)

        self.titleView = titleView
        self.logoView = logoView
        self.closeButton = closeButton
        self.backButton = backButton

        self.showBack = false
        self.clipsToBounds = true
    }

    public override var intrinsicContentSize: CGSize {
        return CGSize(width: 200, height: 154)
    }

    func buttonPressed(_ sender: UIButton) {
        if sender == self.backButton {
            self.onBackPressed()
        }

        if sender == self.closeButton {
            self.onClosePressed()
        }
    }

    // MARK: - Blur

    private var canBlur: Bool {
        return self.blurred && !UIAccessibilityIsReduceTransparencyEnabled()
    }

    private func applyBackground() {
        self.maskImageView?.removeFromSuperview()
        self.blurView?.removeFromSuperview()

        self.backgroundColor = self.canBlur ? .white : UIColor ( red: 0.9451, green: 0.9451, blue: 0.9451, alpha: 1.0 )

        guard self.canBlur else { return }

        let maskView = UIImageView()
        let blur = UIBlurEffect(style: self.blurStyle)
        let blurView = UIVisualEffectView(effect: blur)

        self.insertSubview(maskView, at: 0)
        self.insertSubview(blurView, at: 1)

        constraintEqual(anchor: blurView.leftAnchor, toAnchor: self.leftAnchor)
        constraintEqual(anchor: blurView.topAnchor, toAnchor: self.topAnchor)
        constraintEqual(anchor: blurView.rightAnchor, toAnchor: self.rightAnchor)
        constraintEqual(anchor: blurView.bottomAnchor, toAnchor: self.bottomAnchor)
        blurView.translatesAutoresizingMaskIntoConstraints = false

        maskView.translatesAutoresizingMaskIntoConstraints = false
        dimension(dimension: maskView.widthAnchor, withValue: 400)
        dimension(dimension: maskView.heightAnchor, withValue: 400)
        constraintEqual(anchor: maskView.centerYAnchor, toAnchor: self.centerYAnchor)
        constraintEqual(anchor: maskView.centerXAnchor, toAnchor: self.centerXAnchor)

        maskView.contentMode = .scaleToFill
        maskView.image = image(named: "ic_auth0", compatibleWithTraitCollection: self.traitCollection)?.withRenderingMode(.alwaysTemplate)
        maskView.tintColor = self.maskColor

        self.maskImageView = maskView
        self.blurView = blurView
    }
}

extension HeaderView: Stylable {
    func apply(style: Style) {
        if let color = style.headerColor {
            self.blurred = false
            self.backgroundColor = color
        } else {
            self.blurred = true
            self.blurStyle = style.headerBlur
        }
        self.title = style.hideTitle ? nil : style.title
        self.titleColor = style.titleColor
        self.logo = style.logo.image(compatibleWithTraits: self.traitCollection)
        self.maskImage = style.headerMask
        self.backButton?.setBackgroundImage(style.headerBackIcon.image(compatibleWithTraits: self.traitCollection)?.withRenderingMode(.alwaysOriginal), for: .normal)
        self.closeButton?.setBackgroundImage(style.headerCloseIcon.image(compatibleWithTraits: self.traitCollection)?.withRenderingMode(.alwaysOriginal), for: .normal)
    }
}
