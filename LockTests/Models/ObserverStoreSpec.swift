// ObserverStoreSpec.swift
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

import Auth0
@testable import Lock

class ObserverStoreSpec: QuickSpec {
    override func spec() {

        describe("Dispatcher") {

            var error: Error?
            var credentials: Credentials?
            var closed: Bool = false
            var dispatcher: ObserverStore!
            var newEmail: String?
            var newAttributes: [String: Any]?

            beforeEach {
                closed = false
                error = nil
                credentials = nil
                newEmail = nil
                newAttributes = nil
                var store = ObserverStore()
                store.onFailure = { error = $0 }
                store.onAuth = { credentials = $0 }
                store.onCancel = { closed = true }
                store.onSignUp = { newEmail = $0; newAttributes = $1 }
                store.onForgotPassword = { newEmail = $0 }
                store.onPasswordless = { newEmail = $0 }
                dispatcher = store
            }

            it("should dispatch errors") {
                dispatcher.dispatch(result: .error(UnrecoverableError.invalidClientOrDomain))
                expect(error).toEventuallyNot(beNil())
            }

            it("should dispatch credentials") {
                let value = mockCredentials()
                dispatcher.dispatch(result: .auth(value))
                expect(credentials).toEventually(equal(value))
            }

            it("should dispatch when lock is dismissed") {
                dispatcher.dispatch(result: .cancel)
                expect(closed).toEventually(beTrue())
            }

            it("should disptach when user signs up") {
                dispatcher.dispatch(result: .signUp(email, ["username": username]))
                expect(newEmail).toEventually(equal(email))
                expect(newAttributes?["username"] as? String).toEventually(equal(username))
            }

            it("should disptach when user requests password") {
                dispatcher.dispatch(result: .forgotPassword(email))
                expect(newEmail).toEventually(equal(email))
            }

            it("should disptach when user requests password") {
                dispatcher.dispatch(result: .passwordless(email))
                expect(newEmail).toEventually(equal(email))
            }


            // TODO: Check why it fails only in travis
            pending("controller displayed") {

                var controller: MockLockController!
                var presenter: MockController!

                beforeEach {
                    presenter = MockController()
                    controller = MockLockController(lock: Lock())
                    presenter.presented = controller
                    controller.presenting = presenter
                    dispatcher.controller = controller
                }

                it("should dismiss onAuth") {
                    let value = mockCredentials()
                    dispatcher.dispatch(result: .auth(value))
                    expect(presenter.presented).toEventually(beNil(), timeout: 2)
                }

                it("should not dismiss onAuth when autoclose disabled") {
                    let value = mockCredentials()
                    var options = LockOptions()
                    options.autoClose = false
                    dispatcher.options = options
                    dispatcher.dispatch(result: .auth(value))
                    expect(presenter.presented).toEventuallyNot(beNil(), timeout: 2)
                }

                it("should dismiss onCancel") {
                    dispatcher.dispatch(result: .cancel)
                    expect(presenter.presented).toEventually(beNil(), timeout: 2)
                }

                it("should not dismiss onSignUp") {
                    dispatcher.dispatch(result: .signUp(email, ["username": username]))
                    expect(newEmail).toEventually(equal(email))
                    expect(presenter.presented).toEventuallyNot(beNil(), timeout: 2)
                }

                it("should dismiss onSignUp when single screen") {
                    var options = LockOptions()
                    options.allow = [.Signup]
                    dispatcher.options = options
                    dispatcher.dispatch(result: .signUp(email, ["username": username]))
                    expect(newEmail).toEventually(equal(email))
                    expect(presenter.presented).toEventually(beNil(), timeout: 2)
                }

                it("should not dismiss onSignUp when single screen but autoclose disabled") {
                    var options = LockOptions()
                    options.allow = [.Signup]
                    options.autoClose = false
                    dispatcher.options = options
                    dispatcher.dispatch(result: .signUp(email, ["username": username]))
                    expect(newEmail).toEventually(equal(email))
                    expect(presenter.presented).toEventuallyNot(beNil(), timeout: 2)
                }

                it("should not dismiss forgotPassword") {
                    dispatcher.dispatch(result: .forgotPassword(email))
                    expect(presenter.presented).toEventuallyNot(beNil(), timeout: 2)
                }

                it("should dismiss forgotPassword when single screen") {
                    var options = LockOptions()
                    options.allow = [.ResetPassword]
                    dispatcher.options = options
                    dispatcher.dispatch(result: .forgotPassword(email))
                    expect(newEmail).toEventually(equal(email))
                    expect(presenter.presented).toEventually(beNil(), timeout: 2)
                }

                it("should not dismiss forgotPassword when single screen but autoclose disabled") {
                    var options = LockOptions()
                    options.allow = [.ResetPassword]
                    options.autoClose = false
                    dispatcher.options = options
                    dispatcher.dispatch(result: .forgotPassword(email))
                    expect(newEmail).toEventually(equal(email))
                    expect(presenter.presented).toEventuallyNot(beNil(), timeout: 2)
                }

                it("should not dismiss onPasswordless") {
                    dispatcher.dispatch(result: .passwordless(email))
                    expect(presenter.presented).toEventuallyNot(beNil(), timeout: 2)
                }

            }
        }
    }
}
