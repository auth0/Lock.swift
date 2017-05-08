// OnePasswordSpec.swift
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

class OnePasswordSpec: QuickSpec {

    override func spec() {

        var onePassword: OnePassword?
        var viewController: MockViewController?

        describe("init") {

            beforeEach {
                onePassword = nil
            }

            it("should init with defaults") {
                onePassword = OnePassword()
                expect(onePassword?.appIdentifier) == Bundle.main.bundleIdentifier!
                expect(onePassword?.displayName) == Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
                expect(onePassword?.enabled) == true
            }

            it("should not be available without 1password installed") {
                onePassword = OnePassword()
                expect(onePassword?.available) == false
            }
            
        }

        describe("action") {

            beforeEach {
                viewController = MockViewController()
                onePassword = OnePassword()
                onePassword?.controller = viewController
            }

            it("should present extension prompt on login") {
                onePassword?.login { _ in }
                expect(viewController?.presented).toNot(beNil())
            }


            it("should present extension prompt on store") {
                onePassword?.store(withPolicy: nil, identifier: "username") { _ in }
                expect(viewController?.presented).toNot(beNil())
            }
            
        }
    }
}
