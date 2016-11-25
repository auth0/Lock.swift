// InfoBarView.swift
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

public class InfoBarView: UIView {

    weak var container: UIView?
    weak var iconView: UIImageView?
    weak var titleView: UILabel?

    var title: String? {
        get {
            return self.titleView?.text
        }
        set {
            self.titleView?.text = newValue
            self.setNeedsUpdateConstraints()
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
        let container = UIView()
        let titleView = UILabel()
        let iconView = UIImageView()

        self.addSubview(container)
        container.addSubview(titleView)
        container.addSubview(iconView)

        constraintEqual(anchor: container.leftAnchor, toAnchor: self.leftAnchor)
        constraintEqual(anchor: container.bottomAnchor, toAnchor: self.bottomAnchor)
        constraintEqual(anchor: container.topAnchor, toAnchor: self.topAnchor)
        constraintEqual(anchor: container.rightAnchor, toAnchor: self.rightAnchor)
        container.translatesAutoresizingMaskIntoConstraints = false

        constraintEqual(anchor: titleView.centerXAnchor, toAnchor: container.centerXAnchor)
        constraintEqual(anchor: titleView.centerYAnchor, toAnchor: container.centerYAnchor)
        titleView.translatesAutoresizingMaskIntoConstraints = false

        constraintEqual(anchor: iconView.rightAnchor, toAnchor: titleView.leftAnchor, constant: -5)
        constraintEqual(anchor: iconView.bottomAnchor, toAnchor: titleView.bottomAnchor, constant: -1)
        iconView.translatesAutoresizingMaskIntoConstraints = false

        container.backgroundColor = UIColor(red:0.97, green:0.97, blue:0.97, alpha:1.0)

        titleView.font = UIFont.systemFont(ofSize: 17)
        titleView.textColor = UIColor(red:0.45, green:0.45, blue:0.45, alpha:1.0)

        self.titleView = titleView
        self.iconView = iconView

        self.clipsToBounds = true
    }

    func setIcon(_ name: String) {
        self.iconView?.image = image(named: name)
        self.iconView?.tintColor = UIColor ( red: 0.5725, green: 0.5804, blue: 0.5843, alpha: 1.0 )
    }

    public override var intrinsicContentSize : CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: 35)
    }

}
