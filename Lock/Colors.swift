// Colors.swift
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

extension UIColor {

    static var a0_orange: UIColor { return UIColor ( red: 0.9176, green: 0.3255, blue: 0.1373, alpha: 1.0 ) }

    static func a0_fromRGB(_ string: String, defaultColor: UIColor = .a0_orange) -> UIColor {
        guard string.hasPrefix("#") else { return defaultColor }

        let hexString: String = string.substring(from: string.characters.index(string.startIndex, offsetBy: 1))
        var hexValue: UInt32 = 0

        guard Scanner(string: hexString).scanHexInt32(&hexValue) else {
            return defaultColor
        }

        let divisor = CGFloat(255)
        let red = CGFloat((hexValue & 0xFF0000) >> 16) / divisor
        let green = CGFloat((hexValue & 0x00FF00) >>  8) / divisor
        let blue = CGFloat(hexValue & 0x0000FF) / divisor
        return  UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
}
