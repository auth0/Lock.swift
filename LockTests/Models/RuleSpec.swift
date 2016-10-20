// RuleSpec.swift
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

class RuleSpec: QuickSpec {

    override func spec() {


        describe("length") {

            it("should validate length with range") {
                let rule = withPassword(lengthInRange: 1...10)
                expect(rule.evaluate(on: "password").valid) == true
            }

            it("should fail when length is smaller than desired") {
                let rule = withPassword(lengthInRange: 8...10)
                expect(rule.evaluate(on: "short").valid) == false
            }

            it("should fail when length is greater than desired") {
                let rule = withPassword(lengthInRange: 1...4)
                expect(rule.evaluate(on: "longpassword").valid) == false
            }

            it("should fail with nil") {
                let rule = withPassword(lengthInRange: 1...4)
                expect(rule.evaluate(on: nil).valid) == false
            }

        }

        describe("character set") {

            let rule = withPassword(havingCharactersIn: .alphanumericCharacterSet())

            it("should allow valid characters") {
                expect(rule.evaluate(on: "should match this 1 password").valid) == true
            }

            it("should fail whe no valid character is found") {
                expect(rule.evaluate(on: "#@&$)*@#()*$)(#*)$@#*").valid) == false
            }

            it("should fail with nil") {
                expect(rule.evaluate(on: nil).valid) == false
            }

        }

        describe("consecutive repeats") {

            let rule = withPassword(havingMaxConsecutiveRepeats: 2)

            it("should allow string with no repeating count") {
                expect(rule.evaluate(on: "1234567890").valid) == true
            }

            it("should allow string with max repeating count") {
                expect(rule.evaluate(on: "12234567890").valid) == true
            }

            it("should fail with nil") {
                expect(rule.evaluate(on: nil).valid) == false
            }

            it("should detect repeating characters") {
                expect(rule.evaluate(on: "123455567890").valid) == false
            }

            it("should detect at least one repeating characters") {
                expect(rule.evaluate(on: "1222222345567890").valid) == false
            }

        }

        describe("at least rule") {

            let valid = MockRule(valid: true)
            let invalid = MockRule(valid: false)
            let password = "a password"

            it("should be valid for only one") {
                let rule = AtLeastRule(minimum: 1, rules: [valid])
                expect(rule.evaluate(on: password).valid) == true
            }

            it("should be valid when the minimum valid quote is reached") {
                let rule = AtLeastRule(minimum: 1, rules: [valid, invalid, invalid])
                expect(rule.evaluate(on: password).valid) == true
            }

            it("should be invalid when minimum of valid rules is not reached") {
                let rule = AtLeastRule(minimum: Int.max, rules: [valid, invalid, invalid])
                expect(rule.evaluate(on: password).valid) == false
            }

        }
    }

}

struct MockRule: Rule {
    let valid: Bool

    func evaluate(on password: String?) -> RuleResult {
        return SimpleRule.Result(valid: valid)
    }
}
