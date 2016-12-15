// AuthStyle.swift
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

/// Style for AuthButton
public struct AuthStyle {

        /// Name that will be used for titles. e.g. 'Login with Auth0'
    let name: String
    let image: LazyImage
    let foregroundColor: UIColor
    let normalColor: UIColor
    let highlightedColor: UIColor

    var localizedLoginTitle: String {
        let format = "Log in with %@".i18n(key: "com.auth0.lock.strategy.login.title", comment: "Log in action format")
        return String(format: format, self.name)
    }

    var localizedSignUpTitle: String {
        let format = "Sign up with %@".i18n(key: "com.auth0.lock.strategy.signup.title", comment: "Sign up action format")
        return String(format: format, self.name)
    }

    /**
     Create a new AuthStyle using a brand color

     - parameter name:            name to be used as the name of the Auth provider for the titles
     - parameter color:           brand color that will be used for the button. Default Auth0 color
     - parameter foregroundColor: text color of the button. Default is white
     - parameter image:           icon used in the button. By default is Auth0's

     - returns: a new style
     */
    public init(name: String, color: UIColor = UIColor.a0_orange, foregroundColor: UIColor = .white, withImage image: LazyImage = LazyImage(name: "ic_auth_auth0", bundle: bundleForLock())) {
        self.init(name: name, normalColor: color, highlightedColor: color.a0_darker(0.3), foregroundColor: foregroundColor, withImage: image)
    }

    /**
     Create a new AuthStyle specifying all colors instead of a brand color

     - parameter name:             name to be used as the name of the Auth provider for the titles
     - parameter normalColor:      color used as the normal state color
     - parameter highlightedColor: color used as the highlighted state color and for the icon background if the size of button is `Big`
     - parameter foregroundColor:  text color of the button
     - parameter image:            icon used in the button

     - returns: a new style
     */
    public init(name: String, normalColor: UIColor, highlightedColor: UIColor, foregroundColor: UIColor, withImage image: LazyImage) {
        self.name = name
        self.normalColor = normalColor
        self.highlightedColor = highlightedColor
        self.foregroundColor = foregroundColor
        self.image = image
    }
    static func custom(_ name: String) -> AuthStyle {
        return AuthStyle(name: name)
    }
}

// MARK: - First class social connection styles

public extension AuthStyle {

    /// Amazon style for AuthButton
    public static var Amazon: AuthStyle {
        return AuthStyle(name: "Amazon", color: .a0_fromRGB("#ff9900"), withImage: LazyImage(name: "ic_auth_amazon", bundle: bundleForLock()))
    }

    /// Aol style for AuthButton
    public static var Aol: AuthStyle {
        return AuthStyle(name: "Aol", color: .a0_fromRGB("#ff0b00"), withImage: LazyImage(name: "ic_auth_aol", bundle: bundleForLock()))
    }

    /// Baidu style for AuthButton
    public static var Baidu: AuthStyle {
        return AuthStyle(name: "百度", color: .a0_fromRGB("#2529d8"), withImage: LazyImage(name: "ic_auth_baidu", bundle: bundleForLock()))
    }

    /// Bitbucket style for AuthButton
    public static var Bitbucket: AuthStyle {
        return AuthStyle(name: "Bitbucket", color: .a0_fromRGB("#205081"), withImage: LazyImage(name: "ic_auth_bitbucket", bundle: bundleForLock()))
    }

    /// Dropbox style for AuthButton
    public static var Dropbox: AuthStyle {
        return AuthStyle(name: "Dropbox", color: .a0_fromRGB("#0064d2"), withImage: LazyImage(name: "ic_auth_dropbox", bundle: bundleForLock()))
    }

    /// Dwolla style for AuthButton
    public static var Dwolla: AuthStyle {
        return AuthStyle(name: "Dwolla", color: .a0_fromRGB("#F5891F"), withImage: LazyImage(name: "ic_auth_dwolla", bundle: bundleForLock()))
    }

    /// Ebay style for AuthButton
    public static var Ebay: AuthStyle {
        return AuthStyle(name: "ebay", color: .a0_fromRGB("#007ee5"), withImage: LazyImage(name: "ic_auth_ebay", bundle: bundleForLock()))
    }

    /// Evernote style for AuthButton
    public static var Evernote: AuthStyle {
        return AuthStyle(name: "Evernote", color: .a0_fromRGB("#82B137"), withImage: LazyImage(name: "ic_auth_evernote", bundle: bundleForLock()))
    }

    /// Evernote Sandbox style for AuthButton
    public static var EvernoteSandbox: AuthStyle {
        return AuthStyle(name: "Evernote (Sandbox)", color: .a0_fromRGB("#82B137"), withImage: LazyImage(name: "ic_auth_evernote", bundle: bundleForLock()))
    }

