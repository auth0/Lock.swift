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

func bundleForLock() -> Bundle { return Bundle(for: InputField.classForCoder()) }

func lazyImage(named name: String) -> LazyImage { return LazyImage(name: name, bundle: bundleForLock()) }

func image(named name: String, compatibleWithTraitCollection traitCollection: UITraitCollection? = nil) -> UIImage? {
    return UIImage(named: name, in: bundleForLock(), compatibleWith: traitCollection)
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

func semiBoldSystemFont(size: CGFloat) -> UIFont {
    return UIFont.systemFont(ofSize: size, weight: UIFontWeightSemibold)
}

func mediumSystemFont(size: CGFloat) -> UIFont {
    return UIFont.systemFont(ofSize: size, weight: UIFontWeightMedium)
}

func lightSystemFont(size: CGFloat) -> UIFont {
    return UIFont.systemFont(ofSize: size, weight: UIFontWeightLight)
}

func regularSystemFont(size: CGFloat) -> UIFont {
    return UIFont.systemFont(ofSize: size, weight: UIFontWeightRegular)
}
