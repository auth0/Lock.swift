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
        var router: Router!

        beforeEach {
            lock = Lock(authentication: Auth0.authentication(clientId: "CLIENT_ID", domain: "samples.auth0.com"), webAuth: MockWebAuth())
            lock.withConnections { $0.database(name: "connection", requiresUsername: false) }
            controller = MockLockController(lock: lock)
            router = Router(lock: lock, controller: controller)
        }

        describe("root") {

            beforeEach {
                lock = Lock(authentication: Auth0.authentication(clientId: "CLIENT_ID", domain: "samples.auth0.com"), webAuth: MockWebAuth())
                controller = MockLockController(lock: lock)
                router = Router(lock: lock, controller: controller)
            }

            it("should return root for single database connection") {
                lock.withConnections { $0.database(name: connection, requiresUsername: true) }
                let root = router.root as? DatabasePresenter
                expect(root).toNot(beNil())
                expect(root?.authPresenter).to(beNil())
            }

            it("should return root for single database connection and social") {
                lock.withConnections {
                    $0.database(name: connection, requiresUsername: true)
                    $0.social(name: "facebook", style: .Facebook)
                }
                let root = router.root as? DatabasePresenter
                expect(root).toNot(beNil())
                expect(root?.authPresenter).toNot(beNil())
            }

            it("should return root for only social connections") {
                lock.withConnections { $0.social(name: "dropbox", style: AuthStyle(name: "Dropbox")) }
                expect(router.root as? AuthPresenter).toNot(beNil())
            }

            it("should return root for loading connection from CDN") {
                expect(router.root as? ConnectionLoadingPresenter).toNot(beNil())
            }

        }

        describe("events") {

            it("should call callback with auth result") {
                controller.presenting = MockController()
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

            describe("exit") {

                var presenting: MockController!

                beforeEach {
                    presenting = MockController()
                    presenting.presented = controller
                    controller.presenting = presenting
                }

                it("should dismiss controller") {
                    router.exit(withError: UnrecoverableError.InvalidClientOrDomain)
                    expect(presenting.presented).toEventually(beNil())
                }

                it("should pass error in callback") {
                    waitUntil(timeout: 2) { done in
                        lock.callback = { result in
                            if case .Failure(let cause) = result, case UnrecoverableError.InvalidClientOrDomain = cause {
                                done()
                            }
                        }
                        router.exit(withError: UnrecoverableError.InvalidClientOrDomain)
                    }
                }
            }
        }

        describe("navigate") {
            it("should not show root again") {
                expect(controller.routes.current).toNot(beNil())
                router.navigate(.Root)
                expect(controller.presentable).to(beNil())
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

        it("should present view controller") {
            let presented = UIViewController()
            router.present(presented)
            expect(controller.presented) == presented
        }

        describe("reload") {

            beforeEach {
                let presenting = MockController()
                presenting.presented = controller
                controller.presenting = presenting
            }

            it("should override connections") {
                var connections = OfflineConnections()
                connections.social(name: "facebook", style: .Facebook)
                router.reload(withConnections: connections)
                let actual = router.lock.connectionProvider.connections
                expect(actual.isEmpty) == false
                expect(actual.oauth2.map { $0.name }).to(contain("facebook"))
            }

            it("should show root") {
                var connections = OfflineConnections()
                connections.social(name: "facebook", style: .Facebook)
                router.reload(withConnections: connections)
                expect(controller.presentable).toNot(beNil())
                expect(controller.routes.history).to(beEmpty())
            }

            it("should select when overriding connections") {
                lock = Lock(authentication: Auth0.authentication(clientId: "CLIENT_ID", domain: "samples.auth0.com"), webAuth: MockWebAuth()).allowedConnections(["facebook"])
                controller = MockLockController(lock: lock)
                router = Router(lock: lock, controller: controller)
                var connections = OfflineConnections()
                connections.social(name: "facebook", style: .Facebook)
                connections.social(name: "twitter", style: .Twitter)
                router.reload(withConnections: connections)
                let actual = router.lock.connectionProvider.connections
                expect(actual.oauth2.map { $0.name }).toNot(contain("twitter"))
                expect(actual.oauth2.map { $0.name }).to(contain("facebook"))
            }

            it("should exit with error when connections are empty") {
                waitUntil(timeout: 2) { done in
                    lock.callback = { result in
                        if case .Failure(let cause) = result, case UnrecoverableError.ClientWithNoConnections = cause {
                            done()
                        }
                    }
                    router.reload(withConnections: OfflineConnections())
                }
            }

        }
    }

}