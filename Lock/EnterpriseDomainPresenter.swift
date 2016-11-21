// EnterpriseDomainPresenter.swift
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

class EnterpriseDomainPresenter: Presentable, Loggable {
    
    var interactor: EnterpriseDomainInteractor
    var customLogger: Logger?
    var user: User
    var options: Options
    
    // Social connections
    var authPresenter: AuthPresenter?
    
    init(interactor: EnterpriseDomainInteractor, navigator: Navigable, user: User, options: Options) {
        self.interactor = interactor
        self.navigator = navigator
        self.user = user
        self.options = options
    }
    
    var messagePresenter: MessagePresenter?
    var navigator: Navigable?
    
    var view: View {
        let email = self.interactor.validEmail ? self.interactor.email : nil
        let authCollectionView = self.authPresenter?.newViewToEmbed(withInsets: UIEdgeInsetsMake(0, 0, 0, 0), isLogin: true)
        let view = EnterpriseDomainView(email: email, authCollectionView: authCollectionView)
        let form = view.form

        view.infoBar?.hidden = self.interactor.connection == nil
        
        view.form?.onValueChange = { input in
            self.messagePresenter?.hideCurrent()
            view.infoBar?.hidden = true
            
            guard case .Email = input.type else { return }
            do {
                try self.interactor.updateEmail(input.text)
                self.user.email = self.interactor.email
                input.showValid()
                if let connection = self.interactor.connection {
                    self.logger.debug("Enterprise connection match: \(connection)")
                    view.infoBar?.hidden = false
                }
            } catch {
                input.showError()
            }
        }
        
        let action = { (button: PrimaryButton) in
            
            // Check for credential auth
            if let connection = self.interactor.connection where self.options.enterpriseConnectionUsingActiveAuth.contains(connection.name) {
                self.navigator?.navigate(.EnterpriseActiveAuth(connection: connection))
                return
            }

            self.messagePresenter?.hideCurrent()
            self.logger.info("Enterprise connection started: \(self.interactor.email), \(self.interactor.connection)")
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
