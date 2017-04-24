// AuthStyleSpec.swift
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

import Quick
import Nimble

@testable import Lock

private let NameKey = "name"
private let IconKey = "icon_name"
private let StyleKey = "style"

private let FirstClassStyleExample = "style"

func forStyle(_ style: AuthStyle, name: String, iconName: String) -> [String: Any] {
    return [
        StyleKey: style,
        NameKey: name,
        IconKey: iconName
    ]
}

class AuthStyleSpecSharedExamplesConfiguration: QuickConfiguration {
    override class func configure(_ configuration: Configuration) {
        sharedExamples(FirstClassStyleExample) { (context: SharedExampleContext) in

            let style = context()[StyleKey] as! AuthStyle
            let name = context()[NameKey] as! String
            let iconName = context()[IconKey] as! String

            describe("for \(name.lowercased())") {
                it("should have correct name") {
                    expect(style.name) == name
                }

                it("should have a color") {
                    expect(style.normalColor) != UIColor.a0_orange
                }

                it("should have icon") {
                    expect(style.image.name) == iconName
                    expect(style.image.bundle) == Lock.bundle
                }
            }
        }
    }
}

class AuthStyleSpec: QuickSpec {

    override func spec() {

        describe("init") {
            let strategy = AuthStyle(name: "a name")

            it("should build with a name") {
                expect(strategy.name) == "a name"
            }

            it("should have default image") {
                expect(strategy.image.name) == "ic_auth_auth0"
            }

            it("should have default color") {
                expect(strategy.normalColor) == UIColor.a0_orange
            }

            it("should have default highligted color") {
                expect(strategy.highlightedColor) == UIColor.a0_orange.a0_darker(0.3)
            }

            it("should have default foreground color") {
                expect(strategy.foregroundColor) == UIColor.white
            }

            it("should have main bundle") {
                expect(strategy.image.bundle) == bundleForLock()
            }

        }

        describe("titles") {

            it("should provide login title") {
                let strategy = AuthStyle(name: "facebook")
                expect(strategy.localizedLoginTitle) == "LOG IN WITH facebook"
            }

            it("should provide signup title") {
                let strategy = AuthStyle(name: "facebook")
                expect(strategy.localizedSignUpTitle) == "SIGN UP WITH facebook"
            }

        }

        describe("first class connections") {

            [
                forStyle(.Amazon, name: "AMAZON", iconName: "ic_auth_amazon"),
                forStyle(.Aol, name: "AOL", iconName: "ic_auth_aol"),
                forStyle(.Baidu, name: "百度", iconName: "ic_auth_baidu"),
                forStyle(.Bitbucket, name: "BITBUCKET", iconName: "ic_auth_bitbucket"),
                forStyle(.Dropbox, name: "DROPBOX", iconName: "ic_auth_dropbox"),
                forStyle(.Dwolla, name: "DWOLLA", iconName: "ic_auth_dwolla"),
                forStyle(.Ebay, name: "EBAY", iconName: "ic_auth_ebay"),
                forStyle(.Evernote, name: "EVERNOTE", iconName: "ic_auth_evernote"),
                forStyle(.EvernoteSandbox, name: "EVERNOTE (SANDBOX)", iconName: "ic_auth_evernote"),
                forStyle(.Exact, name: "EXACT", iconName: "ic_auth_exact"),
                forStyle(.Facebook, name: "FACEBOOK", iconName: "ic_auth_facebook"),
                forStyle(.Fitbit, name: "FITBIT", iconName: "ic_auth_fitbit"),
                forStyle(.Github, name: "GITHUB", iconName: "ic_auth_github"),
                forStyle(.Google, name: "GOOGLE", iconName: "ic_auth_google"),
                forStyle(.Instagram, name: "INSTAGRAM", iconName: "ic_auth_instagram"),
                forStyle(.Linkedin, name: "LINKEDIN", iconName: "ic_auth_linkedin"),
                forStyle(.Miicard, name: "MIICARD", iconName: "ic_auth_miicard"),
                forStyle(.Paypal, name: "PAYPAL", iconName: "ic_auth_paypal"),
                forStyle(.PaypalSandbox, name: "PAYPAL (SANDBOX)", iconName: "ic_auth_paypal"),
                forStyle(.PlanningCenter, name: "PLANNING CENTER", iconName: "ic_auth_planningcenter"),
                forStyle(.RenRen, name: "人人", iconName: "ic_auth_renren"),
                forStyle(.Salesforce, name: "SALESFORCE", iconName: "ic_auth_salesforce"),
                forStyle(.SalesforceCommunity, name: "SALESFORCE COMMUNITY", iconName: "ic_auth_salesforce"),
                forStyle(.SalesforceSandbox, name: "SALESFORCE (SANDBOX)", iconName: "ic_auth_salesforce"),
                forStyle(.Shopify, name: "SHOPIFY", iconName: "ic_auth_shopify"),
                forStyle(.Soundcloud, name: "SOUNDCLOUD", iconName: "ic_auth_soundcloud"),
                forStyle(.TheCity, name: "THE CITY", iconName: "ic_auth_thecity"),
                forStyle(.TheCitySandbox, name: "THE CITY (SANDBOX)", iconName: "ic_auth_thecity"),
                forStyle(.ThirtySevenSignals, name: "37 SIGNALS", iconName: "ic_auth_thirtysevensignals"),
                forStyle(.Twitter, name: "TWITTER", iconName: "ic_auth_twitter"),
                forStyle(.Vkontakte, name: "VKONTAKTE", iconName: "ic_auth_vk"),
                forStyle(.Microsoft, name: "MICROSOFT ACCOUNT", iconName: "ic_auth_microsoft"),
                forStyle(.Wordpress, name: "WORDPRESS", iconName: "ic_auth_wordpress"),
                forStyle(.Yahoo, name: "YAHOO!", iconName: "ic_auth_yahoo"),
                forStyle(.Yammer, name: "YAMMER", iconName: "ic_auth_yammer"),
                forStyle(.Yandex, name: "YANDEX", iconName: "ic_auth_yandex"),
                forStyle(.Weibo, name: "新浪微博", iconName: "ic_auth_weibo"),
                ].forEach { style in
                    itBehavesLike(FirstClassStyleExample) { return style }
                }
        }

        describe("style for strategy") {

            it("should default to auth0 style") {
                let style = AuthStyle.style(forStrategy: "random", connectionName: "connection")
                expect(style.name) == "connection"
                expect(style.normalColor) == UIColor.a0_orange
            }

            [
                ("ad", AuthStyle.Microsoft),
                ("adfs", AuthStyle.Microsoft),
                ("amazon", AuthStyle.Amazon),
                ("aol", AuthStyle.Aol),
                ("baidu", AuthStyle.Baidu),
                ("bitbucket", AuthStyle.Bitbucket),
                ("dropbox", AuthStyle.Dropbox),
                ("dwolla", AuthStyle.Dwolla),
                ("ebay", AuthStyle.Ebay),
                ("evernote", AuthStyle.Evernote),
                ("evernote-sandbox", AuthStyle.EvernoteSandbox),
                ("exact", AuthStyle.Exact),
                ("facebook", AuthStyle.Facebook),
                ("fitbit", AuthStyle.Fitbit),
                ("github", AuthStyle.Github),
                ("google-oauth2", AuthStyle.Google),
                ("instagram", AuthStyle.Instagram),
                ("linkedin", AuthStyle.Linkedin),
                ("miicard", AuthStyle.Miicard),
                ("paypal", AuthStyle.Paypal),
                ("paypal-sandbox", AuthStyle.PaypalSandbox),
                ("planningcenter", AuthStyle.PlanningCenter),
                ("renren", AuthStyle.RenRen),
                ("salesforce", AuthStyle.Salesforce),
                ("salesforce-community", AuthStyle.SalesforceCommunity),
                ("salesforce-sandbox", AuthStyle.SalesforceSandbox),
                ("shopify", AuthStyle.Shopify),
                ("soundcloud", AuthStyle.Soundcloud),
                ("thecity", AuthStyle.TheCity),
                ("thecity-sandbox", AuthStyle.TheCitySandbox),
                ("thirtysevensignals", AuthStyle.ThirtySevenSignals),
                ("twitter", AuthStyle.Twitter),
                ("vkontakte", AuthStyle.Vkontakte),
                ("windowslive", AuthStyle.Microsoft),
                ("wordpress", AuthStyle.Wordpress),
                ("yahoo", AuthStyle.Yahoo),
                ("yammer", AuthStyle.Yammer),
                ("yandex", AuthStyle.Yandex),
                ("waad", AuthStyle.Google),
                ("weibo", AuthStyle.Weibo),
            ].forEach { (strategy, expected) in
                it("should match \(strategy) style") {
                    let style = AuthStyle.style(forStrategy: strategy, connectionName: "connection1")
                    expect(style) == expected
                }
            }
        }

        describe("style button color states") {

            let style: Style = Style.Auth0

            it("should have orange for normal") {
                expect(style.primaryButtonColor(forState: .normal)) == UIColor.a0_orange
            }

            it("should be darker for highlighted") {
                let baseColor = UIColor.a0_orange
                expect(style.primaryButtonColor(forState: .highlighted)) == baseColor.a0_darker(0.20)
            }

            it("should match disabled color") {
                expect(style.primaryButtonColor(forState: .disabled)) == UIColor(red: 0.8902, green: 0.898, blue: 0.9059, alpha: 1.0 )
            }

            it("should match disabled color") {
                expect(style.primaryButtonTintColor(forState: .disabled)) == UIColor(red: 0.5725, green: 0.5804, blue: 0.5843, alpha: 1.0 )
            }

            it("should match tint disabled color") {
                expect(style.primaryButtonTintColor(forState: .normal)) == UIColor.white
            }

        }
    }
}

extension AuthStyle: Equatable, CustomStringConvertible {
    public var description: String { return "AuthStyle(name=\(name))" }
}

public func ==(lhs: AuthStyle, rhs: AuthStyle) -> Bool {
    return lhs.name == rhs.name && lhs.normalColor == rhs.normalColor && lhs.highlightedColor == rhs.highlightedColor && lhs.foregroundColor == rhs.foregroundColor && lhs.image.name == rhs.image.name
}
