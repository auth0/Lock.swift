// DatabaseForgotPasswordPresenterSpec.swift
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

class DatabaseForgotPasswordPresenterSpec: QuickSpec {

    override func spec() {

        var interactor: MockForgotInteractor!
        var presenter: DatabaseForgotPasswordPresenter!
        var view: DatabaseForgotPasswordView!
        var messagePresenter: MockMessagePresenter!
        var connections: OfflineConnections!
        var navigator: MockNavigator!
        var options: OptionBuildable!

        beforeEach {
            options = LockOptions()
            navigator = MockNavigator()
            messagePresenter = MockMessagePresenter()
            interactor = MockForgotInteractor()
            connections = OfflineConnections()
            connections.database(name: connection, requiresUsername: true)
            presenter = DatabaseForgotPasswordPresenter(interactor: interactor, connections: connections, navigator: navigator, options: options)
            presenter.messagePresenter = messagePresenter
            view = presenter.view as! DatabaseForgotPasswordView
        }

        it("should use valid email") {
            interactor.email = email
            interactor.validEmail = true
            presenter = DatabaseForgotPasswordPresenter(interactor: interactor, connections: connections, navigator: navigator, options: options)
            let view = (presenter.view as! DatabaseForgotPasswordView).form as! SingleInputView
            expect(view.value) == email
        }

        it("should not use invalid email") {
            interactor.email = email
            interactor.validEmail = false
            presenter = DatabaseForgotPasswordPresenter(interactor: interactor, connections: connections, navigator: navigator, options: options)
            let view = (presenter.view as! DatabaseForgotPasswordView).form as! SingleInputView
            expect(view.value) != email
        }

        it("should have button title") {
            expect(view.primaryButton?.title) == "SEND EMAIL"
        }

        describe("forgot") {

            describe("user input") {

                it("should clear global message") {
                    messagePresenter.showError(PasswordRecoverableError.emailNotSent)
                    let input = mockInput(.email, value: email)
                    view.form?.onValueChange(input)
                    expect(messagePresenter.error).to(beNil())
                    expect(messagePresenter.message).to(beNil())
                }

                it("should update email") {
                    let input = mockInput(.email, value: email)
                    view.form?.onValueChange(input)
                    expect(interactor.email) == email
                }


                it("should not update if type is not valid for db connection") {
                    let input = mockInput(.phone, value: "+1234567890")
                    view.form?.onValueChange(input)
                    expect(interactor.email).to(beNil())
                }

                it("should hide the field error if value is valid") {
                    let input = mockInput(.email, value: email)
                    view.form?.onValueChange(input)
                    expect(input.valid) == true
                }

                it("should show field error if value is invalid") {
                    let input = mockInput(.email, value: "invalid")
                    view.form?.onValueChange(input)
                    expect(input.valid) == false
                }

            }

            describe("request forgot email action") {

                it("should trigger action on return of last field") {
                    let input = mockInput(.email, value: email)
                    input.returnKey = .done
                    waitUntil { done in
                        interactor.onRequest = {
                            done()
                            return nil
                        }
                        view.form?.onReturn(input)
                    }
                }

                it("should not trigger action with nil button") {
                    let input = mockInput(.oneTimePassword, value: "123456")
                    input.returnKey = .done
                    interactor.onRequest = {
                        return .emailNotSent
                    }
                    view.primaryButton = nil
                    view.form?.onReturn(input)
                    expect(messagePresenter.message).toEventually(beNil())
                    expect(messagePresenter.error).toEventually(beNil())
                }

                it("should show global error message") {
                    interactor.onRequest = {
                        return .noDatabaseConnection
                    }
                    view.primaryButton?.onPress(view.primaryButton!)
                    expect(messagePresenter.error).toEventually(beError(error: PasswordRecoverableError.noDatabaseConnection))
                }

                it("should show global error message") {
                    interactor.onRequest = {
                        return .nonValidInput
                    }
                    view.primaryButton?.onPress(view.primaryButton!)
                    expect(messagePresenter.error).toEventually(beError(error: PasswordRecoverableError.nonValidInput))
                }

                it("should show global error message") {
                    interactor.onRequest = {
                        return .emailNotSent
                    }
                    view.primaryButton?.onPress(view.primaryButton!)
                    expect(messagePresenter.error).toEventually(beError(error: PasswordRecoverableError.emailNotSent))
                }

                it("should show global success message") {
                    interactor.onRequest = {
                        return nil
                    }
                    view.primaryButton?.onPress(view.primaryButton!)
                    expect(messagePresenter.message).toEventuallyNot(beNil())
                }

                it("should trigger request on button press") {
                    waitUntil { done in
                        interactor.onRequest = {
                            done()
                            return nil
                        }
                        view.primaryButton?.onPress(view.primaryButton!)
                    }
                }

                it("should set button in progress on button press") {
                    let button = view.primaryButton!
                    waitUntil { done in
                        interactor.onRequest = {
                            expect(button.inProgress) == true
                            done()
                            return nil
                        }
                        button.onPress(button)
                    }
                }

                it("should set button to normal after request") {
                    let button = view.primaryButton!
                    button.onPress(button)
                    expect(button.inProgress).toEventually(beFalse())
                }

                context("no login screen") {

                    beforeEach {
                        options.allow = .ResetPassword
                        presenter = DatabaseForgotPasswordPresenter(interactor: interactor, connections: connections, navigator: navigator, options: options)
                        presenter.messagePresenter = messagePresenter
                        view = presenter.view as! DatabaseForgotPasswordView
                    }

                    it("should not show global success message") {
                        interactor.onRequest = {
                            return nil
                        }
                        view.primaryButton?.onPress(view.primaryButton!)
                        expect(messagePresenter.message).toEventually(beNil())
                    }

                    it("should show global success message") {
                        options.allow = .ResetPassword
                        options.autoClose = false
                        presenter = DatabaseForgotPasswordPresenter(interactor: interactor, connections: connections, navigator: navigator, options: options)
                        presenter.messagePresenter = messagePresenter
                        view = presenter.view as! DatabaseForgotPasswordView

                        interactor.onRequest = {
                            return nil
                        }
                        view.primaryButton?.onPress(view.primaryButton!)
                        expect(messagePresenter.message).toEventuallyNot(beNil())
                    }

                }


            }

            describe("navigation on success") {

                it("should navigate to .root") {
                    let button = view.primaryButton!
                    interactor.onRequest = {
                        return nil
                    }
                    button.onPress(button)
                    expect(navigator.route).toEventually(equal(Route.root))
                }

                it("should not navigate to .root") {
                    options.allow = .ResetPassword
                    navigator.route = .forgotPassword

                    presenter = DatabaseForgotPasswordPresenter(interactor: interactor, connections: connections, navigator: navigator, options: options)
                    view = presenter.view as! DatabaseForgotPasswordView

                    let button = view.primaryButton!
                    interactor.onRequest = {
                        return nil
                    }
                    button.onPress(button)
                    expect(navigator.route).toEventuallyNot(equal(Route.root))
                }

            }

        }

    }

}

class MockForgotInteractor: PasswordRecoverable {

    var validEmail: Bool = false
    var email: String?
    var onRequest: () -> PasswordRecoverableError? = { return nil }

    func requestEmail(_ callback: @escaping (PasswordRecoverableError?) -> ()) {
        callback(onRequest())
    }

    func updateEmail(_ value: String?) throws {
        guard value != "invalid" else {
            self.validEmail = false
            throw NSError(domain: "", code: 0, userInfo: nil)
        }
        self.validEmail = true
        self.email = value
    }
}
