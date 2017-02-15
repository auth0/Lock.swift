// MultifactorPresenterSpec.swift
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

class MultifactorPresenterSpec: QuickSpec {

    override func spec() {

        var interactor: MockMultifactorInteractor!
        var presenter: MultifactorPresenter!
        var view: MultifactorCodeView!
        var messagePresenter: MockMessagePresenter!
        var connection: DatabaseConnection!
        var navigator: Navigable!

        beforeEach {
            navigator = MockNavigator()
            messagePresenter = MockMessagePresenter()
            interactor = MockMultifactorInteractor()
            connection = DatabaseConnection(name: "my-connection", requiresUsername: true)
            presenter = MultifactorPresenter(interactor: interactor, connection: connection, navigator: navigator)
            presenter.messagePresenter = messagePresenter
            view = presenter.view as! MultifactorCodeView
        }

        it("should have button title") {
            expect(view.primaryButton?.title) == "SEND"
        }

        describe("user input") {

            it("should clear global message") {
                messagePresenter.showError(CredentialAuthError.couldNotLogin)
                let input = mockInput(.email, value: email)
                view.form?.onValueChange(input)
                expect(messagePresenter.error).to(beNil())
                expect(messagePresenter.message).to(beNil())
            }

            it("should update code") {
                let input = mockInput(.oneTimePassword, value: code)
                view.form?.onValueChange(input)
                expect(interactor.code) == code
            }

            it("should not update if type is not valid for db connection") {
                let input = mockInput(.phone, value: "not a code")
                view.form?.onValueChange(input)
                expect(interactor.code).to(beNil())
            }

            it("should hide the field error if value is valid") {
                let input = mockInput(.oneTimePassword, value: code)
                view.form?.onValueChange(input)
                expect(input.valid) == true
            }

            it("should show field error if value is invalid") {
                let input = mockInput(.oneTimePassword, value: "invalid")
                view.form?.onValueChange(input)
                expect(input.valid) == false
            }

        }

        describe("login action") {

            it("should trigger action on return of last field") {
                let input = mockInput(.oneTimePassword, value: "123456")
                input.returnKey = .done
                waitUntil { done in
                    interactor.onLogin = {
                        done()
                        return nil
                    }
                    view.form?.onReturn(input)
                }
            }

            it("should not trigger action with nil button") {
                let input = mockInput(.oneTimePassword, value: "123456")
                input.returnKey = .done
                interactor.onLogin = {
                    return .couldNotLogin
                }
                view.primaryButton = nil
                view.form?.onReturn(input)
                expect(messagePresenter.message).toEventually(beNil())
                expect(messagePresenter.error).toEventually(beNil())
            }

            it("should clear global message") {
                messagePresenter.showError(CredentialAuthError.couldNotLogin)
                interactor.onLogin = {
                    return nil
                }
                view.primaryButton?.onPress(view.primaryButton!)
                expect(messagePresenter.error).toEventually(beNil())
                expect(messagePresenter.message).toEventually(beNil())
            }

            it("should show global error message") {
                interactor.onLogin = {
                    return .couldNotLogin
                }
                view.primaryButton?.onPress(view.primaryButton!)
                expect(messagePresenter.error).toEventually(beError(error: CredentialAuthError.couldNotLogin))
            }

            it("should trigger login on button press") {
                waitUntil { done in
                    interactor.onLogin = {
                        done()
                        return nil
                    }
                    view.primaryButton?.onPress(view.primaryButton!)
                }
            }

            it("should set button in progress on button press") {
                let button = view.primaryButton!
                waitUntil { done in
                    interactor.onLogin = {
                        expect(button.inProgress) == true
                        done()
                        return nil
                    }
                    button.onPress(button)
                }
            }

            it("should set button to normal after login") {
                let button = view.primaryButton!
                button.onPress(button)
                expect(button.inProgress).toEventually(beFalse())
            }
        }

    }
}
