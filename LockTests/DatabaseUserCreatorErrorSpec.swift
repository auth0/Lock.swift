// DatabaseUserCreatorErrorSpec.swift
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

class DatabaseUserCreatorErrorSpec: QuickSpec {

    override func spec() {

        describe("localised message response") {

            it(".passwordTooCommon should return relevant string") {
                let error = DatabaseUserCreatorError.passwordTooCommon
                expect(error.localizableMessage).to(contain("PASSWORD IS TOO COMMON"))
            }

            it(".passwordTooWeak should return relevant string") {
                let error = DatabaseUserCreatorError.passwordTooWeak
                expect(error.localizableMessage).to(contain("PASSWORD IS TOO WEAK."))
            }

            it(".passwordHasUserInfo should return relevant string") {
                let error = DatabaseUserCreatorError.passwordHasUserInfo
                expect(error.localizableMessage).to(contain("PASSWORD IS BASED ON USER INFORMATION"))
            }

            it(".passwordAlreadyUsed should return relevant string") {
                let error = DatabaseUserCreatorError.passwordAlreadyUsed
                expect(error.localizableMessage).to(contain("PASSWORD HAS PREVIOUSLY BEEN USED"))
            }

            it(".passwordInvalid should return relevant string") {
                let error = DatabaseUserCreatorError.passwordInvalid
                expect(error.localizableMessage).to(contain("PASSWORD IS INVALID."))
            }

            it(".nonValidInput should return default string") {
                let error = DatabaseUserCreatorError.nonValidInput
                expect(error.localizableMessage).to(contain("SOMETHING WENT WRONG"))
            }
			
            it(".userExists should return relevant string") {
                let error = DatabaseUserCreatorError.userExists
                expect(error.localizableMessage).to(contain("USER ALREADY EXISTS"))
            }
        }

        describe("user visibility") {

            it("should return false") {
                let error = DatabaseUserCreatorError.nonValidInput
                expect(error.userVisible).to(beFalse())
            }
            it("should return true (default)") {
                let error = DatabaseUserCreatorError.passwordTooCommon
                expect(error.userVisible).to(beTrue())
            }
        }

    }
}
