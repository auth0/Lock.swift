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

class DatabasePasswordInteractorSpec: QuickSpec {

    override func spec() {

        let authentication = Auth0.authentication(clientId: clientId, domain: domain)

        afterEach {
            Auth0Stubs.cleanAll()
            Auth0Stubs.failUnknown()
        }

        describe("init") {
            let database = DatabasePasswordInteractor(connections: OfflineConnections(), authentication: authentication, user: User(), dispatcher: ObserverStore())

            it("should build with authentication") {
                expect(database).toNot(beNil())
            }

            it("should have authentication object") {
                expect(database.authentication.clientId) == "CLIENT_ID"
                expect(database.authentication.url.host) == "samples.auth0.com"
            }
        }

        var user: User!
        var connections: OfflineConnections!
        var forgot: DatabasePasswordInteractor!
        var dispatcher: Dispatcher!

        beforeEach {
            dispatcher = ObserverStore()
            connections = OfflineConnections()
            connections.database(name: connection, requiresUsername: true)
            user = User()
            forgot = DatabasePasswordInteractor(connections: connections, authentication: authentication, user: user, dispatcher: dispatcher)
        }

        describe("updateEmail") {

            it("should update email") {
                expect{ try forgot.updateEmail(email) }.toNot(throwError())
                expect(forgot.email) == email
            }

            it("should trim email") {
                expect{ try forgot.updateEmail("  \(email)      ") }.toNot(throwError())
                expect(forgot.email) == email
            }

            describe("email validation") {

                it("should always store value") {
                    let _ = try? forgot.updateEmail("not an email")
                    expect(forgot.email) == "not an email"
                }

                it("should raise error if email is invalid") {
                    expect{ try forgot.updateEmail("not an email") }.to(throwError(InputValidationError.notAnEmailAddress))
                }

                it("should raise error if email is empty") {
                    expect{ try forgot.updateEmail("") }.to(throwError(InputValidationError.mustNotBeEmpty))
                }

                it("should raise error if email is only spaces") {
                    expect{ try forgot.updateEmail("     ") }.to(throwError(InputValidationError.mustNotBeEmpty))
                }

                it("should raise error if email is nil") {
                    expect{ try forgot.updateEmail(nil) }.to(throwError(InputValidationError.mustNotBeEmpty))
                }
            }
        }

        describe("request email") {

            it("should fail if no db connection is found") {
                forgot = DatabasePasswordInteractor(connections: OfflineConnections(), authentication: authentication, user: user, dispatcher: dispatcher)
                try! forgot.updateEmail(email)
                waitUntil(timeout: 2) { done in
                    forgot.requestEmail { error in
                        expect(error) == .noDatabaseConnection
                        done()
                    }
                }
            }

            it("should yield no error on success") {
                stub(condition: databaseForgotPassword(email: email, connection: connection)) { _ in return Auth0Stubs.forgotEmailSent() }
                try! forgot.updateEmail(email)
                waitUntil(timeout: 2) { done in
                    forgot.requestEmail { error in
                        expect(error).to(beNil())
                        done()
                    }
                }
            }

            it("should yield error on failure") {
                stub(condition: databaseForgotPassword(email: email, connection: connection)) { _ in return Auth0Stubs.failure() }
                try! forgot.updateEmail(email)
                waitUntil(timeout: 2) { done in
                    forgot.requestEmail { error in
                        expect(error) == .emailNotSent
                        done()
                    }
                }
            }

            it("should yield error when input is not valid") {
                waitUntil(timeout: 2) { done in
                    forgot.requestEmail { error in
                        expect(error) == .nonValidInput
                        done()
                    }
                }
            }
        }
    }
    
}
