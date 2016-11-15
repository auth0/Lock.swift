// EnterprisePasswordPresenter.swift
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

import Foundation

class EnterprisePasswordPresenter: Presentable, Loggable {
    
    var interactor: EnterprisePasswordInteractor
    var customLogger: Logger?
    
    init(interactor: EnterprisePasswordInteractor) {
        self.interactor = interactor
    }
    
    var messagePresenter: MessagePresenter?
    
    var view: View {
        
        var identifier: String?
        
        if let email = self.interactor.email where self.interactor.validEmail {
            identifier = email
        } else if let username = self.interactor.username where self.interactor.validUsername {
            identifier = username
        }
        
        let view = EnterprisePasswordView(identifer: identifier, identifierAttribute: self.interactor.identifierAttribute)
        let form = view.form
        
        view.infoBar?.title = self.interactor.connection.domains.first
        
        view.form?.onValueChange = { input in
            self.messagePresenter?.hideCurrent()
            
            do {
                switch input.type {
                case .Email, .Username:
                    try self.interactor.update(self.interactor.identifierAttribute, value: input.text)
                    input.showValid()
                case .Password:
                    try self.interactor.update(.Password, value: input.text)
                    input.showValid()
                default:
                    self.logger.warn("Invalid user attribute")
                    return
                }
            } catch {
                input.showError()
            }
        }
        
        let action = { (button: PrimaryButton) in
            self.messagePresenter?.hideCurrent()
            self.logger.info("Enterprise password connection started: \(self.interactor.identifier), \(self.interactor.connection)")
            let interactor = self.interactor
            
            button.inProgress = true
            interactor.login { error in
                Queue.main.async {
                    button.inProgress = false
                    form?.needsToUpdateState()
                    if let error = error {
                        self.messagePresenter?.showError(error)
                        self.logger.error("Enterprise connection failed: \(error)")
                    } else {
                        self.logger.debug("Enterprise authenticator launched")
                    }
                }
                
            }
        }
        
        view.primaryButton?.onPress = action
        view.form?.onReturn = {_ in
            guard let button = view.primaryButton else { return }
            action(button)
        }
        return view
    }
    
}
