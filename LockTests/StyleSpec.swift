// StyleSpec.swift
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

class StyleSpec: QuickSpec {

    override func spec() {

        describe("style Auth0") {

            let style = Style.Auth0

            it("should have primary color") {
                expect(style.primaryColor) == UIColor.a0_orange
            }

            it("should have background color") {
                expect(style.backgroundColor) == UIColor.white
            }

            it("should not hide title") {
                expect(style.hideTitle) == false
            }

            it("should not hide button title") {
                expect(style.hideButtonTitle) == false
            }

            it("should have text color") {
                expect(style.textColor) == UIColor.black
            }

            it("should have logo") {
                expect(style.logo) == lazyImage(named: "ic_auth0")
            }

            it("should have social seperator text color") {
                expect(style.seperatorTextColor) == UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.54)
            }

            it("should have input field text color") {
                expect(style.inputTextColor) == UIColor.black
            }

            it("should have input field placeholder text color") {
                expect(style.inputPlaceholderTextColor) == UIColor(red: 0.780, green: 0.780, blue: 0.804, alpha: 1.00)
            }

            it("should have input field border color default") {
                expect(style.inputBorderColor) == UIColor(red: 0.9333, green: 0.9333, blue: 0.9333, alpha: 1.0)
            }

            it("should have input field border color invalid") {
                expect(style.inputBorderColorError) == UIColor.red
            }

            it("should have input field background color") {
                expect(style.inputBackgroundColor) == UIColor.white
            }

            it("should have input field icon background color") {
                expect(style.inputIconBackgroundColor) == UIColor(red: 0.9333, green: 0.9333, blue: 0.9333, alpha: 1.0)
            }

            it("should have input field icon color") {
                expect(style.inputIconColor) == UIColor(red: 0.5725, green: 0.5804, blue: 0.5843, alpha: 1.0 )
            }

            it("should have secondary button color") {
                expect(style.secondaryButtonColor) == UIColor.black
            }

            it("should have database login tab text color") {
                expect(style.tabTextColor) == UIColor(red: 0.3608, green: 0.4, blue: 0.4353, alpha: 0.6)
            }

            it("should have database login tab tint color") {
                expect(style.tabTintColor) == UIColor(red: 0.3608, green: 0.4, blue: 0.4353, alpha: 0.6)
            }

            it("should have lock controller status bar update animation") {
                expect(style.statusBarUpdateAnimation.rawValue) == 0
            }

            it("should have lock controller status bar hidden") {
                expect(style.statusBarHidden) == false
            }

            it("should have lock controller status bar style") {
                expect(style.statusBarStyle.rawValue) == 0
            }

            it("should have search status bar style") {
                expect(style.searchBarStyle.rawValue) == 0
            }

            it("should have header close button image") {
                expect(style.headerCloseIcon) == lazyImage(named: "ic_close")
            }

            it("should have header back button image") {
                expect(style.headerBackIcon) == lazyImage(named: "ic_back")
            }

            it("should have header close button image") {
                expect(style.onePasswordIconColor) == UIColor(red: 0.5725, green: 0.5804, blue: 0.5843, alpha: 1.0)
            }

            it("should have modal popup true") {
                expect(style.modalPopup) == true
            }

        }

        describe("custom style") {

            var style: Style!

            beforeEach {
                style = Style.Auth0
            }

            it("should show button title when header title is hidden") {
                style.hideTitle = true
                expect(style.hideButtonTitle) == false
            }
        }
    }
}
