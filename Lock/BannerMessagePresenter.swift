// BannerMessagePresenter.swift
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

import UIKit

struct BannerMessagePresenter: MessagePresenter {

    weak var root: UIView?
    weak var messageView: MessageView?

    mutating func showError(_ error: LocalizableError) {
        guard error.userVisible else { return }
        show(message: error.localizableMessage, flavor: .failure)
    }

    mutating func showSuccess(_ message: String) {
        show(message: message, flavor: .success)
    }

    mutating func hideCurrent() {
        self.messageView?.removeFromSuperview()
        self.messageView = nil
    }

    private mutating func show(message: String, flavor: MessageView.Flavor) {
        let view = MessageView()
        view.type = flavor
        view.message = message

        guard let root = self.root else { return }
        root.addSubview(view)

        constraintEqual(anchor: view.topAnchor, toAnchor: root.layoutMarginsGuide.topAnchor)
        constraintEqual(anchor: view.leftAnchor, toAnchor: root.leftAnchor)
        constraintEqual(anchor: view.rightAnchor, toAnchor: root.rightAnchor)
        view.translatesAutoresizingMaskIntoConstraints = false

        self.messageView = view

        Queue.main.after(4) { [weak view] in view?.removeFromSuperview() }
    }

}
