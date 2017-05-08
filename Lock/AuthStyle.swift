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
        let format = "LOG IN WITH %1$@".i18n(key: "com.auth0.lock.strategy.login.title", comment: "Log in with %@{strategy}")
        return String(format: format, self.name)
    }

    var localizedSignUpTitle: String {
        let format = "SIGN UP WITH %1$@".i18n(key: "com.auth0.lock.strategy.signup.title", comment: "Sign up with %@{strategy}")
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
        return AuthStyle(
                name: "AMAZON".i18n(key: "com.auth0.lock.strategy.localized.amazon", comment: "Amazon"),
                color: .a0_fromRGB("#ff9900"),
                withImage: LazyImage(name: "ic_auth_amazon", bundle: bundleForLock())
        )
    }

    /// Aol style for AuthButton
    public static var Aol: AuthStyle {
        return AuthStyle(
                name: "AOL".i18n(key: "com.auth0.lock.strategy.localized.aol", comment: "Aol"),
                color: .a0_fromRGB("#ff0b00"),
                withImage: LazyImage(name: "ic_auth_aol", bundle: bundleForLock())
        )
    }

    /// Baidu style for AuthButton
    public static var Baidu: AuthStyle {
        return AuthStyle(
                name: "百度".i18n(key: "com.auth0.lock.strategy.localized.baidu", comment: "Baidu"),
                color: .a0_fromRGB("#2529d8"),
                withImage: LazyImage(name: "ic_auth_baidu", bundle: bundleForLock())
        )
    }

    /// Bitbucket style for AuthButton
    public static var Bitbucket: AuthStyle {
        return AuthStyle(
                name: "BITBUCKET".i18n(key: "com.auth0.lock.strategy.localized.bitbucket", comment: "Bitbucket"),
                color: .a0_fromRGB("#205081"),
                withImage: LazyImage(name: "ic_auth_bitbucket", bundle: bundleForLock())
        )
    }

    /// Dropbox style for AuthButton
    public static var Dropbox: AuthStyle {
        return AuthStyle(
                name: "DROPBOX".i18n(key: "com.auth0.lock.strategy.localized.dropbox", comment: "Dropbox"),
                color: .a0_fromRGB("#0064d2"),
                withImage: LazyImage(name: "ic_auth_dropbox", bundle: bundleForLock())
        )
    }

    /// Dwolla style for AuthButton
    public static var Dwolla: AuthStyle {
        return AuthStyle(
                name: "DWOLLA".i18n(key: "com.auth0.lock.strategy.localized.dwolla", comment: "Dwolla"),
                color: .a0_fromRGB("#F5891F"),
                withImage: LazyImage(name: "ic_auth_dwolla", bundle: bundleForLock())
        )
    }

    /// Ebay style for AuthButton
    public static var Ebay: AuthStyle {
        return AuthStyle(
                name: "EBAY".i18n(key: "com.auth0.lock.strategy.localized.ebay", comment: "Ebay"),
                color: .a0_fromRGB("#007ee5"),
                withImage: LazyImage(name: "ic_auth_ebay", bundle: bundleForLock())
        )
    }

    /// Evernote style for AuthButton
    public static var Evernote: AuthStyle {
        return AuthStyle(
                name: "EVERNOTE".i18n(key: "com.auth0.lock.strategy.localized.evernote", comment: "Evernote"),
                color: .a0_fromRGB("#2dbe60"),
                withImage: LazyImage(name: "ic_auth_evernote", bundle: bundleForLock())
        )
    }

    /// Evernote Sandbox style for AuthButton
    public static var EvernoteSandbox: AuthStyle {
        return AuthStyle(
                name: "EVERNOTE (SANDBOX)".i18n(key: "com.auth0.lock.strategy.localized.evernote_sandbox", comment: "EvernoteSandbox"),
                color: .a0_fromRGB("#2dbe60"),
                withImage: LazyImage(name: "ic_auth_evernote", bundle: bundleForLock())
        )
    }

    /// Exact style for AuthButton
    public static var Exact: AuthStyle {
        return AuthStyle(
                name: "EXACT".i18n(key: "com.auth0.lock.strategy.localized.exact", comment: "Exact"),
                color: .a0_fromRGB("#ED1C24"),
                withImage: LazyImage(name: "ic_auth_exact", bundle: bundleForLock())
        )
    }

    /// Facebook style for AuthButton
    public static var Facebook: AuthStyle {
        return AuthStyle(
                name: "FACEBOOK".i18n(key: "com.auth0.lock.strategy.localized.facebook", comment: "Facebook"),
                color: .a0_fromRGB("#3b5998"),
                withImage: LazyImage(name: "ic_auth_facebook", bundle: bundleForLock())
        )
    }

    /// Fitbit style for AuthButton
    public static var Fitbit: AuthStyle {
        return AuthStyle(
                name: "FITBIT".i18n(key: "com.auth0.lock.strategy.localized.fitbit", comment: "Fitbit"),
                color: .a0_fromRGB("#4cc2c4"),
                withImage: LazyImage(name: "ic_auth_fitbit", bundle: bundleForLock())
        )
    }

    /// Github style for AuthButton
    public static var Github: AuthStyle {
        return AuthStyle(
                name: "GITHUB".i18n(key: "com.auth0.lock.strategy.localized.github", comment: "Github"),
                color: .a0_fromRGB("#333333"),
                withImage: LazyImage(name: "ic_auth_github", bundle: bundleForLock())
        )
    }

    /// Google style for AuthButton
    public static var Google: AuthStyle {
        return AuthStyle(
                name: "GOOGLE".i18n(key: "com.auth0.lock.strategy.localized.google", comment: "Google"),
                color: .a0_fromRGB("#4285f4"),
                withImage: LazyImage(name: "ic_auth_google", bundle: bundleForLock())
        )
    }

    /// Instagram style for AuthButton
    public static var Instagram: AuthStyle {
        return AuthStyle(
                name: "INSTAGRAM".i18n(key: "com.auth0.lock.strategy.localized.instagram", comment: "Instagram"),
                color: .a0_fromRGB("#3f729b"),
                withImage: LazyImage(name: "ic_auth_instagram", bundle: bundleForLock())
        )
    }

    /// Linkedin style for AuthButton
    public static var Linkedin: AuthStyle {
        return AuthStyle(
                name: "LINKEDIN".i18n(key: "com.auth0.lock.strategy.localized.linkedin", comment: "Linkedin"),
                color: .a0_fromRGB("#0077b5"),
                withImage: LazyImage(name: "ic_auth_linkedin", bundle: bundleForLock())
        )
    }

    /// Miicard style for AuthButton
    public static var Miicard: AuthStyle {
        return AuthStyle(
                name: "MIICARD".i18n(key: "com.auth0.lock.strategy.localized.miicard", comment: "Miicard"),
                color: .a0_fromRGB("#35A6FE"),
                withImage: LazyImage(name: "ic_auth_miicard", bundle: bundleForLock())
        )
    }

    /// Paypal style for AuthButton
    public static var Paypal: AuthStyle {
        return AuthStyle(
                name: "PAYPAL".i18n(key: "com.auth0.lock.strategy.localized.paypal", comment: "Paypal"),
                color: .a0_fromRGB("#009cde"),
                withImage: LazyImage(name: "ic_auth_paypal", bundle: bundleForLock())
        )
    }

    /// Paypal style for AuthButton
    public static var PaypalSandbox: AuthStyle {
        return AuthStyle(
            name: "PAYPAL (SANDBOX)".i18n(key: "com.auth0.lock.strategy.localized.paypal_sandbox", comment: "PaypalSandbox"),
            color: .a0_fromRGB("#009cde"),
            withImage: LazyImage(name: "ic_auth_paypal", bundle: bundleForLock())
        )
    }

    /// Planning Center style for AuthButton
    public static var PlanningCenter: AuthStyle {
        return AuthStyle(
                name: "PLANNING CENTER".i18n(key: "com.auth0.lock.strategy.localized.planning_center", comment: "PlanningCenter"),
                color: .a0_fromRGB("#4e4e4e"),
                withImage: LazyImage(name: "ic_auth_planningcenter", bundle: bundleForLock())
        )
    }

    /// RenRen style for AuthButton
    public static var RenRen: AuthStyle {
        return AuthStyle(
                name: "人人".i18n(key: "com.auth0.lock.strategy.localized.renren", comment: "RenRen"),
                color: .a0_fromRGB("#0056B5"),
                withImage: LazyImage(name: "ic_auth_renren", bundle: bundleForLock())
        )
    }

    /// Salesforce style for AuthButton
    public static var Salesforce: AuthStyle {
        return AuthStyle(
                name: "SALESFORCE".i18n(key: "com.auth0.lock.strategy.localized.salesforce", comment: "Salesforce"),
                color: .a0_fromRGB("#1798c1"),
                withImage: LazyImage(name: "ic_auth_salesforce", bundle: bundleForLock())
        )
    }

    /// Salesforce Community style for AuthButton
    public static var SalesforceCommunity: AuthStyle {
        return AuthStyle(
                name: "SALESFORCE COMMUNITY".i18n(key: "com.auth0.lock.strategy.localized.salesforce_community", comment: "SalesforceCommunity"),
                color: .a0_fromRGB("#1798c1"),
                withImage: LazyImage(name: "ic_auth_salesforce", bundle: bundleForLock())
        )
    }

    /// Salesforce Sandbox style for AuthButton
    public static var SalesforceSandbox: AuthStyle {
        return AuthStyle(
                name: "SALESFORCE (SANDBOX)".i18n(key: "com.auth0.lock.strategy.localized.salesforce_sandbox", comment: "SalesforceSandbox"),
                color: .a0_fromRGB("#1798c1"),
                withImage: LazyImage(name: "ic_auth_salesforce", bundle: bundleForLock())
        )
    }

    /// Shopify style for AuthButton
    public static var Shopify: AuthStyle {
        return AuthStyle(
                name: "SHOPIFY".i18n(key: "com.auth0.lock.strategy.localized.shopify", comment: "Shopify"),
                color: .a0_fromRGB("#96bf48"),
                withImage: LazyImage(name: "ic_auth_shopify", bundle: bundleForLock())
        )
    }

    /// Soundcloud style for AuthButton
    public static var Soundcloud: AuthStyle {
        return AuthStyle(
                name: "SOUNDCLOUD".i18n(key: "com.auth0.lock.strategy.localized.soundcloud", comment: "Soundcloud"),
                color: .a0_fromRGB("#ff8800"),
                withImage: LazyImage(name: "ic_auth_soundcloud", bundle: bundleForLock())
        )
    }

    /// The City style for AuthButton
    public static var TheCity: AuthStyle {
        return AuthStyle(
                name: "THE CITY".i18n(key: "com.auth0.lock.strategy.localized.the_city", comment: "TheCity"),
                color: .a0_fromRGB("#767571"),
                withImage: LazyImage(name: "ic_auth_thecity", bundle: bundleForLock())
        )
    }

    /// The City Sandbox style for AuthButton
    public static var TheCitySandbox: AuthStyle {
        return AuthStyle(
                name: "THE CITY (SANDBOX)".i18n(key: "com.auth0.lock.strategy.localized.the_city_sandbox", comment: "TheCitySandbox"),
                color: .a0_fromRGB("#767571"),
                withImage: LazyImage(name: "ic_auth_thecity", bundle: bundleForLock())
        )
    }

    /// 37 Signals style for AuthButton
    public static var ThirtySevenSignals: AuthStyle {
        return AuthStyle(
                name: "37 SIGNALS".i18n(key: "com.auth0.lock.strategy.localized.thirty_seven_signals", comment: "ThirtySevenSignals"),
                color: .a0_fromRGB("#6AC071"),
                withImage: LazyImage(name: "ic_auth_thirtysevensignals", bundle: bundleForLock())
        )
    }

    /// Twitter style for AuthButton
    public static var Twitter: AuthStyle {
        return AuthStyle(
                name: "TWITTER".i18n(key: "com.auth0.lock.strategy.localized.twitter", comment: "Twitter"),
                color: .a0_fromRGB("#55acee"),
                withImage: LazyImage(name: "ic_auth_twitter", bundle: bundleForLock())
        )
    }

    /// Vkontakte style for AuthButton
    public static var Vkontakte: AuthStyle {
        return AuthStyle(
                name: "VKONTAKTE".i18n(key: "com.auth0.lock.strategy.localized.vkontakte", comment: "Vkontakte"),
                color: .a0_fromRGB("#45668e"),
                withImage: LazyImage(name: "ic_auth_vk", bundle: bundleForLock())
        )
    }

    /// Microsoft style for AuthButton
    public static var Microsoft: AuthStyle {
        return AuthStyle(
                name: "MICROSOFT ACCOUNT".i18n(key: "com.auth0.lock.strategy.localized.microsoft", comment: "Microsoft"),
                color: .a0_fromRGB("#00a1f1"),
                withImage: LazyImage(name: "ic_auth_microsoft", bundle: bundleForLock())
        )
    }

    /// Wordpress style for AuthButton
    public static var Wordpress: AuthStyle {
        return AuthStyle(
                name: "WORDPRESS".i18n(key: "com.auth0.lock.strategy.localized.wordpress", comment: "Wordpress"),
                color: .a0_fromRGB("#21759b"),
                withImage: LazyImage(name: "ic_auth_wordpress", bundle: bundleForLock())
        )
    }

    /// Yahoo style for AuthButton
    public static var Yahoo: AuthStyle {
        return AuthStyle(
                name: "YAHOO!".i18n(key: "com.auth0.lock.strategy.localized.yahoo", comment: "Yahoo"),
                color: .a0_fromRGB("#410093"),
                withImage: LazyImage(name: "ic_auth_yahoo", bundle: bundleForLock())
        )
    }

    /// Yammer style for AuthButton
    public static var Yammer: AuthStyle {
        return AuthStyle(
                name: "YAMMER".i18n(key: "com.auth0.lock.strategy.localized.yammer", comment: "Yammer"),
                color: .a0_fromRGB("#0072c6"),
                withImage: LazyImage(name: "ic_auth_yammer", bundle: bundleForLock())
        )
    }

    /// Yandex style for AuthButton
    public static var Yandex: AuthStyle {
        return AuthStyle(
                name: "YANDEX".i18n(key: "com.auth0.lock.strategy.localized.yandex", comment: "Yandex"),
                color: .a0_fromRGB("#ffcc00"),
                withImage: LazyImage(name: "ic_auth_yandex", bundle: bundleForLock())
        )
    }

    /// Weibo style for AuthButton
    public static var Weibo: AuthStyle {
        return AuthStyle(
                name: "新浪微博".i18n(key: "com.auth0.lock.strategy.localized.weibo", comment: "Weibo"),
                color: .a0_fromRGB("#DD4B39"),
                withImage: LazyImage(name: "ic_auth_weibo", bundle: bundleForLock())
        )
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
        case "paypal-sandbox":
            return .PaypalSandbox
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
