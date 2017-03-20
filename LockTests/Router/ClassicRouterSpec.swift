// ClassicRouterSpec.swift
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

class ClassicRouterSpec: QuickSpec {

    override func spec() {

        var lock: Lock!
        var controller: MockLockController!
        var router: ClassicRouter!
        var header: HeaderView!

        beforeEach {
            lock = Lock(authentication: Auth0.authentication(clientId: "CLIENT_ID", domain: "samples.auth0.com"), webAuth: MockWebAuth())
            _ = lock.withConnections { $0.database(name: "connection", requiresUsername: false) }
            controller = MockLockController(lock: lock)
            header = HeaderView()
            controller.headerView = header
            router = ClassicRouter(lock: lock, controller: controller)
        }

        describe("root") {

            beforeEach {
                lock = Lock(authentication: Auth0.authentication(clientId: "CLIENT_ID", domain: "samples.auth0.com"), webAuth: MockWebAuth())
                controller = MockLockController(lock: lock)
                router = ClassicRouter(lock: lock, controller: controller)
            }

            it("should be in classic mode") {
                expect(lock.classicMode) == true
            }

            it("should return root for single database connection") {
                _ = lock.withConnections { $0.database(name: connection, requiresUsername: true) }
                let root = router.root as? DatabasePresenter
                expect(root).toNot(beNil())
                expect(root?.authPresenter).to(beNil())
            }

            it("should return root for single database connection and social") {
                _ = lock.withConnections {
                    $0.database(name: connection, requiresUsername: true)
                    $0.social(name: "facebook", style: .Facebook)
                }
                let root = router.root as? DatabasePresenter
                expect(root).toNot(beNil())
                expect(root?.authPresenter).toNot(beNil())
            }

            it("should return root for single database connection and social and enterprise") {
                _ = lock.withConnections {
                    $0.database(name: connection, requiresUsername: true)
                    $0.social(name: "facebook", style: .Facebook)
                    $0.enterprise(name: "testAD", domains: ["testAD.com"])
                }
                let root = router.root as? DatabasePresenter
                expect(root).toNot(beNil())
                expect(root?.authPresenter).toNot(beNil())
                expect(root?.enterpriseInteractor).toNot(beNil())
            }

            it("should return root for single enterprise and social") {
                _ = lock.withConnections {
                    $0.social(name: "facebook", style: .Facebook)
                    $0.enterprise(name: "testAD", domains: ["testAD.com"])
                }
                let root = router.root as? AuthPresenter
                expect(root).toNot(beNil())
            }

            it("should return root for only social connections") {
                _ = lock.withConnections { $0.social(name: "dropbox", style: AuthStyle(name: "Dropbox")) }
                expect(router.root as? AuthPresenter).toNot(beNil())
            }

            it("should return root for only enterprise connections") {
                _ = lock.withConnections {
                    $0.enterprise(name: "testAD", domains: ["testAD.com"])
                    $0.enterprise(name: "validAD", domains: ["validAD.com"])
                }
                expect(router.root as? EnterpriseDomainPresenter).toNot(beNil())
            }

            it("should return root for one enterprise") {
                _ = lock.withConnections {
                    $0.enterprise(name: "testAD", domains: ["testAD.com"])
                }
                expect(router.root as? AuthPresenter).toNot(beNil())
            }

            it("should return root for one enterprise with active auth") {
                _ = lock.withConnections {
                    $0.enterprise(name: "testAD", domains: ["testAD.com"])
                    }.withOptions { $0.enterpriseConnectionUsingActiveAuth = ["testAD"] }
                expect(router.root as? EnterpriseActiveAuthPresenter).toNot(beNil())
            }

            it("should return root for loading connection from CDN") {
                expect(router.root as? ConnectionLoadingPresenter).toNot(beNil())
            }

            it("should return root when only reset password is allowed and there is a database connection") {
                _ = lock
                    .withConnections { $0.database(name: connection, requiresUsername: false) }
                    .withOptions { $0.allow = [.ResetPassword] }
                expect(router.root as? DatabaseForgotPasswordPresenter).toNot(beNil())
            }

            it("should return root when reset password is the initial screen and there is a database connection") {
                _ = lock
                    .withConnections { $0.database(name: connection, requiresUsername: false) }
                    .withOptions { $0.allow = [.ResetPassword] }
                expect(router.root as? DatabaseForgotPasswordPresenter).toNot(beNil())
            }

            it("should return root for single native social") {
                _ = lock.withConnections {
                    $0.social(name: "facebook", style: .Facebook)
                }.nativeAuthentication(forConnection: "facebook", handler: MockNativeAuthHandler())
                expect(router.root as? AuthPresenter).toNot(beNil())
            }

            describe("passwordless") {

                it("should not return root for passwordless email connection") {
                    _ = lock.withConnections {
                        $0.passwordless(name: "custom-email", strategy: "email")
                    }
                    let presenter = router.root as? PasswordlessPresenter
                    expect(presenter).to(beNil())
                }

                it("should not return root for passwordless sms connection") {
                    _ = lock.withConnections {
                        $0.passwordless(name: "custom-sms", strategy: "sms")
                    }
                    let presenter = router.root as? PasswordlessPresenter
                    expect(presenter).to(beNil())
                }
            }
        }

        describe("events") {

            describe("back") {

                beforeEach {
                    router.navigate(.multifactor)
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

            it("should set title for root") {
                router.navigate(.forgotPassword)
                router.navigate(.root)
                expect(controller.headerView.title) == Style.Auth0.title
            }

            it("should not show root again") {
                expect(controller.routes.current).toNot(beNil())
                router.navigate(.root)
                expect(controller.presentable).to(beNil())
            }

            it("should show forgot pwd screen") {
                router.navigate(.forgotPassword)
                expect(controller.presentable as? DatabaseForgotPasswordPresenter).toNot(beNil())
                expect(controller.headerView.title) == "Reset Password"
            }

            it("should show multifactor screen") {
                router.navigate(.multifactor)
                expect(controller.presentable as? MultifactorPresenter).toNot(beNil())
                expect(controller.headerView.title) == "Two Step Verification"
            }

            it("should show enterprise active auth screen") {
                router.navigate(.enterpriseActiveAuth(connection: EnterpriseConnection(name: "testAD", domains: ["testad.com"]), domain: "testad.com"))
                expect(controller.presentable as? EnterpriseActiveAuthPresenter).toNot(beNil())
                expect(controller.headerView.title) == Style.Auth0.title
            }

            it("should show connection error screen") {
                router.navigate(.unrecoverableError(error: UnrecoverableError.connectionTimeout))
                expect(controller.presentable as? UnrecoverableErrorPresenter).toNot(beNil())
            }

            context("no connection") {
                beforeEach {
                    lock = Lock(authentication: Auth0.authentication(clientId: "CLIENT_ID", domain: "samples.auth0.com"), webAuth: MockWebAuth())
                    controller = MockLockController(lock: lock)
                    controller.headerView = header
                    router = ClassicRouter(lock: lock, controller: controller)
                }

                it("should fail multifactor screen") {
                    router.navigate(.multifactor)
                    expect(controller.presentable).to(beNil())
                }

                it("should fail forgotPassword screen") {
                    router.navigate(.forgotPassword)
                    expect(controller.presentable).to(beNil())
                }
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
                connections.social(name: "facebook", style: .Facebook)
                router.reload(with: connections)
                let actual = router.lock.connections
                expect(actual.isEmpty) == false
                expect(actual.oauth2.map { $0.name }).to(contain("facebook"))
            }

            it("should show root") {
                var connections = OfflineConnections()
                connections.social(name: "facebook", style: .Facebook)
                router.reload(with: connections)
                expect(controller.presentable).toNot(beNil())
                expect(controller.routes.history).to(beEmpty())
            }

            it("should select when overriding connections") {
                lock = Lock(authentication: Auth0.authentication(clientId: "CLIENT_ID", domain: "samples.auth0.com"), webAuth: MockWebAuth()).allowedConnections(["facebook"])
                controller = MockLockController(lock: lock)
                controller.headerView = header
                router = ClassicRouter(lock: lock, controller: controller)
                var connections = OfflineConnections()
                connections.social(name: "facebook", style: .Facebook)
                connections.social(name: "twitter", style: .Twitter)
                router.reload(with: connections)
                let actual = router.lock.connections
                expect(actual.oauth2.map { $0.name }).toNot(contain("twitter"))
                expect(actual.oauth2.map { $0.name }).to(contain("facebook"))
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

            it("Multifactor should should be equatable with Multifactor") {
                let match = Route.multifactor == Route.multifactor
                expect(match).to(beTrue())
            }

            it("ForgotPassword should should be equatable with ForgotPassword") {
                let match = Route.forgotPassword == Route.forgotPassword
                expect(match).to(beTrue())
            }

            it("EnterpriseActiveAuth should should be equatable with EnterpriseActiveAuth") {
                let enterpriseConnection = EnterpriseConnection(name: "TestAD", domains: ["test.com"])
                let match = Route.enterpriseActiveAuth(connection: enterpriseConnection, domain: "test.com") == Route.enterpriseActiveAuth(connection: enterpriseConnection, domain: "test.com")
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
