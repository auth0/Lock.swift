// Resources.swift
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
import UIKit

public func bundleForLock() -> Bundle {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: InputField.classForCoder())
    #endif
}

@available(*, deprecated, renamed: "UIImage")
public typealias LazyImage = UIImage

extension UIImage {
    public convenience init?(named name: String, in bundle: Bundle) {
        self.init(named: name, in: bundle, compatibleWith: nil)
    }

    @available(*, deprecated, renamed: "init(named:)")
    public convenience init?(name: String) {
        self.init(named: name)
    }

    @available(*, deprecated, renamed: "init(named:in:)")
    public convenience init?(name: String, bundle: Bundle) {
        self.init(named: name, in: bundle, compatibleWith: nil)
    }
}

func image(withColor color: UIColor) -> UIImage? {
    let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
    UIGraphicsBeginImageContext(rect.size)
    guard let context = UIGraphicsGetCurrentContext() else { return nil }
    context.setFillColor(color.cgColor)

    context.fill(rect)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image
}

func boldSystemFont(size: CGFloat) -> UIFont {
    return UIFont.systemFont(ofSize: size, weight: UIFont.weightBold)
}

func semiBoldSystemFont(size: CGFloat) -> UIFont {
    return UIFont.systemFont(ofSize: size, weight: UIFont.weightSemiBold)
}

func mediumSystemFont(size: CGFloat) -> UIFont {
    return UIFont.systemFont(ofSize: size, weight: UIFont.weightMedium)
}

func lightSystemFont(size: CGFloat) -> UIFont {
    return UIFont.systemFont(ofSize: size, weight: UIFont.weightLight)
}

func regularSystemFont(size: CGFloat) -> UIFont {
    return UIFont.systemFont(ofSize: size, weight: UIFont.weightRegular)
}
