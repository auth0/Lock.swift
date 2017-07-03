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
    public var title = "Auth0".i18n(key: "com.auth0.lock.header.default_title", comment: "Header Title")

        /// Primary color of Lock used in the principal components like the Primary Button
    public var primaryColor = UIColor.a0_orange

        /// Lock background color
    public var backgroundColor = UIColor.white

        /// Lock background image
    public var backgroundImage: LazyImage?

        /// Lock disabled component color
    public var disabledColor = UIColor(red: 0.8902, green: 0.898, blue: 0.9059, alpha: 1.0 )

        /// Lock disabled component text color
    public var disabledTextColor = UIColor(red: 0.5725, green: 0.5804, blue: 0.5843, alpha: 1.0 )

        /// Primary button tint color
    public var buttonTintColor = UIColor.white

        /// Header background color. By default it has no color but a blur
    public var headerColor: UIColor?

        /// Blur effect style used. It can be any value defined in `UIBlurEffectStyle`
    public var headerBlur: UIBlurEffectStyle = .light

        /// Header close button image
    public var headerCloseIcon: LazyImage = lazyImage(named: "ic_close")

        /// Header back button image
    public var headerBackIcon: LazyImage = lazyImage(named: "ic_back")

        /// Header title color
    public var titleColor = UIColor.black

        /// Hide header title (show only logo). By default is false
    public var hideTitle = false {
        didSet {
            hideButtonTitle = false
        }
    }

        /// Main body text color
    public var textColor = UIColor.black

        /// Hide primary bytton title (show only icon). By default is false
    public var hideButtonTitle = false

        /// Header logo image
    public var logo: LazyImage = lazyImage(named: "ic_auth0")

        /// OAuth2 custom connection styles by mapping a connection name with an `AuthStyle`
    public var oauth2: [String: AuthStyle] = [:]

        /// Social seperator label
    public var seperatorTextColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.54)

        /// Input field text color
    public var inputTextColor = UIColor.black

        /// Input field placeholder text color
    public var inputPlaceholderTextColor = UIColor(red: 0.780, green: 0.780, blue: 0.804, alpha: 1.00)

        /// Input field border color default
    public var inputBorderColor = UIColor(red: 0.9333, green: 0.9333, blue: 0.9333, alpha: 1.0)

        /// Input field border color invalid
    public var inputBorderColorError = UIColor.red

        /// Input field background color
    public var inputBackgroundColor = UIColor.white

        /// Input field icon background color
    public var inputIconBackgroundColor = UIColor(red: 0.9333, green: 0.9333, blue: 0.9333, alpha: 1.0)

        /// Input field icon color
    public var inputIconColor = UIColor(red: 0.5725, green: 0.5804, blue: 0.5843, alpha: 1.0)

        /// Secondary button color
    public var secondaryButtonColor = UIColor.black

        /// Database login Tab Text Color
    public var tabTextColor = UIColor(red: 0.3608, green: 0.4, blue: 0.4353, alpha: 0.6)

        /// Database login Tab Tint Color
    public var tabTintColor = UIColor(red: 0.3608, green: 0.4, blue: 0.4353, alpha: 0.6)

        /// Lock Controller Status bar update animation
    public var statusBarUpdateAnimation: UIStatusBarAnimation = .none

        /// Lock Controller Status bar hidden
    public var statusBarHidden = false

        /// Lock Controller Status bar style
    public var statusBarStyle: UIStatusBarStyle = .default

        /// Passwordless search bar style
    public var searchBarStyle: UISearchBarStyle = .default

        /// 1Password Icon color
    public var onePasswordIconColor = UIColor(red: 0.5725, green: 0.5804, blue: 0.5843, alpha: 1.0)

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
