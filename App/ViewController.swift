// ViewController.swift
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
import Lock


class ViewController: UIViewController {

    weak var messageLabel: UILabel?

    override func loadView() {
        let view = UIView()
        view.backgroundColor = .whiteColor()
        self.view = view
        let header = HeaderView()
        header.title = "Welcome to Lock"

        view.addSubview(header)

        NSLayoutConstraint.activateConstraints([
            header.leftAnchor.constraintEqualToAnchor(view.leftAnchor),
            header.topAnchor.constraintEqualToAnchor(view.topAnchor),
            header.rightAnchor.constraintEqualToAnchor(view.rightAnchor),
            ])
        header.translatesAutoresizingMaskIntoConstraints = false

        let button = PrimaryButton()
        button.onPress = { [weak self] _ in self?.showLock() }

        view.addSubview(button)

        NSLayoutConstraint.activateConstraints([
            button.leftAnchor.constraintEqualToAnchor(view.leftAnchor),
            button.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor),
            button.rightAnchor.constraintEqualToAnchor(view.rightAnchor),
            ])
        button.translatesAutoresizingMaskIntoConstraints = false

        let centerGuide = UILayoutGuide()

        view.addLayoutGuide(centerGuide)

        NSLayoutConstraint.activateConstraints([
            centerGuide.topAnchor.constraintEqualToAnchor(header.bottomAnchor),
            centerGuide.bottomAnchor.constraintEqualToAnchor(button.topAnchor),
            centerGuide.centerXAnchor.constraintEqualToAnchor(self.view.centerXAnchor),
            ])

        let message = UILabel()
        message.numberOfLines = 0
        message.preferredMaxLayoutWidth = 200
        message.textAlignment = .Center
        
        view.addSubview(message)

        NSLayoutConstraint.activateConstraints([
            message.centerXAnchor.constraintEqualToAnchor(centerGuide.centerXAnchor),
            message.centerYAnchor.constraintEqualToAnchor(centerGuide.centerYAnchor)
            ])
        message.translatesAutoresizingMaskIntoConstraints = false

        self.messageLabel = message
    }

    private func showLock() {
        Lock
            .login()
            .connections { connections in
                connections.database(name: "Username-Password-Authentication", requiresUsername: true)
            }
            .options {
                $0.closable = true
            }
            .on { result in
                switch result {
                case .Success(let credentials):
                    print("Obtained credentials \(credentials)")
                    self.messageLabel?.text = "Logged in user and got token \(credentials.accessToken)"
                case .Failure(let cause):
                    print("Failed with \(cause)")
                    self.messageLabel?.text = "Failed with \(cause)"
                default:
                    self.messageLabel?.text = nil
                    print(result)
                }
            }
            .present(from: self)
    }
}

