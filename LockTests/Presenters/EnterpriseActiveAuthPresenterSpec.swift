// EnterprisePasswordPresenterSpec.swift
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
import Auth0

@testable import Lock

class EnterpriseActiveAuthPresenterSpec: QuickSpec {

    override func spec() {
        let authentication = Auth0.authentication(clientId: clientId, domain: domain)

        var interactor: EnterpriseActiveAuthInteractor!
        var presenter: EnterpriseActiveAuthPresenter!
        var messagePresenter: MockMessagePresenter!
        var view: EnterpriseActiveAuthView!
        var options: LockOptions!
        var user: User!
        var connection: EnterpriseConnection!

        beforeEach {
            options = LockOptions()
            user = User()
            messagePresenter = MockMessagePresenter()
            connection = EnterpriseConnection(name: "TestAD", domains: ["test.com"])
            interactor = EnterpriseActiveAuthInteractor(connection: connection, authentication: authentication, user: user, options: options, dispatcher: ObserverStore())
            presenter = EnterpriseActiveAuthPresenter(interactor: interactor, options: options, domain: "test.com")
            presenter.messagePresenter = messagePresenter

            view = presenter.view as! EnterpriseActiveAuthView
        }

        describe("init") {

            it("should have a presenter object") {
                expect(presenter).toNot(beNil())
            }

            it("should set button title") {
                expect(view.primaryButton?.title) == "LOG IN"
            }
        }

        describe("user state") {

            it("should return initial valid email") {
                interactor.validEmail = true
                interactor.email = email
                presenter = EnterpriseActiveAuthPresenter(interactor: interactor, options: options, domain: "test.com")
                let view = (presenter.view as! EnterpriseActiveAuthView).form as! CredentialView
                expect(view.identityField.text).to(equal(email))
            }

            it("should return initial username") {
                interactor.validUsername = true
                interactor.username = username
                presenter = EnterpriseActiveAuthPresenter(interactor: interactor, options: options, domain: "test.com")
                let view = (presenter.view as! EnterpriseActiveAuthView).form as! CredentialView
                expect(view.identityField.text).to(equal(username))
            }

            it("should expect default identifier input type to be UserName") {
                let view = (presenter.view as! EnterpriseActiveAuthView).form as! CredentialView
                expect(view.identityField.type).toEventually(equal(InputField.InputType.username))
            }

            context("use email as identifier option") {

                beforeEach {
                    options = LockOptions()
                    options.activeDirectoryEmailAsUsername = true

                    interactor = EnterpriseActiveAuthInteractor(connection: connection, authentication: authentication, user: user, options: options, dispatcher: ObserverStore())
                    presenter = EnterpriseActiveAuthPresenter(interactor: interactor, options: options, domain: "test.com")
                    presenter.messagePresenter = messagePresenter
                }

                it("should expect default identifier type to be email") {
                    let view = (presenter.view as! EnterpriseActiveAuthView).form as! CredentialView
                    expect(view.identityField.type).toEventually(equal(InputField.InputType.email))
                }

            }

        }

        describe("user input") {

            it("should update username if value is valid") {
                let input = mockInput(.username, value: username)
                view.form?.onValueChange(input)
                expect(presenter.interactor.username).to(equal(username))
                expect(presenter.interactor.validUsername).to(beTrue())
            }

            it("should hide the field error if value is valid") {
                let input = mockInput(.username, value: username)
                view.form?.onValueChange(input)
                expect(input.valid).to(equal(true))
            }

            it("should show field error for empty username") {
                let input = mockInput(.username, value: "")
                view.form?.onValueChange(input)
                expect(input.valid).to(equal(false))
            }

            it("should update password if value is valid") {
                let input = mockInput(.password, value: password)
                view.form?.onValueChange(input)
                expect(presenter.interactor.password).to(equal(password))
                expect(presenter.interactor.validPassword).to(beTrue())
            }

            it("should show field error for empty password") {
                let input = mockInput(.password, value: "")
                view.form?.onValueChange(input)
                expect(input.valid).to(equal(false))
            }

            it("should not process unsupported input type") {
                let input = mockInput(.oneTimePassword, value: password)
                view.form?.onValueChange(input)
                expect(input.valid).to(beNil())
            }

            context("use email as identifier option") {

                beforeEach {
                    options = LockOptions()
                    options.activeDirectoryEmailAsUsername = true

                    interactor = EnterpriseActiveAuthInteractor(connection: connection, authentication: authentication, user: user, options: options, dispatcher: ObserverStore())
                    presenter = EnterpriseActiveAuthPresenter(interactor: interactor, options: options, domain: "test.com")
                    presenter.messagePresenter = messagePresenter

                    view = presenter.view as! EnterpriseActiveAuthView
                }

                it("should update email if value is valid") {
                    let input = mockInput(.email, value: email)
                    view.form?.onValueChange(input)
                    expect(presenter.interactor.email).to(equal(email))
                    expect(presenter.interactor.validEmail).to(beTrue())
                }

                it("should hide the field error if value is valid") {
                    let input = mockInput(.email, value: email)
                    view.form?.onValueChange(input)
                    expect(input.valid).to(equal(true))
                }

                it("should show field error for invalid email") {
                    let input = mockInput(.email, value: "invalid")
                    view.form?.onValueChange(input)
                    expect(input.valid).to(equal(false))
                }

            }

        }

        describe("login action") {

            beforeEach {
                options = LockOptions()
                options.activeDirectoryEmailAsUsername = true

                interactor = EnterpriseActiveAuthInteractor(connection: connection, authentication: authentication, user: user, options: options, dispatcher: ObserverStore())
                try! interactor.update(.username, value: username)
                try! interactor.update(.password(enforcePolicy: false), value: password)
                presenter = EnterpriseActiveAuthPresenter(interactor: interactor, options: options, domain: "test.com")
                presenter.messagePresenter = messagePresenter

                view = presenter.view as! EnterpriseActiveAuthView
            }

            it("should not trigger action with nil button") {
                let input = mockInput(.username, value: username)
                input.returnKey = .done
                view.primaryButton = nil
                view.form?.onReturn(input)
                expect(messagePresenter.message).toEventually(beNil())
                expect(messagePresenter.error).toEventually(beNil())
            }

            it("should trigger login on button press and fail with with CouldNotLogin") {
                view.primaryButton?.onPress(view.primaryButton!)
                expect(messagePresenter.error).toEventually(beError(error: CredentialAuthError.couldNotLogin))
            }

            it("should trigger submission of form") {
                let input = mockInput(.password, value: password)
                input.returnKey = .done
                view.form?.onReturn(input)
                expect(messagePresenter.error).toEventually(beError(error: CredentialAuthError.couldNotLogin))
            }

        }

    }
}

extension InputField.InputType: Equatable {}

public func ==(lhs: InputField.InputType, rhs: InputField.InputType) -> Bool {
    switch((lhs, rhs)) {
    case (.username, .username), (.email, .email), (.oneTimePassword, .oneTimePassword), (.phone, .phone):
        return true
    default:
        return false
    }
}


