// AuthPresenterSpec.swift
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

class AuthPresenterSpec: QuickSpec {

    override func spec() {

        var presenter: AuthPresenter!
        var interactor: MockOAuth2!
        var messagePresenter: MockMessagePresenter!

        beforeEach {
            var connections = OfflineConnections()
            connections.social(name: "social0", style: AuthStyle(name: "custom"))
            interactor = MockOAuth2()
            messagePresenter = MockMessagePresenter()
            presenter = AuthPresenter(connections: connections, interactor: interactor)
            presenter.messagePresenter = messagePresenter
        }

        describe("view") {

            it("should return view") {
                expect(presenter.view as? AuthCollectionView).toNot(beNil())
            }

            it("should return view in Expanded mode") {
                expect((presenter.view as? AuthCollectionView)?.mode).to(beExpandedMode())
            }

        }

        describe("newView") {

            it("should return view") {
                expect(presenter.newView(withInsets: UIEdgeInsetsZero, mode: .Expanded(isLogin: true))).toNot(beNil())
            }

            it("should return view with correct mode") {
                expect(presenter.newView(withInsets: UIEdgeInsetsZero, mode: .Compact).mode).to(beCompactMode())
            }

        }

        describe("action") {

            var view: AuthCollectionView!

            beforeEach {
                view = presenter.view as! AuthCollectionView

            }

            it("should login with connection") {
                view.onAction("social0")
                expect(interactor.connection) == "social0"
            }

            it("should hide current message on start") {
                view.onAction("social0")
                expect(messagePresenter.message).toEventually(beNil())
            }

            it("should show error") {
                interactor.onLogin = { return .CouldNotAuthenticate }
                view.onAction("social0")
                expect(messagePresenter.message).toEventually(equal("CouldNotAuthenticate"))
                expect(messagePresenter.success).toEventually(beFalse())
            }

        }
    }

}