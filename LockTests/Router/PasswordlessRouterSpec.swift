// PasswordlessRouterSpec.swift
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

import Nimble
import Quick
import Auth0

@testable import Lock

class PasswordlessRouterSpec: QuickSpec {

    override func spec() {

        var lock: Lock!
        var controller: MockLockController!
        var router: PasswordlessRouter!
        var header: HeaderView!

        beforeEach {
            lock = Lock(authentication: Auth0.authentication(clientId: "CLIENT_ID", domain: "samples.auth0.com"), webAuth: MockWebAuth(), classic: false)
            _ = lock.withConnections { $0.passwordless(name: "custom-email", strategy: "email") }
            controller = MockLockController(lock: lock)
            header = HeaderView()
            controller.headerView = header
            router = PasswordlessRouter(lock: lock, controller: controller)
        }

        describe("root") {

            it("should not be in classic mode") {
                expect(lock.classicMode) == false
            }

            it("should return root for passwordless email connection") {
                _ = lock.withConnections {
                    $0.passwordless(name: "custom-email", strategy: "email")
                }
                let presenter = router.root as? PasswordlessPresenter
                expect(presenter).toNot(beNil())
            }

            it("should return root for passwordless sms connection") {
                _ = lock.withConnections {
                    $0.passwordless(name: "custom-sms", strategy: "sms")
                }
                let presenter = router.root as? PasswordlessPresenter
                expect(presenter).toNot(beNil())
            }

            it("should return for only social connections") {
                _ = lock.withConnections {
                    $0.social(name: "facebook", style: .Facebook)
                }
                let presenter = router.root as? AuthPresenter
                expect(presenter).toNot(beNil())
            }

            it("should return root for social connections and passwordless email") {
                _ = lock.withConnections {
                    $0.social(name: "facebook", style: .Facebook)
                    $0.passwordless(name: "custom-email", strategy: "email")
                }
                let presenter = router.root as? PasswordlessPresenter
                expect(presenter).toNot(beNil())
                expect(presenter?.authPresenter).toNot(beNil())
            }

            it("should return root for social connections and passwordless sms") {
                _ = lock.withConnections {
                    $0.social(name: "facebook", style: .Facebook)
                    $0.passwordless(name: "custom-sms", strategy: "sms")
                }
                let presenter = router.root as? PasswordlessPresenter
                expect(presenter).toNot(beNil())
            }

            describe("classic") {

                it("should not return root for single database connection") {
                    _ = lock.withConnections { $0.database(name: connection, requiresUsername: true) }
                    let root = router.root as? DatabasePresenter
                    expect(root).to(beNil())
                }

                it("should not return root for only enterprise connections") {
                    _ = lock.withConnections {
                        $0.enterprise(name: "testAD", domains: ["testAD.com"])
                        $0.enterprise(name: "validAD", domains: ["validAD.com"])
                    }
                    expect(router.root as? EnterpriseDomainPresenter).to(beNil())
                }


            }
        }

        describe("events") {

            describe("back") {

                beforeEach {
                    router.navigate(.passwordless(screen: .request, connection: PasswordlessConnection(name: "custom-email", strategy: "email")))
                }

                it("should navigate back to root") {
                    router.onBack()
                    expect(controller.routes.current) == Route.root
                }

                it("should clean user email") {
                    router.user.email = email
                    router.onBack()
                    expect(router.user.email).to(beNil())
                }


                it("should not clean valid user email") {
                    router.user.email = email
                    router.user.validEmail = true
                    router.onBack()
                    expect(router.user.email) == email
                }

            }

            describe("exit") {

                var presenting: MockViewController!

                beforeEach {
                    presenting = MockViewController()
                    presenting.presented = controller
                    controller.presenting = presenting
                }

                it("should dismiss controller") {
                    router.exit(withError: UnrecoverableError.invalidClientOrDomain)
                    expect(presenting.presented).toEventually(beNil())
                }

                it("should pass error in callback") {
                    waitUntil(timeout: 2) { done in
                        lock.observerStore.onFailure = { cause in
                            if  case UnrecoverableError.invalidClientOrDomain = cause {
                                done()
                            }
                        }
                        router.exit(withError: UnrecoverableError.invalidClientOrDomain)
                    }
                }
            }
        }

        describe("navigate") {

            it("should not show root again") {
                expect(controller.routes.current).toNot(beNil())
                router.navigate(.root)
                expect(controller.presentable).to(beNil())
            }

            it("should show connection error screen") {
                router.navigate(.unrecoverableError(error: UnrecoverableError.connectionTimeout))
                expect(controller.presentable as? UnrecoverableErrorPresenter).toNot(beNil())
            }

        }

        it("should present view controller") {
            let presented = UIViewController()
            router.present(presented)
            expect(controller.presented) == presented
        }

        describe("reload") {

            beforeEach {
                let presenting = MockViewController()
                presenting.presented = controller
                controller.presenting = presenting
            }

            it("should override connections") {
                var connections = OfflineConnections()
                connections.passwordless(name: "custom-email", strategy: "email")
                router.reload(with: connections)
                let actual = router.lock.connections
                expect(actual.isEmpty) == false
                expect(actual.passwordless.map { $0.name }).to(contain("custom-email"))
            }

            it("should show root") {
                var connections = OfflineConnections()
                connections.passwordless(name: "custom-email", strategy: "email")
                router.reload(with: connections)
                expect(controller.presentable).toNot(beNil())
                expect(controller.routes.history).to(beEmpty())
            }

            it("should select when overriding connections") {
                lock = Lock(authentication: Auth0.authentication(clientId: "CLIENT_ID", domain: "samples.auth0.com"), webAuth: MockWebAuth(), classic: false).allowedConnections(["custom-email"])
                controller = MockLockController(lock: lock)
                controller.headerView = header
                router = PasswordlessRouter(lock: lock, controller: controller)
                var connections = OfflineConnections()
                connections.passwordless(name: "custom-email", strategy: "email")
                connections.passwordless(name: "custom-sms", strategy: "sms")
                router.reload(with: connections)
                let actual = router.lock.connections
                expect(actual.passwordless.map { $0.name }).toNot(contain("sms"))
                expect(actual.passwordless.map { $0.name }).to(contain("custom-email"))
            }

            it("should exit with error when connections are empty") {
                waitUntil(timeout: 2) { done in
                    lock.observerStore.onFailure = { cause in
                        if case UnrecoverableError.clientWithNoConnections = cause {
                            done()
                        }
                    }
                    router.reload(with: OfflineConnections())
                }
            }

        }

        describe("route equatable") {

            it("root should should be equatable with root") {
                let match = Route.root == Route.root
                expect(match).to(beTrue())
            }

            it("PasswordlessConnection should should be equatable with PasswordlessConnection") {
                let passwordlessConnection = PasswordlessConnection(name: "custom-email", strategy: "email")
                let match = Route.passwordless(screen: .code, connection: passwordlessConnection) ==  Route.passwordless(screen: .code, connection: passwordlessConnection)
                expect(match).to(beTrue())
            }

            it("UnrecoverableError should should be equatable with UnrecoverableError") {
                let error = UnrecoverableError.connectionTimeout
                let match = Route.unrecoverableError(error: error) == Route.unrecoverableError(error: error)
                expect(match).to(beTrue())
            }
            
            it("root should should not be equatable with Multifactor") {
                let match = Route.root == Route.multifactor
                expect(match).to(beFalse())
            }
            
        }
    }
    
}
