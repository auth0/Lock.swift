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

        let actions = [
            actionButton(withTitle: "LOGIN WITH CDN") {
                return Lock
                    .classic()
                    .options {
                        applyDefaultOptions(&$0)
                    }
                    .allowedConnections(["github", "instagram", "Username-Password-Authentication", "slack"])
            },
            actionButton(withTitle: "LOGIN WITH CUSTOM STYLE") {
                return Lock
                    .classic()
                    .options {
                        applyDefaultOptions(&$0)
                    }
                    .style {
                        $0.title = "Phantom Inc."
                        $0.headerBlur = .ExtraLight
                        $0.logo = LazyImage(name: "icn_phantom", bundle: NSBundle.mainBundle())
                        $0.primaryColor = UIColor ( red: 0.6784, green: 0.5412, blue: 0.7333, alpha: 1.0 )
                    }
                    .withConnections { connections in
                        connections.database(name: "Username-Password-Authentication", requiresUsername: true)
                }
            },
            actionButton(withTitle: "LOGIN WITH DB") {
                return Lock
                    .classic()
                    .options {
                        applyDefaultOptions(&$0)
                    }
                    .withConnections { connections in
                        connections.database(name: "Username-Password-Authentication", requiresUsername: true)
                }
            },
            actionButton(withTitle: "LOGIN ONLY WITH DB") {
                return Lock
                    .classic()
                    .options {
                        applyDefaultOptions(&$0)
                        $0.allow = [.Login]
                        $0.usernameStyle = [.Email]
                    }
                    .withConnections { connections in
                        connections.database(name: "Username-Password-Authentication", requiresUsername: true)
                }
            },
            actionButton(withTitle: "LOGIN WITH DB & SOCIAL") {
                return Lock
                    .classic()
                    .options {
                        applyDefaultOptions(&$0)
                    }
                    .withConnections { connections in
                        connections.social(name: "facebook", style: .Facebook)
                        connections.social(name: "google-oauth2", style: .Google)
                        connections.database(name: "Username-Password-Authentication", requiresUsername: true)
                }
            },
            actionButton(withTitle: "LOGIN WITH SOCIAL") {
                return Lock
                    .classic()
                    .options {
                        applyDefaultOptions(&$0)
                    }
                    .allowedConnections(["facebook", "google-oauth2", "twitter", "dropbox", "bitbucket"])
                    .withConnections { connections in
                        connections.social(name: "facebook", style: .Facebook)
                        connections.social(name: "google-oauth2", style: .Google)
                        connections.social(name: "instagram", style: .Instagram)
                        connections.social(name: "twitter", style: .Twitter)
                        connections.social(name: "fitbit", style: .Fitbit)
                        connections.social(name: "dropbox", style: .Dropbox)
                        connections.social(name: "bitbucket", style: .Bitbucket)
                }
            },

            ]

        let stack = UIStackView(arrangedSubviews: actions.map { wrap($0) })
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

    private func actionButton(withTitle title: String, action: () -> Lock) -> AuthButton {
        let button = AuthButton(size: .Big)
        button.title = title
        button.onPress = { [weak self] _ in
            self?.showLock(action())
        }
        return button
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
        Log.enable(minimumSeverity: LogSeverity.verbose)
        lock
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

private func applyDefaultOptions(inout options: OptionBuildable) {
    options.closable = true
    options.logLevel = .All
    options.loggerOutput = CleanroomLockLogger()
    options.logHttpRequest = true
}

class CleanroomLockLogger: LoggerOutput {

    func message(message: String, level: LoggerLevel, filename: String, line: Int) {
        let channel: LogChannel?
        switch level {
        case .Debug:
            channel = Log.debug
        case .Error:
            channel = Log.error
        case .Info:
            channel = Log.info
        case .Verbose:
            channel = Log.verbose
        case .Warn:
            channel = Log.warning
        default:
            channel = nil
        }
        channel?.message(message, filePath: filename, fileLine: line)
    }
}
