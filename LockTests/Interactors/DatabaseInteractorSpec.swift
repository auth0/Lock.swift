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
            let database = DatabaseInteractor(connections: OfflineConnections(), authentication: authentication, user: User(), options: LockOptions(), callback: {_ in})

            it("should build with authentication") {
                expect(database).toNot(beNil())
            }

            it("should have authentication object") {
                expect(database.authentication.clientId) == "CLIENT_ID"
                expect(database.authentication.url.host) == "samples.auth0.com"
            }
        }


        var connections: OfflineConnections!
        var database: DatabaseInteractor!
        var user: User!

        beforeEach {
            Auth0Stubs.failUnknown()
            connections = OfflineConnections()
            connections.database(name: connection, requiresUsername: true)
            user = User()
            database = DatabaseInteractor(connections: connections, authentication: authentication, user: user, options: LockOptions(), callback: { _ in })
        }

        describe("updateAttribute") {

            it("should update email") {
                expect{ try database.update(.Email, value: email) }.toNot(throwError())
                expect(database.email) == email
                expect(database.username).to(beNil())
                expect(database.password).to(beNil())
            }

            it("should trim email") {
                expect{ try database.update(.Email, value: "  \(email)      ") }.toNot(throwError())
                expect(database.email) == email
            }

            it("should update username") {
                expect{ try database.update(.Username, value: username) }.toNot(throwError())
                expect(database.username) == username
                expect(database.email).to(beNil())
                expect(database.password).to(beNil())
            }

            it("should update username or email with an email") {
                expect{ try database.update(.EmailOrUsername, value: email) }.toNot(throwError())
                expect(database.username) == email
                expect(database.email) == email
                expect(database.validEmail) == true
                expect(database.validUsername) == false
                expect(database.password).to(beNil())
            }

            it("should update username or email with an username") {
                expect{ try database.update(.EmailOrUsername, value: username) }.toNot(throwError())
                expect(database.username) == username
                expect(database.email) == username
                expect(database.validEmail) == false
                expect(database.validUsername) == true
                expect(database.password).to(beNil())
            }

            it("should update password") {
                expect{ try database.update(.Password, value: password) }.toNot(throwError())
                expect(database.password) == password
                expect(database.username).to(beNil())
                expect(database.email).to(beNil())
            }

            describe("email or username validation") {

                it("should always store value") {
                    let _ = try? database.update(.EmailOrUsername, value: "not an email")
                    expect(database.email) == "not an email"
                    expect(database.username) == "not an email"
                }

                it("should fallback to username if valid") {
                    expect { try database.update(.EmailOrUsername, value: username) }.notTo(throwError())
                    expect(database.username) == username
                    expect(database.validUsername) == true
                }

                it("should raise error if email is invalid") {
                    expect{ try database.update(.EmailOrUsername, value: "not an email") }.to(throwError(InputValidationError.NotAnEmailAddress))
                }

                it("should raise error if email is empty") {
                    expect{ try database.update(.EmailOrUsername, value: "") }.to(throwError(InputValidationError.MustNotBeEmpty))
                }

                it("should raise error if email is only spaces") {
                    expect{ try database.update(.EmailOrUsername, value: "     ") }.to(throwError(InputValidationError.MustNotBeEmpty))
                }

                it("should raise error if email is nil") {
                    expect{ try database.update(.EmailOrUsername, value: nil) }.to(throwError(InputValidationError.MustNotBeEmpty))
                }
                
            }
            describe("email validation") {

                it("should always store value") {
                    let _ = try? database.update(.Email, value: "not an email")
                    expect(database.email) == "not an email"
                }

                it("should raise error if email is invalid") {
                    expect{ try database.update(.Email, value: "not an email") }.to(throwError(InputValidationError.NotAnEmailAddress))
                }

                it("should raise error if email is empty") {
                    expect{ try database.update(.Email, value: "") }.to(throwError(InputValidationError.MustNotBeEmpty))
                }

                it("should raise error if email is only spaces") {
                    expect{ try database.update(.Email, value: "     ") }.to(throwError(InputValidationError.MustNotBeEmpty))
                }

                it("should raise error if email is nil") {
                    expect{ try database.update(.Email, value: nil) }.to(throwError(InputValidationError.MustNotBeEmpty))
                }

            }

            describe("username validation") {

                it("should always store value") {
                    let _ = try? database.update(.Username, value: "not a username")
                    expect(database.username) == "not a username"
                }

                it("should accept '_' as valid character") {
                    expect{ try database.update(.Username, value: "info_auth0") }.toNot(throwError())
                }

                it("should raise error if username has invalid chars") {
                    expect{ try database.update(.Username, value: "!not avalidusername+++") }.to(throwError(InputValidationError.NotAUsername))
                }

                it("should raise error if username has too many chars") {
                    expect{ try database.update(.Username, value: "12345678901234567890") }.to(throwError(InputValidationError.NotAUsername))
                }

                it("should raise error if username is empty") {
                    expect{ try database.update(.Username, value: "") }.to(throwError(InputValidationError.MustNotBeEmpty))
                }

                it("should raise error if username is only spaces") {
                    expect{ try database.update(.Username, value: "     ") }.to(throwError(InputValidationError.MustNotBeEmpty))
                }

                it("should raise error if email is nil") {
                    expect{ try database.update(.Username, value: nil) }.to(throwError(InputValidationError.MustNotBeEmpty))
                }
                
            }

            describe("password validation") {

                it("should always store value") {
                    let _ = try? database.update(.Password, value: "pass")
                    expect(database.password) == "pass"
                }

                it("should raise error if username is empty") {
                    expect{ try database.update(.Password, value: "") }.to(throwError(InputValidationError.MustNotBeEmpty))
                }

                it("should raise error if password is only spaces") {
                    expect{ try database.update(.Password, value: "     ") }.to(throwError(InputValidationError.MustNotBeEmpty))
                }

                it("should raise error if password is nil") {
                    expect{ try database.update(.Password, value: nil) }.to(throwError(InputValidationError.MustNotBeEmpty))
                }
                
            }

            describe("custom attribute validation") {

                beforeEach {
                    var options = LockOptions()
                    options.customSignupFields = [CustomTextField(name: "first_name", placeholder: "First Name", icon: LazyImage(name: "ic_person", bundle: Lock.bundle))]
                    database = DatabaseInteractor(connections: connections, authentication: authentication, user: user, options: options, callback: { _ in })
                }

                it("should always store value") {
                    let _ = try? database.update(.Custom(name: "first_name"), value: "Auth0")
                    expect(user.additionalAttributes["first_name"]) == "Auth0"
                }

                it("should raise error if value is empty") {
                    expect{ try database.update(.Custom(name: "first_name"), value: "") }.to(throwError(InputValidationError.MustNotBeEmpty))
                }

                it("should raise error if password is only spaces") {
                    expect{ try database.update(.Custom(name: "first_name"), value: "     ") }.to(throwError(InputValidationError.MustNotBeEmpty))
                }

                it("should raise error if password is nil") {
                    expect{ try database.update(.Custom(name: "first_name"), value: nil) }.to(throwError(InputValidationError.MustNotBeEmpty))
                }

                it("should raise error for custom validation") {
                    var options = LockOptions()
                    let error = NSError(domain: "com.auth0", code: -99999, userInfo: [:])
                    options.customSignupFields = [CustomTextField(name: "first_name", placeholder: "First Name", icon: LazyImage(name: "ic_person", bundle: Lock.bundle), validation: { _ in return error })]
                    database = DatabaseInteractor(connections: connections, authentication: authentication, user: user, options: options, callback: { _ in })
                    expect{ try database.update(.Custom(name: "first_name"), value: nil) }.to(throwError(error))
                }

            }

        }

        describe("login") {

            it("should fail if no db connection is found") {
                database = DatabaseInteractor(connections: OfflineConnections(), authentication: authentication, user: user, options: LockOptions(), callback: { _ in })
                try! database.update(.Email, value: email)
                try! database.update(.Password, value: password)
                waitUntil(timeout: 2) { done in
                    database.login { error in
                        expect(error) == .NoDatabaseConnection
                        done()
                    }
                }
            }

            it("should yield no error on success") {
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

            it("should send scope") {
                let scope = "openid email"
                var options = LockOptions()
                options.scope = scope
                database = DatabaseInteractor(connections: connections, authentication: authentication, user: user, options: options, callback: { _ in })
                stub(databaseLogin(identifier: email, password: password, connection: connection) && hasEntry(key: "scope", value: scope)) { _ in return Auth0Stubs.authentication() }
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

            it("should send parameters") {
                let state = NSUUID().UUIDString
                var options = LockOptions()
                options.parameters = ["state": state]
                database = DatabaseInteractor(connections: connections, authentication: authentication, user: user, options: options, callback: { _ in })
                stub(databaseLogin(identifier: email, password: password, connection: connection) && hasEntry(key: "state", value: state)) { _ in return Auth0Stubs.authentication() }
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

            it("should yield invalid credentials error on failure") {
                stub(databaseLogin(identifier: email, password: password, connection: connection)) { _ in return Auth0Stubs.failure("invalid_user_password") }
                try! database.update(.Email, value: email)
                try! database.update(.Password, value: password)
                waitUntil(timeout: 2) { done in
                    database.login { error in
                        expect(error) == .InvalidEmailPassword
                        done()
                    }
                }
            }

            it("should indicate that mfa is required") {
                stub(databaseLogin(identifier: email, password: password, connection: connection)) { _ in return Auth0Stubs.failure("a0.mfa_required") }
                try! database.update(.Email, value: email)
                try! database.update(.Password, value: password)
                waitUntil(timeout: 2) { done in
                    database.login { error in
                        expect(error) == .MultifactorRequired
                        done()
                    }
                }
            }

            it("should indicate that mfa is required") {
                stub(databaseLogin(identifier: email, password: password, connection: connection)) { _ in return Auth0Stubs.failure("a0.mfa_registration_required") }
                try! database.update(.Email, value: email)
                try! database.update(.Password, value: password)
                waitUntil(timeout: 2) { done in
                    database.login { error in
                        expect(error) == .MultifactorRequired
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

            it("should indicate the user is blocked for too many attempts") {
                stub(databaseLogin(identifier: email, password: password, connection: connection)) { _ in return Auth0Stubs.failure("too_many_attempts") }
                try! database.update(.Email, value: email)
                try! database.update(.Password, value: password)
                waitUntil(timeout: 2) { done in
                    database.login { error in
                        expect(error) == .TooManyAttempts
                        done()
                    }
                }
            }

            it("should indicate the user is blocked") {
                stub(databaseLogin(identifier: email, password: password, connection: connection)) { _ in return Auth0Stubs.failure("unauthorized", description: "user is blocked") }
                try! database.update(.Email, value: email)
                try! database.update(.Password, value: password)
                waitUntil(timeout: 2) { done in
                    database.login { error in
                        expect(error) == .UserBlocked
                        done()
                    }
                }
            }

            it("should indicate the password needs to be changed") {
                stub(databaseLogin(identifier: email, password: password, connection: connection)) { _ in return Auth0Stubs.failure("password_change_required") }
                try! database.update(.Email, value: email)
                try! database.update(.Password, value: password)
                waitUntil(timeout: 2) { done in
                    database.login { error in
                        expect(error) == .PasswordChangeRequired
                        done()
                    }
                }
            }

            it("should indicate the password is leaked") {
                stub(databaseLogin(identifier: email, password: password, connection: connection)) { _ in return Auth0Stubs.failure("password_leaked") }
                try! database.update(.Email, value: email)
                try! database.update(.Password, value: password)
                waitUntil(timeout: 2) { done in
                    database.login { error in
                        expect(error) == .PasswordLeaked
                        done()
                    }
                }
            }

        }

        describe("signup") {

            it("should fail if no db connection is found") {
                database = DatabaseInteractor(connections: OfflineConnections(), authentication: authentication, user: user, options: LockOptions(), callback: { _ in })
                try! database.update(.Email, value: email)
                try! database.update(.Username, value: username)
                try! database.update(.Password, value: password)
                waitUntil(timeout: 2) { done in
                    database.create { create, login in
                        expect(create) == .NoDatabaseConnection
                        done()
                    }
                }
            }

            it("should yield no error on success") {
                stub(databaseSignUp(email: email, username: username, password: password, connection: connection)) { _ in return Auth0Stubs.createdUser(email) }
                stub(databaseLogin(identifier: email, password: password, connection: connection)) { _ in return Auth0Stubs.authentication() }
                try! database.update(.Email, value: email)
                try! database.update(.Username, value: username)
                try! database.update(.Password, value: password)
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
                connections = OfflineConnections()
                connections.database(name: connection, requiresUsername: false)
                database = DatabaseInteractor(connections: connections, authentication: authentication, user: user, options: LockOptions(), callback: { _ in })
                stub(databaseSignUp(email: email, password: password, connection: connection) && !hasEntry(key: "username", value: username)) { _ in return Auth0Stubs.createdUser(email) }
                stub(databaseLogin(identifier: email, password: password, connection: connection)) { _ in return Auth0Stubs.authentication() }
                try! database.update(.Email, value: email)
                let _ = try? database.update(.Username, value: username)
                try! database.update(.Password, value: password)
                waitUntil(timeout: 2) { done in
                    database.create { create, login in
                        expect(create).to(beNil())
                        expect(login).to(beNil())
                        done()
                    }
                }
            }

            it("should indicate that mfa is required") {
                stub(databaseSignUp(email: email, username: username, password: password, connection: connection)) { _ in return Auth0Stubs.createdUser(email) }
                stub(databaseLogin(identifier: email, password: password, connection: connection)) { _ in return Auth0Stubs.failure("a0.mfa_required") }
                try! database.update(.Email, value: email)
                try! database.update(.Username, value: username)
                try! database.update(.Password, value: password)
                waitUntil(timeout: 2) { done in
                    database.create { create, login in
                        expect(create).to(beNil())
                        expect(login) == .MultifactorRequired
                        done()
                    }
                }
            }

            it("should yield error on login failure") {
                stub(databaseSignUp(email: email, username: username, password: password, connection: connection)) { _ in return Auth0Stubs.createdUser(email) }
                stub(databaseLogin(identifier: email, password: password, connection: connection)) { _ in return Auth0Stubs.failure() }
                try! database.update(.Email, value: email)
                try! database.update(.Username, value: username)
                try! database.update(.Password, value: password)
                waitUntil(timeout: 2) { done in
                    database.create { create, login in
                        expect(create).to(beNil())
                        expect(login) == .CouldNotLogin
                        done()
                    }
                }
            }

            it("should yield error on signup failure") {
                stub(databaseSignUp(email: email, username: username, password: password, connection: connection)) { _ in return Auth0Stubs.failure() }
                try! database.update(.Email, value: email)
                try! database.update(.Username, value: username)
                try! database.update(.Password, value: password)
                waitUntil(timeout: 2) { done in
                    database.create { create, login in
                        expect(create) == .CouldNotCreateUser
                        done()
                    }
                }
            }

            it("should yield invalid password") {
                stub(databaseSignUp(email: email, username: username, password: password, connection: connection)) { _ in return Auth0Stubs.failure("invalid_password") }
                try! database.update(.Email, value: email)
                try! database.update(.Username, value: username)
                try! database.update(.Password, value: password)
                waitUntil(timeout: 2) { done in
                    database.create { create, login in
                        expect(create) == .PasswordInvalid
                        done()
                    }
                }
            }

            it("should yield password too weak") {
                stub(databaseSignUp(email: email, username: username, password: password, connection: connection)) { _ in return Auth0Stubs.failure("invalid_password", name: "PasswordStrengthError") }
                try! database.update(.Email, value: email)
                try! database.update(.Username, value: username)
                try! database.update(.Password, value: password)
                waitUntil(timeout: 2) { done in
                    database.create { create, login in
                        expect(create) == .PasswordTooWeak
                        done()
                    }
                }
            }

            it("should yield password already used") {
                stub(databaseSignUp(email: email, username: username, password: password, connection: connection)) { _ in return Auth0Stubs.failure("invalid_password", name: "PasswordHistoryError") }
                try! database.update(.Email, value: email)
                try! database.update(.Username, value: username)
                try! database.update(.Password, value: password)
                waitUntil(timeout: 2) { done in
                    database.create { create, login in
                        expect(create) == .PasswordAlreadyUsed
                        done()
                    }
                }
            }

            it("should yield password too common") {
                stub(databaseSignUp(email: email, username: username, password: password, connection: connection)) { _ in return Auth0Stubs.failure("invalid_password", name: "PasswordDictionaryError") }
                try! database.update(.Email, value: email)
                try! database.update(.Username, value: username)
                try! database.update(.Password, value: password)
                waitUntil(timeout: 2) { done in
                    database.create { create, login in
                        expect(create) == .PasswordTooCommon
                        done()
                    }
                }
            }

            it("should yield password has user info") {
                stub(databaseSignUp(email: email, username: username, password: password, connection: connection)) { _ in return Auth0Stubs.failure("invalid_password", name: "PasswordNoUserInfoError") }
                try! database.update(.Email, value: email)
                try! database.update(.Username, value: username)
                try! database.update(.Password, value: password)
                waitUntil(timeout: 2) { done in
                    database.create { create, login in
                        expect(create) == .PasswordHasUserInfo
                        done()
                    }
                }
            }

            it("should yield error when input is not valid") {
                waitUntil(timeout: 2) { done in
                    database.create { create, login in
                        expect(create) == .NonValidInput
                        done()
                    }
                }
            }

            it("should yield error when username is not valid and required") {
                try! database.update(.Email, value: email)
                try! database.update(.Password, value: password)
                waitUntil(timeout: 2) { done in
                    database.create { create, login in
                        expect(create) == .NonValidInput
                        done()
                    }
                }
            }


            it("should send scope on login") {
                let scope = "openid email"
                var options = LockOptions()
                options.scope = scope
                database = DatabaseInteractor(connections: connections, authentication: authentication, user: user, options: options, callback: { _ in })
                stub(databaseSignUp(email: email, username: username, password: password, connection: connection)) { _ in return Auth0Stubs.createdUser(email) }
                stub(databaseLogin(identifier: email, password: password, connection: connection) && hasEntry(key: "scope", value: scope)) { _ in return Auth0Stubs.authentication() }
                try! database.update(.Email, value: email)
                try! database.update(.Username, value: username)
                try! database.update(.Password, value: password)
                waitUntil(timeout: 2) { done in
                    database.create { create, login in
                        expect(create).to(beNil())
                        expect(login).to(beNil())
                        done()
                    }
                }
            }

            it("should send parameters on login") {
                let state = NSUUID().UUIDString
                var options = LockOptions()
                options.parameters = ["state": state]
                database = DatabaseInteractor(connections: connections, authentication: authentication, user: user, options: options, callback: { _ in })
                stub(databaseSignUp(email: email, username: username, password: password, connection: connection)) { _ in return Auth0Stubs.createdUser(email) }
                stub(databaseLogin(identifier: email, password: password, connection: connection) && hasEntry(key: "state", value: state)) { _ in return Auth0Stubs.authentication() }
                try! database.update(.Email, value: email)
                try! database.update(.Username, value: username)
                try! database.update(.Password, value: password)
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
