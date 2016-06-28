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

        beforeEach {
            interactor = MockDBInteractor()
            var connections = OfflineConnections()
            connections.database(name: connection, requiresUsername: true)
            presenter = DatabasePresenter(interactor: interactor, connections: connections)
            view = presenter.view
        }

        describe("login") {

            it("should set title for secondary button") {
                expect(view.secondaryButton?.title) == DatabaseModes.ForgotPassword.title
            }

            describe("user input") {

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

}

func mockInput(type: InputField.InputType, value: String? = nil) -> MockInputField {
    let input = MockInputField()
    input.type = type
    input.text = value
    return input
}

class MockInputField: InputField {
    var valid: Bool? = nil

    override func showError(error: String?) {
        self.valid = false
    }

    override func hideError() {
        self.valid = true
    }
}

class MockDBInteractor: CredentialAuthenticatable {

    var email: String? = nil
    var password: String? = nil
    var username: String? = nil

    var onLogin: () -> AuthenticatableError? = { _ in return nil }

    func login(callback: (AuthenticatableError?) -> ()) {
        callback(onLogin())
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