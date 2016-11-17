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

class EnterprisePasswordPresenterSpec: QuickSpec {

    override func spec() {
        let authentication = Auth0.authentication(clientId: clientId, domain: domain)

        var interactor: EnterprisePasswordInteractor!
        var presenter: EnterprisePasswordPresenter!
        var messagePresenter: MockMessagePresenter!
        var view: EnterprisePasswordView!
        var options: LockOptions!
        var user: User!
        var connection: EnterpriseConnection!

        beforeEach {
            options = LockOptions()
            user = User()
            messagePresenter = MockMessagePresenter()

            connection = EnterpriseConnection(name: "TestAD", domains: ["test.com"])
            interactor = EnterprisePasswordInteractor(connection: connection, authentication: authentication, user: user, options: options, callback: {_ in})
            presenter = EnterprisePasswordPresenter(interactor: interactor)
            presenter.messagePresenter = messagePresenter

            view = presenter.view as! EnterprisePasswordView
        }

        describe("init") {

            it("should have a presenter object") {
                expect(presenter).toNot(beNil())
            }

            it("should have info bar") {
                expect(view.infoBar).toNot(beNil())
            }

            it("info bar should contain first connection domain") {
                expect(view.infoBar!.title!.containsString(connection.domains.first!)).to(beTrue())
            }
        }


        describe("user state") {

            it("should return initial valid email") {
                interactor.validEmail = true
                interactor.email = email
                presenter = EnterprisePasswordPresenter(interactor: interactor)
                let view = (presenter.view as! EnterprisePasswordView).form as! CredentialView
                expect(view.identityField.text).to(equal(email))
            }

            it("should return initial username") {
                interactor.validUsername = true
                interactor.username = username
                presenter = EnterprisePasswordPresenter(interactor: interactor)
                let view = (presenter.view as! EnterprisePasswordView).form as! CredentialView
                expect(view.identityField.text).to(equal(username))
            }

            it("should expect default identifier input type to be UserName") {
                let view = (presenter.view as! EnterprisePasswordView).form as! CredentialView
                expect(view.identityField.type).toEventually(equal(InputField.InputType.Username))
            }

            context("use email as identifier option") {

                beforeEach {
                    options = LockOptions()
                    options.activeDirectoryEmailAsUsername = true
                    
                    interactor = EnterprisePasswordInteractor(connection: connection, authentication: authentication, user: user, options: options, callback: {_ in})
                    presenter = EnterprisePasswordPresenter(interactor: interactor)
                    presenter.messagePresenter = messagePresenter
                }

                it("should expect default identifier type to be email") {
                    let view = (presenter.view as! EnterprisePasswordView).form as! CredentialView
                    expect(view.identityField.type).toEventually(equal(InputField.InputType.Email))
                }

            }

        }

        describe("user input") {

            it("should update username if value is valid") {
                let input = mockInput(.Username, value: username)
                view.form?.onValueChange(input)
                expect(presenter.interactor.username).to(equal(username))
                expect(presenter.interactor.validUsername).to(beTrue())
            }

            it("should hide the field error if value is valid") {
                let input = mockInput(.Username, value: username)
                view.form?.onValueChange(input)
                expect(input.valid).to(equal(true))
            }

            it("should show field error for empty username") {
                let input = mockInput(.Username, value: "")
                view.form?.onValueChange(input)
                expect(input.valid).to(equal(false))
            }

            context("use email as identifier option") {

                beforeEach {
                    options = LockOptions()
                    options.activeDirectoryEmailAsUsername = true

                    interactor = EnterprisePasswordInteractor(connection: connection, authentication: authentication, user: user, options: options, callback: {_ in})
                    presenter = EnterprisePasswordPresenter(interactor: interactor)
                    presenter.messagePresenter = messagePresenter

                    view = presenter.view as! EnterprisePasswordView
                }

                it("should update email if value is valid") {
                    let input = mockInput(.Email, value: email)
                    view.form?.onValueChange(input)
                    expect(presenter.interactor.email).to(equal(email))
                    expect(presenter.interactor.validEmail).to(beTrue())
                }

                it("should hide the field error if value is valid") {
                    let input = mockInput(.Email, value: email)
                    view.form?.onValueChange(input)
                    expect(input.valid).to(equal(true))
                }

                it("should show field error for invalid email") {
                    let input = mockInput(.Email, value: "invalid")
                    view.form?.onValueChange(input)
                    expect(input.valid).to(equal(false))
                }
                
            }

        }

        describe("login action") {

            beforeEach {
                options = LockOptions()
                options.activeDirectoryEmailAsUsername = true

                interactor = EnterprisePasswordInteractor(connection: connection, authentication: authentication, user: user, options: options, callback: {_ in})
                try! interactor.update(.Username, value: username)
                try! interactor.update(.Password, value: password)
                presenter = EnterprisePasswordPresenter(interactor: interactor)
                presenter.messagePresenter = messagePresenter

                view = presenter.view as! EnterprisePasswordView
            }

            it("should not trigger action with nil button") {
                let input = mockInput(.Username, value: username)
                input.returnKey = .Done
                view.primaryButton = nil
                view.form?.onReturn(input)
                expect(messagePresenter.message).toEventually(beNil())
                expect(messagePresenter.error).toEventually(beNil())
            }

            it("should trigger login on button press and fail with with CouldNotLogin") {
                view.primaryButton?.onPress(view.primaryButton!)
                expect(messagePresenter.error).toEventually(beError(error: DatabaseAuthenticatableError.CouldNotLogin))
            }

        }

    }
}

extension InputField.InputType: Equatable {}

public func ==(lhs: InputField.InputType, rhs: InputField.InputType) -> Bool {
    switch((lhs, rhs)) {
    case (.Username, .Username), (.Email, .Email):
        return true
    default:
        return false
    }
}


