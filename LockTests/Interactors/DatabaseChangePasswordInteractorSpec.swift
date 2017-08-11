// DatabaseChangePasswordInteractorSpec.swift
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
import OHHTTPStubs
import Auth0

@testable import Lock

private let ConfirmField = InputField.InputType.custom(name: "match", placeholder: "Confirm password", icon: InputField.InputType.password.icon, keyboardType: InputField.InputType.password.keyboardType, autocorrectionType: InputField.InputType.password.autocorrectionType, secure: InputField.InputType.password.secure)

class DatabaseChangePasswordInteractorSpec: QuickSpec {

    override func spec() {

        let authentication = Auth0.authentication(clientId: clientId, domain: domain)

        afterEach {
            Auth0Stubs.cleanAll()
            Auth0Stubs.failUnknown()
        }

        describe("init") {
            let interactor = DatabaseChangePasswordInteractor(connection: DatabaseConnection(name: "db", requiresUsername: false), authentication: authentication, user: User(), options: LockOptions(), dispatcher: ObserverStore())

            it("should build with authentication") {
                expect(interactor).toNot(beNil())
            }

            it("should have authentication object") {
                expect(interactor.authentication.clientId) == "CLIENT_ID"
                expect(interactor.authentication.url.host) == "samples.auth0.com"
            }
        }

        var user: User!
        var connection: DatabaseConnection!
        var interactor: DatabaseChangePasswordInteractor!
        var options: OptionBuildable!
        var dispatcher: ObserverStore!
        var input: MockInputField!

        beforeEach {
            dispatcher = ObserverStore()
            connection = DatabaseConnection(name: "Username-Password-Authentication", requiresUsername: false)
            user = User()
            options = LockOptions()
            interactor = DatabaseChangePasswordInteractor(connection: connection, authentication: authentication, user: user, options: options, dispatcher: dispatcher)
            input = mockInput(InputField.InputType.password)
        }

        describe("defaults") {

            it("should have nil email") {
                expect(interactor.email).to(beNil())
            }

            it("should have invalidEmail") {
                expect(interactor.validPassword).to(beFalse())
            }

            it("should have confirmed true") {
                expect(interactor.confirmed).to(beTrue())
            }

            it("should have confirmed password") {
                expect(interactor.confirmed) == true
            }

            context("disable alloShowPassword") {

                beforeEach {
                    options.allowShowPassword = false
                    interactor = DatabaseChangePasswordInteractor(connection: connection, authentication: authentication, user: user, options: options, dispatcher: dispatcher)
                    input = mockInput(InputField.InputType.password)
                }

                it("should not have confirmed password") {
                    expect(interactor.confirmed) == false
                }

            }
        }

        describe("update") {

            it("should update password") {
                input = mockInput(InputField.InputType.password, value: password)
                expect{ try interactor.update(input) }.toNot(throwError())
                expect(interactor.newPassword) == password
                expect(interactor.validPassword) == true
            }

            describe("password validation") {

                it("should raise error if password is empty") {
                    input = mockInput(InputField.InputType.password, value: "")
                    expect{ try interactor.update(input) }.to(throwError(InputValidationError.passwordPolicyViolation(result: [])))
                }

                it("should raise error if password is only spaces") {
                    input = mockInput(InputField.InputType.password, value: "     ")
                    expect{ try interactor.update(input) }.to(throwError(InputValidationError.passwordPolicyViolation(result: [])))
                }
            }

            context("do not allow show password") {

                beforeEach {
                    options.allowShowPassword = false
                    interactor = DatabaseChangePasswordInteractor(connection: connection, authentication: authentication, user: user, options: options, dispatcher: dispatcher)
                    input = mockInput(InputField.InputType.password)
                    interactor.newPassword = password
                }

                it("should not have confirmed password") {
                    expect(interactor.confirmed) == false
                }

                describe("confirm validation") {

                    it("should raise error if confirm is empty") {
                        input = mockInput(ConfirmField, value: "")
                        expect{ try interactor.update(input) }.to(throwError(PasswordChangeableError.noConfirmation))
                        expect(interactor.confirmed) == false
                    }

                    it("should raise error if confirm is only spaces") {
                        input = mockInput(ConfirmField, value: "     ")
                        expect{ try interactor.update(input) }.to(throwError(PasswordChangeableError.noConfirmation))
                        expect(interactor.confirmed) == false
                    }

                    it("should be valid confirmation when password matches") {
                        input = mockInput(ConfirmField, value: password)
                        expect{ try interactor.update(input) }.toNot(throwError())
                        expect(interactor.confirmed) == true
                    }

                }


            }

        }

        describe("request") {

            var credentials: Credentials?

            beforeEach {
                user.email = email
                user.validEmail = true
                user.password = password
                user.validPassword = true
                credentials = nil
                dispatcher.onAuth = { credentials = $0 }
                interactor = DatabaseChangePasswordInteractor(connection: connection, authentication: authentication, user: user, options: options, dispatcher: dispatcher)
                stub(condition: databaseChangePassword(username: email, oldPassword: password, newPassword: newPassword, connection: connection.name)) { _ in return Auth0Stubs.changePasswordSuccess() }
                stub(condition: databaseLogin(identifier: email, password: newPassword, connection: connection.name)) { _ in return Auth0Stubs.authentication() }
                input = mockInput(InputField.InputType.password, value: newPassword)
            }

            it("should yield no credentials on success") {
                try! interactor.update(input)
                waitUntil(timeout: 2) { done in
                    interactor.changePassword { error in
                        expect(error).to(beNil())
                        done()
                    }
                }
                expect(credentials).toEventuallyNot(beNil())
            }

            it("should yield error on failure") {
                stub(condition: databaseChangePassword(username: email, oldPassword: password, newPassword: newPassword, connection: connection.name)) { _ in return Auth0Stubs.failure() }
                try! interactor.update(input)
                waitUntil(timeout: 2) { done in
                    interactor.changePassword { error in
                        expect(error).to(beError(error: PasswordChangeableError.changeFailed))
                        done()
                    }
                }

            }

            it("should yield policy error on failed policy") {
                stub(condition: databaseChangePassword(username: email, oldPassword: password, newPassword: newPassword, connection: connection.name)) { _ in return Auth0Stubs.failure("change_password_error") }
                try! interactor.update(input)
                waitUntil(timeout: 2) { done in
                    interactor.changePassword { error in
                        expect(error).to(beError(error: PasswordChangeableError.policyFail("FAILURE")))
                        done()
                    }
                }

            }

            it("should yield error on invalid input") {
                waitUntil(timeout: 2) { done in
                    interactor.changePassword { error in
                        expect(error).to(beError(error: PasswordChangeableError.nonValidInput))
                        done()
                    }
                }

            }
            
        }
        
        
    }
}
