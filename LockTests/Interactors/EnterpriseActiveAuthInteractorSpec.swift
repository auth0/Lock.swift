// EnterprisePasswordInteractorSpec.swift
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

class EnterpriseActiveAuthInteractorSpec: QuickSpec {

    override func spec() {

        let authentication = Auth0.authentication(clientId: clientId, domain: domain)
        var user: User!
        var options: LockOptions!
        var interactor: EnterpriseActiveAuthInteractor!
        var connection: EnterpriseConnection!

        beforeEach {
            connection = EnterpriseConnection(name: "TestAD", domains: ["test.com"])
            user = User()
            options = LockOptions()
            interactor = EnterpriseActiveAuthInteractor(connection: connection, authentication: authentication, user: user, options: options, dispatcher: ObserverStore())
        }

        afterEach {
            Auth0Stubs.cleanAll()
            Auth0Stubs.failUnknown()
        }

        describe("init") {

            it("should have an entperise object") {
                expect(interactor).toNot(beNil())
            }
        }

        describe("initial state") {

            it("should use username identifier and username will be nil") {
                user = User()
                user.email = nil
                interactor = EnterpriseActiveAuthInteractor(connection: connection, authentication: authentication, user: user, options: options, dispatcher: ObserverStore())

                expect(interactor.identifierAttribute).to(equal(UserAttribute.username))
                expect(interactor.username).to(beNil())
                expect(interactor.validUsername).to(beFalse())
            }

            it("should use username identifier and match username") {
                user = User()
                user.email = email
                interactor = EnterpriseActiveAuthInteractor(connection: connection, authentication: authentication, user: user, options: options, dispatcher: ObserverStore())

                expect(interactor.identifierAttribute).to(equal(UserAttribute.username))
                expect(interactor.username).to(equal(username))
                expect(interactor.validUsername).to(beTrue())
            }

            context("use email as identifier option set") {

                beforeEach {
                    options = LockOptions()
                    options.activeDirectoryEmailAsUsername = true
                }

                it("should use email identifier and match email") {
                    user.email = email
                    interactor = EnterpriseActiveAuthInteractor(connection: connection, authentication: authentication, user: user, options: options, dispatcher: ObserverStore())

                    expect(interactor.identifierAttribute).to(equal(UserAttribute.email))
                    expect(interactor.email).to(equal(email))
                    expect(interactor.validEmail).to(beTrue())
                }

                it("should use email identifier and email will be nil") {
                    user.email = nil
                    interactor = EnterpriseActiveAuthInteractor(connection: connection, authentication: authentication, user: user, options: options, dispatcher: ObserverStore())

                    expect(interactor.identifierAttribute).to(equal(UserAttribute.email))
                    expect(interactor.email).to(beNil())
                    expect(interactor.validEmail).to(beFalse())
                }

            }

        }

        describe("user input") {

            it("should update email") {
                try! interactor.update(.email, value: email)
                expect(interactor.email).to(equal(email))
                expect(interactor.validEmail).to(beTrue())
            }

            it("should update username") {
                try! interactor.update(.username, value:username)
                expect(interactor.username).to(equal(username))
                expect(interactor.validUsername).to(beTrue())
            }

            it("should update password") {
                try! interactor.update(.password(enforcePolicy: false), value: password)
                expect(interactor.password).to(equal(password))
                expect(interactor.validPassword).to(beTrue())
            }

            it("should ignore unsupported atrribute") {
                expect{ try interactor.update(.emailOrUsername, value: "asdfsdafasdfasdfasdfasdffds") }.toNot(throwError())
            }
        }

        describe ("login") {

            var error: CredentialAuthError?

            beforeEach {
                options.oidcConformant = false
                user.email = email
                interactor = EnterpriseActiveAuthInteractor(connection: connection, authentication: authentication, user: user, options: options, dispatcher: ObserverStore())
            }

            it("should fail with no input as password missing") {
                interactor.login() { error = $0 }
                expect(error).toEventually(equal(CredentialAuthError.nonValidInput))
            }

            it("should yield no error on success") {
                stub(condition: databaseLogin(identifier: email, password: password, connection: interactor.connection.name)) { _ in return Auth0Stubs.authentication() }
                try! interactor.update(.email, value: email)
                try! interactor.update(.password(enforcePolicy: false), value: password)
                waitUntil(timeout: 2) { done in
                    interactor.login { error in
                        expect(error).to(beNil())
                        done()
                    }
                }
            }

            it("should yield invalid credentials error on failure") {
                stub(condition: databaseLogin(identifier: email, password: password, connection: interactor.connection.name)) { _ in return Auth0Stubs.failure("invalid_user_password") }
                try! interactor.update(.email, value: email)
                try! interactor.update(.password(enforcePolicy: false), value: password)
                waitUntil(timeout: 2) { done in
                    interactor.login { error in
                        expect(error) == .invalidEmailPassword
                        done()
                    }
                }
            }

            it("should indicate that mfa is required") {
                stub(condition: databaseLogin(identifier: email, password: password, connection: interactor.connection.name)) { _ in return Auth0Stubs.failure("a0.mfa_required") }
                try! interactor.update(.email, value: email)
                try! interactor.update(.password(enforcePolicy: false), value: password)
                waitUntil(timeout: 2) { done in
                    interactor.login { error in
                        expect(error) == .multifactorRequired
                        done()
                    }
                }
            }

            it("should indicate that mfa is required registration") {
                stub(condition: databaseLogin(identifier: email, password: password, connection: interactor.connection.name)) { _ in return Auth0Stubs.failure("a0.mfa_registration_required") }
                try! interactor.update(.email, value: email)
                try! interactor.update(.password(enforcePolicy: false), value: password)
                waitUntil(timeout: 2) { done in
                    interactor.login { error in
                        expect(error) == .multifactorRequired
                        done()
                    }
                }
            }

            it("should indicate the user is blocked") {
                stub(condition: databaseLogin(identifier: email, password: password, connection: interactor.connection.name)) { _ in return Auth0Stubs.failure("unauthorized", description: "user is blocked") }
                try! interactor.update(.email, value: email)
                try! interactor.update(.password(enforcePolicy: false), value: password)
                waitUntil(timeout: 2) { done in
                    interactor.login { error in
                        expect(error) == .userBlocked
                        done()
                    }
                }
            }

            it("should indicate the password needs to be changed") {
                stub(condition: databaseLogin(identifier: email, password: password, connection: interactor.connection.name)) { _ in return Auth0Stubs.failure("password_change_required") }
                try! interactor.update(.email, value: email)
                try! interactor.update(.password(enforcePolicy: false), value: password)
                waitUntil(timeout: 2) { done in
                    interactor.login { error in
                        expect(error) == .passwordChangeRequired
                        done()
                    }
                }
            }

            it("should indicate that a custom rule prevented the user from logging in") {
                stub(condition: databaseLogin(identifier: email, password: password, connection: interactor.connection.name)) { _ in return Auth0Stubs.failure("unauthorized", description: "Only admins can use this") }
                try! interactor.update(.email, value: email)
                try! interactor.update(.password(enforcePolicy: false), value: password)
                waitUntil(timeout: 2) { done in
                    interactor.login { error in
                        expect(error) == .customRuleFailure(cause: "Only admins can use this")
                        done()
                    }
                }
            }
        }

        describe ("login OIDC Conformnat") {

            var error: CredentialAuthError?

            beforeEach {
                options.oidcConformant = true
                user.email = email
                interactor = EnterpriseActiveAuthInteractor(connection: connection, authentication: authentication, user: user, options: options, dispatcher: ObserverStore())
            }

            it("should fail with no input as password missing") {
                interactor.login() { error = $0 }
                expect(error).toEventually(equal(CredentialAuthError.nonValidInput))
            }

            it("should yield no error on success") {
                stub(condition: realmLogin(identifier: email, password: password, realm: interactor.connection.name)) { _ in return Auth0Stubs.authentication() }
                try! interactor.update(.email, value: email)
                try! interactor.update(.password(enforcePolicy: false), value: password)
                waitUntil(timeout: 2) { done in
                    interactor.login { error in
                        expect(error).to(beNil())
                        done()
                    }
                }
            }

            it("should yield invalid credentials error on failure") {
                stub(condition: realmLogin(identifier: email, password: password, realm: interactor.connection.name)) { _ in return Auth0Stubs.failure("invalid_user_password") }
                try! interactor.update(.email, value: email)
                try! interactor.update(.password(enforcePolicy: false), value: password)
                waitUntil(timeout: 2) { done in
                    interactor.login { error in
                        expect(error) == .invalidEmailPassword
                        done()
                    }
                }
            }

            it("should indicate that mfa is required") {
                stub(condition: realmLogin(identifier: email, password: password, realm: interactor.connection.name)) { _ in return Auth0Stubs.failure("a0.mfa_required") }
                try! interactor.update(.email, value: email)
                try! interactor.update(.password(enforcePolicy: false), value: password)
                waitUntil(timeout: 2) { done in
                    interactor.login { error in
                        expect(error) == .multifactorRequired
                        done()
                    }
                }
            }

            it("should indicate that mfa is required registration") {
                stub(condition: realmLogin(identifier: email, password: password, realm: interactor.connection.name)) { _ in return Auth0Stubs.failure("a0.mfa_registration_required") }
                try! interactor.update(.email, value: email)
                try! interactor.update(.password(enforcePolicy: false), value: password)
                waitUntil(timeout: 2) { done in
                    interactor.login { error in
                        expect(error) == .multifactorRequired
                        done()
                    }
                }
            }

            it("should indicate the user is blocked") {
                stub(condition: realmLogin(identifier: email, password: password, realm: interactor.connection.name)) { _ in return Auth0Stubs.failure("unauthorized", description: "user is blocked") }
                try! interactor.update(.email, value: email)
                try! interactor.update(.password(enforcePolicy: false), value: password)
                waitUntil(timeout: 2) { done in
                    interactor.login { error in
                        expect(error) == .userBlocked
                        done()
                    }
                }
            }

            it("should indicate the password needs to be changed") {
                stub(condition: realmLogin(identifier: email, password: password, realm: interactor.connection.name)) { _ in return Auth0Stubs.failure("password_change_required") }
                try! interactor.update(.email, value: email)
                try! interactor.update(.password(enforcePolicy: false), value: password)
                waitUntil(timeout: 2) { done in
                    interactor.login { error in
                        expect(error) == .passwordChangeRequired
                        done()
                    }
                }
            }
            
            it("should indicate that a custom rule prevented the user from logging in") {
                stub(condition: realmLogin(identifier: email, password: password, realm: interactor.connection.name)) { _ in return Auth0Stubs.failure("unauthorized", description: "Only admins can use this") }
                try! interactor.update(.email, value: email)
                try! interactor.update(.password(enforcePolicy: false), value: password)
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

extension UserAttribute: Equatable {}

public func ==(lhs: UserAttribute, rhs: UserAttribute) -> Bool {
    switch((lhs, rhs)) {
    case (.email, .email), (.username, .username), (.password, .password), (.emailOrUsername, .emailOrUsername):
        return true
    case (.custom(let lhsConnection), .custom(let rhsConnection)):
        return lhsConnection == rhsConnection
    default:
        return false
    }
}

