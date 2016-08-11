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

            it("should build one button per connection") {
                expect(presenter.actions(forSignUp: true)).toNot(beEmpty())
            }

            it("should return view in Expanded mode") {
                expect((presenter.view as? AuthCollectionView)?.mode) == .Expanded
            }

            it("should set title") {
                let view = presenter.view as! AuthCollectionView
                view.buttons.forEach { expect($0.title).toNot(beNil()) }
            }
        }

        describe("newView") {

            it("should return view") {
                expect(presenter.newView(withInsets: UIEdgeInsetsZero, mode: .Expanded)).toNot(beNil())
            }

            it("should return view with correct mode") {
                expect(presenter.newView(withInsets: UIEdgeInsetsZero, mode: .Compact).mode) == AuthCollectionView.Mode.Compact
            }

            it("should build one button per connection") {
                expect(presenter.actions(forSignUp: true)).toNot(beEmpty())
            }

            it("should set title for login") {
                let view = presenter.newView(withInsets: UIEdgeInsetsZero, mode: .Expanded, showSignUp: false)
                view.buttons.forEach { expect($0.title).toNot(beNil()) }
            }

            it("should set title for signup") {
                let view = presenter.newView(withInsets: UIEdgeInsetsZero, mode: .Expanded, showSignUp: true)
                view.buttons.forEach { expect($0.title).toNot(beNil()) }
            }

        }

        describe("styling") {

            func styleButton(style: AuthStyle, signUp: Bool = false) -> AuthButton {
                var connections = OfflineConnections()
                connections.social(name: "social0", style: style)
                let presenter = AuthPresenter(connections: connections, interactor: interactor)
                let view = presenter.newView(withInsets: UIEdgeInsetsZero, mode: .Compact, showSignUp: signUp)
                return view.buttons.first!
            }

            it("should set proper title") {
                let button = styleButton(.Facebook)
                expect(button.title) == "LOG IN WITH FACEBOOK"
            }

            it("should set proper title") {
                let button = styleButton(.Facebook, signUp: true)
                expect(button.title) == "SIGN UP WITH FACEBOOK"
            }

            it("should set color") {
                let style = AuthStyle.Facebook
                let button = styleButton(style)
                expect(button.color) == style.color
            }

            it("should set icon") {
                let style = AuthStyle.Facebook
                let button = styleButton(style)
                expect(button.icon).toNot(beNil())
            }

        }

        describe("action") {

            var button: AuthButton!

            beforeEach {
                let view = presenter.view as! AuthCollectionView
                button = view.buttons.first!
            }

            it("should login with connection") {
                button.onPress(button)
                expect(interactor.connection) == "social0"
            }

            it("should hide current message on start") {
                button.onPress(button)
                expect(messagePresenter.message).toEventually(beNil())
            }

            it("should show error") {
                interactor.onLogin = { return .CouldNotAuthenticate }
                button.onPress(button)
                expect(messagePresenter.message).toEventually(equal("CouldNotAuthenticate"))
                expect(messagePresenter.success).toEventually(beFalse())
            }

        }
    }

}