// EnterpriseDomainPresenterSpec.swift
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

@testable import Lock

class EnterpriseDomainPresenterSpec: QuickSpec {

    override func spec() {

        var interactor: EnterpriseDomainInteractor!
        var presenter: EnterpriseDomainPresenter!
        var view: EnterpriseDomainView!
        var messagePresenter: MockMessagePresenter!
        var connections: OfflineConnections!
        var oauth2: MockOAuth2!
        var authPresenter: MockAuthPresenter!
        var navigator: MockNavigator!
        var options: OptionBuildable!
        var user: User!

        beforeEach {
            messagePresenter = MockMessagePresenter()
            oauth2 = MockOAuth2()
            authPresenter = MockAuthPresenter(connections: [], interactor: MockAuthInteractor(), customStyle: [:])
            user = User()
            navigator = MockNavigator()
            options = LockOptions()
            user = User()

            connections = OfflineConnections()
            connections.enterprise(name: "TestAD", domains: ["test.com"])
            connections.enterprise(name: "ValidAD", domains: ["validad.com"])
            presenter = EnterpriseDomainPresenter(interactor: interactor, navigator: navigator, options: options)
            presenter.messagePresenter = messagePresenter
            view = presenter.view as! EnterpriseDomainView
        }

        describe("init") {

            it("should have a presenter object") {
                expect(presenter).toNot(beNil())
            }

            it("should have an entperise domain view") {
                expect(view).toNot(beNil())
            }

            it("should have primary button when more than one domain") {
                expect(view.primaryButton).toNot(beNil())
            }

            it("should not have auth button") {
                expect(view.authButton).to(beNil())
            }
        }

        describe("email input validation") {

            it("should use valid email") {
                user.email = email
                user.validEmail = true
                presenter = EnterpriseDomainPresenter(interactor: interactor, navigator: navigator, options: options)

                let view = (presenter.view as? EnterpriseDomainView)?.form as? EnterpriseSingleInputView
                expect(view?.value) == email
            }

            it("should not use invalid email") {
                user.email = email
                user.validEmail = false
                presenter = EnterpriseDomainPresenter(interactor: interactor, navigator: navigator, options: options)

                let view = (presenter.view as? EnterpriseDomainView)?.form as? EnterpriseSingleInputView
                expect(view?.value) != email
            }
        }

        describe("user input") {

            it("email should update with valid email") {
                let input = mockInput(.email, value: "valid@email.com")
                view.form?.onValueChange(input)
                expect(presenter.interactor.email).to(equal("valid@email.com"))
            }

            it("email should be invalid when nil") {
                let input = mockInput(.email, value: nil)
                view.form?.onValueChange(input)
                expect(presenter.interactor.validEmail).to(equal(false))
            }

            it("email should be invalid when garbage") {
                let input = mockInput(.email, value: "       ")
                view.form?.onValueChange(input)
                expect(presenter.interactor.validEmail).to(equal(false))
            }

            it("connection should match with valid domain") {
                let input = mockInput(.email, value: "valid@test.com")
                view.form?.onValueChange(input)
                expect(presenter.interactor.connection).toNot(beNil())
                expect(presenter.interactor.connection?.name).to(equal("TestAD"))
            }

            it("connection should not match with an invalid domain") {
                let input = mockInput(.email, value: "email@nomatchdomain.com")
                view.form?.onValueChange(input)
                expect(presenter.interactor.connection).to(beNil())
            }

            it("should hide the field error if value is valid") {
                let input = mockInput(.email, value: email)
                view.form?.onValueChange(input)
                expect(input.valid).to(equal(true))
            }

            it("should show field error if value is invalid") {
                let input = mockInput(.email, value: "invalid")
                view.form?.onValueChange(input)
                expect(input.valid).to(equal(false))
            }

        }

        describe("login action") {

            it("should not trigger action with nil button") {
                let input = mockInput(.email, value: "invalid")
                input.returnKey = .done
                view.primaryButton = nil
                view.form?.onReturn(input)
                expect(messagePresenter.message).toEventually(beNil())
                expect(messagePresenter.error).toEventually(beNil())
            }

            it("should trigger submission of form") {
                presenter.interactor.connection = EnterpriseConnection(name: "ad", domains: ["auth0.com"], style: AuthStyle(name: "ad"))
                oauth2.onLogin = { return OAuth2AuthenticatableError.couldNotAuthenticate }
                let input = mockInput(.email, value: "user@test.com")
                input.returnKey = .done
                view.form?.onReturn(input)
                expect(messagePresenter.error).toEventually(beError(error: OAuth2AuthenticatableError.couldNotAuthenticate))
            }

            it("should fail when no connection is matched") {
                presenter.interactor.connection = nil
                view.primaryButton?.onPress(view.primaryButton!)
                expect(messagePresenter.error).toEventually(beError(error: OAuth2AuthenticatableError.noConnectionAvailable))
            }

            it("should show yield oauth2 error on failure") {
                presenter.interactor.connection = EnterpriseConnection(name: "ad", domains: ["auth0.com"])
                oauth2.onLogin = { return OAuth2AuthenticatableError.couldNotAuthenticate }
                view.primaryButton?.onPress(view.primaryButton!)
                expect(messagePresenter.error).toEventually(beError(error: OAuth2AuthenticatableError.couldNotAuthenticate))
            }

            it("should show no error on success") {
                let input = mockInput(.email, value: "user@test.com")
                view.form?.onValueChange(input)
                view.primaryButton?.onPress(view.primaryButton!)
                expect(messagePresenter.error).toEventually(beNil())
            }

            it("should not navigate to enterprise passwod presenter") {
                let input = mockInput(.email, value: "user@test.com")
                view.form?.onValueChange(input)
                view.primaryButton?.onPress(view.primaryButton!)
                expect(navigator.route).toEventually(beNil())
            }

            context("connection with credential auth flag set") {

                beforeEach {
                    options.enterpriseConnectionUsingActiveAuth.append("TestAD")

                    presenter = EnterpriseDomainPresenter(interactor: interactor, navigator: navigator, options: options)
                    presenter.messagePresenter = messagePresenter
                    view = presenter.view as! EnterpriseDomainView
                }

                it("should navigate to enterprise password presenter") {
                    let input = mockInput(.email, value: "user@test.com")
                    view.form?.onValueChange(input)
                    view.primaryButton?.onPress(view.primaryButton!)

                    expect(navigator.route).toEventually(equal(Route.enterpriseActiveAuth(connection: presenter.interactor.connection!, domain: presenter.interactor.domain!)))
                }

                it("should not navigate to enterprise passwod presenter") {
                    let input = mockInput(.email, value: "user@testfail.com")
                    view.form?.onValueChange(input)
                    view.primaryButton?.onPress(view.primaryButton!)

                    expect(navigator.route).toEventually(beNil())
                }
            }
        }

        describe("auth buttons") {

            it("should init view with social view") {
                presenter.authPresenter = authPresenter
                let view = presenter.view as? EnterpriseDomainView
                expect(view?.authCollectionView).to(equal(authPresenter.authView))
            }

            it("should init view with not social view") {
                presenter.authPresenter = nil
                let view = presenter.view as? EnterpriseDomainView
                expect(view?.authCollectionView).to(beNil())
            }

        }
    }

}
