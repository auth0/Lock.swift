// PasswordlessPresenterSpec.swift
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
import Auth0

@testable import Lock

private let phone = "01234567891"

class PasswordlessPresenterSpec: QuickSpec {

    override func spec() {

        let authentication = Auth0.authentication(clientId: clientId, domain: domain)

        var messagePresenter: MockMessagePresenter!
        var options: OptionBuildable!
        var user: User!
        var passwordlessActivity: MockPasswordlessActivity!
        var interactor: PasswordlessInteractor!
        var presenter: PasswordlessPresenter!
        var connection: PasswordlessConnection!
        var navigator: MockNavigator!
        var dispatcher: Dispatcher!
        var view: PasswordlessView!

        context("email") {

            beforeEach {
                navigator = MockNavigator()
                connection = PasswordlessConnection(name: "email")
                messagePresenter = MockMessagePresenter()
                options = LockOptions()
                options.passwordlessMethod = .emailCode
                user = User()
                passwordlessActivity = MockPasswordlessActivity()
                dispatcher = ObserverStore()
                interactor = PasswordlessInteractor(authentication: authentication, dispatcher: dispatcher, user: user, options: options, passwordlessActivity: passwordlessActivity)
                presenter = PasswordlessPresenter(interactor: interactor, connection: connection, navigator: navigator, options: options)
                presenter.messagePresenter = messagePresenter
                view = presenter.view as! PasswordlessView
            }

            describe("request screen") {

                it("should show request screen") {
                    expect(presenter.screen) == PasswordlessScreen.request
                }

                it("should expect email input in form") {
                    let form = view.form as! SingleInputView
                    expect(form.type) == InputField.InputType.email
                }

                it("should expect no secondary button") {
                    expect(view.secondaryButton).to(beNil())
                }

                describe("input") {

                    it("should update email") {
                        let input = mockInput(.email, value: email)
                        view.form?.onValueChange(input)
                        expect(interactor.identifier) == email
                        expect(interactor.validIdentifier) == true
                    }

                    it("should show field error if email is invalid") {
                        let input = mockInput(.email, value: "invalid_email")
                        view.form?.onValueChange(input)
                        expect(input.valid) == false
                    }

                }

                describe("request code") {

                    var interactor: MockPasswordlessInteractor!

                    beforeEach {
                        interactor = MockPasswordlessInteractor()
                        interactor.onLogin = { return nil }
                        interactor.onRequest = { return nil }
                        presenter = PasswordlessPresenter(interactor: interactor, connection: connection, navigator: navigator, options: options)
                        presenter.messagePresenter = messagePresenter
                        view = presenter.view as! PasswordlessView
                    }

                    it("should trigger action on return of field") {
                        let input = mockInput(.email, value: email)
                        input.returnKey = .done
                        interactor.onRequest = { return nil }
                        view.form?.onReturn(input)
                        expect(messagePresenter.error).toEventually(beNil())
                    }

                    it("should trigger action on primary button press") {
                        view.primaryButton!.onPress(view.primaryButton!)
                        expect(messagePresenter.error).toEventually(beNil())
                    }

                    it("should route to code screen upon success") {
                        view.primaryButton!.onPress(view.primaryButton!)
                        expect(navigator.route).toEventually(equal(Route.passwordless(screen: .code, connection: connection)))
                    }

                    it("should show error on failure") {
                        interactor.onRequest = { return .codeNotSent }
                        view.primaryButton!.onPress(view.primaryButton!)
                        expect(messagePresenter.error).toEventuallyNot(beNil())
                    }

                }

                describe("request link") {

                    var interactor: MockPasswordlessInteractor!

                    beforeEach {
                        options.passwordlessMethod = .emailLink
                        interactor = MockPasswordlessInteractor()
                        interactor.onLogin = { return nil }
                        interactor.onRequest = { return nil }
                        presenter = PasswordlessPresenter(interactor: interactor, connection: connection, navigator: navigator, options: options)
                        presenter.messagePresenter = messagePresenter
                        view = presenter.view as! PasswordlessView
                    }

                    it("should trigger action on return of field") {
                        let input = mockInput(.email, value: email)
                        input.returnKey = .done
                        interactor.onRequest = { return nil }
                        view.form?.onReturn(input)
                        expect(messagePresenter.error).toEventually(beNil())
                    }

                    it("should trigger action on primary button press") {
                        view.primaryButton!.onPress(view.primaryButton!)
                        expect(messagePresenter.error).toEventually(beNil())
                    }

                    it("should route to link sent screen upon success") {
                        view.primaryButton!.onPress(view.primaryButton!)
                        expect(navigator.route).toEventually(equal(Route.passwordless(screen: .linkSent, connection: connection)))
                    }

                    it("should show error on failure") {
                        interactor.onRequest = { return .codeNotSent }
                        view.primaryButton!.onPress(view.primaryButton!)
                        expect(messagePresenter.error).toEventuallyNot(beNil())
                    }

                }

            }

            describe("code auth screen") {

                let screen = PasswordlessScreen.code

                beforeEach {
                    presenter = PasswordlessPresenter(interactor: interactor, connection: connection, navigator: navigator, options: options, screen: screen)
                    presenter.messagePresenter = messagePresenter
                    view = presenter.view as! PasswordlessView
                }

                it("should show code screen") {
                    expect(presenter.screen) == PasswordlessScreen.code
                }

                it("should expect code input in form") {
                    let form = view.form as! SingleInputView
                    expect(form.type) == InputField.InputType.oneTimePassword
                }

                it("should expect title on secondary button") {
                    expect(view.secondaryButton!.title).to(contain("Did not get the code"))
                }

                describe("input") {

                    it("should update code") {
                        let input = mockInput(.oneTimePassword, value: "123456")
                        view.form?.onValueChange(input)
                        expect(presenter.interactor.code) == "123456"
                        expect(presenter.interactor.validCode) == true
                    }

                    it("should show field error if code is invalid") {
                        let input = mockInput(.oneTimePassword, value: "ABC")
                        view.form?.onValueChange(input)
                        expect(input.valid) == false
                    }

                }

                describe("login") {

                    var interactor: MockPasswordlessInteractor!

                    beforeEach {
                        interactor = MockPasswordlessInteractor()
                        interactor.onLogin = { return nil }
                        interactor.onRequest = { return nil }
                        presenter = PasswordlessPresenter(interactor: interactor, connection: connection, navigator: navigator, options: options, screen: screen)
                        presenter.messagePresenter = messagePresenter
                        view = presenter.view as! PasswordlessView
                    }

                    it("should trigger action on return of field") {
                        messagePresenter.error = CredentialAuthError.couldNotLogin
                        let input = mockInput(.oneTimePassword, value: "123456")
                        input.returnKey = .done
                        view.form?.onReturn(input)
                        expect(messagePresenter.error).toEventually(beNil())
                    }

                    it("should show no error upon success") {
                        messagePresenter.error = CredentialAuthError.couldNotLogin
                        view.primaryButton!.onPress(view.primaryButton!)
                        expect(messagePresenter.error).toEventually(beNil())
                    }
                    
                    it("should show error on failure") {
                        interactor.onLogin = { return .couldNotLogin }
                        view.primaryButton!.onPress(view.primaryButton!)
                        expect(messagePresenter.error).toEventuallyNot(beNil())
                    }
                    
                }
                
            }
            
            describe("link sent screen") {
                
                let screen = PasswordlessScreen.linkSent
                
                beforeEach {
                    presenter = PasswordlessPresenter(interactor: interactor, connection: connection, navigator: navigator, options: options, screen: screen)
                    presenter.messagePresenter = messagePresenter
                    view = presenter.view as! PasswordlessView
                }
                
                it("should show code screen") {
                    expect(presenter.screen) == PasswordlessScreen.linkSent
                }
                
                it("should expect title on secondary button") {
                    expect(view.secondaryButton!.title).to(contain("Did not receive the link"))
                }
                
            }
        }

        context("sms") {

            beforeEach {
                navigator = MockNavigator()
                connection = PasswordlessConnection(name: "sms")
                messagePresenter = MockMessagePresenter()
                options = LockOptions()
                options.passwordlessMethod = .smsCode
                user = User()
                passwordlessActivity = MockPasswordlessActivity()
                dispatcher = ObserverStore()
                interactor = PasswordlessInteractor(authentication: authentication, dispatcher: dispatcher, user: user, options: options, passwordlessActivity: passwordlessActivity)
                presenter = PasswordlessPresenter(interactor: interactor, connection: connection, navigator: navigator, options: options)
                presenter.messagePresenter = messagePresenter
                view = presenter.view as! PasswordlessView
            }

            describe("request screen") {

                it("should show request screen") {
                    expect(presenter.screen) == PasswordlessScreen.request
                }

                it("should expect phone input in form") {
                    let form = view.form as! InternationalPhoneInputView
                    expect(form.type) == InputField.InputType.phone
                }

                it("should expect country store data in form") {
                    let form = view.form as! InternationalPhoneInputView
                    expect(form.countryStore).toNot(beNil())
                }

                it("should expect no secondary button") {
                    expect(view.secondaryButton).to(beNil())
                }

                describe("input") {

                    it("should update sms") {
                        let input = mockInput(.phone, value: phone)
                        view.form?.onValueChange(input)
                        expect(interactor.identifier) == phone
                        expect(interactor.validIdentifier) == true
                    }

                    it("should show field error if email is invalid") {
                        let input = mockInput(.phone, value: "0")
                        view.form?.onValueChange(input)
                        expect(input.valid) == false
                    }

                }

                describe("request code") {

                    var interactor: MockPasswordlessInteractor!

                    beforeEach {
                        interactor = MockPasswordlessInteractor()
                        interactor.onLogin = { return nil }
                        interactor.onRequest = { return nil }
                        presenter = PasswordlessPresenter(interactor: interactor, connection: connection, navigator: navigator, options: options)
                        presenter.messagePresenter = messagePresenter
                        view = presenter.view as! PasswordlessView
                    }

                    it("should trigger action on return of field") {
                        let input = mockInput(.phone, value: phone)
                        input.returnKey = .done
                        interactor.onRequest = { return nil }
                        view.form?.onReturn(input)
                        expect(messagePresenter.error).toEventually(beNil())
                    }

                    it("should trigger action on primary button press") {
                        view.primaryButton!.onPress(view.primaryButton!)
                        expect(messagePresenter.error).toEventually(beNil())
                    }

                    it("should route to code screen upon success") {
                        view.primaryButton!.onPress(view.primaryButton!)
                        expect(navigator.route).toEventually(equal(Route.passwordless(screen: .code, connection: connection)))
                    }

                    it("should show error on failure") {
                        interactor.onRequest = { return .codeNotSent }
                        view.primaryButton!.onPress(view.primaryButton!)
                        expect(messagePresenter.error).toEventuallyNot(beNil())
                    }

                }

                describe("request link") {

                    var interactor: MockPasswordlessInteractor!

                    beforeEach {
                        options.passwordlessMethod = .smsLink
                        interactor = MockPasswordlessInteractor()
                        interactor.onLogin = { return nil }
                        interactor.onRequest = { return nil }
                        presenter = PasswordlessPresenter(interactor: interactor, connection: connection, navigator: navigator, options: options)
                        presenter.messagePresenter = messagePresenter
                        view = presenter.view as! PasswordlessView
                    }

                    it("should trigger action on return of field") {
                        let input = mockInput(.phone, value: phone)
                        input.returnKey = .done
                        interactor.onRequest = { return nil }
                        view.form?.onReturn(input)
                        expect(messagePresenter.error).toEventually(beNil())
                    }

                    it("should trigger action on primary button press") {
                        view.primaryButton!.onPress(view.primaryButton!)
                        expect(messagePresenter.error).toEventually(beNil())
                    }

                    it("should route to link sent screen upon success") {
                        view.primaryButton!.onPress(view.primaryButton!)
                        expect(navigator.route).toEventually(equal(Route.passwordless(screen: .linkSent, connection: connection)))
                    }

                    it("should show error on failure") {
                        interactor.onRequest = { return .codeNotSent }
                        view.primaryButton!.onPress(view.primaryButton!)
                        expect(messagePresenter.error).toEventuallyNot(beNil())
                    }

                }

            }

            describe("code auth screen") {

                let screen = PasswordlessScreen.code

                beforeEach {
                    presenter = PasswordlessPresenter(interactor: interactor, connection: connection, navigator: navigator, options: options, screen: screen)
                    presenter.messagePresenter = messagePresenter
                    view = presenter.view as! PasswordlessView
                }

                it("should show code screen") {
                    expect(presenter.screen) == PasswordlessScreen.code
                }

                it("should expect code input in form") {
                    let form = view.form as! SingleInputView
                    expect(form.type) == InputField.InputType.oneTimePassword
                }

                it("should expect title on secondary button") {
                    expect(view.secondaryButton!.title).to(contain("Did not get the code"))
                }

                describe("input") {

                    it("should update code") {
                        let input = mockInput(.oneTimePassword, value: "123456")
                        view.form?.onValueChange(input)
                        expect(presenter.interactor.code) == "123456"
                        expect(presenter.interactor.validCode) == true
                    }

                    it("should show field error if code is invalid") {
                        let input = mockInput(.oneTimePassword, value: "ABC")
                        view.form?.onValueChange(input)
                        expect(input.valid) == false
                    }

                }

                describe("login") {

                    var interactor: MockPasswordlessInteractor!

                    beforeEach {
                        interactor = MockPasswordlessInteractor()
                        interactor.onLogin = { return nil }
                        interactor.onRequest = { return nil }
                        presenter = PasswordlessPresenter(interactor: interactor, connection: connection, navigator: navigator, options: options, screen: screen)
                        presenter.messagePresenter = messagePresenter
                        view = presenter.view as! PasswordlessView
                    }

                    it("should trigger action on return of field") {
                        messagePresenter.error = CredentialAuthError.couldNotLogin
                        let input = mockInput(.oneTimePassword, value: "123456")
                        input.returnKey = .done
                        view.form?.onReturn(input)
                        expect(messagePresenter.error).toEventually(beNil())
                    }

                    it("should show no error upon success") {
                        messagePresenter.error = CredentialAuthError.couldNotLogin
                        view.primaryButton!.onPress(view.primaryButton!)
                        expect(messagePresenter.error).toEventually(beNil())
                    }

                    it("should show error on failure") {
                        interactor.onLogin = { return .couldNotLogin }
                        view.primaryButton!.onPress(view.primaryButton!)
                        expect(messagePresenter.error).toEventuallyNot(beNil())
                    }

                }

            }

            describe("link sent screen") {

                let screen = PasswordlessScreen.linkSent

                beforeEach {
                    presenter = PasswordlessPresenter(interactor: interactor, connection: connection, navigator: navigator, options: options, screen: screen)
                    presenter.messagePresenter = messagePresenter
                    view = presenter.view as! PasswordlessView
                }
                
                it("should show code screen") {
                    expect(presenter.screen) == PasswordlessScreen.linkSent
                }
                
                it("should expect title on secondary button") {
                    expect(view.secondaryButton!.title).to(contain("Did not receive the link"))
                }
                
            }
        }
    }
}


