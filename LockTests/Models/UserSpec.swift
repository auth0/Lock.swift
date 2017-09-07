// UserSpec.swift
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

class UserSpec: QuickSpec {

    override func spec() {

        var user: User!

        beforeEach {
            user = User()
        }

        describe("identifier") {
            beforeEach {
                user.email = email
                user.username = username
            }

            it("should return valid email") {
                user.validUsername = false
                user.validEmail = true
                expect(user.identifier) == email
            }

            it("should always return valid email") {
                user.validUsername = true
                user.validEmail = true
                expect(user.identifier) == email
            }

            it("should return valid username") {
                user.validUsername = true
                user.validEmail = false
                expect(user.identifier) == username
            }

        }

        describe("reset") {

            it("should clear invalid email") {
                user.email = email
                user.validEmail = false
                user.reset()
                expect(user.email).to(beNil())
            }

            it("should clear invalid username") {
                user.username = username
                user.validUsername = false
                user.reset()
                expect(user.username).to(beNil())
            }

            it("should clear password") {
                user.password = password
                user.validUsername = false
                user.reset()
                expect(user.username).to(beNil())
            }

            it("should not clear email") {
                user.email = email
                user.validEmail = true
                user.reset()
                expect(user.email) == email
            }

            it("should not clear username") {
                user.username = username
                user.validUsername = true
                user.reset()
                expect(user.username) == username
            }

            it("should always clear password") {
                user.password = password
                user.validUsername = true
                user.reset()
                expect(user.username).to(beNil())
            }

            it("should clear additional attributes") {
                user.additionalAttributes["first_name"] = "John"
                user.additionalAttributesStatus["first_name"] = true
                user.reset()
                expect(user.additionalAttributes["first_name"]).to(beNil())
            }
        }

        describe("additional attributes") {

            it("should return nil by default") {
                expect(user.additionalAttributes["attr"]).to(beNil())
            }

            it("should return non valid as default") {
                expect(user.validAdditionalAttribute("attr")) == false
            }

            it("should update attribute status") {
                user.validAdditionalAttribute("attr", valid: true)
                expect(user.validAdditionalAttribute("attr")) == true
            }

        }
    }

}
