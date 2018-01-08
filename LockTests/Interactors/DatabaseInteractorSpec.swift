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
        }

        describe("init") {

            let options = LockOptions()
            let dispatcher = ObserverStore()

            it("should build with authentication") {
                let database = DatabaseInteractor(connection: DatabaseConnection(name: "db", requiresUsername: true), authentication: authentication, user: User(), options: options, dispatcher: dispatcher)
                expect(database).toNot(beNil())
            }

            it("should have authentication object") {
                let database = DatabaseInteractor(connection: DatabaseConnection(name: "db", requiresUsername: true), authentication: authentication, user: User(), options: options, dispatcher: dispatcher)
                expect(database.credentialAuth.authentication.clientId) == "CLIENT_ID"
                expect(database.credentialAuth.authentication.url.host) == "samples.auth0.com"
                expect(database.credentialAuth.oidc) == false
                expect(database.credentialAuth.realm) == "db"
            }
        }


        var database: DatabaseInteractor!
        var user: User!
        var options: OptionBuildable!
        var dispatcher: ObserverStore!

        beforeEach {
            options = LockOptions()
            dispatcher = ObserverStore()

            Auth0Stubs.failUnknown()
            user = User()
            let db = DatabaseConnection(name: connection, requiresUsername: true, usernameValidator: UsernameValidator(withLength: 1...15, characterSet: UsernameValidator.auth0), passwordValidator: PasswordPolicyValidator(policy: .good))
            database = DatabaseInteractor(connection: db, authentication: authentication, user: user, options: options, dispatcher: dispatcher)
        }

        describe("updateAttribute") {

            it("should update email") {
                expect{ try database.update(.email, value: email) }.toNot(throwError())
                expect(database.email) == email
                expect(database.username).to(beNil())
                expect(database.password).to(beNil())
            }

            it("should trim email") {
                expect{ try database.update(.email, value: "  \(email)      ") }.toNot(throwError())
                expect(database.email) == email
            }

            it("should update username") {
                expect{ try database.update(.username, value: username) }.toNot(throwError())
                expect(database.username) == username
                expect(database.email).to(beNil())
                expect(database.password).to(beNil())
            }

            it("should update username or email with an email") {
                expect{ try database.update(.emailOrUsername, value: email) }.toNot(throwError())
                expect(database.username) == email
                expect(database.email) == email
                expect(database.validEmail) == true
                expect(database.validUsername) == false
                expect(database.password).to(beNil())
            }

            it("should update username or email with an username") {
                expect{ try database.update(.emailOrUsername, value: username) }.toNot(throwError())
                expect(database.username) == username
                expect(database.email) == username
                expect(database.validEmail) == false
                expect(database.validUsername) == true
                expect(database.password).to(beNil())
            }

            it("should update password") {
                expect{ try database.update(.password(enforcePolicy: false), value: password) }.toNot(throwError())
                expect(database.password) == password
                expect(database.username).to(beNil())
                expect(database.email).to(beNil())
            }

            describe("email or username validation") {

                it("should always store value") {
                    let _ = try? database.update(.emailOrUsername, value: "not an email")
                    expect(database.email) == "not an email"
                    expect(database.username) == "not an email"
                }

                it("should fallback to username if valid") {
                    expect { try database.update(.emailOrUsername, value: username) }.notTo(throwError())
                    expect(database.username) == username
                    expect(database.validUsername) == true
                }

                it("should not raise error if email is invalid") {
                    expect{ try database.update(.emailOrUsername, value: "not an email") }.to(throwError(InputValidationError.notAnEmailAddress))
                }

                it("should raise error if email/username is empty") {
                    expect{ try database.update(.emailOrUsername, value: "") }.to(throwError(InputValidationError.mustNotBeEmpty))
                }

                it("should raise error if email/username is only spaces") {
                    expect{ try database.update(.emailOrUsername, value: "     ") }.to(throwError(InputValidationError.mustNotBeEmpty))
                }

                it("should raise error if email/username is nil") {
                    expect{ try database.update(.emailOrUsername, value: nil) }.to(throwError(InputValidationError.mustNotBeEmpty))
                }

            }
            describe("email validation") {

                it("should always store value") {
                    let _ = try? database.update(.email, value: "not an email")
                    expect(database.email) == "not an email"
                }

                it("should raise error if email is invalid") {
                    expect{ try database.update(.email, value: "not an email") }.to(throwError(InputValidationError.notAnEmailAddress))
                }

                it("should raise error if email is empty") {
                    expect{ try database.update(.email, value: "") }.to(throwError(InputValidationError.mustNotBeEmpty))
                }

                it("should raise error if email is only spaces") {
                    expect{ try database.update(.email, value: "     ") }.to(throwError(InputValidationError.mustNotBeEmpty))
                }

                it("should raise error if email is nil") {
                    expect{ try database.update(.email, value: nil) }.to(throwError(InputValidationError.mustNotBeEmpty))
                }

            }

            // MARK:- Username Validation
            describe("username validation") {

                it("should always store value") {
                    let _ = try? database.update(.username, value: "not a username")
                    expect(database.username) == "not a username"
                }

                it("should accept '_' as valid character") {
                    expect{ try database.update(.username, value: "info_auth0") }.toNot(throwError())
                }

                it("should raise error if username has invalid chars") {
                    expect{ try database.update(.username, value: "!not avalidusername+++") }.to(throwError(InputValidationError.notAUsername))
                }

                it("should raise error if username has too many chars") {
                    expect{ try database.update(.username, value: "12345678901234567890") }.to(throwError(InputValidationError.notAUsername))
                }

                it("should raise error if username is empty") {
                    expect{ try database.update(.username, value: "") }.to(throwError(InputValidationError.mustNotBeEmpty))
                }

                it("should raise error if username is only spaces") {
                    expect{ try database.update(.username, value: "     ") }.to(throwError(InputValidationError.mustNotBeEmpty))
                }

                it("should raise error if email is nil") {
                    expect{ try database.update(.username, value: nil) }.to(throwError(InputValidationError.mustNotBeEmpty))
                }

            }

            // MARK:- Password Validation
            describe("password validation") {

                it("should always store value") {
                    let _ = try? database.update(.password(enforcePolicy: false), value: "pass")
                    expect(database.password) == "pass"
                }

                it("should raise error if password is empty not enforcing policy") {
                    expect{ try database.update(.password(enforcePolicy: false), value: "") }.to(throwError(InputValidationError.mustNotBeEmpty))
                }

                it("should raise error if password is nil not enforcing policy") {
                    expect{ try database.update(.password(enforcePolicy: false), value: nil) }.to(throwError(InputValidationError.mustNotBeEmpty))
                }

                it("should raise error if password is empty") {
                    expect{ try database.update(.password(enforcePolicy: true), value: "") }.to(throwError(InputValidationError.passwordPolicyViolation(result: [])))
                }

                it("should raise error if password is nil") {
                    expect{ try database.update(.password(enforcePolicy: true), value: nil) }.to(throwError(InputValidationError.passwordPolicyViolation(result: [])))
                }

                context("password low, 6 char min") {

                    beforeEach {
                        Auth0Stubs.failUnknown()
                        user = User()
                        let db = DatabaseConnection(name: connection, requiresUsername: true, usernameValidator: UsernameValidator(withLength: 1...15, characterSet: UsernameValidator.auth0), passwordValidator: PasswordPolicyValidator(policy: .low))
                        database = DatabaseInteractor(connection: db, authentication: authentication, user: user, options: LockOptions(), dispatcher: ObserverStore())
                    }

                    it("should raise error if password is <6 characters") {
                        expect{ try database.update(.password(enforcePolicy: true), value: "12345") }.to(throwError(InputValidationError.passwordPolicyViolation(result: [])))
                    }

                    it("should pass if password is 6 characters") {
                        expect{ try database.update(.password(enforcePolicy: true), value: "123456") }.toNot(throwError(InputValidationError.passwordPolicyViolation(result: [])))
                    }
                }

                context("password fair, 8 char min, 3/3 rules") {

                    beforeEach {
                        Auth0Stubs.failUnknown()
                        user = User()
                        let db = DatabaseConnection(name: connection, requiresUsername: true, usernameValidator: UsernameValidator(withLength: 1...15, characterSet: UsernameValidator.auth0), passwordValidator: PasswordPolicyValidator(policy: .fair))
                        database = DatabaseInteractor(connection: db, authentication: authentication, user: user, options: LockOptions(), dispatcher: ObserverStore())
                    }

                    it("should raise error if password is <8 characters") {
                        expect{ try database.update(.password(enforcePolicy: true), value: "12345") }.to(throwError(InputValidationError.passwordPolicyViolation(result: [])))
                    }

                    it("should raise error, length good, does not meet 3/4 rules") {
                        expect{ try database.update(.password(enforcePolicy: true), value: "12345678") }.to(throwError(InputValidationError.passwordPolicyViolation(result: [])))
                    }

                    it("should raise error, length good, includes numbers, includes lower, missing upper") {
                        expect{ try database.update(.password(enforcePolicy: true), value: "123a5678") }.to(throwError(InputValidationError.passwordPolicyViolation(result: [])))
                    }

                    it("should pass, length good, includes numbers, includes lower, includes upper") {
                        expect{ try database.update(.password(enforcePolicy: true), value: "123a5A78") }.toNot(throwError(InputValidationError.passwordPolicyViolation(result: [])))
                    }
                }

                context("password good, 8 min, 3/4 rules") {

                    beforeEach {
                        Auth0Stubs.failUnknown()
                        user = User()
                        let db = DatabaseConnection(name: connection, requiresUsername: true, usernameValidator: UsernameValidator(withLength: 1...15, characterSet: UsernameValidator.auth0), passwordValidator: PasswordPolicyValidator(policy: .good))
                        database = DatabaseInteractor(connection: db, authentication: authentication, user: user, options: LockOptions(), dispatcher: ObserverStore())
                    }

                    it("should raise error if password is <8 characters") {
                        expect{ try database.update(.password(enforcePolicy: true), value: "12345") }.to(throwError(InputValidationError.passwordPolicyViolation(result: [])))
                    }

                    it("should raise error, length good, but does not meet 3/4 rules") {
                        expect{ try database.update(.password(enforcePolicy: true), value: "12345678") }.to(throwError(InputValidationError.passwordPolicyViolation(result: [])))
                    }

                    it("should raise error, length good, includes numbers, includes lower, missing upper") {
                        expect{ try database.update(.password(enforcePolicy: true), value: "123a5678") }.to(throwError(InputValidationError.passwordPolicyViolation(result: [])))
                    }

                    it("should pass, length good, includes numbers, includes lower, includes upper, no special") {
                        expect{ try database.update(.password(enforcePolicy: true), value: "123a5A78") }.toNot(throwError(InputValidationError.passwordPolicyViolation(result: [])))
                    }

                    it("should pass, length good, includes numbers, includes lower, no upper, includes special") {
                        expect{ try database.update(.password(enforcePolicy: true), value: "123a5b78$") }.toNot(throwError(InputValidationError.passwordPolicyViolation(result: [])))
                    }
                }

                context("password excellent, 10 min, 3/4 rules, no more than 2 identical characters in a row") {

                    beforeEach {
                        Auth0Stubs.failUnknown()
                        user = User()
                        let db = DatabaseConnection(name: connection, requiresUsername: true, usernameValidator: UsernameValidator(withLength: 1...15, characterSet: UsernameValidator.auth0), passwordValidator: PasswordPolicyValidator(policy: .excellent))
                        database = DatabaseInteractor(connection: db, authentication: authentication, user: user, options: LockOptions(), dispatcher: ObserverStore())
                    }

                    it("should raise error if password is <10 characters") {
                        expect{ try database.update(.password(enforcePolicy: true), value: "12345") }.to(throwError(InputValidationError.passwordPolicyViolation(result: [])))
                    }

                    it("should raise error, length good, but does not meet 3/4 rules") {
                        expect{ try database.update(.password(enforcePolicy: true), value: "12345678") }.to(throwError(InputValidationError.passwordPolicyViolation(result: [])))
                    }

                    it("should raise error, length good, includes numbers, includes lower, missing upper") {
                        expect{ try database.update(.password(enforcePolicy: true), value: "123456789a") }.to(throwError(InputValidationError.passwordPolicyViolation(result: [])))
                    }

                    it("should pass, length good, includes numbers, includes lower, includes upper, no special") {
                        expect{ try database.update(.password(enforcePolicy: true), value: "12345678aA") }.toNot(throwError(InputValidationError.passwordPolicyViolation(result: [])))
                    }

                    it("should pass, length good, includes numbers, includes lower, no upper, includes special") {
                        expect{ try database.update(.password(enforcePolicy: true), value: "12345678a$") }.toNot(throwError(InputValidationError.passwordPolicyViolation(result: [])))
                    }

                    it("should raise error, 3 char in a row, length good, includes numbers, includes lower, no upper, includes special") {
                        expect{ try database.update(.password(enforcePolicy: true), value: "1aaa5678a$9") }.to(throwError(InputValidationError.passwordPolicyViolation(result: [])))
                    }
                }
            }

            // MARK:- Attribute Validation
            describe("custom attribute validation") {

                beforeEach {
                    var options = LockOptions()
                    options.customSignupFields = [CustomTextField(name: "first_name", placeholder: "First Name", icon: LazyImage(name: "ic_person", bundle: Lock.bundle))]
                    database = DatabaseInteractor(connection: DatabaseConnection(name: connection, requiresUsername: true), authentication: authentication, user: user, options: options, dispatcher: ObserverStore())
                }

                it("should always store value") {
                    let _ = try? database.update(.custom(name: "first_name"), value: "Auth0")
                    expect(user.additionalAttributes["first_name"]) == "Auth0"
                }

                it("should raise error if value is empty") {
                    expect{ try database.update(.custom(name: "first_name"), value: "") }.to(throwError(InputValidationError.mustNotBeEmpty))
                }

                it("should raise error if password is only spaces") {
                    expect{ try database.update(.custom(name: "first_name"), value: "     ") }.to(throwError(InputValidationError.mustNotBeEmpty))
                }

                it("should raise error if password is nil") {
                    expect{ try database.update(.custom(name: "first_name"), value: nil) }.to(throwError(InputValidationError.mustNotBeEmpty))
                }

                it("should raise error for custom validation") {
                    var options = LockOptions()
                    let error = NSError(domain: "com.auth0", code: -99999, userInfo: [:])
                    options.customSignupFields = [CustomTextField(name: "first_name", placeholder: "First Name", icon: LazyImage(name: "ic_person", bundle: Lock.bundle), validation: { _ in return error })]
                    database = DatabaseInteractor(connection: DatabaseConnection(name: connection, requiresUsername: true), authentication: authentication, user: user, options: options, dispatcher: ObserverStore())
                    expect{ try database.update(.custom(name: "first_name"), value: nil) }.to(throwError(error))
                }

            }

        }

        // MARK: - Login
        describe("login") {

            beforeEach {
                options = LockOptions()
                options.oidcConformant = false

                Auth0Stubs.failUnknown()
                user = User()
                let db = DatabaseConnection(name: connection, requiresUsername: true, usernameValidator: UsernameValidator(withLength: 1...15, characterSet: UsernameValidator.auth0), passwordValidator: PasswordPolicyValidator(policy: .good))
                database = DatabaseInteractor(connection: db, authentication: authentication, user: user, options: options, dispatcher: ObserverStore())
            }

            it("should yield no error on success") {
                stub(condition: databaseLogin(identifier: email, password: password, connection: connection)) { _ in return Auth0Stubs.authentication() }
                try! database.update(.email, value: email)
                try! database.update(.password(enforcePolicy: false), value: password)
                waitUntil(timeout: 2) { done in
                    database.login { error in
                        expect(error).to(beNil())
                        done()
                    }
                }
            }

            it("should prefer email over username") {
                stub(condition: databaseLogin(identifier: email, password: password, connection: connection)) { _ in return Auth0Stubs.authentication() }
                try! database.update(.email, value: email)
                try! database.update(.username, value: username)
                try! database.update(.password(enforcePolicy: false), value: password)
                waitUntil(timeout: 2) { done in
                    database.login { error in
                        expect(error).to(beNil())
                        done()
                    }
                }
            }

            it("should send scope") {
                let scope = "openid email"
                var options = LockOptions()
                options.scope = scope
                database = DatabaseInteractor(connection: DatabaseConnection(name: connection, requiresUsername: true), authentication: authentication, user: user, options: options, dispatcher: ObserverStore())
                stub(condition: databaseLogin(identifier: email, password: password, connection: connection) && hasEntry(key: "scope", value: scope)) { _ in return Auth0Stubs.authentication() }
                try! database.update(.email, value: email)
                try! database.update(.username, value: username)
                try! database.update(.password(enforcePolicy: false), value: password)
                waitUntil(timeout: 2) { done in
                    database.login { error in
                        expect(error).to(beNil())
                        done()
                    }
                }
            }

            it("should send parameters") {
                let state = UUID().uuidString
                var options = LockOptions()
                options.parameters = ["state": state as Any]
                database = DatabaseInteractor(connection: DatabaseConnection(name: connection, requiresUsername: true), authentication: authentication, user: user, options: options, dispatcher: ObserverStore())
                stub(condition: databaseLogin(identifier: email, password: password, connection: connection) && hasEntry(key: "state", value: state)) { _ in return Auth0Stubs.authentication() }
                try! database.update(.email, value: email)
                try! database.update(.username, value: username)
                try! database.update(.password(enforcePolicy: false), value: password)
                waitUntil(timeout: 2) { done in
                    database.login { error in
                        expect(error).to(beNil())
                        done()
                    }
                }
            }

            it("should use username") {
                stub(condition: databaseLogin(identifier: username, password: password, connection: connection)) { _ in return Auth0Stubs.authentication() }
                try! database.update(.username, value: username)
                try! database.update(.password(enforcePolicy: false), value: password)
                waitUntil(timeout: 2) { done in
                    database.login { error in
                        expect(error).to(beNil())
                        done()
                    }
                }
            }

            it("should yield error on failure") {
                stub(condition: databaseLogin(identifier: email, password: password, connection: connection)) { _ in return Auth0Stubs.failure() }
                try! database.update(.email, value: email)
                try! database.update(.password(enforcePolicy: false), value: password)
                waitUntil(timeout: 2) { done in
                    database.login { error in
                        expect(error) == .couldNotLogin
                        done()
                    }
                }
            }

            it("should yield invalid credentials error on failure") {
                stub(condition: databaseLogin(identifier: email, password: password, connection: connection)) { _ in return Auth0Stubs.failure("invalid_user_password") }
                try! database.update(.email, value: email)
                try! database.update(.password(enforcePolicy: false), value: password)
                waitUntil(timeout: 2) { done in
                    database.login { error in
                        expect(error) == .invalidEmailPassword
                        done()
                    }
                }
            }

            it("should indicate that mfa is required") {
                stub(condition: databaseLogin(identifier: email, password: password, connection: connection)) { _ in return Auth0Stubs.failure("a0.mfa_required") }
                try! database.update(.email, value: email)
                try! database.update(.password(enforcePolicy: false), value: password)
                waitUntil(timeout: 2) { done in
                    database.login { error in
                        expect(error) == .multifactorRequired
                        done()
                    }
                }
            }

            it("should indicate that mfa is required") {
                stub(condition: databaseLogin(identifier: email, password: password, connection: connection)) { _ in return Auth0Stubs.failure("a0.mfa_registration_required") }
                try! database.update(.email, value: email)
                try! database.update(.password(enforcePolicy: false), value: password)
                waitUntil(timeout: 2) { done in
                    database.login { error in
                        expect(error) == .multifactorRequired
                        done()
                    }
                }
            }

            it("should yield error when input is not valid") {
                waitUntil(timeout: 2) { done in
                    database.login { error in
                        expect(error) == .nonValidInput
                        done()
                    }
                }
            }

            it("should indicate the user is blocked for too many attempts") {
                stub(condition: databaseLogin(identifier: email, password: password, connection: connection)) { _ in return Auth0Stubs.failure("too_many_attempts") }
                try! database.update(.email, value: email)
                try! database.update(.password(enforcePolicy: false), value: password)
                waitUntil(timeout: 2) { done in
                    database.login { error in
                        expect(error) == .tooManyAttempts
                        done()
                    }
                }
            }

            it("should indicate the user is blocked") {
                stub(condition: databaseLogin(identifier: email, password: password, connection: connection)) { _ in return Auth0Stubs.failure("unauthorized", description: "user is blocked") }
                try! database.update(.email, value: email)
                try! database.update(.password(enforcePolicy: false), value: password)
                waitUntil(timeout: 2) { done in
                    database.login { error in
                        expect(error) == .userBlocked
                        done()
                    }
                }
            }

            it("should indicate the password needs to be changed") {
                stub(condition: databaseLogin(identifier: email, password: password, connection: connection)) { _ in return Auth0Stubs.failure("password_change_required") }
                try! database.update(.email, value: email)
                try! database.update(.password(enforcePolicy: false), value: password)
                waitUntil(timeout: 2) { done in
                    database.login { error in
                        expect(error) == .passwordChangeRequired
                        done()
                    }
                }
            }

            it("should indicate the password is leaked") {
                stub(condition: databaseLogin(identifier: email, password: password, connection: connection)) { _ in return Auth0Stubs.failure("password_leaked") }
                try! database.update(.email, value: email)
                try! database.update(.password(enforcePolicy: false), value: password)
                waitUntil(timeout: 2) { done in
                    database.login { error in
                        expect(error) == .passwordLeaked
                        done()
                    }
                }
            }

            it("should indicate that a custom rule prevented the user from logging in") {
                stub(condition: databaseLogin(identifier: email, password: password, connection: connection)) { _ in return Auth0Stubs.failure("unauthorized", description: "Only admins can use this") }
                try! database.update(.email, value: email)
                try! database.update(.password(enforcePolicy: false), value: password)
                waitUntil(timeout: 2) { done in
                    database.login { error in
                        expect(error) == .customRuleFailure(cause: "Only admins can use this")
                        done()
                    }
                }
            }
        }

        describe("login OIDC Conformant") {

            beforeEach {
                options = LockOptions()
                options.oidcConformant = true

                Auth0Stubs.failUnknown()
                user = User()
                let db = DatabaseConnection(name: connection, requiresUsername: true, usernameValidator: UsernameValidator(withLength: 1...15, characterSet: UsernameValidator.auth0), passwordValidator: PasswordPolicyValidator(policy: .good))
                database = DatabaseInteractor(connection: db, authentication: authentication, user: user, options: options, dispatcher: ObserverStore())
            }

            it("should yield no error on success") {
                stub(condition: realmLogin(identifier: email, password: password, realm: connection)) { _ in return Auth0Stubs.authentication() }
                try! database.update(.email, value: email)
                try! database.update(.password(enforcePolicy: false), value: password)
                waitUntil(timeout: 2) { done in
                    database.login { error in
                        expect(error).to(beNil())
                        done()
                    }
                }
            }

            it("should prefer email over username") {
                stub(condition: realmLogin(identifier: email, password: password, realm: connection)) { _ in return Auth0Stubs.authentication() }
                try! database.update(.email, value: email)
                try! database.update(.username, value: username)
                try! database.update(.password(enforcePolicy: false), value: password)
                waitUntil(timeout: 2) { done in
                    database.login { error in
                        expect(error).to(beNil())
                        done()
                    }
                }
            }

            it("should send scope") {
                let scope = "openid email"
                var options = LockOptions()
                options.oidcConformant = true
                options.scope = scope
                database = DatabaseInteractor(connection: DatabaseConnection(name: connection, requiresUsername: true), authentication: authentication, user: user, options: options, dispatcher: ObserverStore())
                stub(condition: realmLogin(identifier: email, password: password, realm: connection) && hasEntry(key: "scope", value: scope)) { _ in return Auth0Stubs.authentication() }
                try! database.update(.email, value: email)
                try! database.update(.username, value: username)
                try! database.update(.password(enforcePolicy: false), value: password)
                waitUntil(timeout: 2) { done in
                    database.login { error in
                        expect(error).to(beNil())
                        done()
                    }
                }
            }

            it("should use username") {
                stub(condition: realmLogin(identifier: username, password: password, realm: connection)) { _ in return Auth0Stubs.authentication() }
                try! database.update(.username, value: username)
                try! database.update(.password(enforcePolicy: false), value: password)
                waitUntil(timeout: 2) { done in
                    database.login { error in
                        expect(error).to(beNil())
                        done()
                    }
                }
            }

            it("should yield error on failure") {
                stub(condition: realmLogin(identifier: email, password: password, realm: connection)) { _ in return Auth0Stubs.failure() }
                try! database.update(.email, value: email)
                try! database.update(.password(enforcePolicy: false), value: password)
                waitUntil(timeout: 2) { done in
                    database.login { error in
                        expect(error) == .couldNotLogin
                        done()
                    }
                }
            }

            it("should yield invalid credentials error on failure") {
                stub(condition: realmLogin(identifier: email, password: password, realm: connection)) { _ in return Auth0Stubs.failure("invalid_user_password") }
                try! database.update(.email, value: email)
                try! database.update(.password(enforcePolicy: false), value: password)
                waitUntil(timeout: 2) { done in
                    database.login { error in
                        expect(error) == .invalidEmailPassword
                        done()
                    }
                }
            }

            it("should indicate that mfa is required") {
                stub(condition: realmLogin(identifier: email, password: password, realm: connection)) { _ in return Auth0Stubs.failure("a0.mfa_required") }
                try! database.update(.email, value: email)
                try! database.update(.password(enforcePolicy: false), value: password)
                waitUntil(timeout: 2) { done in
                    database.login { error in
                        expect(error) == .multifactorRequired
                        done()
                    }
                }
            }

            it("should indicate that mfa is required") {
                stub(condition: realmLogin(identifier: email, password: password, realm: connection)) { _ in return Auth0Stubs.failure("a0.mfa_registration_required") }
                try! database.update(.email, value: email)
                try! database.update(.password(enforcePolicy: false), value: password)
                waitUntil(timeout: 2) { done in
                    database.login { error in
                        expect(error) == .multifactorRequired
                        done()
                    }
                }
            }

            it("should yield error when input is not valid") {
                waitUntil(timeout: 2) { done in
                    database.login { error in
                        expect(error) == .nonValidInput
                        done()
                    }
                }
            }

            it("should indicate the user is blocked for too many attempts") {
                stub(condition: realmLogin(identifier: email, password: password, realm: connection)) { _ in return Auth0Stubs.failure("too_many_attempts") }
                try! database.update(.email, value: email)
                try! database.update(.password(enforcePolicy: false), value: password)
                waitUntil(timeout: 2) { done in
                    database.login { error in
                        expect(error) == .tooManyAttempts
                        done()
                    }
                }
            }

            it("should indicate the user is blocked") {
                stub(condition: realmLogin(identifier: email, password: password, realm: connection)) { _ in return Auth0Stubs.failure("unauthorized", description: "user is blocked") }
                try! database.update(.email, value: email)
                try! database.update(.password(enforcePolicy: false), value: password)
                waitUntil(timeout: 2) { done in
                    database.login { error in
                        expect(error) == .userBlocked
                        done()
                    }
                }
            }

            it("should indicate the password needs to be changed") {
                stub(condition: realmLogin(identifier: email, password: password, realm: connection)) { _ in return Auth0Stubs.failure("password_change_required") }
                try! database.update(.email, value: email)
                try! database.update(.password(enforcePolicy: false), value: password)
                waitUntil(timeout: 2) { done in
                    database.login { error in
                        expect(error) == .passwordChangeRequired
                        done()
                    }
                }
            }

            it("should indicate the password is leaked") {
                stub(condition: realmLogin(identifier: email, password: password, realm: connection)) { _ in return Auth0Stubs.failure("password_leaked") }
                try! database.update(.email, value: email)
                try! database.update(.password(enforcePolicy: false), value: password)
                waitUntil(timeout: 2) { done in
                    database.login { error in
                        expect(error) == .passwordLeaked
                        done()
                    }
                }
            }

            it("should indicate that a custom rule prevented the user from logging in") {
                stub(condition: realmLogin(identifier: email, password: password, realm: connection)) { _ in return Auth0Stubs.failure("unauthorized", description: "Only admins can use this") }
                try! database.update(.email, value: email)
                try! database.update(.password(enforcePolicy: false), value: password)
                waitUntil(timeout: 2) { done in
                    database.login { error in
                        expect(error) == .customRuleFailure(cause: "Only admins can use this")
                        done()
                    }
                }
            }
        }

        // MARK: - Signup
        describe("signup") {

            beforeEach {
                options = LockOptions()
                options.oidcConformant = false

                Auth0Stubs.failUnknown()
                user = User()
                let db = DatabaseConnection(name: connection, requiresUsername: true, usernameValidator: UsernameValidator(withLength: 1...15, characterSet: UsernameValidator.auth0), passwordValidator: PasswordPolicyValidator(policy: .good))
                database = DatabaseInteractor(connection: db, authentication: authentication, user: user, options: options, dispatcher: ObserverStore())
            }

            it("should yield no error on success") {
                stub(condition: databaseSignUp(email: email, username: username, password: password, connection: connection)) { _ in return Auth0Stubs.createdUser(email) }
                stub(condition: databaseLogin(identifier: email, password: password, connection: connection)) { _ in return Auth0Stubs.authentication() }
                try! database.update(.email, value: email)
                try! database.update(.username, value: username)
                try! database.update(.password(enforcePolicy: false), value: password)
                waitUntil(timeout: 2) { done in
                    database.create { create, login in
                        expect(create).to(beNil())
                        expect(login).to(beNil())
                        done()
                    }
                }
            }

            it("should not send username") {
                let username = "AN INVALID USERNAME"
                database = DatabaseInteractor(connection: DatabaseConnection(name: connection, requiresUsername: false), authentication: authentication, user: user, options: options, dispatcher: ObserverStore())
                stub(condition: databaseSignUp(email: email, password: password, connection: connection) && !hasEntry(key: "username", value: username)) { _ in return Auth0Stubs.createdUser(email) }
                stub(condition: databaseLogin(identifier: email, password: password, connection: connection)) { _ in return Auth0Stubs.authentication() }
                try! database.update(.email, value: email)
                let _ = try? database.update(.username, value: username)
                try! database.update(.password(enforcePolicy: false), value: password)
                waitUntil(timeout: 2) { done in
                    database.create { create, login in
                        expect(create).to(beNil())
                        expect(login).to(beNil())
                        done()
                    }
                }
            }

            it("should indicate that mfa is required") {
                stub(condition: databaseSignUp(email: email, username: username, password: password, connection: connection)) { _ in return Auth0Stubs.createdUser(email) }
                stub(condition: databaseLogin(identifier: email, password: password, connection: connection)) { _ in return Auth0Stubs.failure("a0.mfa_required") }
                try! database.update(.email, value: email)
                try! database.update(.username, value: username)
                try! database.update(.password(enforcePolicy: false), value: password)
                waitUntil(timeout: 2) { done in
                    database.create { create, login in
                        expect(create).to(beNil())
                        expect(login) == .multifactorRequired
                        done()
                    }
                }
            }

            context("auto log in after sign up") {

                var options = LockOptions()

                beforeEach {
                    options.loginAfterSignup = true
                    let db = DatabaseConnection(name: connection, requiresUsername: true, usernameValidator: UsernameValidator(withLength: 1...15, characterSet: UsernameValidator.auth0), passwordValidator: PasswordPolicyValidator(policy: .good))
                    database = DatabaseInteractor(connection: db, authentication: authentication, user: user, options: options, dispatcher: ObserverStore())
                }

                it("should yield no error on success") {
                    stub(condition: databaseSignUp(email: email, username: username, password: password, connection: connection)) { _ in return Auth0Stubs.createdUser(email) }
                    stub(condition: databaseLogin(identifier: email, password: password, connection: connection)) { _ in return Auth0Stubs.authentication() }
                    try! database.update(.email, value: email)
                    try! database.update(.username, value: username)
                    try! database.update(.password(enforcePolicy: false), value: password)
                    waitUntil(timeout: 2) { done in
                        database.create { create, login in
                            expect(create).to(beNil())
                            expect(login).to(beNil())
                            done()
                        }
                    }
                }

                it("should not send username") {
                    let username = "AN INVALID USERNAME"
                    database = DatabaseInteractor(connection: DatabaseConnection(name: connection, requiresUsername: false), authentication: authentication, user: user, options: options, dispatcher: ObserverStore())
                    stub(condition: databaseSignUp(email: email, password: password, connection: connection) && !hasEntry(key: "username", value: username)) { _ in return Auth0Stubs.createdUser(email) }
                    stub(condition: databaseLogin(identifier: email, password: password, connection: connection)) { _ in return Auth0Stubs.authentication() }
                    try! database.update(.email, value: email)
                    let _ = try? database.update(.username, value: username)
                    try! database.update(.password(enforcePolicy: false), value: password)
                    waitUntil(timeout: 2) { done in
                        database.create { create, login in
                            expect(create).to(beNil())
                            expect(login).to(beNil())
                            done()
                        }
                    }
                }

                it("should indicate that mfa is required") {
                    stub(condition: databaseSignUp(email: email, username: username, password: password, connection: connection)) { _ in return Auth0Stubs.createdUser(email) }
                    stub(condition: databaseLogin(identifier: email, password: password, connection: connection)) { _ in return Auth0Stubs.failure("a0.mfa_required") }
                    try! database.update(.email, value: email)
                    try! database.update(.username, value: username)
                    try! database.update(.password(enforcePolicy: false), value: password)
                    waitUntil(timeout: 2) { done in
                        database.create { create, login in
                            expect(create).to(beNil())
                            expect(login) == .multifactorRequired
                            done()
                        }
                    }
                }

                it("should yield error on login failure") {
                    stub(condition: databaseSignUp(email: email, username: username, password: password, connection: connection)) { _ in return Auth0Stubs.createdUser(email) }
                    stub(condition: databaseLogin(identifier: email, password: password, connection: connection)) { _ in return Auth0Stubs.failure() }
                    try! database.update(.email, value: email)
                    try! database.update(.username, value: username)
                    try! database.update(.password(enforcePolicy: false), value: password)
                    waitUntil(timeout: 2) { done in
                        database.create { create, login in
                            expect(create).to(beNil())
                            expect(login) == .couldNotLogin
                            done()
                        }
                    }
                }

                it("should yield error on signup failure") {
                    stub(condition: databaseSignUp(email: email, username: username, password: password, connection: connection)) { _ in return Auth0Stubs.failure() }
                    try! database.update(.email, value: email)
                    try! database.update(.username, value: username)
                    try! database.update(.password(enforcePolicy: false), value: password)
                    waitUntil(timeout: 2) { done in
                        database.create { create, login in
                            expect(create) == .couldNotCreateUser
                            done()
                        }
                    }
                }

                it("should yield invalid password") {
                    stub(condition: databaseSignUp(email: email, username: username, password: password, connection: connection)) { _ in return Auth0Stubs.failure("invalid_password") }
                    try! database.update(.email, value: email)
                    try! database.update(.username, value: username)
                    try! database.update(.password(enforcePolicy: false), value: password)
                    waitUntil(timeout: 2) { done in
                        database.create { create, login in
                            expect(create) == .passwordInvalid
                            done()
                        }
                    }
                }

                it("should yield password too weak") {
                    stub(condition: databaseSignUp(email: email, username: username, password: password, connection: connection)) { _ in return Auth0Stubs.failure("invalid_password", name: "PasswordStrengthError") }
                    try! database.update(.email, value: email)
                    try! database.update(.username, value: username)
                    try! database.update(.password(enforcePolicy: false), value: password)
                    waitUntil(timeout: 2) { done in
                        database.create { create, login in
                            expect(create) == .passwordTooWeak
                            done()
                        }
                    }
                }

                it("should yield password already used") {
                    stub(condition: databaseSignUp(email: email, username: username, password: password, connection: connection)) { _ in return Auth0Stubs.failure("invalid_password", name: "PasswordHistoryError") }
                    try! database.update(.email, value: email)
                    try! database.update(.username, value: username)
                    try! database.update(.password(enforcePolicy: false), value: password)
                    waitUntil(timeout: 2) { done in
                        database.create { create, login in
                            expect(create) == .passwordAlreadyUsed
                            done()
                        }
                    }
                }

                it("should yield password too common") {
                    stub(condition: databaseSignUp(email: email, username: username, password: password, connection: connection)) { _ in return Auth0Stubs.failure("invalid_password", name: "PasswordDictionaryError") }
                    try! database.update(.email, value: email)
                    try! database.update(.username, value: username)
                    try! database.update(.password(enforcePolicy: false), value: password)
                    waitUntil(timeout: 2) { done in
                        database.create { create, login in
                            expect(create) == .passwordTooCommon
                            done()
                        }
                    }
                }
            }

            it("should yield error on login failure") {
                stub(condition: databaseSignUp(email: email, username: username, password: password, connection: connection)) { _ in return Auth0Stubs.createdUser(email) }
                stub(condition: databaseLogin(identifier: email, password: password, connection: connection)) { _ in return Auth0Stubs.failure() }
                try! database.update(.email, value: email)
                try! database.update(.username, value: username)
                try! database.update(.password(enforcePolicy: false), value: password)
                waitUntil(timeout: 2) { done in
                    database.create { create, login in
                        expect(create).to(beNil())
                        expect(login) == .couldNotLogin
                        done()
                    }
                }
            }

            it("should yield password has user info") {
                stub(condition: databaseSignUp(email: email, username: username, password: password, connection: connection)) { _ in return Auth0Stubs.failure("invalid_password", name: "PasswordNoUserInfoError") }
                try! database.update(.email, value: email)
                try! database.update(.username, value: username)
                try! database.update(.password(enforcePolicy: false), value: password)
                waitUntil(timeout: 2) { done in
                    database.create { create, login in
                        expect(create) == .passwordHasUserInfo
                        done()
                    }
                }
            }

            it("should yield error when input is not valid") {
                waitUntil(timeout: 2) { done in
                    database.create { create, login in
                        expect(create) == .nonValidInput
                        done()
                    }
                }
            }

            it("should yield error when username is not valid and required") {
                try! database.update(.email, value: email)
                try! database.update(.password(enforcePolicy: false), value: password)
                waitUntil(timeout: 2) { done in
                    database.create { create, login in
                        expect(create) == .nonValidInput
                        done()
                    }
                }
            }


            it("should send scope on login") {
                let scope = "openid email"
                options.scope = scope
                database = DatabaseInteractor(connection: DatabaseConnection(name: connection, requiresUsername: true), authentication: authentication, user: user, options: options, dispatcher: ObserverStore())
                stub(condition: databaseSignUp(email: email, username: username, password: password, connection: connection)) { _ in return Auth0Stubs.createdUser(email) }
                stub(condition: databaseLogin(identifier: email, password: password, connection: connection) && hasEntry(key: "scope", value: scope)) { _ in return Auth0Stubs.authentication() }
                try! database.update(.email, value: email)
                try! database.update(.username, value: username)
                try! database.update(.password(enforcePolicy: false), value: password)
                waitUntil(timeout: 2) { done in
                    database.create { create, login in
                        expect(create).to(beNil())
                        expect(login).to(beNil())
                        done()
                    }
                }
            }

            it("should send parameters on login") {
                let state = UUID().uuidString
                options.parameters = ["state": state as Any]
                database = DatabaseInteractor(connection: DatabaseConnection(name: connection, requiresUsername: true), authentication: authentication, user: user, options: options, dispatcher: ObserverStore())
                stub(condition: databaseSignUp(email: email, username: username, password: password, connection: connection)) { _ in return Auth0Stubs.createdUser(email) }
                stub(condition: databaseLogin(identifier: email, password: password, connection: connection) && hasEntry(key: "state", value: state)) { _ in return Auth0Stubs.authentication() }
                try! database.update(.email, value: email)
                try! database.update(.username, value: username)
                try! database.update(.password(enforcePolicy: false), value: password)
                waitUntil(timeout: 2) { done in
                    database.create { create, login in
                        expect(create).to(beNil())
                        expect(login).to(beNil())
                        done()
                    }
                }
            }
        }

        describe("signup OIDC Conformnant") {

            beforeEach {
                options = LockOptions()
                options.oidcConformant = true

                Auth0Stubs.failUnknown()
                user = User()
                let db = DatabaseConnection(name: connection, requiresUsername: true, usernameValidator: UsernameValidator(withLength: 1...15, characterSet: UsernameValidator.auth0), passwordValidator: PasswordPolicyValidator(policy: .good))
                database = DatabaseInteractor(connection: db, authentication: authentication, user: user, options: options, dispatcher: ObserverStore())
            }

            it("should yield no error on success") {
                stub(condition: databaseSignUp(email: email, username: username, password: password, connection: connection)) { _ in return Auth0Stubs.createdUser(email) }
                stub(condition: realmLogin(identifier: email, password: password, realm: connection)) { _ in return Auth0Stubs.authentication() }
                try! database.update(.email, value: email)
                try! database.update(.username, value: username)
                try! database.update(.password(enforcePolicy: false), value: password)
                waitUntil(timeout: 2) { done in
                    database.create { create, login in
                        expect(create).to(beNil())
                        expect(login).to(beNil())
                        done()
                    }
                }
            }

            it("should not send username") {
                let username = "AN INVALID USERNAME"
                database = DatabaseInteractor(connection: DatabaseConnection(name: connection, requiresUsername: false), authentication: authentication, user: user, options: options, dispatcher: ObserverStore())
                stub(condition: databaseSignUp(email: email, password: password, connection: connection) && !hasEntry(key: "username", value: username)) { _ in return Auth0Stubs.createdUser(email) }
                stub(condition: realmLogin(identifier: email, password: password, realm: connection)) { _ in return Auth0Stubs.authentication() }
                try! database.update(.email, value: email)
                let _ = try? database.update(.username, value: username)
                try! database.update(.password(enforcePolicy: false), value: password)
                waitUntil(timeout: 2) { done in
                    database.create { create, login in
                        expect(create).to(beNil())
                        expect(login).to(beNil())
                        done()
                    }
                }
            }

            it("should indicate that mfa is required") {
                stub(condition: databaseSignUp(email: email, username: username, password: password, connection: connection)) { _ in return Auth0Stubs.createdUser(email) }
                stub(condition: realmLogin(identifier: email, password: password, realm: connection)) { _ in return Auth0Stubs.failure("a0.mfa_required") }
                try! database.update(.email, value: email)
                try! database.update(.username, value: username)
                try! database.update(.password(enforcePolicy: false), value: password)
                waitUntil(timeout: 2) { done in
                    database.create { create, login in
                        expect(create).to(beNil())
                        expect(login) == .multifactorRequired
                        done()
                    }
                }
            }

            it("should yield error on login failure") {
                stub(condition: databaseSignUp(email: email, username: username, password: password, connection: connection)) { _ in return Auth0Stubs.createdUser(email) }
                stub(condition: databaseLogin(identifier: email, password: password, connection: connection)) { _ in return Auth0Stubs.failure() }
                try! database.update(.email, value: email)
                try! database.update(.username, value: username)
                try! database.update(.password(enforcePolicy: false), value: password)
                waitUntil(timeout: 2) { done in
                    database.create { create, login in
                        expect(create).to(beNil())
                        expect(login) == .couldNotLogin
                        done()
                    }
                }
            }

            it("should yield error on signup failure") {
                stub(condition: databaseSignUp(email: email, username: username, password: password, connection: connection)) { _ in return Auth0Stubs.failure() }
                try! database.update(.email, value: email)
                try! database.update(.username, value: username)
                try! database.update(.password(enforcePolicy: false), value: password)
                waitUntil(timeout: 2) { done in
                    database.create { create, login in
                        expect(create) == .couldNotCreateUser
                        done()
                    }
                }
            }

            it("should yield invalid password") {
                stub(condition: databaseSignUp(email: email, username: username, password: password, connection: connection)) { _ in return Auth0Stubs.failure("invalid_password") }
                try! database.update(.email, value: email)
                try! database.update(.username, value: username)
                try! database.update(.password(enforcePolicy: false), value: password)
                waitUntil(timeout: 2) { done in
                    database.create { create, login in
                        expect(create) == .passwordInvalid
                        done()
                    }
                }
            }

            it("should yield password too weak") {
                stub(condition: databaseSignUp(email: email, username: username, password: password, connection: connection)) { _ in return Auth0Stubs.failure("invalid_password", name: "PasswordStrengthError") }
                try! database.update(.email, value: email)
                try! database.update(.username, value: username)
                try! database.update(.password(enforcePolicy: false), value: password)
                waitUntil(timeout: 2) { done in
                    database.create { create, login in
                        expect(create) == .passwordTooWeak
                        done()
                    }
                }
            }

            it("should yield password already used") {
                stub(condition: databaseSignUp(email: email, username: username, password: password, connection: connection)) { _ in return Auth0Stubs.failure("invalid_password", name: "PasswordHistoryError") }
                try! database.update(.email, value: email)
                try! database.update(.username, value: username)
                try! database.update(.password(enforcePolicy: false), value: password)
                waitUntil(timeout: 2) { done in
                    database.create { create, login in
                        expect(create) == .passwordAlreadyUsed
                        done()
                    }
                }
            }

            it("should yield password too common") {
                stub(condition: databaseSignUp(email: email, username: username, password: password, connection: connection)) { _ in return Auth0Stubs.failure("invalid_password", name: "PasswordDictionaryError") }
                try! database.update(.email, value: email)
                try! database.update(.username, value: username)
                try! database.update(.password(enforcePolicy: false), value: password)
                waitUntil(timeout: 2) { done in
                    database.create { create, login in
                        expect(create) == .passwordTooCommon
                        done()
                    }
                }
            }

            it("should yield password has user info") {
                stub(condition: databaseSignUp(email: email, username: username, password: password, connection: connection)) { _ in return Auth0Stubs.failure("invalid_password", name: "PasswordNoUserInfoError") }
                try! database.update(.email, value: email)
                try! database.update(.username, value: username)
                try! database.update(.password(enforcePolicy: false), value: password)
                waitUntil(timeout: 2) { done in
                    database.create { create, login in
                        expect(create) == .passwordHasUserInfo
                        done()
                    }
                }
            }

            it("should yield error when input is not valid") {
                waitUntil(timeout: 2) { done in
                    database.create { create, login in
                        expect(create) == .nonValidInput
                        done()
                    }
                }
            }

            it("should yield error when username is not valid and required") {
                try! database.update(.email, value: email)
                try! database.update(.password(enforcePolicy: false), value: password)
                waitUntil(timeout: 2) { done in
                    database.create { create, login in
                        expect(create) == .nonValidInput
                        done()
                    }
                }
            }


            it("should send scope on login") {
                let scope = "openid email"
                var options = LockOptions()
                options.scope = scope
                database = DatabaseInteractor(connection: DatabaseConnection(name: connection, requiresUsername: true), authentication: authentication, user: user, options: options, dispatcher: ObserverStore())
                stub(condition: databaseSignUp(email: email, username: username, password: password, connection: connection)) { _ in return Auth0Stubs.createdUser(email) }
                stub(condition: databaseLogin(identifier: email, password: password, connection: connection) && hasEntry(key: "scope", value: scope)) { _ in return Auth0Stubs.authentication() }
                try! database.update(.email, value: email)
                try! database.update(.username, value: username)
                try! database.update(.password(enforcePolicy: false), value: password)
                waitUntil(timeout: 2) { done in
                    database.create { create, login in
                        expect(create).to(beNil())
                        expect(login).to(beNil())
                        done()
                    }
                }
            }
            
            it("should send parameters on login") {
                let state = UUID().uuidString
                var options = LockOptions()
                options.parameters = ["state": state as Any]
                database = DatabaseInteractor(connection: DatabaseConnection(name: connection, requiresUsername: true), authentication: authentication, user: user, options: options, dispatcher: ObserverStore())
                stub(condition: databaseSignUp(email: email, username: username, password: password, connection: connection)) { _ in return Auth0Stubs.createdUser(email) }
                stub(condition: databaseLogin(identifier: email, password: password, connection: connection) && hasEntry(key: "state", value: state)) { _ in return Auth0Stubs.authentication() }
                try! database.update(.email, value: email)
                try! database.update(.username, value: username)
                try! database.update(.password(enforcePolicy: false), value: password)
                waitUntil(timeout: 2) { done in
                    database.create { create, login in
                        expect(create).to(beNil())
                        expect(login).to(beNil())
                        done()
                    }
                }
            }
            
        }
        
    }
}
