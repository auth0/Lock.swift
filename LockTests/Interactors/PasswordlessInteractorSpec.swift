// PasswordlessInteractorSpec.swift
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

private let phone = "01234567891"
private let phoneInternational = "+4401234567891"
private let countryData = CountryCode(id: "UK", prefix: "+44", name: "United Kingdom")

class PasswordlessInteractorSpec: QuickSpec {

    override func spec() {

        let authentication = Auth0.authentication(clientId: clientId, domain: domain)

        var messagePresenter: MockMessagePresenter!
        var options: LockOptions!
        var user: User!
        var passwordlessActivity: PasswordlessActivity!
        var interactor: PasswordlessInteractor!
        var dispatcher: ObserverStore!
        var dispatchCredentials: Credentials?
        var dispatchError: Error?
        var dispatchPasswordlessIdentifier: String?
        var connection: String!

        afterEach {
            Auth0Stubs.cleanAll()
            Auth0Stubs.failUnknown()
        }

        context("email") {

            beforeEach {
                connection = "email"
                dispatchCredentials = nil
                dispatchError = nil
                dispatchPasswordlessIdentifier = nil
                messagePresenter = MockMessagePresenter()
                options = LockOptions()
                options.passwordlessMethod = .emailCode
                user = User()
                passwordlessActivity = PasswordlessActivity.shared.withMessagePresenter(messagePresenter)
                dispatcher = ObserverStore()
                dispatcher.onAuth = { dispatchCredentials = $0 }
                dispatcher.onFailure = { dispatchError = $0 }
                dispatcher.onPasswordless = { dispatchPasswordlessIdentifier = $0 }
                interactor = PasswordlessInteractor(authentication: authentication, dispatcher: dispatcher, user: user, options: options, passwordlessActivity: passwordlessActivity)
            }

        describe("identifier validation") {

            it("should set valid false") {
                let _ = try? interactor.update(.email, value: "not an email")
                expect(interactor.validIdentifier) == false
            }

            it("should set valid true") {
                let _ = try? interactor.update(.email, value: email)
                expect(interactor.validIdentifier) == true
            }

            it("should always store value") {
                let _ = try? interactor.update(.email, value: "not an email")
                expect(interactor.identifier) == "not an email"
            }

            it("should raise error if email is invalid") {
                expect{ try interactor.update(.email, value: "not an email") }.to(throwError(InputValidationError.notAnEmailAddress))
            }

            it("should raise error if email is empty") {
                expect{ try interactor.update(.email, value: "") }.to(throwError(InputValidationError.mustNotBeEmpty))
            }

            it("should raise error if email is only spaces") {
                expect{ try interactor.update(.email, value: "     ") }.to(throwError(InputValidationError.mustNotBeEmpty))
            }

            it("should raise error if email is nil") {
                expect{ try interactor.update(.email, value: nil) }.to(throwError(InputValidationError.mustNotBeEmpty))
            }

        }

        describe("code validation") {

            it("should set valid flag true") {
                let _ = try? interactor.update(.oneTimePassword, value: "123456")
                expect(interactor.validCode) == true
            }

            it("should set valid flag false") {
                let _ = try? interactor.update(.oneTimePassword, value: "not a code")
                expect(interactor.validCode) == false
            }

            it("should always store value") {
                let _ = try? interactor.update(.oneTimePassword, value: "not a code")
                expect(interactor.code) == "not a code"
            }

            it("should raise error if code is invalid") {
                expect{ try interactor.update(.oneTimePassword, value: "not a code") }.to(throwError(InputValidationError.notAOneTimePassword))
            }

            it("should raise error if code is empty") {
                expect{ try interactor.update(.oneTimePassword, value: "") }.to(throwError(InputValidationError.mustNotBeEmpty))
            }

            it("should raise error if email is only spaces") {
                expect{ try interactor.update(.oneTimePassword, value: "     ") }.to(throwError(InputValidationError.mustNotBeEmpty))
            }

            it("should raise error if email is nil") {
                expect{ try interactor.update(.oneTimePassword, value: nil) }.to(throwError(InputValidationError.mustNotBeEmpty))
            }
        }

        describe("login") {

            it("should yield no error and dipsatch credentials on success") {
                stub(condition: databaseLogin(identifier: email, password: code, connection: connection)) { _ in return Auth0Stubs.authentication() }
                try! interactor.update(.email, value: email)
                try! interactor.update(.oneTimePassword, value: code)
                waitUntil(timeout: 2) { done in
                    interactor.login(connection) { error in
                        expect(error).to(beNil())
                        done()
                    }
                }
                expect(dispatchCredentials).toEventuallyNot(beNil())
            }

            it("should yield error when email input invalid") {
                let user = User()
                user.validEmail = false
                interactor = PasswordlessInteractor(authentication: authentication, dispatcher: dispatcher, user: user, options: options, passwordlessActivity: passwordlessActivity)
                waitUntil(timeout: 2) { done in
                    interactor.login(connection) { error in
                        expect(error) == .nonValidInput
                        done()
                    }
                }
            }

            it("should yield error when code input invalid") {
                let user = User()
                user.validEmail = true
                user.validPassword = false
                interactor = PasswordlessInteractor(authentication: authentication, dispatcher: dispatcher, user: user, options: options, passwordlessActivity: passwordlessActivity)
                waitUntil(timeout: 2) { done in
                    interactor.login(connection) { error in
                        expect(error) == .nonValidInput
                        done()
                    }
                }
            }
        }

        describe("request") {

            beforeEach {
                user.email = email
                user.validEmail = true
                interactor = PasswordlessInteractor(authentication: authentication, dispatcher: dispatcher, user: user, options: options, passwordlessActivity: passwordlessActivity)
            }

            it("should yield error on invalid input") {
                user = User()
                user.validEmail = false
                interactor = PasswordlessInteractor(authentication: authentication, dispatcher: dispatcher, user: user, options: options, passwordlessActivity: passwordlessActivity)
                waitUntil(timeout: 2) { done in
                    interactor.request(connection) { error in
                        expect(error) == .nonValidInput
                        done()
                    }
                }
            }


            it("should yield specific error when new signups disabled") {
                stub(condition: passwordlessStart(email: email, connection: connection)) { _ in return Auth0Stubs.failure("bad.connection", name: "no_signup") }
                waitUntil(timeout: 2) { done in
                    interactor.request(connection) { error in
                        expect(error) == .noSignup
                        done()
                    }
                }
                expect(dispatchError).toEventuallyNot(beNil())
            }

            it("should yield error on response error") {
                stub(condition: passwordlessStart(email: email, connection: connection)) { _ in return Auth0Stubs.failure("unknown.error", name: "Generic error") }
                waitUntil(timeout: 2) { done in
                    interactor.request(connection) { error in
                        expect(error) == .codeNotSent
                        done()
                    }
                }
                expect(dispatchError).toEventuallyNot(beNil())
            }

            it("should yield success on response success") {
                stub(condition: passwordlessStart(email: email, connection: connection)) { _ in return Auth0Stubs.passwordlessSent(email) }
                waitUntil(timeout: 2) { done in
                    interactor.request(connection) { error in
                        expect(error).to(beNil())
                        done()
                    }
                }
                expect(dispatchPasswordlessIdentifier).toEventuallyNot(beNil())
            }

            describe("link") {

                var activity: NSUserActivity!

                beforeEach {
                    activity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
                    user = User()
                    user.email = email
                    user.validEmail = true
                    options.passwordlessMethod = .emailLink
                    interactor = PasswordlessInteractor(authentication: authentication, dispatcher: dispatcher, user: user, options: options, passwordlessActivity: passwordlessActivity)
                    stub(condition: passwordlessStart(email: email, connection: connection)) { _ in return Auth0Stubs.passwordlessSent(email) }
                    stub(condition: databaseLogin(identifier: email, password: code, connection: connection)) { _ in return Auth0Stubs.authentication() }
                }
                
                it("should error on invalid code in url") {
                    activity.webpageURL = URL(string: "http://testdomain.auth0.com/" + Bundle.main.bundleIdentifier!.lowercased() + "/?code=")
                    waitUntil(timeout: 2) { done in
                        interactor.request(connection) { error in
                            expect(error).to(beNil())
                            done()
                        }
                    }
                    expect(PasswordlessActivity.shared.continueAuth(withActivity: activity)) == true
                    expect(messagePresenter.error).toEventuallyNot(beNil())
                    expect(dispatchError).toEventuallyNot(beNil())
                }

                it("should yield auth on success") {
                    activity.webpageURL = URL(string: "http://testdomain.auth0.com/" + Bundle.main.bundleIdentifier!.lowercased() + "/?code=" + code)
                    waitUntil(timeout: 2) { done in
                        interactor.request(connection) { error in
                            expect(error).to(beNil())
                            done()
                        }
                    }
                    expect(PasswordlessActivity.shared.continueAuth(withActivity: activity)) == true
                    expect(messagePresenter.error).toEventually(beNil())
                    expect(dispatchError).toEventually(beNil())
                    expect(dispatchCredentials).toEventuallyNot(beNil())
                }
            }
            
        }
        }

        context("sms") {

            beforeEach {
                connection = "sms"
                dispatchCredentials = nil
                dispatchError = nil
                dispatchPasswordlessIdentifier = nil
                messagePresenter = MockMessagePresenter()
                options = LockOptions()
                options.passwordlessMethod = .smsCode
                user = User()
                passwordlessActivity = PasswordlessActivity.shared.withMessagePresenter(messagePresenter)
                dispatcher = ObserverStore()
                dispatcher.onAuth = { dispatchCredentials = $0 }
                dispatcher.onFailure = { dispatchError = $0 }
                dispatcher.onPasswordless = { dispatchPasswordlessIdentifier = $0 }
                interactor = PasswordlessInteractor(authentication: authentication, dispatcher: dispatcher, user: user, options: options, passwordlessActivity: passwordlessActivity)
            }

            describe("identifier validation") {

                it("should set valid false") {
                    let _ = try? interactor.update(.phone, value: "00")
                    expect(interactor.validIdentifier) == false
                }

                it("should set valid true") {
                    let _ = try? interactor.update(.phone, value: phone)
                    expect(interactor.validIdentifier) == true
                }

                it("should always store value") {
                    let _ = try? interactor.update(.phone, value: "00")
                    expect(interactor.identifier) == "00"
                }

                it("should raise error if phone is invalid") {
                    expect{ try interactor.update(.phone, value: "00") }.to(throwError(InputValidationError.notAPhoneNumber))
                }

                it("should raise error if email is empty") {
                    expect{ try interactor.update(.phone, value: "") }.to(throwError(InputValidationError.mustNotBeEmpty))
                }

                it("should raise error if email is only spaces") {
                    expect{ try interactor.update(.phone, value: "     ") }.to(throwError(InputValidationError.mustNotBeEmpty))
                }

                it("should raise error if phone is nil") {
                    expect{ try interactor.update(.phone, value: nil) }.to(throwError(InputValidationError.mustNotBeEmpty))
                }

            }

            describe("code validation") {

                it("should set valid flag true") {
                    let _ = try? interactor.update(.oneTimePassword, value: "123456")
                    expect(interactor.validCode) == true
                }

                it("should set valid flag false") {
                    let _ = try? interactor.update(.oneTimePassword, value: "not a code")
                    expect(interactor.validCode) == false
                }

                it("should always store value") {
                    let _ = try? interactor.update(.oneTimePassword, value: "not a code")
                    expect(interactor.code) == "not a code"
                }

                it("should raise error if code is invalid") {
                    expect{ try interactor.update(.oneTimePassword, value: "not a code") }.to(throwError(InputValidationError.notAOneTimePassword))
                }

                it("should raise error if code is empty") {
                    expect{ try interactor.update(.oneTimePassword, value: "") }.to(throwError(InputValidationError.mustNotBeEmpty))
                }

                it("should raise error if email is only spaces") {
                    expect{ try interactor.update(.oneTimePassword, value: "     ") }.to(throwError(InputValidationError.mustNotBeEmpty))
                }

                it("should raise error if email is nil") {
                    expect{ try interactor.update(.oneTimePassword, value: nil) }.to(throwError(InputValidationError.mustNotBeEmpty))
                }
            }

            describe("login") {

                it("should yield no error and dipsatch credentials on success") {
                    stub(condition: databaseLogin(identifier: phone, password: code, connection: connection)) { _ in return Auth0Stubs.authentication() }
                    try! interactor.update(.phone, value: phone)
                    try! interactor.update(.oneTimePassword, value: code)
                    waitUntil(timeout: 2) { done in
                        interactor.login(connection) { error in
                            expect(error).to(beNil())
                            done()
                        }
                    }
                    expect(dispatchCredentials).toEventuallyNot(beNil())
                }

                it("should yield error when email input invalid") {
                    let user = User()
                    user.validEmail = false
                    interactor = PasswordlessInteractor(authentication: authentication, dispatcher: dispatcher, user: user, options: options, passwordlessActivity: passwordlessActivity)
                    waitUntil(timeout: 2) { done in
                        interactor.login(connection) { error in
                            expect(error) == .nonValidInput
                            done()
                        }
                    }
                }

                it("should yield error when code input invalid") {
                    let user = User()
                    user.validEmail = true
                    user.validPassword = false
                    interactor = PasswordlessInteractor(authentication: authentication, dispatcher: dispatcher, user: user, options: options, passwordlessActivity: passwordlessActivity)
                    waitUntil(timeout: 2) { done in
                        interactor.login(connection) { error in
                            expect(error) == .nonValidInput
                            done()
                        }
                    }
                }
            }

            describe("request") {

                beforeEach {
                    user.email = phone
                    user.validEmail = true
                    user.countryCode = countryData
                    interactor = PasswordlessInteractor(authentication: authentication, dispatcher: dispatcher, user: user, options: options, passwordlessActivity: passwordlessActivity)
                }

                it("should yield error on invalid input") {
                    user = User()
                    user.validEmail = false
                    interactor = PasswordlessInteractor(authentication: authentication, dispatcher: dispatcher, user: user, options: options, passwordlessActivity: passwordlessActivity)
                    waitUntil(timeout: 2) { done in
                        interactor.request(connection) { error in
                            expect(error) == .nonValidInput
                            done()
                        }
                    }
                }

                it("should yield error on no country code") {
                    user.countryCode = nil
                    interactor = PasswordlessInteractor(authentication: authentication, dispatcher: dispatcher, user: user, options: options, passwordlessActivity: passwordlessActivity)
                    waitUntil(timeout: 2) { done in
                        interactor.request(connection) { error in
                            expect(error) == .nonValidInput
                            done()
                        }
                    }
                }


                it("should yield specific error when new signups disabled") {
                    stub(condition: passwordlessStart(phone: phoneInternational, connection: connection)) { _ in
                        return Auth0Stubs.failure("bad.connection", name: "no_signup")
                    }
                    print(phoneInternational)
                    waitUntil(timeout: 2) { done in
                        interactor.request(connection) { error in
                            expect(error) == .noSignup
                            done()
                        }
                    }
                    expect(dispatchError).toEventuallyNot(beNil())
                }

                it("should yield error on response error") {
                    stub(condition: passwordlessStart(phone: phoneInternational, connection: connection)) { _ in return Auth0Stubs.failure("unknown.error", name: "Generic error") }
                    waitUntil(timeout: 2) { done in
                        interactor.request(connection) { error in
                            expect(error) == .codeNotSent
                            done()
                        }
                    }
                    expect(dispatchError).toEventuallyNot(beNil())
                }

                it("should yield success on response success") {
                    stub(condition: passwordlessStart(phone: phoneInternational, connection: connection)) { _ in return Auth0Stubs.passwordlessSent(email) }
                    waitUntil(timeout: 2) { done in
                        interactor.request(connection) { error in
                            expect(error).to(beNil())
                            done()
                        }
                    }
                    expect(dispatchPasswordlessIdentifier).toEventuallyNot(beNil())
                }

                describe("link") {

                    var activity: NSUserActivity!

                    beforeEach {
                        activity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
                        user = User()
                        user.email = phone
                        user.validEmail = true
                        user.countryCode = countryData
                        options.passwordlessMethod = .smsLink
                        interactor = PasswordlessInteractor(authentication: authentication, dispatcher: dispatcher, user: user, options: options, passwordlessActivity: passwordlessActivity)
                        stub(condition: passwordlessStart(phone: phoneInternational, connection: connection)) { _ in return Auth0Stubs.passwordlessSent(phoneInternational)
                        }
                        stub(condition: databaseLogin(identifier: phoneInternational, password: code, connection: connection)) { _ in return Auth0Stubs.authentication() }
                    }

                    it("should error on invalid code in url") {
                        activity.webpageURL = URL(string: "http://testdomain.auth0.com/" + Bundle.main.bundleIdentifier!.lowercased() + "/?code=")
                        waitUntil(timeout: 2) { done in
                            interactor.request(connection) { error in
                                expect(error).to(beNil())
                                done()
                            }
                        }
                        expect(PasswordlessActivity.shared.continueAuth(withActivity: activity)) == true
                        expect(messagePresenter.error).toEventuallyNot(beNil())
                        expect(dispatchError).toEventuallyNot(beNil())
                    }
                    
                    it("should yield auth on success") {
                        activity.webpageURL = URL(string: "http://testdomain.auth0.com/" + Bundle.main.bundleIdentifier!.lowercased() + "/?code=" + code)
                        waitUntil(timeout: 2) { done in
                            interactor.request(connection) { error in
                                expect(error).to(beNil())
                                done()
                            }
                        }
                        expect(PasswordlessActivity.shared.continueAuth(withActivity: activity)) == true
                        expect(messagePresenter.error).toEventually(beNil())
                        expect(dispatchError).toEventually(beNil())
                        expect(dispatchCredentials).toEventuallyNot(beNil())
                    }
                }
                
            }
        }
        
    }
}

