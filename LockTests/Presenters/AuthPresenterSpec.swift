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
        var nativeInteractor: MockNativeAuthInteractor!
        var nativeHandler: MockNativeAuthHandler!

        beforeEach {
            nativeInteractor = MockNativeAuthInteractor()
            nativeHandler = MockNativeAuthHandler()
            var connections = OfflineConnections()
            connections.social(name: "social0", style: AuthStyle(name: "custom"))
            connections.oauth2(name: "social1", style: AuthStyle(name: "custom"), handler: nativeHandler)
            interactor = MockOAuth2()
            messagePresenter = MockMessagePresenter()
            presenter = AuthPresenter(connections: connections, interactor: interactor, nativeInteractor: nativeInteractor,customStyle: [:])
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

        describe("embedded view") {

            it("should return view") {
                expect(presenter.newViewToEmbed(withInsets: UIEdgeInsets.zero)).toNot(beNil())
            }

            it("should return view with expanded mode for single connection") {
                let connections = OfflineConnections(databases: [], oauth2: mockConnections(count: 1), enterprise: [])
                presenter = AuthPresenter(connections: connections, interactor: interactor, nativeInteractor: nativeInteractor, customStyle: [:])
                expect(presenter.newViewToEmbed(withInsets: UIEdgeInsets.zero).mode).to(beExpandedMode())
            }

            it("should return view with expanded mode and signup flag") {
                let connections = OfflineConnections(databases: [], oauth2: mockConnections(count: 1), enterprise: [])
                presenter = AuthPresenter(connections: connections, interactor: interactor, nativeInteractor: nativeInteractor,customStyle: [:])
                expect(presenter.newViewToEmbed(withInsets: UIEdgeInsets.zero, isLogin: false).mode).to(beExpandedMode(isLogin: false))
            }

            it("should return view with expanded mode for two connections") {
                let connections = OfflineConnections(databases: [], oauth2: mockConnections(count: 2), enterprise: [])
                presenter = AuthPresenter(connections: connections, interactor: interactor, nativeInteractor: nativeInteractor,customStyle: [:])
                expect(presenter.newViewToEmbed(withInsets: UIEdgeInsets.zero).mode).to(beExpandedMode())
            }

            it("should return view with compact mode for more than three connecitons") {
                let connections = OfflineConnections(databases: [], oauth2: mockConnections(count: Int(arc4random_uniform(10)) + 3), enterprise: [])
                presenter = AuthPresenter(connections: connections, interactor: interactor, nativeInteractor: nativeInteractor,customStyle: [:])
                expect(presenter.newViewToEmbed(withInsets: UIEdgeInsets.zero).mode).to(beCompactMode())
            }

        }

        describe("action") {

            context("oauth2") {

                var view: AuthCollectionView!

                beforeEach {
                    view = presenter.view as! AuthCollectionView

                }

                it("should login with connection") {
                    view.onAction("social0", nil)
                    expect(interactor.connection) == "social0"
                }

                it("should hide current message on start") {
                    view.onAction("social0", nil)
                    expect(messagePresenter.message).toEventually(beNil())
                }

                it("should show error") {
                    interactor.onLogin = { return .couldNotAuthenticate }
                    view.onAction("social0", nil)
                    expect(messagePresenter.error).toEventually(beError(error: OAuth2AuthenticatableError.couldNotAuthenticate))
                }
            }

            context("native") {

                var view: AuthCollectionView!

                beforeEach {
                    view = presenter.view as! AuthCollectionView
                }

                it("should login with connection and handler") {
                    view.onAction("social1", nativeHandler)
                    expect(nativeInteractor.connection).to(equal("social1"))
                    expect(nativeInteractor.handler).toEventuallyNot(beNil())
                }

                it("should hide current message on start") {
                    view.onAction("social1", nativeHandler)
                    expect(messagePresenter.message).toEventually(beNil())
                }

                it("should show error") {
                    nativeInteractor.onLogin = { return NativeAuthenticatableError.nativeIssue }
                    view.onAction("social1", nativeHandler)
                    expect(messagePresenter.error).toEventually(beError(error: NativeAuthenticatableError.nativeIssue))
                }
            }

        }
    }

}
