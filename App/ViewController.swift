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
import CleanroomLogger

class ViewController: UIViewController {

    override func loadView() {
        let view = UIView()
        view.backgroundColor = .whiteColor()
        self.view = view
        let header = HeaderView()
        header.title = "Welcome to Lock"
        header.showClose = false

        view.addSubview(header)

        NSLayoutConstraint.activateConstraints([
            header.leftAnchor.constraintEqualToAnchor(view.leftAnchor),
            header.topAnchor.constraintEqualToAnchor(view.topAnchor),
            header.rightAnchor.constraintEqualToAnchor(view.rightAnchor),
            header.heightAnchor.constraintEqualToConstant(154),
            ])
        header.translatesAutoresizingMaskIntoConstraints = false

        let databaseOnly = AuthButton(size: .Big)
        databaseOnly.title = "LOGIN WITH DB"
        databaseOnly.onPress = { [weak self] _ in
            let lock = Lock
                .login()
                .connections { connections in
                    connections.database(name: "Username-Password-Authentication", requiresUsername: true)
                }
            self?.showLock(lock)
        }
        let databaseAndSocial = AuthButton(size: .Big)
        databaseAndSocial.title = "LOGIN WITH DB & SOCIAL"
        databaseAndSocial.onPress = { [weak self] _ in
            let lock = Lock
                .login()
                .connections { connections in
                    connections.social(name: "facebook", style: .Facebook)
                    connections.social(name: "google-oauth2", style: .Google)
                    connections.database(name: "Username-Password-Authentication", requiresUsername: true)
            }
            self?.showLock(lock)
        }
        let socialOnly = AuthButton(size: .Big)
        socialOnly.title = "LOGIN WITH SOCIAL"
        socialOnly.onPress = { [weak self] _ in
            let lock = Lock
                .login()
                .connections { connections in
                    connections.social(name: "facebook", style: .Facebook)
                    connections.social(name: "google-oauth2", style: .Google)
                    connections.social(name: "instagram", style: .Instagram)
                    connections.social(name: "twitter", style: .Twitter)
                    connections.social(name: "fitbit", style: .Fitbit)
                    connections.social(name: "dropbox", style: .Dropbox)
                    connections.social(name: "bitbucket", style: .Bitbucket)
                }
            self?.showLock(lock)
        }

        let stack = UIStackView(arrangedSubviews: [wrap(databaseOnly), wrap(socialOnly), wrap(databaseAndSocial)])
        stack.axis = .Vertical
        stack.distribution = .FillProportionally
        stack.alignment = .Fill

        view.addSubview(stack)

        NSLayoutConstraint.activateConstraints([
            stack.leftAnchor.constraintEqualToAnchor(view.leftAnchor, constant: 18),
            stack.topAnchor.constraintEqualToAnchor(header.bottomAnchor),
            stack.rightAnchor.constraintEqualToAnchor(view.rightAnchor, constant: -18),
            stack.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor),
            ])
        stack.translatesAutoresizingMaskIntoConstraints = false
    }

    private func wrap(button: AuthButton) -> UIView {
        let wrapper = UIView()
        wrapper.backgroundColor = .whiteColor()
        wrapper.addSubview(button)

        button.leftAnchor.constraintEqualToAnchor(wrapper.leftAnchor).active = true
        button.rightAnchor.constraintEqualToAnchor(wrapper.rightAnchor).active = true
        button.centerYAnchor.constraintEqualToAnchor(wrapper.centerYAnchor).active = true
        button.translatesAutoresizingMaskIntoConstraints = false

        return wrapper
    }

    private func showLock(lock: Lock) {
        Log.enable(minimumSeverity: LogSeverity.Verbose)
        lock
            .options {
                $0.closable = true
                $0.logLevel = .All
                $0.logger = CleanroomLockLogger()
                $0.logHttpRequest = true
            }
            .on { result in
                switch result {
                case .Success(let credentials):
                    Log.info?.message("Obtained credentials \(credentials)")
                case .Failure(let cause):
                    Log.error?.message("Failed with \(cause)")
                default:
                    Log.debug?.value(result)
                }
            }
            .present(from: self)
    }
}

class CleanroomLockLogger: Logger {

    var level: LoggerLevel = .All

    func debug(message: String, filename: String, line: Int) {
        Log.debug?.message(message, filePath: filename, fileLine: line)
    }

    func info(message: String, filename: String, line: Int) {
        Log.info?.message(message, filePath: filename, fileLine: line)
    }

    func error(message: String, filename: String, line: Int) {
        Log.error?.message(message, filePath: filename, fileLine: line)
    }

    func warn(message: String, filename: String, line: Int) {
        Log.warning?.message(message, filePath: filename, fileLine: line)
    }

    func verbose(message: String, filename: String, line: Int) {
        Log.verbose?.message(message, filePath: filename, fileLine: line)
    }
}
