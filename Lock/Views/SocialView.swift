// SocialView.swift
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

class SocialView: UIView, View {

    // MARK:- Initialisers

    init(buttons: [AuthButton], style: AuthButton.Style) {
        super.init(frame: CGRectZero)
        self.layout(buttons, style: style)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK:- Layout

    private func layout(buttons: [AuthButton], style: AuthButton.Style) {
        guard let sample = buttons.first else { return } // FIXME: Show error
        let height = Int(sample.intrinsicContentSize().height) * buttons.count + (8 * buttons.count - 1)

        let stack = UIStackView(arrangedSubviews: buttons)

        self.addSubview(stack)

        constraintEqual(anchor: stack.leftAnchor, toAnchor: self.leftAnchor, constant: 18)
        constraintGreaterOrEqual(anchor: stack.topAnchor, toAnchor: self.topAnchor, constant: 18)
        constraintEqual(anchor: stack.rightAnchor, toAnchor: self.rightAnchor, constant: -18)
        constraintGreaterOrEqual(anchor: stack.bottomAnchor, toAnchor: self.bottomAnchor, constant: -18)
        constraintEqual(anchor: stack.centerYAnchor, toAnchor: self.centerYAnchor)
        dimension(stack.heightAnchor, withValue: CGFloat(height))
        stack.translatesAutoresizingMaskIntoConstraints = false

        stack.axis = .Vertical
        stack.alignment = .Fill
        stack.distribution = .EqualSpacing
    }
}