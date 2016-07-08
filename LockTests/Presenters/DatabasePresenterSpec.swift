// DatabasePresenterSpec.swift
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

class DatabasePresenterSpec: QuickSpec {

    override func spec() {

        var interactor: MockDBInteractor!
        var presenter: DatabasePresenter!
        var view: DatabaseView!
        var messagePresenter: MockMessagePresenter!

        beforeEach {
            messagePresenter = MockMessagePresenter()
            interactor = MockDBInteractor()
            var connections = OfflineConnections()
            connections.database(name: connection, requiresUsername: true)
            presenter = DatabasePresenter(interactor: interactor, connections: connections)
            presenter.messagePresenter = messagePresenter
            view = presenter.view as! DatabaseView
        }

        describe("login") {

            beforeEach {
                view.switcher?.selected = .Login
                view.switcher?.onSelectionChange(view.switcher!)
            }

            it("should set title for secondary button") {
                expect(view.secondaryButton?.title) == DatabaseModes.ForgotPassword.title
            }

            describe("user input") {

                it("should clear global message") {
                    messagePresenter.showError("Some Error")
                    let input = mockInput(.Email, value: email)
                    view.form?.onValueChange(input)
                    expect(messagePresenter.success).to(beNil())
                    expect(messagePresenter.message).to(beNil())
                }

                it("should update email") {
                    let input = mockInput(.Email, value: email)
                    view.form?.onValueChange(input)
                    expect(interactor.email) == email
                }

                it("should update username") {
                    let input = mockInput(.Username, value: username)
                    view.form?.onValueChange(input)
                    expect(interactor.username) == username
                }

                it("should update password") {
                    let input = mockInput(.Password, value: password)
                    view.form?.onValueChange(input)
                    expect(interactor.password) == password
                }

                it("should update username or email") {
                    let input = mockInput(.EmailOrUsername, value: username)
                    view.form?.onValueChange(input)
                    expect(interactor.username) == username
                }

                it("should not update if type is not valid for db connection") {
                    let input = mockInput(.Phone, value: "+1234567890")
                    view.form?.onValueChange(input)
                    expect(interactor.username).to(beNil())
                    expect(interactor.email).to(beNil())
                    expect(interactor.password).to(beNil())
                }

                it("should hide the field error if value is valid") {
                    let input = mockInput(.Username, value: username)
                    view.form?.onValueChange(input)
                    expect(input.valid) == true
                }

                it("should show field error if value is invalid") {
                    let input = mockInput(.Username, value: "invalid")
                    view.form?.onValueChange(input)
                    expect(input.valid) == false
                }

            }

            describe("login action") {

                it("should clear global message") {
                    messagePresenter.showError("Some Error")
                    interactor.onLogin = {
                        return nil
                    }
                    view.primaryButton?.onPress(view.primaryButton!)
                    expect(messagePresenter.success).toEventually(beNil())
                    expect(messagePresenter.message).toEventually(beNil())
                }

                it("should show global error message") {
                    interactor.onLogin = {
                        return .CouldNotLogin
                    }
                    view.primaryButton?.onPress(view.primaryButton!)
                    expect(messagePresenter.success).toEventually(beFalse())
                    expect(messagePresenter.message).toEventually(equal("CouldNotLogin"))
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

        describe("sign up") {

            beforeEach {
                view.switcher?.selected = .Signup
                view.switcher?.onSelectionChange(view.switcher!)
            }

            it("should set title for secondary button") {
                expect(view.secondaryButton?.title).notTo(beNil())
            }

            describe("user input") {

                it("should clear global message") {
                    messagePresenter.showError("Some Error")
                    let input = mockInput(.Email, value: email)
                    view.form?.onValueChange(input)
                    expect(messagePresenter.success).to(beNil())
                    expect(messagePresenter.message).to(beNil())
                }

                it("should update email") {
                    let input = mockInput(.Email, value: email)
                    view.form?.onValueChange(input)
                    expect(interactor.email) == email
                }

                it("should update username") {
                    let input = mockInput(.Username, value: username)
                    view.form?.onValueChange(input)
                    expect(interactor.username) == username
                }

                it("should update password") {
                    let input = mockInput(.Password, value: password)
                    view.form?.onValueChange(input)
                    expect(interactor.password) == password
                }

                it("should not update if type is not valid for db connection") {
                    let input = mockInput(.Phone, value: "+1234567890")
                    view.form?.onValueChange(input)
                    expect(interactor.username).to(beNil())
                    expect(interactor.email).to(beNil())
                    expect(interactor.password).to(beNil())
                }

                it("should hide the field error if value is valid") {
                    let input = mockInput(.Username, value: username)
                    view.form?.onValueChange(input)
                    expect(input.valid) == true
                }

                it("should show field error if value is invalid") {
                    let input = mockInput(.Username, value: "invalid")
                    view.form?.onValueChange(input)
                    expect(input.valid) == false
                }

            }

            describe("sign up action") {

                it("should clear global message") {
                    messagePresenter.showError("Some Error")
                    interactor.onSignUp = {
                        return nil
                    }
                    view.primaryButton?.onPress(view.primaryButton!)
                    expect(messagePresenter.success).toEventually(beNil())
                    expect(messagePresenter.message).toEventually(beNil())
                }

                it("should show global error message") {
                    interactor.onSignUp = {
                        return .CouldNotLogin
                    }
                    view.primaryButton?.onPress(view.primaryButton!)
                    expect(messagePresenter.success).toEventually(beFalse())
                    expect(messagePresenter.message).toEventually(equal("CouldNotLogin"))
                }

                it("should trigger sign up on button press") {
                    waitUntil { done in
                        interactor.onSignUp = {
                            done()
                            return nil
                        }
                        view.primaryButton?.onPress(view.primaryButton!)
                    }
                }

                it("should set button in progress on button press") {
                    let button = view.primaryButton!
                    waitUntil { done in
                        interactor.onSignUp = {
                            expect(button.inProgress) == true
                            done()
                            return nil
                        }
                        button.onPress(button)
                    }
                }

                it("should set button to normal after signup") {
                    let button = view.primaryButton!
                    button.onPress(button)
                    expect(button.inProgress).toEventually(beFalse())
                }
                
            }
        }
    }

}

func mockInput(type: InputField.InputType, value: String? = nil) -> MockInputField {
    let input = MockInputField()
    input.type = type
    input.text = value
    return input
}

class MockMessagePresenter: MessagePresenter {
    var success: Bool? = nil
    var message: String? = nil

    func showSuccess(message: String) {
        self.success = true
        self.message = message
    }

    func showError(message: String) {
        self.success = false
        self.message = message
    }

    func hideCurrent() {
        self.message = nil
        self.success = nil
    }
}

class MockInputField: InputField {
    var valid: Bool? = nil

    override func showError(error: String?, noDelay: Bool) {
        self.valid = false
    }

    override func showValid() {
        self.valid = true
    }
}

class MockDBInteractor: DatabaseAuthenticatable {

    var email: String? = nil
    var password: String? = nil
    var username: String? = nil

    var onLogin: () -> DatabaseAuthenticatableError? = { return nil }
    var onSignUp: () -> DatabaseAuthenticatableError? = { return nil }

    func login(callback: (DatabaseAuthenticatableError?) -> ()) {
        callback(onLogin())
    }

    func create(callback: (DatabaseAuthenticatableError?) -> ()) {
        callback(onSignUp())
    }

    func update(attribute: CredentialAttribute, value: String?) throws {
        guard value != "invalid" else { throw NSError(domain: "", code: 0, userInfo: nil) }
        switch attribute {
        case .Email:
            self.email = value
        case .Username:
            self.username = value
        case .Password:
            self.password = value
        }
    }
}