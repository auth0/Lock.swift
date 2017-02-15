// AuthCollectionViewSpec.swift
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

class AuthCollectionViewSpec: QuickSpec {
    override func spec() {

        context("expanded") {

            describe("height") {

                it("should return 0 when there are no buttons") {
                    let view = AuthCollectionView(connections: [], mode: .expanded(isLogin: true), insets: UIEdgeInsets.zero, customStyle: [:]) { _ in }
                    expect(view.height) == 0
                }

                it("should just use the button size if there is only one button") {
                    let view = AuthCollectionView(connections: [SocialConnection(name: "social", style: .Facebook)], mode: .expanded(isLogin: true), insets: UIEdgeInsets.zero, customStyle: [:]) { _ in }
                    expect(view.height) == 50
                }

                it("should add padding") {
                    let max = Int(arc4random_uniform(15)) + 2
                    let connections = mockConnections(count: max)
                    let view = AuthCollectionView(connections: connections, mode: .expanded(isLogin: true), insets: UIEdgeInsets.zero, customStyle: [:]) { _ in }
                    let expected = (max * 50) + (max * 8) - 8
                    expect(view.height) == CGFloat(expected)
                }
            }

        }

        context("compact") {

            describe("height") {

                it("should return 0 when there are no buttons") {
                    let view = AuthCollectionView(connections: [], mode: .compact, insets: UIEdgeInsets.zero, customStyle: [:]) { _ in }
                    expect(view.height) == 0
                }

                it("should just use the button size if there is only one button") {
                    let view = AuthCollectionView(connections: [SocialConnection(name: "social", style: .Facebook)], mode: .compact, insets: UIEdgeInsets.zero, customStyle: [:]) { _ in }
                    expect(view.height) == 50
                }

                it("should just use the button size for less than 6 buttons") {
                    let connections: [OAuth2Connection] = mockConnections(count: 5)
                    let view = AuthCollectionView(connections: connections, mode: .compact, insets: UIEdgeInsets.zero, customStyle: [:]) { _ in }
                    expect(view.height) == 50
                }

                it("should add padding per row") {
                    let count = Int(arc4random_uniform(15)) + 2
                    let rows = Int(ceil(Double(count) / 5))
                    let connections = mockConnections(count: count)
                    let view = AuthCollectionView(connections: connections, mode: .compact, insets: UIEdgeInsets.zero, customStyle: [:]) { _ in }
                    let expected = (rows * 50) + (rows * 8) - 8
                    expect(view.height) == CGFloat(expected)
                }
            }

        }

        describe("styling") {

            func styleButton(_ style: AuthStyle, isLogin: Bool = true) -> AuthButton {
                return oauth2Buttons(forConnections: [SocialConnection(name: "social0", style: style)], customStyle: [:], isLogin: isLogin, onAction: {_ in }).first!
            }

            it("should set proper title") {
                let button = styleButton(.Facebook)
                expect(button.title) == "LOG IN WITH FACEBOOK"
            }

            it("should set proper title") {
                let button = styleButton(.Facebook, isLogin: false)
                expect(button.title) == "SIGN UP WITH FACEBOOK"
            }

            it("should set color") {
                let style = AuthStyle.Facebook
                let button = styleButton(style)
                expect(button.normalColor) == style.normalColor
                expect(button.highlightedColor) == style.highlightedColor
            }

            it("should set icon") {
                let style = AuthStyle.Facebook
                let button = styleButton(style)
                expect(button.icon).toNot(beNil())
            }

            it("should use custom style") {
                let style = ["steam": AuthStyle(name: "Steam", color: .white)]
                let button = oauth2Buttons(forConnections: [SocialConnection(name: "steam", style: AuthStyle(name: "steam"))], customStyle: style, isLogin: true, onAction: {_ in }).first!
                expect(button.title) == "LOG IN WITH Steam"
                expect(button.color) == UIColor.white
            }

        }
    }
}

func mockConnections(count: Int) -> [OAuth2Connection] {
    return (1...count).map { _ -> OAuth2Connection in return SocialConnection(name: "social", style: .Facebook) }
}
