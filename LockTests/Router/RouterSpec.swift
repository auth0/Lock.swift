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
        var controller: MockController!
        var router: Router!

        beforeEach {
            lock = Lock(authentication: Auth0.authentication(clientId: "CLIENT_ID", domain: "samples.auth0.com"))
            var connections = OfflineConnections()
            lock.connections = connections.database(name: "connection", requiresUsername: false)
            controller = MockController(lock: Lock(authentication: Auth0.authentication(clientId: "CLIENT_ID", domain: "samples.auth0.con")))
            router = Router(lock: lock, controller: controller)
        }

        describe("root") {

            it("should return no root if there are no connections") {
                lock.connections = nil
                expect(router.root).to(beNil())
            }

            it("should return root for single database connection") {
                var connections: ConnectionBuildable = OfflineConnections()
                connections.database(name: connection, requiresUsername: true)
                lock.connections = connections
                expect(router.root).toNot(beNil())
            }

        }

        describe("events") {

            it("should call callback with auth result") {
                let credentials = Credentials(accessToken: "ACCESS_TOKEN", tokenType: "bearer")
                waitUntil(timeout: 2) { done in
                    lock.callback = { result in
                        if case .Success(let actual) = result {
                            expect(actual) == credentials
                            done()
                        }
                    }
                    router.onAuthentication(credentials)
                }
            }

            describe("back") {

                beforeEach {
                    router.navigate(.Multifactor)
                }

                it("should navigate back to root") {
                    router.onBack()
                    expect(controller.routes.current) == Route.Root
                }

                it("should clean user email") {
                    router.user.email = email
                    router.onBack()
                    expect(router.user.email).to(beNil())
                }

                it("should clean user username") {
                    router.user.username = username
                    router.onBack()
                    expect(router.user.username).to(beNil())
                }

                it("should clean user password") {
                    router.user.password = password
                    router.onBack()
                    expect(router.user.password).to(beNil())
                }

                it("should not clean valid user email") {
                    router.user.email = email
                    router.user.validEmail = true
                    router.onBack()
                    expect(router.user.email) == email
                }

                it("should not clean valid user username") {
                    router.user.username = username
                    router.user.validUsername = true
                    router.onBack()
                    expect(router.user.username) == username
                }

                it("should always clean user password") {
                    router.user.password = password
                    router.user.validPassword = true
                    router.onBack()
                    expect(router.user.password).to(beNil())
                }

            }
        }

        it("should show forgot pwd screen") {
            router.navigate(.ForgotPassword)
            expect(controller.presentable as? DatabaseForgotPasswordPresenter).toNot(beNil())
        }

        it("should show multifactor screen") {
            router.navigate(.Multifactor)
            expect(controller.presentable as? MultifactorPresenter).toNot(beNil())
        }
    }

}

class MockController: LockViewController {

    var presentable: Presentable?

    override func dismissViewControllerAnimated(flag: Bool, completion: (() -> Void)?) {
        completion?()
    }

    override func present(presentable: Presentable?) {
        self.presentable = presentable
    }
}