// EnterpriseDomainInteractorSpec.swift
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
import OHHTTPStubs
import Auth0

@testable import Lock

class EnterpriseDomainInteractorSpec: QuickSpec {
    override func spec() {

        let authentication = MockAuthentication(clientId: clientId, domain: domain)

        var authInteractor: Auth0OAuth2Interactor!
        var credentials: Credentials?
        var connections: OfflineConnections!
        var enterprise: EnterpriseDomainInteractor!
        var user: User!

        beforeEach {
            user = User()
            connections = OfflineConnections()
            connections.enterprise(name: "TestAD", domains: ["test.com"])
            connections.enterprise(name: "validAD", domains: ["valid.com"])
            credentials = nil
            var dispatcher = ObserverStore()
            dispatcher.onAuth = {credentials = $0}
            authInteractor = Auth0OAuth2Interactor(authentication: authentication, dispatcher: dispatcher, options: LockOptions(), nativeHandlers: [:])
            enterprise = EnterpriseDomainInteractor(connections: connections, user: user, authentication: authInteractor)
        }

        afterEach {
            Auth0Stubs.cleanAll()
            Auth0Stubs.failUnknown()
        }

        describe("init") {

            it("should have an entperise object") {
                expect(enterprise).toNot(beNil())
            }

            it("connection should be nil") {
                expect(enterprise.connection).to(beNil())
            }

            context("connection with single enterprise conection") {

                beforeEach {
                    connections = OfflineConnections()
                    connections.enterprise(name: "TestAD", domains: [])

                    enterprise = EnterpriseDomainInteractor(connections: connections, user: user, authentication: authInteractor)
                }

                it("connection should not default to single connection") {
                    expect(enterprise.connection).toNot(beNil())
                }

            }

        }

        describe("updateEmail") {

            context("connection with no domain") {

                beforeEach {
                    connections = OfflineConnections()
                    connections.enterprise(name: "TestAD", domains: [])
                    enterprise = EnterpriseDomainInteractor(connections: connections, user: user, authentication: authInteractor)
                }

                it("should raise no error but no connection provided") {
                    expect{ try enterprise.updateEmail("user@domainnotmatched.com") }.toNot(throwError())
                    expect(enterprise.connection).to(beNil())
                }

            }

            context("connection with one domain") {

                beforeEach {
                    connections = OfflineConnections()
                    connections.enterprise(name: "TestAD", domains: ["test.com"])
                    enterprise = EnterpriseDomainInteractor(connections: connections, user: user, authentication: authInteractor)
                }

                it("should match email domain") {
                    expect{ try enterprise.updateEmail("user@test.com") }.toNot(throwError())
                    expect(enterprise.email) == "user@test.com"
                    expect(enterprise.domain) == "test.com"
                }

                it("should match email domain and provide enteprise connection") {
                    try! enterprise.updateEmail("user@test.com")
                    expect(enterprise.connection?.name) == "TestAD"
                }

                it("should not match connection with unknown domain") {
                    try! enterprise.updateEmail("user@domainnotmatched.com")
                    expect(enterprise.connection).to(beNil())
                    expect(enterprise.domain) == "domainnotmatched.com"
                }

                it("should raise error if email is nil") {
                    expect{ try enterprise.updateEmail(nil)}.to(throwError())
                }

                it("should not match a connection with nil email") {
                    expect{ try enterprise.updateEmail(nil)}.to(throwError())
                    expect(enterprise.connection).to(beNil())
                }
            }

            context("connection with multiple domains") {

                beforeEach {
                    connections = OfflineConnections()
                    connections.enterprise(name: "TestAD", domains: ["test.com", "pepe.com"])

                    enterprise = EnterpriseDomainInteractor(connections: connections, user: user, authentication: authInteractor)
                }

                it("should match first email domain and provide enteprise connection") {
                    try! enterprise.updateEmail("user@test.com")
                    expect(enterprise.connection?.name) == "TestAD"
                }

                it("should match second email domain and provide enteprise connection") {
                    try! enterprise.updateEmail("user@pepe.com")
                    expect(enterprise.connection?.name) == "TestAD"
                }
            }

        }

        describe("login") {

            var error: OAuth2AuthenticatableError?

            beforeEach {
                error = nil

                connections = OfflineConnections()
                connections.enterprise(name: "TestAD", domains: ["test.com"])
                enterprise = EnterpriseDomainInteractor(connections: connections, user: user, authentication: authInteractor)
            }

            it("should fail to launch on no valid connection") {

                try! enterprise.updateEmail("user@domainnotmatched.com")
                enterprise.login() { error = $0 }
                expect(error).toEventually(equal(OAuth2AuthenticatableError.noConnectionAvailable))
            }

            it("should not yield error on success") {
                authentication.webAuthResult = { return .success(result: mockCredentials()) }
                try! enterprise.updateEmail("user@test.com")
                enterprise.login() { error = $0 }
                expect(error).toEventually(beNil())
            }

            it("should add login_hint to login") {
                authentication.webAuthResult = { return .success(result: mockCredentials()) }
                try! enterprise.updateEmail("user@test.com")
                enterprise.login() { error = $0 }
                expect(error).toEventually(beNil())
                expect(authentication.webAuth.parameters["login_hint"]) == "user@test.com"
            }


            it("should call credentials callback") {
                let expected = mockCredentials()
                authentication.webAuthResult  = { return .success(result: expected) }

                try! enterprise.updateEmail("user@test.com")
                enterprise.login() { error = $0 }
                expect(credentials).toEventually(equal(expected))
            }

        }
    }
}
