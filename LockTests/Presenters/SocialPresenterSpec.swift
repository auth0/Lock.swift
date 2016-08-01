// SocialPresenterSpec.swift
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

class SocialPresenterSpec: QuickSpec {

    override func spec() {

        var presenter: SocialPresenter!

        beforeEach {
            var connections = OfflineConnections()
            connections.social(name: "social0", strategy: .Custom)
            connections.social(name: "social1", strategy: .Custom)
            connections.social(name: "social2", strategy: .Custom)
            connections.social(name: "social3", strategy: .Custom)
            presenter = SocialPresenter(connections: connections)
        }

        describe("view") {

            it("should return view") {
                expect(presenter.view as? SocialView).toNot(beNil())
            }

            it("should build one button per connection") {
                expect(presenter.actions).to(haveCount(4))
            }
        }

    }

}