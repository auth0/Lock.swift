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
        var enterpriseInteractor: EnterpriseDomainInteractor!
        var oauth2: MockOAuth2!
        var connections: OfflineConnections!
        var interactor: MockDBInteractor!
        var presenter: DatabasePresenter!
        var view: DatabaseOnlyView!
        var messagePresenter: MockMessagePresenter!
        var authPresenter: MockAuthPresenter!
        var navigator: MockNavigator!
        
        beforeEach {
            oauth2 = MockOAuth2()
            connections = OfflineConnections()
            
            enterpriseInteractor = EnterpriseDomainInteractor(connections: connections.enterprise, authentication: oauth2)
            authPresenter = MockAuthPresenter(connections: connections, interactor: MockAuthInteractor(), customStyle: [:])
            messagePresenter = MockMessagePresenter()
            interactor = MockDBInteractor()
            navigator = MockNavigator()
            presenter = DatabasePresenter(authenticator: interactor, creator: interactor, connection: DatabaseConnection(name: connection, requiresUsername: true), navigator: navigator, options: LockOptions())
            presenter.messagePresenter = messagePresenter
            view = presenter.view as! DatabaseOnlyView
        }
        
        describe("auth buttons") {
            
            it("should init view with social view") {
                presenter.authPresenter = authPresenter
                let view = presenter.view as? DatabaseView
                expect(view?.authCollectionView) == authPresenter.authView
            }
            
            it("should init view with not social view") {
                presenter.authPresenter = nil
                let view = presenter.view as? DatabaseView
                expect(view?.authCollectionView).to(beNil())
            }
            
            it("should set a new one when switching tabs") {
                presenter.authPresenter = authPresenter
                let view = presenter.view as? DatabaseView
                let newView = AuthCollectionView(connections: [], mode: .Expanded(isLogin: true), insets: UIEdgeInsetsZero, customStyle: [:])  { _ in }
                authPresenter.authView = newView
                view?.switcher?.onSelectionChange((view?.switcher)!)
                expect(view?.authCollectionView) == newView
            }
            
        }
        
        describe("user state") {
            
            it("should return initial valid email") {
                interactor.validEmail = true
                interactor.email = email
                expect(presenter.initialEmail) == email
            }
            
            it("should not return initial invalid email") {
                interactor.validEmail = false
                interactor.email = email
                expect(presenter.initialEmail).to(beNil())
            }
            
            it("should return initial valid username") {
                interactor.validUsername = true
                interactor.username = username
                expect(presenter.initialUsername) == username
            }
            
            it("should not return initial invalid email") {
                interactor.validUsername = false
                interactor.username = username
                expect(presenter.initialUsername).to(beNil())
            }
            
            it("should set identifier default in login") {
                interactor.identifier = email
                view.switcher?.selected = .Login
                view.switcher?.onSelectionChange(view.switcher!)
                let view = view.form as! CredentialView
                expect(view.identityField.text) == email
            }
            
            it("should set email and password in signup") {
                interactor.validEmail = true
                interactor.email = email
                interactor.validUsername = true
                interactor.username = username
                view.switcher?.selected = .Signup
                view.switcher?.onSelectionChange(view.switcher!)
                let view = view.form as! SignUpView
                expect(view.emailField.text) == email
                expect(view.usernameField?.text) == username
            }
            
        }
        
        describe("allowed modes & initial screen") {
            
            it("should keep switcher when login and signup are allowed") {
                var options = LockOptions()
                options.allow = [.Login, .Signup]
                presenter = DatabasePresenter(authenticator: interactor, creator: interactor, connection: DatabaseConnection(name: connection, requiresUsername: true), navigator: navigator, options: options)
                view = presenter.view as! DatabaseOnlyView
                expect(view.switcher).toNot(beNil())
            }
            
            it("should remove switcher when login or signup are not allowed") {
                var options = LockOptions()
                options.allow = [.Login]
                presenter = DatabasePresenter(authenticator: interactor, creator: interactor, connection: DatabaseConnection(name: connection, requiresUsername: true), navigator: navigator, options: options)
                view = presenter.view as! DatabaseOnlyView
                expect(view.switcher).to(beNil())
            }
            
            it("should remove forgot button if it's not allowed") {
                var options = LockOptions()
                options.allow = [.Login]
                presenter = DatabasePresenter(authenticator: interactor, creator: interactor, connection: DatabaseConnection(name: connection, requiresUsername: true), navigator: navigator, options: options)
                view = presenter.view as! DatabaseOnlyView
                expect(view.secondaryButton).to(beNil())
            }
            
            it("should show login if is allowed and is initial screen") {
                var options = LockOptions()
                options.allow = [.Login]
                options.initialScreen = .Login
                presenter = DatabasePresenter(authenticator: interactor, creator: interactor, connection: DatabaseConnection(name: connection, requiresUsername: true), navigator: navigator, options: options)
                view = presenter.view as! DatabaseOnlyView
                expect(view.form as? CredentialView).toNot(beNil())
            }
            
            it("should show signup if login is not allowed") {
                var options = LockOptions()
                options.allow = [.Signup]
                presenter = DatabasePresenter(authenticator: interactor, creator: interactor, connection: DatabaseConnection(name: connection, requiresUsername: true), navigator: navigator, options: options)
                view = presenter.view as! DatabaseOnlyView
                expect(view.form as? SignUpView).toNot(beNil())
            }
            
            it("should show signup if is the initial screen") {
                var options = LockOptions()
                options.allow = [.Signup, .Login]
                options.initialScreen = .Signup
                presenter = DatabasePresenter(authenticator: interactor, creator: interactor, connection: DatabaseConnection(name: connection, requiresUsername: true), navigator: navigator, options: options)
                view = presenter.view as! DatabaseOnlyView
                expect(view.form as? SignUpView).toNot(beNil())
            }
            
            it("should always show terms button in signup") {
                var options = LockOptions()
                options.allow = [.Signup]
                presenter = DatabasePresenter(authenticator: interactor, creator: interactor, connection: DatabaseConnection(name: connection, requiresUsername: true), navigator: navigator, options: options)
                view = presenter.view as! DatabaseOnlyView
                expect(view.secondaryButton).toNot(beNil())
            }
            
        }
        
        describe("login") {
            
            beforeEach {
                view.switcher?.selected = .Login
                view.switcher?.onSelectionChange(view.switcher!)
            }
            
            it("should set title for secondary button") {
                expect(view.secondaryButton?.title) == "Don’t remember your password?"
            }
            
            it("should reset scroll") {
                expect(navigator.resetted) == true
            }
            
            describe("user input") {
                
                it("should clear global message") {
                    messagePresenter.showError(DatabaseAuthenticatableError.CouldNotLogin)
                    let input = mockInput(.Email, value: email)
                    view.form?.onValueChange(input)
                    expect(messagePresenter.error).to(beNil())
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
                
                it("should trigger action on return of last field") {
                    let input = mockInput(.Password, value: password)
                    input.returnKey = .Done
                    waitUntil { done in
                        interactor.onLogin = {
                            done()
                            return nil
                        }
                        view.form?.onReturn(input)
                    }
                }
                
                it("should not trigger action if return key is not .Done") {
                    let input = mockInput(.Password, value: password)
                    input.returnKey = .Next
                    interactor.onLogin = {
                        return .CouldNotLogin
                    }
                    view.form?.onReturn(input)
                    expect(messagePresenter.message).toEventually(beNil())
                    expect(messagePresenter.error).toEventually(beNil())
                }
                
                it("should clear global message") {
                    messagePresenter.showError(DatabaseAuthenticatableError.CouldNotLogin)
                    interactor.onLogin = {
                        return nil
                    }
                    view.primaryButton?.onPress(view.primaryButton!)
                    expect(messagePresenter.error).toEventually(beNil())
                    expect(messagePresenter.message).toEventually(beNil())
                }
                
                it("should show global error message") {
                    interactor.onLogin = {
                        return .CouldNotLogin
                    }
                    view.primaryButton?.onPress(view.primaryButton!)
                    expect(messagePresenter.error).toEventually(beError(error: DatabaseAuthenticatableError.CouldNotLogin))
                }
                
                it("should navigate to multifactor required screen") {
                    interactor.onLogin = {
                        return .MultifactorRequired
                    }
                    view.primaryButton?.onPress(view.primaryButton!)
                    expect(navigator.route).toEventually(equal(Route.Multifactor))
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
                
                it("should navigate to forgot password") {
                    let button = view.secondaryButton!
                    button.onPress(button)
                    expect(navigator.route).toEventually(equal(Route.ForgotPassword))
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
                    messagePresenter.showError(DatabaseUserCreatorError.CouldNotCreateUser)
                    let input = mockInput(.Email, value: email)
                    view.form?.onValueChange(input)
                    expect(messagePresenter.error).to(beNil())
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
                
                it("should custom field") {
                    let name = "Auth0"
                    let input = mockInput(.Custom(name: "first_name", placeholder: "Name", icon: LazyImage(name: "ic_auth0", bundle: Lock.bundle), keyboardType: .Default, autocorrectionType: .No, secure: false), value: name)
                    view.form?.onValueChange(input)
                    expect(interactor.custom["first_name"]) == name
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
                
                it("should trigger action on return of last field") {
                    let input = mockInput(.Password, value: password)
                    input.returnKey = .Done
                    waitUntil { done in
                        interactor.onSignUp = {
                            done()
                            return nil
                        }
                        view.form?.onReturn(input)
                    }
                }
                
                it("should not trigger action if return key is not .Done") {
                    let input = mockInput(.Password, value: password)
                    input.returnKey = .Next
                    interactor.onSignUp = {
                        return .CouldNotCreateUser
                    }
                    view.form?.onReturn(input)
                    expect(messagePresenter.message).toEventually(beNil())
                    expect(messagePresenter.error).toEventually(beNil())
                }
                
                it("should not trigger action with nil button") {
                    let input = mockInput(.OneTimePassword, value: "123456")
                    input.returnKey = .Done
                    interactor.onLogin = {
                        return .CouldNotLogin
                    }
                    view.primaryButton = nil
                    view.form?.onReturn(input)
                    expect(messagePresenter.message).toEventually(beNil())
                    expect(messagePresenter.error).toEventually(beNil())
                }
                
                it("should clear global message") {
                    messagePresenter.showError(DatabaseUserCreatorError.CouldNotCreateUser)
                    interactor.onSignUp = {
                        return nil
                    }
                    view.primaryButton?.onPress(view.primaryButton!)
                    expect(messagePresenter.error).toEventually(beNil())
                    expect(messagePresenter.message).toEventually(beNil())
                }
                
                it("should show global error message") {
                    interactor.onSignUp = {
                        return .CouldNotCreateUser
                    }
                    view.primaryButton?.onPress(view.primaryButton!)
                    expect(messagePresenter.error).toEventually(beError(error: DatabaseUserCreatorError.CouldNotCreateUser))
                }
                
                it("should show global error message for login") {
                    interactor.onLogin = {
                        return .CouldNotLogin
                    }
                    view.primaryButton?.onPress(view.primaryButton!)
                    expect(messagePresenter.error).toEventually(beError(error: DatabaseAuthenticatableError.CouldNotLogin))
                }
                
                it("should navigate to multifactor required screen") {
                    interactor.onLogin = {
                        return .MultifactorRequired
                    }
                    view.primaryButton?.onPress(view.primaryButton!)
                    expect(navigator.route).toEventually(equal(Route.Multifactor))
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
            
            describe("tos action") {
                
                beforeEach {
                    let button = view.secondaryButton!
                    button.onPress(button)
                }
                
                it("should present alert controller for ToS") {
                    expect(navigator.presented as? UIAlertController).toEventuallyNot(beNil())
                    expect(navigator.presented?.title).toEventually(beNil())
                }
                
                it("should have actions") {
                    let alert = navigator.presented as? UIAlertController
                    expect(alert?.message).toEventually(beNil())
                    expect(alert?.preferredStyle) == UIAlertControllerStyle.ActionSheet
                    expect(alert?.actions).to(haveAction("Cancel", style: .Cancel))
                    expect(alert?.actions).to(haveAction("Terms of Service", style: .Default))
                    expect(alert?.actions).to(haveAction("Privacy Policy", style: .Default))
                }
            }
            
            describe("enterprise support") {
                
                beforeEach {
                    connections = OfflineConnections()
                    connections.enterprise(name: "validAD", domains: ["valid.com"])
                    
                    enterpriseInteractor = EnterpriseDomainInteractor(connections: connections.enterprise, authentication: oauth2)
                    presenter.enterpriseInteractor = enterpriseInteractor
                    
                    view = presenter.view as! DatabaseOnlyView
                }
                
                it("should not have enterprise support") {
                    presenter.enterpriseInteractor = nil
                    expect(presenter.enterpriseInteractor).to(beNil())
                }
                
                it("should have enterprise support") {
                    expect(presenter.enterpriseInteractor).toNot(beNil())
                }
                
                it("should return nil for invalid enterprise domain") {
                    expect(presenter.enterpriseInteractor?.matchDomain("user@invalid.com")).to(beNil())
                }
                
                it("should return connection for valid enterprise domain") {
                    expect(presenter.enterpriseInteractor?.matchDomain("user@valid.com")).toNot(beNil())
                }

                it("should match connection name enterprise domain") {
                    let connection = presenter.enterpriseInteractor?.matchDomain("user@valid.com")
                    expect(connection?.name).to(equal("validAD"))
                }
                
                it("should match connection name enterprise domain") {
                    let connection = presenter.enterpriseInteractor?.matchDomain("user@valid.com")
                    expect(connection?.name).to(equal("validAD"))
                }
                
                it("should modify display with enterprise changes") {
                    let input = mockInput(.Email, value: "user@valid.com")
                    view.form?.onValueChange(input)
                    expect(view.ssoBar).toNot(beNil())
                }
                
                it("should not modify display with enterprise changes") {
                    let input = mockInput(.Email, value: "user@invalid.com")
                    view.form?.onValueChange(input)
                    expect(view.ssoBar).to(beNil())
                }
                
                context("enterprise mode") {
                    
                    beforeEach {
                        let input = mockInput(.Email, value: "user@valid.com")
                        view.form?.onValueChange(input)
                    }
                    
                    it("should show ssoBar") {
                        expect(view.ssoBar).toNot(beNil())
                    }
                    
                    it("should not show ssoBar") {
                        let input = mockInput(.Email, value: "user@invalid.com")
                        view.form?.onValueChange(input)
                        expect(view.ssoBar).to(beNil())
                    }
                    
                    it("should return identity returntype as .Done") {
                        let form = view.form as! CredentialView
                        expect(form.identityField.returnKey).to(equal(UIReturnKeyType.Done))
                    }
                    
                    it("should restore identity returntype as .Next") {
                        let input = mockInput(.Email, value: "user@invalid.com")
                        view.form?.onValueChange(input)
                        
                        let form = view.form as! CredentialView
                        expect(form.identityField.returnKey).to(equal(UIReturnKeyType.Next))
                    }

                    it("should show no error on success") {
                        let input = mockInput(.Email, value: "user@valid.com")
                        view.form?.onValueChange(input)
                        view.primaryButton?.onPress(view.primaryButton!)
                        expect(messagePresenter.error).toEventually(beNil())
                    }
                    
                }

                context("enterprise mode with credential auth enabled") {

                    beforeEach {
                        var options = LockOptions()
                        options.enterpriseConnectionUsingActiveAuth = ["validAD"]

                        connections = OfflineConnections()
                        connections.enterprise(name: "validAD", domains: ["valid.com"])

                        presenter = DatabasePresenter(authenticator: interactor, creator: interactor, connection: DatabaseConnection(name: connection, requiresUsername: true), navigator: navigator, options: options)
                        enterpriseInteractor = EnterpriseDomainInteractor(connections: connections.enterprise, authentication: oauth2)
                        presenter.enterpriseInteractor = enterpriseInteractor

                        view = presenter.view as! DatabaseOnlyView

                        let input = mockInput(.Email, value: "user@valid.com")
                        view.form?.onValueChange(input)

                    }

                    it("should navigate to enterprise password presenter") {
                        view.primaryButton?.onPress(view.primaryButton!)
                        let connection = presenter.enterpriseInteractor?.connection!
                        expect(connection).toNot(beNil())
                        expect(navigator.route).toEventually(equal(Route.EnterpriseActiveAuth(connection: connection!)))
                    }

                }
                
            }
            
        }
    }
}

func haveAction(title: String, style: UIAlertActionStyle) -> MatcherFunc<[UIAlertAction]> {
    return MatcherFunc { expression, failureMessage in
        failureMessage.postfixMessage = "have action with title \(title) and style \(style)"
        if let actions = try expression.evaluate() {
            return actions.contains { alert in
                return alert.title == title && alert.style == style
            }
        }
        return false
    }
}