    /// Exact style for AuthButton
    public static var Exact: AuthStyle {
        return AuthStyle(name: "Exact", color: .a0_fromRGB("#ED1C24"), withImage: LazyImage(name: "ic_auth_exact", bundle: bundleForLock()))
    }

    /// Facebook style for AuthButton
    public static var Facebook: AuthStyle {
        return AuthStyle(name: "Facebook", color: .a0_fromRGB("#3b5998"), withImage: LazyImage(name: "ic_auth_facebook", bundle: bundleForLock()))
    }

    /// Fitbit style for AuthButton
    public static var Fitbit: AuthStyle {
        return AuthStyle(name: "Fitbit", color: .a0_fromRGB("#4cc2c4"), withImage: LazyImage(name: "ic_auth_fitbit", bundle: bundleForLock()))
    }

    /// Github style for AuthButton
    public static var Github: AuthStyle {
        return AuthStyle(name: "Github", color: .a0_fromRGB("#333333"), withImage: LazyImage(name: "ic_auth_github", bundle: bundleForLock()))
    }

    /// Google style for AuthButton
    public static var Google: AuthStyle {
        return AuthStyle(name: "Google", color: .a0_fromRGB("#4285f4"), withImage: LazyImage(name: "ic_auth_google", bundle: bundleForLock()))
    }

    /// Instagram style for AuthButton
    public static var Instagram: AuthStyle {
        return AuthStyle(name: "Instagram", color: .a0_fromRGB("#3f729b"), withImage: LazyImage(name: "ic_auth_instagram", bundle: bundleForLock()))
    }

    /// Linkedin style for AuthButton
    public static var Linkedin: AuthStyle {
        return AuthStyle(name: "LinkedIn", color: .a0_fromRGB("#0077b5"), withImage: LazyImage(name: "ic_auth_linkedin", bundle: bundleForLock()))
    }

    /// Miicard style for AuthButton
    public static var Miicard: AuthStyle {
        return AuthStyle(name: "MiiCard", color: .a0_fromRGB("#35A6FE"), withImage: LazyImage(name: "ic_auth_miicard", bundle: bundleForLock()))
    }

    /// Paypal style for AuthButton
    public static var Paypal: AuthStyle {
        return AuthStyle(name: "PayPal", color: .a0_fromRGB("#009cde"), withImage: LazyImage(name: "ic_auth_paypal", bundle: bundleForLock()))
    }

    /// Planning Center style for AuthButton
    public static var PlanningCenter: AuthStyle {
        return AuthStyle(name: "Planning Center", color: .a0_fromRGB("#4e4e4e"), withImage: LazyImage(name: "ic_auth_planningcenter", bundle: bundleForLock()))
    }

    /// RenRen style for AuthButton
    public static var RenRen: AuthStyle {
        return AuthStyle(name: "人人", color: .a0_fromRGB("#0056B5"), withImage: LazyImage(name: "ic_auth_renren", bundle: bundleForLock()))
    }

    /// Salesforce style for AuthButton
    public static var Salesforce: AuthStyle {
        return AuthStyle(name: "Salesforce", color: .a0_fromRGB("#1798c1"), withImage: LazyImage(name: "ic_auth_salesforce", bundle: bundleForLock()))
    }

    /// Salesforce Community style for AuthButton
    public static var SalesforceCommunity: AuthStyle {
        return AuthStyle(name: "Salesforce Community", color: .a0_fromRGB("#1798c1"), withImage: LazyImage(name: "ic_auth_salesforce", bundle: bundleForLock()))
    }

    /// Salesforce Sandbox style for AuthButton
    public static var SalesforceSandbox: AuthStyle {
        return AuthStyle(name: "Salesforce (Sandbox)", color: .a0_fromRGB("#1798c1"), withImage: LazyImage(name: "ic_auth_salesforce", bundle: bundleForLock()))
    }

    /// Shopify style for AuthButton
    public static var Shopify: AuthStyle {
        return AuthStyle(name: "Shopify", color: .a0_fromRGB("#96bf48"), withImage: LazyImage(name: "ic_auth_shopify", bundle: bundleForLock()))
    }

    /// Soundcloud style for AuthButton
    public static var Soundcloud: AuthStyle {
        return AuthStyle(name: "Soundcloud", color: .a0_fromRGB("#ff8800"), withImage: LazyImage(name: "ic_auth_soundcloud", bundle: bundleForLock()))
    }

    /// The City style for AuthButton
    public static var TheCity: AuthStyle {
        return AuthStyle(name: "The City", color: .a0_fromRGB("#767571"), withImage: LazyImage(name: "ic_auth_thecity", bundle: bundleForLock()))
    }

