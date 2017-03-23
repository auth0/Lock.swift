// PolicyViewSpec.swift
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

class PolicyViewSpec: QuickSpec {

    override func spec() {

        describe("init") {

            it("init with one rule") {
                let rule = SimpleRule(message: "Simple Message") { _ in return true }
                let policyView = PolicyView(rules: [rule])
                expect(policyView.views.count) == 1
            }
        }

        context("rule view") {

            describe("init") {

                it("should have label with custom rule text") {
                    let ruleView = RuleView(message: "MY RULE")
                    expect(ruleView.label.text).to(contain("MY RULE"))
                }

                it("should have default color of status none") {
                    let ruleView = RuleView(message: "MY RULE")
                    expect(ruleView.status.color) == UIColor(red: 0.016, green: 0.016, blue: 0.016, alpha: 1)
                }

            }

            describe("status") {

                var ruleView: RuleView!

                beforeEach {
                    ruleView = RuleView(message: "MY RULE")
                }

                it("should change status color to error") {
                    ruleView.status = .error
                    expect(ruleView.status.color) == UIColor(red: 0.745, green: 0.271, blue: 0.153, alpha: 1)
                }

            }
        }

    }


}
