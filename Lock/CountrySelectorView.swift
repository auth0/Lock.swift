// CountrySelectorView.swift
//
// Copyright (c) 2017 Auth0 (http://auth0.com)
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

class CountrySelectorView: UIView {

    weak var containerView: UIView?
    weak var countryLabel: UILabel?
    weak var codeLabel: UILabel?

    convenience init() {
        self.init(frame: CGRect.zero)
    }

    required override init(frame: CGRect) {
        super.init(frame: frame)
        self.layoutField()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layoutField()
    }

    var country: (String?, String?) {
        get {
            return (self.countryLabel?.text, self.codeLabel?.text)
        }
        set {
            self.countryLabel?.text = newValue.0
            self.codeLabel?.text = newValue.1
        }
    }

    // MARK: - Layout

    private func layoutField() {

        self.isUserInteractionEnabled = true

        let container = UIView()
        let iconContainer = UIView()
        let iconView = UIImageView()
        let countryLabel = UILabel()
        let codeLabel = UILabel()
        let actionIconContainer = UIImageView()
        let actionIconView = UIImageView()

        self.countryLabel = countryLabel
        self.codeLabel = codeLabel

        iconContainer.addSubview(iconView)
        container.addSubview(iconContainer)
        container.addSubview(countryLabel)
        container.addSubview(codeLabel)
        container.addSubview(actionIconContainer)
        actionIconContainer.addSubview(actionIconView)
        self.addSubview(container)

        constraintEqual(anchor: container.leftAnchor, toAnchor: self.leftAnchor, constant: 0)
        constraintEqual(anchor: container.topAnchor, toAnchor: self.topAnchor)
        constraintEqual(anchor: container.rightAnchor, toAnchor: self.rightAnchor, constant: 0)
        constraintEqual(anchor: container.bottomAnchor, toAnchor: self.bottomAnchor)
        dimension(dimension: container.heightAnchor, withValue: 50)
        container.translatesAutoresizingMaskIntoConstraints = false

        constraintEqual(anchor: iconContainer.leftAnchor, toAnchor: container.leftAnchor)
        constraintEqual(anchor: iconContainer.topAnchor, toAnchor: container.topAnchor)
        constraintEqual(anchor: iconContainer.bottomAnchor, toAnchor: container.bottomAnchor)
        constraintEqual(anchor: iconContainer.heightAnchor, toAnchor: iconContainer.widthAnchor)
        iconContainer.translatesAutoresizingMaskIntoConstraints = false

        constraintEqual(anchor: countryLabel.leftAnchor, toAnchor: iconContainer.rightAnchor, constant: 16)
        constraintEqual(anchor: countryLabel.topAnchor, toAnchor: container.topAnchor)
        constraintEqual(anchor: countryLabel.rightAnchor, toAnchor: codeLabel.leftAnchor)
        constraintEqual(anchor: countryLabel.bottomAnchor, toAnchor: container.bottomAnchor)
        countryLabel.translatesAutoresizingMaskIntoConstraints = false

        constraintEqual(anchor: codeLabel.leftAnchor, toAnchor: countryLabel.rightAnchor, constant: 0)
        constraintEqual(anchor: codeLabel.topAnchor, toAnchor: container.topAnchor)
        constraintEqual(anchor: codeLabel.rightAnchor, toAnchor: actionIconContainer.leftAnchor, constant: -10)
        constraintEqual(anchor: codeLabel.bottomAnchor, toAnchor: container.bottomAnchor)
        codeLabel.translatesAutoresizingMaskIntoConstraints = false

        constraintGreaterOrEqual(anchor: actionIconContainer.leftAnchor, toAnchor: codeLabel.rightAnchor, constant: 0)
        constraintEqual(anchor: actionIconContainer.topAnchor, toAnchor: container.topAnchor)
        constraintEqual(anchor: actionIconContainer.rightAnchor, toAnchor: container.rightAnchor, constant: 0)
        constraintEqual(anchor: actionIconContainer.bottomAnchor, toAnchor: container.bottomAnchor)
        constraintEqual(anchor: actionIconContainer.widthAnchor, toAnchor: actionIconContainer.heightAnchor)
        actionIconContainer.translatesAutoresizingMaskIntoConstraints = false

        constraintEqual(anchor: actionIconView.centerXAnchor, toAnchor: actionIconContainer.centerXAnchor)
        constraintEqual(anchor: actionIconView.centerYAnchor, toAnchor: actionIconContainer.centerYAnchor)
        actionIconView.translatesAutoresizingMaskIntoConstraints = false

        constraintEqual(anchor: iconView.centerXAnchor, toAnchor: iconContainer.centerXAnchor)
        constraintEqual(anchor: iconView.centerYAnchor, toAnchor: iconContainer.centerYAnchor)
        iconView.translatesAutoresizingMaskIntoConstraints = false

        iconView.image = lazyImage(named: "ic_globe").image()
        actionIconView.image = lazyImage(named: "ic_chevron_right").image()

        countryLabel.textColor = UIColor(red:0.73, green:0.73, blue:0.73, alpha:1.0)
        codeLabel.textColor = countryLabel.textColor
        iconContainer.backgroundColor = UIColor ( red: 0.9333, green: 0.9333, blue: 0.9333, alpha: 1.0 )
        iconView.tintColor = UIColor ( red: 0.5725, green: 0.5804, blue: 0.5843, alpha: 1.0 )
        actionIconView.tintColor = UIColor.black

        container.backgroundColor = UIColor(red:0.98, green:0.98, blue:0.98, alpha:1.0)
        container.layer.cornerRadius = 3.67
        container.layer.masksToBounds = true
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor ( red: 0.9333, green: 0.9333, blue: 0.9333, alpha: 1.0 ).cgColor
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("Hello")
    }

}
