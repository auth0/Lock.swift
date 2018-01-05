// Extensions.swift
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

import Foundation

extension Optional {

    func verbatim() -> String {
        switch self {
        case .some(let value):
            return String(describing: value)
        case _:
            return "<no value>"
        }
    }
}

extension UIView {

    func styleSubViews(style: Style) {
        self.subviews.forEach { view in
            if let view = view as? Stylable {
                view.apply(style: style)
            }
            view.styleSubViews(style: style)
        }
    }
}

extension UILayoutPriority {
    #if swift(>=4.0)
    static let priorityRequired = UILayoutPriority.required
    static let priorityDefaultLow = UILayoutPriority.defaultLow
    static let priorityDefaultHigh = UILayoutPriority.defaultHigh
    #else
    static let priorityRequired = UILayoutPriorityRequired
    static let priorityDefaultLow = UILayoutPriorityDefaultLow
    static let priorityDefaultHigh = UILayoutPriorityDefaultHigh
    #endif
}

#if swift(>=4.0)
let attributedKeyColor = NSAttributedStringKey.foregroundColor
let attributedFont = NSAttributedStringKey.font
#else
let attributedKeyColor = NSForegroundColorAttributeName
let attributedFont = NSFontAttributeName
#endif

extension UIFont {
    #if swift(>=4.0)
    static let weightLight = UIFont.Weight.light
    static let weightMedium = UIFont.Weight.medium
    static let weightRegular = UIFont.Weight.regular
    static let weightSemiBold = UIFont.Weight.semibold
    #else
    static let weightLight = UIFontWeightLight
    static let weightMedium = UIFontWeightMedium
    static let weightRegular = UIFontWeightRegular
    static let weightSemiBold = UIFontWeightSemibold
    #endif
}
