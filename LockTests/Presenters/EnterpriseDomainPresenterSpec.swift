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
        
        beforeEach {
            messagePresenter = MockMessagePresenter()
            oauth2 = MockOAuth2()
            authPresenter = MockAuthPresenter(connections: OfflineConnections(), interactor: MockAuthInteractor(), customStyle: [:])
            
            connections = OfflineConnections()
            connections.enterprise(name: "testAD", domains: ["test.com"])
            
            interactor = EnterpriseDomainInteractor(connections: connections.enterprise, authentication: oauth2)
            
            presenter = EnterpriseDomainPresenter(interactor: interactor)
            presenter.messagePresenter = messagePresenter
            
            view = presenter.view as! EnterpriseDomainView
        }
        
        describe("email input validation") {
            
            it("should use valid email") {
                interactor.email = email
                interactor.validEmail = true
                presenter = EnterpriseDomainPresenter(interactor: interactor)
                
                let view = (presenter.view as! EnterpriseDomainView).form as! EnterpriseSingleInputView
                expect(view.value).to(equal(email))
            }
            
            it("should not use invalid email") {
                interactor.email = email
                interactor.validEmail = false
                presenter = EnterpriseDomainPresenter(interactor: interactor)
                
                let view = (presenter.view as! EnterpriseDomainView).form as! EnterpriseSingleInputView
                expect(view.value).toNot(equal(email))
            }
        }
        
        
        
        describe("user input") {
            
            it("email should update with valid email") {
                let input = mockInput(.Email, value: "valid@email.com")
                view.form?.onValueChange(input)
                expect(presenter.interactor.email).to(equal("valid@email.com"))
            }
            
            it("email should be invalid when nil") {
                let input = mockInput(.Email, value: nil)
                view.form?.onValueChange(input)
                expect(presenter.interactor.validEmail).to(equal(false))
            }
            
            it("email should be invalid when garbage") {
                let input = mockInput(.Email, value: "       ")
                view.form?.onValueChange(input)
                expect(presenter.interactor.validEmail).to(equal(false))
            }
            
            it("connection should match with valid domain") {
                let input = mockInput(.Email, value: "valid@test.com")
                view.form?.onValueChange(input)
                expect(presenter.interactor.connection).toNot(beNil())
                expect(presenter.interactor.connection?.name).to(equal("testAD"))
            }
            
            it("connection should not match with an invalid domain") {
                let input = mockInput(.Email, value: "email@nomatchdomain.com")
                view.form?.onValueChange(input)
                expect(presenter.interactor.connection).to(beNil())
            }
            
            it("should hide the field error if value is valid") {
                let input = mockInput(.Email, value: email)
                view.form?.onValueChange(input)
                expect(input.valid).to(equal(true))
            }
            
            it("should show field error if value is invalid") {
                let input = mockInput(.Email, value: "invalid")
                view.form?.onValueChange(input)
                expect(input.valid).to(equal(false))
            }
            
        }
        
        
        describe("login action") {
            
            it("should not trigger action with nil button") {
                let input = mockInput(.Email, value: "invalid")
                input.returnKey = .Done
                view.primaryButton = nil
                view.form?.onReturn(input)
                expect(messagePresenter.message).toEventually(beNil())
                expect(messagePresenter.error).toEventually(beNil())
            }
            
            
            it("should fail when no connection is matched") {
                presenter.interactor.connection = nil
                view.primaryButton?.onPress(view.primaryButton!)
                expect(messagePresenter.error).toEventually(beError(error: OAuth2AuthenticatableError.NoConnectionAvailable))
            }
            
            it("should show yield oauth2 error on failure") {
                presenter.interactor.connection = EnterpriseConnection(name: "ad", domains: ["auth0.com"])
                oauth2.onLogin = { return OAuth2AuthenticatableError.CouldNotAuthenticate }
                view.primaryButton?.onPress(view.primaryButton!)
                expect(messagePresenter.error).toEventually(beError(error: OAuth2AuthenticatableError.CouldNotAuthenticate))
            }
            
            it("should show no error on success") {
                let input = mockInput(.Email, value: "user@test.com")
                view.form?.onValueChange(input)
                view.primaryButton?.onPress(view.primaryButton!)
                expect(messagePresenter.error).toEventually(beNil())
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

