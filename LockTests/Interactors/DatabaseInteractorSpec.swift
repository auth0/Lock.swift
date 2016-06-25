// DatabaseInteractorSpec.swift
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

class DatabaseInteractorSpec: QuickSpec {

    override func spec() {
        let authentication = Auth0.authentication(clientId: clientId, domain: domain)

        afterEach {
            Auth0Stubs.cleanAll()
            Auth0Stubs.failUnknown()
        }

        describe("init") {
            let database = DatabaseInteractor(authentication: authentication)

            it("should build with authentication") {
                expect(database).toNot(beNil())
            }

            it("should have authentication object") {
                expect(database.authentication.clientId) == "CLIENT_ID"
                expect(database.authentication.url.host) == "samples.auth0.com"
            }
        }


        var database: DatabaseInteractor!

        beforeEach {
            database = DatabaseInteractor(authentication: authentication)
        }

        describe("updateAttribute") {
            it("should update email") {
                expect{ try database.update(.Email, value: email) }.toNot(throwError())
                expect(database.email) == email
                expect(database.username).to(beNil())
                expect(database.password).to(beNil())
            }

            it("should update username") {
                expect{ try database.update(.Username, value: username) }.toNot(throwError())
                expect(database.username) == username
                expect(database.email).to(beNil())
                expect(database.password).to(beNil())
            }

            it("should update password") {
                expect{ try database.update(.Password, value: password) }.toNot(throwError())
                expect(database.password) == password
                expect(database.username).to(beNil())
                expect(database.email).to(beNil())
            }

        }

        describe("login") {
            it("should yield no error no success") {
                stub(databaseLogin(identifier: email, password: password, connection: connection)) { _ in return Auth0Stubs.authentication() }
                try! database.update(.Email, value: email)
                try! database.update(.Password, value: password)
                waitUntil(timeout: 2) { done in
                    database.login { error in
                        expect(error).to(beNil())
                        done()
                    }
                }
            }

            it("should prefer email over username") {
                stub(databaseLogin(identifier: email, password: password, connection: connection)) { _ in return Auth0Stubs.authentication() }
                try! database.update(.Email, value: email)
                try! database.update(.Username, value: username)
                try! database.update(.Password, value: password)
                waitUntil(timeout: 2) { done in
                    database.login { error in
                        expect(error).to(beNil())
                        done()
                    }
                }
            }

            it("should use username") {
                stub(databaseLogin(identifier: username, password: password, connection: connection)) { _ in return Auth0Stubs.authentication() }
                try! database.update(.Username, value: username)
                try! database.update(.Password, value: password)
                waitUntil(timeout: 2) { done in
                    database.login { error in
                        expect(error).to(beNil())
                        done()
                    }
                }
            }

            it("should yield error on failure") {
                stub(databaseLogin(identifier: email, password: password, connection: connection)) { _ in return Auth0Stubs.failure() }
                try! database.update(.Email, value: email)
                try! database.update(.Password, value: password)
                waitUntil(timeout: 2) { done in
                    database.login { error in
                        expect(error) == .CouldNotLogin
                        done()
                    }
                }
            }

            it("should yield error when input is not valid") {
                waitUntil(timeout: 2) { done in
                    database.login { error in
                        expect(error) == .NonValidInput
                        done()
                    }
                }
            }

        }
    }
}
