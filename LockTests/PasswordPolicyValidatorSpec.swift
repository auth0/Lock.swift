 // PasswordPolicyValidatorSpec.swift
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

class PasswordPolicyValidatorSpec: QuickSpec {
    
    override func spec() {

        it("should return no error when password is allowed by policy") {
            let policy = passingPolicy(withConditionCount: 1)
            let validator = PasswordPolicyValidator(policy: policy)
            expect(validator.validate(password)).to(beNil())
        }

        it("should return no error when password is allowed by policy") {
            let policy = failingPolicy(withConditionCount: 1)
            let validator = PasswordPolicyValidator(policy: policy)
            expect(validator.validate(password)).toNot(beNil())
        }

        it("should return policy output on error") {
            let policy = failingPolicy(withConditionCount: 1)
            let validator = PasswordPolicyValidator(policy: policy)
            let error = validator.validate(password) as? InputValidationError
            expect(error).toNot(beNil())
            if case .passwordPolicyViolation(let result) = error! {
                expect(result.first?.valid) == false
                expect(result.first?.message) == "MOCK"
            } else {
                fail("Invalid error. Expected PasswordPolicyViolation")
            }
        }

        it("should return all policy output on error") {
            let policy = failingPolicy(withConditionCount: 2)
            let validator = PasswordPolicyValidator(policy: policy)
            let error = validator.validate(password) as? InputValidationError
            expect(error).toNot(beNil())
            if case .passwordPolicyViolation(let result) = error! {
                expect(result).to(haveCount(2))
            } else {
                fail("Invalid error. Expected PasswordPolicyViolation")
            }
        }
    }
}

private func failingPolicy(withConditionCount count: Int) -> PasswordPolicy {
    var rules: [Rule] = []
    (1...count).forEach { _ in rules.append(MockRule(valid: false)) }
    return PasswordPolicy(name: "custom", rules: rules)
}

private func passingPolicy(withConditionCount count: Int) -> PasswordPolicy {
    var rules: [Rule] = []
    (1...count).forEach { _ in rules.append(MockRule(valid: true)) }
    return PasswordPolicy(name: "custom", rules: rules)
}
