// DatabasePasswordInteractorSpec.swift
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

private struct Enterprise {
    struct Connection {
        struct Single {
            static let name = "TestAD"
            static let domain = ["test.com"]
            static let validDomain = "user@test.com"
        }
        struct MultiDomain {
            static let name = "TestAD"
            static let domain = ["test.com","pepe.com"]
            static let validDomain = ["user@test.com", "user@pepe.com"]
        }
    }
}

class EnterpriseDomainInteractorSpec: QuickSpec {
    
    override func spec() {
        
        var authentication: Auth0OAuth2Interactor!
        var webAuth: MockWebAuth!
        var credentials: Credentials?
        var connections: OfflineConnections!
        var enterprise: EnterpriseDomainInteractor!
        
        beforeEach {
            connections = OfflineConnections()
            connections.enterprise(name: Enterprise.Connection.Single.name, domains: Enterprise.Connection.Single.domain)
            
            credentials = nil
            webAuth = MockWebAuth()
            authentication = Auth0OAuth2Interactor(webAuth: webAuth, onCredentials: {credentials = $0}, options: LockOptions())
            enterprise = EnterpriseDomainInteractor(connections: connections.enterprise, authentication: authentication)
        }
        
        afterEach {
            Auth0Stubs.cleanAll()
            Auth0Stubs.failUnknown()
        }
        
        describe("init") {
            
            it("should have an entperise object") {
                expect(enterprise).toNot(beNil())
            }
            
        }
        
        describe("updateEmail") {
            
            context("connection with no domain") {
                
                beforeEach {
                    connections = OfflineConnections()
                    connections.enterprise(name: Enterprise.Connection.Single.name, domains: [])
                    enterprise = EnterpriseDomainInteractor(connections: connections.enterprise, authentication: authentication)
                }
                
                it("should raise no error but no connection provided") {
                    expect{ try enterprise.updateEmail("user@domainnotmatched.com") }.toNot(throwError())
                    expect(enterprise.connection).to(beNil())
                }
                
            }
            
            context("connection with one domain") {
                
                
                beforeEach {
                    connections = OfflineConnections()
                    connections.enterprise(name: Enterprise.Connection.Single.name, domains: Enterprise.Connection.Single.domain)
                    enterprise = EnterpriseDomainInteractor(connections: connections.enterprise, authentication: authentication)
                }
                
                it("should match email domain") {
                    expect{ try enterprise.updateEmail(Enterprise.Connection.Single.validDomain) }.toNot(throwError())
                    expect(enterprise.email) == Enterprise.Connection.Single.validDomain
                }
                
                it("should match email domain and provide enteprise connection") {
                    try! enterprise.updateEmail(Enterprise.Connection.Single.validDomain)
                    expect(enterprise.connection?.name) == Enterprise.Connection.Single.name
                }
                
                
                it("should not match connection with uknown domain") {
                    try! enterprise.updateEmail("user@domainnotmatched.com")
                    expect(enterprise.connection).to(beNil())
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
                    connections.enterprise(name: Enterprise.Connection.MultiDomain.name, domains: Enterprise.Connection.MultiDomain.domain)
                    
                    enterprise = EnterpriseDomainInteractor(connections: connections.enterprise, authentication: authentication)
                }
                
                it("should match first email domain and provide enteprise connection") {
                    try! enterprise.updateEmail(Enterprise.Connection.MultiDomain.validDomain.first)
                    expect(enterprise.connection?.name) == Enterprise.Connection.MultiDomain.name
                }
                
                it("should match second email domain and provide enteprise connection") {
                    try! enterprise.updateEmail(Enterprise.Connection.MultiDomain.validDomain.last)
                    expect(enterprise.connection?.name) == Enterprise.Connection.MultiDomain.name
                }
            }
            
        }
        
        describe("login") {
            
            var error: OAuth2AuthenticatableError?
            
            beforeEach {
                error = nil
                
                connections = OfflineConnections()
                connections.enterprise(name: Enterprise.Connection.Single.name, domains: Enterprise.Connection.Single.domain)
                enterprise = EnterpriseDomainInteractor(connections: connections.enterprise, authentication: authentication)
            }
            
            it("should fail to launch on no valid connection") {
                
                try! enterprise.updateEmail("user@domainnotmatched.com")
                enterprise.login() { error = $0 }
                expect(error).toEventually(equal(OAuth2AuthenticatableError.NoConnectionAvailable))
            }
            
            it("should not yield error on success") {
                
                webAuth.result = { return .Success(result: mockCredentials()) }
                
                try! enterprise.updateEmail(Enterprise.Connection.Single.validDomain)
                enterprise.login() { error = $0 }
                expect(error).toEventually(beNil())
            }
            
            it("should call credentials callback") {
                let expected = mockCredentials()
                webAuth.result = { return .Success(result: expected) }
                
                try! enterprise.updateEmail(Enterprise.Connection.Single.validDomain)
                enterprise.login() { error = $0 }
                expect(credentials).toEventually(equal(expected))
            }
            
            
        }
    }
}
