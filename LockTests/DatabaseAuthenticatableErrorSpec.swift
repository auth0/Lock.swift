// CredentialAuthErrorSpec.swift
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

class CredentialAuthErrorSpec: QuickSpec {

    override func spec() {

        describe("localised message response") {

            it(".userBlocked should return relevant string") {
                let error = CredentialAuthError.userBlocked
                expect(error.localizableMessage).to(contain("The user is blocked"))
            }

            it(".invalidEmailPassword should return relevant string") {
                let error = CredentialAuthError.invalidEmailPassword
                expect(error.localizableMessage).to(contain("Wrong credentials"))
            }

            it(".passwordChangeRequired should return relevant string") {
                let error = CredentialAuthError.passwordChangeRequired
                expect(error.localizableMessage).to(contain("You need to update your password"))
            }

            it(".passwordLeaked should return relevant string") {
                let error = CredentialAuthError.passwordLeaked
                expect(error.localizableMessage).to(contain("This login has been blocked"))
            }

            it(".tooManyAttempts should return relevant string") {
                let error = CredentialAuthError.tooManyAttempts
                expect(error.localizableMessage).to(contain("Your account has been blocked"))
            }

            it(".multifactorInvalid should return relevant string") {
                let error = CredentialAuthError.multifactorInvalid
                expect(error.localizableMessage).to(contain("Wrong code."))
            }

            it(".nonValidInput should return generic string") {
                let error = CredentialAuthError.nonValidInput
                expect(error.localizableMessage).to(contain("something went wrong"))
            }

        }

        describe("user visibility") {

            it("should return false") {
                let error = CredentialAuthError.multifactorRequired
                expect(error.userVisible).to(beFalse())
            }

            it("should return false") {
                let error = CredentialAuthError.nonValidInput
                expect(error.userVisible).to(beFalse())
            }

            it("should return true") {
                let error = CredentialAuthError.invalidEmailPassword
                expect(error.userVisible).to(beTrue())
            }
        }
        
    }
}
