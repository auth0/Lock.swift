// DatabaseChangePasswordPresenterSpec.swift
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

@testable import Lock

private let ConfirmField = InputField.InputType.custom(name: "match", placeholder: "Confirm password", icon: InputField.InputType.password.icon, keyboardType: InputField.InputType.password.keyboardType, autocorrectionType: InputField.InputType.password.autocorrectionType, secure: InputField.InputType.password.secure)

class DatabaseChangePasswordPresenterSpec: QuickSpec {

    override func spec() {

        describe("init") {
            let presenter = DatabaseChangePasswordPresenter(interactor: MockPasswordChangeableInteractor(), connection: DatabaseConnection(name: "Username-Password-Authentication", requiresUsername: false), navigator: MockNavigator(), options: LockOptions())

            it("should build presenter") {
                expect(presenter).toNot(beNil())
            }
        }

        var interactor: MockPasswordChangeableInteractor!
        var presenter: DatabaseChangePasswordPresenter!
        var view: DatabaseChangePasswordView!
        var form: ChangeInputView!
        var messagePresenter: MockMessagePresenter!
        var connection: DatabaseConnection!
        var navigator: MockNavigator!
        var options: OptionBuildable!

        beforeEach {
            options = LockOptions()
            navigator = MockNavigator()
            messagePresenter = MockMessagePresenter()
            interactor = MockPasswordChangeableInteractor()
            connection = DatabaseConnection(name: "Username-Password-Authentication", requiresUsername: false)
            presenter = DatabaseChangePasswordPresenter(interactor: interactor, connection: connection, navigator: navigator, options: options)
            presenter.messagePresenter = messagePresenter
            view = presenter.view as! DatabaseChangePasswordView
            form = view.form as! ChangeInputView
        }

        describe("defaults") {

            it("should have button title") {
                expect(view.primaryButton?.title) == "CHANGE PASSWORD"
            }

            it("should have password field") {
                expect(form.newValueField).toNot(beNil())
            }

            it("should not have password confirm field") {
                expect(form.confirmValueField.superview).to(beNil())
            }

            context("disable allowShowPassword") {

                beforeEach {
                    options.allowShowPassword = false
                    presenter = DatabaseChangePasswordPresenter(interactor: interactor, connection: connection, navigator: navigator, options: options)
                    presenter.messagePresenter = messagePresenter
                    view = presenter.view as! DatabaseChangePasswordView
                    form = view.form as! ChangeInputView
                }

                it("should have password field") {
                    expect(form.newValueField).toNot(beNil())
                }

                it("should have password confirm field") {
                    expect(form.confirmValueField).toNot(beNil())
                }

            }

        }

        describe("user input") {

            it("should clear global error message") {
                messagePresenter.showError(PasswordChangeableError.nonValidInput)
                let input = mockInput(.password, value: password)
                view.form?.onValueChange(input)
                expect(messagePresenter.error).to(beNil())
                expect(messagePresenter.message).to(beNil())
            }

            it("should update password and be valid") {
                let input = mockInput(.password, value: password)
                view.form?.onValueChange(input)
                expect(interactor.newPassword) == password
                expect(interactor.validPassword).to(beTrue())
            }

            it("should hide the field error if value is valid") {
                let input = mockInput(.password, value: password)
                view.form?.onValueChange(input)
                expect(input.valid) == true
            }

            it("should show the field error if value is invalid") {
                let input = mockInput(.password, value: "invalid")
                view.form?.onValueChange(input)
                expect(input.valid) == false
            }

            it("should be confirmed as matching password") {
                interactor.newPassword = password
                let input = mockInput(ConfirmField, value: password)
                view.form?.onValueChange(input)
                expect(interactor.confirmed).to(beTrue())
            }

            it("should not be confirmed as non match") {
                let input = mockInput(ConfirmField, value: password)
                view.form?.onValueChange(input)
                expect(interactor.confirmed).to(beFalse())
                expect(input.valid) == false
            }

        }

        describe("change password") {

            it("should trigger action on return of last field") {
                let input = mockInput(.password, value: password)
                input.returnKey = .done
                waitUntil { done in
                    interactor.onRequest = {
                        done()
                        return nil
                    }
                    view.form?.onReturn(input)
                }
            }

        }

    }
}

class MockPasswordChangeableInteractor: PasswordChangeable {

    var newPassword: String?
    var validPassword: Bool = false
    var confirmed: Bool = false
    var email: String?
    var onRequest: () -> PasswordChangeableError? = { return nil }

    func changePassword(_ callback: @escaping (PasswordChangeableError?) -> ()) {
        callback(onRequest())
    }

    func update(_ input: InputField) throws {
        if case .password = input.type {
            guard input.text != "invalid" else {
                self.validPassword = false
                throw PasswordChangeableError.nonValidInput
            }
            self.newPassword = input.text
            self.validPassword = true
        } else if case .custom = input.type {
            self.confirmed = input.text == newPassword
            if !confirmed { throw PasswordChangeableError.noConfirmation }
        }
    }
}