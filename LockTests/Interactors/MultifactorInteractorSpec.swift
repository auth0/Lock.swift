// MultifactorInteractorSpec.swift
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

class MultifactorInteractorSpec: QuickSpec {
    override func spec() {

        var user: User!
        var interactor: MultifactorInteractor!
        var connection: DatabaseConnection!
        var credentials: Credentials?
        var options: OptionBuildable!

        beforeEach {
            user = User()
            user.email = email
            user.validEmail = true
            user.password = password
            user.validPassword = true
            options = LockOptions()
            credentials = nil
            var dispatcher = ObserverStore()
            dispatcher.onAuth = { credentials = $0 }
            connection = DatabaseConnection(name: "myConnection", requiresUsername: true)
            interactor = MultifactorInteractor(user: user, authentication: Auth0.authentication(clientId: clientId, domain: domain), connection: connection, options: options, dispatcher: dispatcher)
        }

        describe("updateCode") {

            it("should update code") {
                expect{ try interactor.setMultifactorCode(code) }.toNot(throwError())
                expect(interactor.code) == code
            }

            it("should trim email") {
                expect{ try interactor.setMultifactorCode("  \(code)      ") }.toNot(throwError())
                expect(interactor.code) == code
            }

            it("should set valid flag") {
                let _ = try? interactor.setMultifactorCode(code)
                expect(interactor.validCode) == true
            }

            describe("code validation") {

                it("should set valid flag") {
                    let _ = try? interactor.setMultifactorCode("not a code")
                    expect(interactor.validCode) == false
                }

                it("should always store value") {
                    let _ = try? interactor.setMultifactorCode("not a code")
                    expect(interactor.code) == "not a code"
                }

                it("should raise error if code is invalid") {
                    expect{ try interactor.setMultifactorCode("not an email") }.to(throwError(InputValidationError.notAOneTimePassword))
                }

                it("should raise error if code is empty") {
                    expect{ try interactor.setMultifactorCode("") }.to(throwError(InputValidationError.mustNotBeEmpty))
                }

                it("should raise error if email is only spaces") {
                    expect{ try interactor.setMultifactorCode("     ") }.to(throwError(InputValidationError.mustNotBeEmpty))
                }

                it("should raise error if email is nil") {
                    expect{ try interactor.setMultifactorCode(nil) }.to(throwError(InputValidationError.mustNotBeEmpty))
                }
            }
        }

        describe("login") {

            beforeEach {
                options.oidcConformant = false
                var dispatcher = ObserverStore()
                dispatcher.onAuth = { credentials = $0 }
                interactor = MultifactorInteractor(user: user, authentication: Auth0.authentication(clientId: clientId, domain: domain), connection: connection, options: options, dispatcher: dispatcher)
            }


            it("should yield no error on success") {
                stub(condition: databaseLogin(identifier: email, password: password, code: code, connection: connection.name)) { _ in return Auth0Stubs.authentication() }
                try! interactor.setMultifactorCode(code)
                waitUntil(timeout: 2) { done in
                    interactor.login { error in
                        expect(error).to(beNil())
                        done()
                    }
                }
            }

            it("should yield credentials") {
                stub(condition: databaseLogin(identifier: email, password: password, code: code, connection: connection.name)) { _ in return Auth0Stubs.authentication() }
                try! interactor.setMultifactorCode(code)
                interactor.login { _ in }
                expect(credentials).toEventuallyNot(beNil())
            }

            it("should yield error on failure") {
                stub(condition: databaseLogin(identifier: email, password: password, code: code, connection: connection.name)) { _ in return Auth0Stubs.failure() }
                try! interactor.setMultifactorCode(code)
                waitUntil(timeout: 2) { done in
                    interactor.login { error in
                        expect(error) == .couldNotLogin
                        done()
                    }
                }
            }

            it("should notify when code is invalid") {
                stub(condition: databaseLogin(identifier: email, password: password, code: code, connection: connection.name)) { _ in return Auth0Stubs.failure("a0.mfa_invalid_code") }
                try! interactor.setMultifactorCode(code)
                waitUntil(timeout: 2) { done in
                    interactor.login { error in
                        expect(error) == .multifactorInvalid
                        done()
                    }
                }
            }

            it("should yield error when input is not valid") {
                waitUntil(timeout: 2) { done in
                    interactor.login { error in
                        expect(error) == .nonValidInput
                        done()
                    }
                }
            }
            
            it("should indicate that a custom rule prevented the user from logging in") {
                stub(condition: databaseLogin(identifier: email, password: password, code: code, connection: connection.name)) { _ in return Auth0Stubs.failure("unauthorized", description: "Only admins can use this") }
                try! interactor.setMultifactorCode(code)
                waitUntil(timeout: 2) { done in
                    interactor.login { error in
                        expect(error) == .customRuleFailure(cause: "Only admins can use this")
                        done()
                    }
                }
            }
        }

    }
}
