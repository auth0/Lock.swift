// Style.swift
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

/**
 *  Define Auth0 Lock style and allows to customise it.
 */
public struct Style {

        /// Title used in Header
    public var title = "Auth0".i18n(key: "com.auth0.lock.header.default-title", comment: "Header Title")

        /// Primary color of Lock used in the principal components like the Primary Button
    public var primaryColor = UIColor.a0_orange

        /// Lock background color
    public var backgroundColor = UIColor.white

        /// Lock disabled component color
    public var disabledColor = UIColor ( red: 0.8902, green: 0.898, blue: 0.9059, alpha: 1.0 )

        /// Lock disabled component text color
    public var disabledTextColor = UIColor ( red: 0.5725, green: 0.5804, blue: 0.5843, alpha: 1.0 )

        /// Primary button tint color
    public var buttonTintColor = UIColor.white

        /// Header background color. By default it has no color but a blur
    public var headerColor: UIColor? = nil

        /// Blur effect style used. It can be any value defined in `UIBlurEffectStyle`
    public var headerBlur: UIBlurEffectStyle = .light

        /// Header title color
    public var titleColor = UIColor.black

        /// Hide header title (show only logo). By default is false
    public var hideTitle = false {
        didSet {
            hideButtonTitle = false
        }
    }

        /// Hide primary bytton title (show only icon). By default is false
    public var hideButtonTitle = false

        /// Header logo image
    public var logo: LazyImage = lazyImage(named: "ic_auth0")

        /// OAuth2 custom connection styles by mapping a connection name with an `AuthStyle`
    public var oauth2: [String: AuthStyle] = [:]

    var headerMask: UIImage? {
        let image = self.logo.image(compatibleWithTraits: nil)
        if Style.Auth0.logo == self.logo {
            return image?.withRenderingMode(.alwaysTemplate)
        }
        return image
    }

    func primaryButtonColor(forState state: UIControlState) -> UIColor {
        if state.contains(.highlighted) {
            return self.primaryColor.a0_darker(0.20)
        }

        if state.contains(.disabled) {
            return self.disabledColor
        }

        return self.primaryColor
    }

    func primaryButtonTintColor(forState state: UIControlState) -> UIColor {
        if state.contains(.disabled) {
            return self.disabledTextColor
        }

        return self.buttonTintColor
    }

    static let Auth0 = Style()
}

protocol Stylable {
    func apply(style: Style)
}
