// RouterSpec.swift
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

import Nimble
import Quick
import Auth0

@testable import Lock

class RouterSpec: QuickSpec {

    override func spec() {

        var lock: Lock!
        var controller: MockLockController!

        beforeEach {
            lock = Lock(authentication: Auth0.authentication(clientId: "CLIENT_ID", domain: "samples.auth0.com"), webAuth: MockWebAuth())
            controller = MockLockController(lock: lock)
        }

        describe("router factory") {

            it("should return router classic") {
                let router = RouterFactory.router(with: .classic, lock: lock, controller: controller)
                expect(router as? RouterClassic).toNot(beNil())
            }

            it("should return router passwordless") {
                let router = RouterFactory.router(with: .passwordless, lock: lock, controller: controller)
                expect(router as? RouterPasswordless).toNot(beNil())
            }

        }
    }

}