    /// The City Sandbox style for AuthButton
    public static var TheCitySandbox: AuthStyle {
        return AuthStyle(name: "The City (Sandbox)", color: .a0_fromRGB("#767571"), withImage: LazyImage(name: "ic_auth_thecity", bundle: bundleForLock()))
    }

    /// 37 Signals style for AuthButton
    public static var ThirtySevenSignals: AuthStyle {
        return AuthStyle(name: "37 Signals", color: .a0_fromRGB("#6AC071"), withImage: LazyImage(name: "ic_auth_thirtysevensignals", bundle: bundleForLock()))
    }

    /// Twitter style for AuthButton
    public static var Twitter: AuthStyle {
        return AuthStyle(name: "Twitter", color: .a0_fromRGB("#55acee"), withImage: LazyImage(name: "ic_auth_twitter", bundle: bundleForLock()))
    }

    /// Vkontakte style for AuthButton
    public static var Vkontakte: AuthStyle {
        return AuthStyle(name: "vKontakte", color: .a0_fromRGB("#45668e"), withImage: LazyImage(name: "ic_auth_vk", bundle: bundleForLock()))
    }

    /// Microsoft style for AuthButton
    public static var Microsoft: AuthStyle {
        return AuthStyle(name: "Microsoft Account", color: .a0_fromRGB("#00a1f1"), withImage: LazyImage(name: "ic_auth_microsoft", bundle: bundleForLock()))
    }

    /// Wordpress style for AuthButton
    public static var Wordpress: AuthStyle {
        return AuthStyle(name: "Wordpress", color: .a0_fromRGB("#21759b"), withImage: LazyImage(name: "ic_auth_wordpress", bundle: bundleForLock()))
    }

    /// Yahoo style for AuthButton
    public static var Yahoo: AuthStyle {
        return AuthStyle(name: "Yahoo!", color: .a0_fromRGB("#410093"), withImage: LazyImage(name: "ic_auth_yahoo", bundle: bundleForLock()))
    }

    /// Yammer style for AuthButton
    public static var Yammer: AuthStyle {
        return AuthStyle(name: "Yammer", color: .a0_fromRGB("#0072c6"), withImage: LazyImage(name: "ic_auth_yammer", bundle: bundleForLock()))
    }

    /// Yandex style for AuthButton
    public static var Yandex: AuthStyle {
        return AuthStyle(name: "Yandex", color: .a0_fromRGB("#ffcc00"), withImage: LazyImage(name: "ic_auth_yandex", bundle: bundleForLock()))
    }

    /// Weibo style for AuthButton
    public static var Weibo: AuthStyle {
        return AuthStyle(name: "新浪微博", color: .a0_fromRGB("#DD4B39"), withImage: LazyImage(name: "ic_auth_weibo", bundle: bundleForLock()))
    }
}

// MARK: - AuthStyle from Strategy & Connection

extension AuthStyle {

    static func style(forStrategy strategy: String, connectionName: String) -> AuthStyle {
        switch strategy.lowercased() {
        case "ad", "adfs":
            return .Microsoft
        case "amazon":
            return .Amazon
        case "aol":
            return .Aol
        case "baidu":
            return .Baidu
        case "bitbucket":
            return .Bitbucket
        case "dropbox":
            return .Dropbox
        case "dwolla":
            return .Dwolla
        case "ebay":
            return .Ebay
        case "evernote":
            return .Evernote
        case "evernote-sandbox":
            return .EvernoteSandbox
        case "exact":
            return .Exact
        case "facebook":
            return .Facebook
        case "fitbit":
            return .Fitbit
        case "github":
            return .Github
        case "google-oauth2":
            return .Google
        case "instagram":
            return .Instagram
        case "linkedin":
            return .Linkedin
        case "miicard":
            return .Miicard
        case "paypal":
            return .Paypal
        case "planningcenter":
            return .PlanningCenter
        case "renren":
            return .RenRen
        case "salesforce":
            return .Salesforce
        case "salesforce-community":
            return .SalesforceCommunity
        case "salesforce-sandbox":
            return .SalesforceSandbox
        case "shopify":
            return .Shopify
        case "soundcloud":
            return .Soundcloud
        case "thecity":
            return .TheCity
        case "thecity-sandbox":
            return .TheCitySandbox
        case "thirtysevensignals":
            return .ThirtySevenSignals
        case "twitter":
            return .Twitter
        case "vkontakte":
            return .Vkontakte
        case "windowslive":
            return .Microsoft
        case "wordpress":
            return .Wordpress
        case "yahoo":
            return .Yahoo
        case "yammer":
            return .Yammer
        case "yandex":
            return .Yandex
        case "waad":
            return .Google
        case "weibo":
            return .Weibo
        default:
            return AuthStyle(name: connectionName)
        }
    }
}
