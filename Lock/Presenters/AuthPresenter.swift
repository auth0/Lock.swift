// AuthPresenter.swift
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

class AuthPresenter: Presentable {

    let connections: [OAuth2Connection]
    let interactor: OAuth2Authenticatable

    var messagePresenter: MessagePresenter?

    init(connections: Connections, interactor: OAuth2Authenticatable) {
        self.connections = connections.oauth2
        self.interactor = interactor
    }

    var view: View {
        return self.newView(withInsets: UIEdgeInsets(top: 18, left: 18, bottom: 18, right: 18), mode: .Expanded)
    }

    func newView(withInsets insets: UIEdgeInsets, mode: AuthCollectionView.Mode, showSignUp: Bool = false) -> AuthCollectionView {
        let buttons = self.actions(forSignUp: showSignUp)
        return AuthCollectionView(buttons: buttons, mode: mode, insets: insets)
    }

    func actions(forSignUp signUp: Bool) -> [AuthButton] {
        return self.connections.map { connection -> AuthButton in
            let button = AuthButton(size: .Big)
            let style = connection.style
            button.title = signUp ? style.localizedSignUpTitle.uppercaseString : style.localizedLoginTitle.uppercaseString
            button.color = style.color
            button.icon = style.image.image(compatibleWithTraits: button.traitCollection)
            button.onPress = { _ in
                self.interactor.login(connection.name) { error in
                    guard let error = error else { return }
                    self.messagePresenter?.showError("\(error)")
                }
            }
            return button
        }
    }
}
