// LoadingView.swift
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

class LoadingView: UIView, View {

    weak var indicator: UIActivityIndicatorView?

    var inProgress: Bool {
        get {
            return self.indicator?.isAnimating ?? false
        }
        set {
            Queue.main.async {
                if newValue {
                    self.indicator?.startAnimating()
                } else {
                    self.indicator?.stopAnimating()
                }
            }
        }
    }

    // MARK: - Initialisers

    init() {
        super.init(frame: CGRect.zero)
        self.backgroundColor = Style.Auth0.backgroundColor

        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        apply(style: Style.Auth0)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(activityIndicator)
        constraintEqual(anchor: activityIndicator.centerXAnchor, toAnchor: self.centerXAnchor)
        constraintEqual(anchor: activityIndicator.centerYAnchor, toAnchor: self.centerYAnchor)

        self.indicator = activityIndicator
        self.indicator?.startAnimating()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func apply(style: Style) {
        self.backgroundColor = style.backgroundColor
        self.indicator?.color = style.disabledTextColor
    }
}
