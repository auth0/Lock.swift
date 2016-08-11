// SocialViewSpec.swift
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

class SocialViewSpec: QuickSpec {
    override func spec() {

        context("expanded") {

            describe("height") {

                it("should return 0 when there are no buttons") {
                    let view = SocialView(buttons: [], mode: .Expanded, insets: UIEdgeInsetsZero)
                    expect(view.height) == 0
                }

                it("should just use the button size if there is only one button") {
                    let view = SocialView(buttons: [AuthButton(size: .Big)], mode: .Expanded, insets: UIEdgeInsetsZero)
                    expect(view.height) == 50
                }

                it("should add padding") {
                    let max = Int(arc4random_uniform(15)) + 2
                    let buttons = (1...max).map { _ in return AuthButton(size: .Big) }
                    let view = SocialView(buttons: buttons, mode: .Expanded, insets: UIEdgeInsetsZero)
                    let expected = (max * 50) + (max * 8) - 8
                    expect(view.height) == CGFloat(expected)
                }
            }

        }

        context("compact") {

            describe("height") {

                it("should return 0 when there are no buttons") {
                    let view = SocialView(buttons: [], mode: .Compact, insets: UIEdgeInsetsZero)
                    expect(view.height) == 0
                }

                it("should just use the button size if there is only one button") {
                    let view = SocialView(buttons: [AuthButton(size: .Small)], mode: .Compact, insets: UIEdgeInsetsZero)
                    expect(view.height) == 50
                }

                it("should just use the button size for less than 6 buttons") {
                    let buttons = [AuthButton(size: .Small), AuthButton(size: .Small), AuthButton(size: .Small), AuthButton(size: .Small), AuthButton(size: .Small)]
                    let view = SocialView(buttons: buttons, mode: .Compact, insets: UIEdgeInsetsZero)
                    expect(view.height) == 50
                }

                it("should add padding per row") {
                    let count = Int(arc4random_uniform(15)) + 2
                    let rows = Int(ceil(Double(count) / 5))
                    let buttons = (1...count).map { _ in return AuthButton(size: .Big) }
                    let view = SocialView(buttons: buttons, mode: .Compact, insets: UIEdgeInsetsZero)
                    let expected = (rows * 50) + (rows * 8) - 8
                    expect(view.height) == CGFloat(expected)
                }
            }
            
        }

    }
}