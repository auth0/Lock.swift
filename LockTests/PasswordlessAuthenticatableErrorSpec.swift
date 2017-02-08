// PasswordlessAuthenticatableErrorSpec.swift
//
// Copyright (c) 2017 Auth0 (http://auth0.com)
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

class PasswordlessAuthenticatableErrorSpec: QuickSpec {

    override func spec() {

        describe("localised message response") {

            it("should return default string for invalid input") {
                let error = PasswordlessAuthenticatableError.nonValidInput
                expect(error.localizableMessage).to(contain("SOMETHING WENT WRONG"))
            }

            it("should return default string for code not sent") {
                let error = PasswordlessAuthenticatableError.codeNotSent
                expect(error.localizableMessage).to(contain("SOMETHING WENT WRONG"))
            }

            it("should return specific string for invalid limnk") {
                let error = PasswordlessAuthenticatableError.invalidLink
                expect(error.localizableMessage).to(contain("PROBLEM WITH YOUR LINK"))
            }

            it("should return specific string for no signup") {
                let error = PasswordlessAuthenticatableError.noSignup
                expect(error.localizableMessage).to(contain("DISABLED FOR THIS ACCOUNT"))
            }

        }

        describe("user visibility") {

            it("should return false") {
                let error = PasswordlessAuthenticatableError.nonValidInput
                expect(error.userVisible).to(beFalse())
            }
        }
        
    }
}
