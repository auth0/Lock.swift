// View.swift
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

protocol View: Stylable {
    func layout(inView root: UIView, below view: UIView) -> NSLayoutConstraint?
    func remove()
    func applyAll(withStyle style: Style)
}

extension View where Self: UIView {

    func layout(inView root: UIView, below view: UIView) -> NSLayoutConstraint? {
        root.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        constraintEqual(anchor: self.leftAnchor, toAnchor: root.leftAnchor)
        constraintEqual(anchor: self.topAnchor, toAnchor: view.bottomAnchor)
        constraintEqual(anchor: self.rightAnchor, toAnchor: root.rightAnchor)
        constraintEqual(anchor: self.bottomAnchor, toAnchor: root.bottomAnchor)
        if let superview = root.superview?.bottomAnchor {
            return constraintEqual(anchor: self.bottomAnchor, toAnchor: superview, priority: UILayoutPriorityDefaultLow)
        }
        return nil
    }

    func remove() {
        self.removeFromSuperview()
    }

    func applyAll(withStyle style: Style) {
        self.apply(style: style)
        self.styleSubViews(style: style)
    }
}
