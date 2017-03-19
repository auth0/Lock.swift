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
        view.backgroundColor = .white
        self.view = view
        let header = HeaderView()
        header.title = "Welcome to Lock"
        header.showClose = false

        view.addSubview(header)

        NSLayoutConstraint.activate([
            header.leftAnchor.constraint(equalTo: view.leftAnchor),
            header.topAnchor.constraint(equalTo: view.topAnchor),
            header.rightAnchor.constraint(equalTo: view.rightAnchor),
            header.heightAnchor.constraint(equalToConstant: 154)
            ])
        header.translatesAutoresizingMaskIntoConstraints = false

        let actions = [
            actionButton(withTitle: "LOGIN WITH CDN CLASSIC") {
                return Lock
                    .classic()
                    .withOptions {
                        applyDefaultOptions(&$0)
                        $0.customSignupFields = [
                            CustomTextField(name: "first_name", placeholder: "First Name", icon: LazyImage(name: "ic_person", bundle: Lock.bundle)),
                            CustomTextField(name: "last_name", placeholder: "Last Name", icon: LazyImage(name: "ic_person", bundle: Lock.bundle))
                        ]
                    }
                    .withStyle {
                            $0.oauth2["slack"] = AuthStyle(
                            name: "Slack",
                            color: UIColor ( red: 0.4118, green: 0.8078, blue: 0.6588, alpha: 1.0 ),
                            withImage: LazyImage(name: "ic_slack")
                        )
                }
            },
            actionButton(withTitle: "LOGIN WITH CDN PASSWORDLESS") {
                return Lock
                    .passwordless()
                    .withOptions {
                        applyDefaultOptions(&$0)
                    }
                    .withStyle {
                        $0.oauth2["slack"] = AuthStyle(
                            name: "Slack",
                            color: UIColor ( red: 0.4118, green: 0.8078, blue: 0.6588, alpha: 1.0 ),
                            withImage: LazyImage(name: "ic_slack")
                        )
                }
            },
            actionButton(withTitle: "LOGIN WITH CUSTOM STYLE") {
                return Lock
                    .classic()
                    .withOptions {
                        applyDefaultOptions(&$0)
                    }
                    .withStyle {
                        $0.title = "Phantom Inc."
                        $0.headerBlur = .extraLight
                        $0.logo = LazyImage(name: "icn_phantom")
                        $0.primaryColor = UIColor ( red: 0.6784, green: 0.5412, blue: 0.7333, alpha: 1.0 )
                    }
                    .withConnections { connections in
                        connections.database(name: "Username-Password-Authentication", requiresUsername: true)
                }
            },
            actionButton(withTitle: "LOGIN WITH DB") {
                return Lock
                    .classic()
                    .withOptions {
                        applyDefaultOptions(&$0)
                        $0.customSignupFields = [
                            CustomTextField(name: "first_name", placeholder: "First Name", icon: LazyImage(name: "ic_person", bundle: Lock.bundle)),
                            CustomTextField(name: "last_name", placeholder: "Last Name", icon: LazyImage(name: "ic_person", bundle: Lock.bundle)),
                        ]
                    }
                    .withConnections { connections in
                        let usernameValidator = UsernameValidator(withLength: 1...20, characterSet: UsernameValidator.auth0)
                        connections.database(name: "Username-Password-Authentication", requiresUsername: true, usernameValidator: usernameValidator, passwordPolicy: .excellent)
                }
            },
            actionButton(withTitle: "LOGIN ONLY WITH DB") {
                return Lock
                    .classic()
                    .withOptions {
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
                    .withOptions {
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
                    .withOptions {
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
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        stack.alignment = .fill

        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 18),
            stack.topAnchor.constraint(equalTo: header.bottomAnchor),
            stack.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -18),
            stack.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])
        stack.translatesAutoresizingMaskIntoConstraints = false
    }

    private func actionButton(withTitle title: String, action: @escaping () -> Lock) -> AuthButton {
        let button = AuthButton(size: .big)
        button.title = title
        button.onPress = { [weak self] _ in
            self?.showLock(lock: action())
        }
        return button
    }

    private func wrap(_ button: AuthButton) -> UIView {
        let wrapper = UIView()
        wrapper.backgroundColor = .white
        wrapper.addSubview(button)

        button.leftAnchor.constraint(equalTo: wrapper.leftAnchor).isActive = true
        button.rightAnchor.constraint(equalTo: wrapper.rightAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: wrapper.centerYAnchor).isActive = true
        button.translatesAutoresizingMaskIntoConstraints = false

        return wrapper
    }

    private func showLock(lock: Lock) {
        Log.enable(minimumSeverity: LogSeverity.verbose, debugMode: true)
        lock
            .onAuth { Log.info?.message("Obtained credentials \($0)") }
            .onError { Log.error?.message("Failed with \($0)") }
            .onSignUp { email, _ in  Log.debug?.message("New user \(email)") }
            .onCancel { Log.debug?.message("User closed lock") }
            .onPasswordless { Log.debug?.message("Passwordless requested for \($0)") }
            .present(from: self)
    }
}

func applyDefaultOptions(_ options: inout OptionBuildable) {
    options.closable = true
    options.logLevel = .all
    options.loggerOutput = CleanroomLockLogger()
    options.logHttpRequest = true
}

class CleanroomLockLogger: LoggerOutput {

    func message(_ message: String, level: LoggerLevel, filename: String, line: Int) {
        let channel: LogChannel?
        switch level {
        case .debug:
            channel = Log.debug
        case .error:
            channel = Log.error
        case .info:
            channel = Log.info
        case .verbose:
            channel = Log.verbose
        case .warn:
            channel = Log.warning
        default:
            channel = nil
        }
        channel?.message(message, filePath: filename, fileLine: line)
    }
}
