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

    weak var login: CredentialView?
    weak var signup: SignUpView?
    weak var guide: UILayoutGuide?
    weak var primaryButton: PrimaryButton?
    weak var secondaryButton: SecondaryButton?
    weak var header: HeaderView?
    weak var switcher: DatabaseModeSwitcher?
    weak var container: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()

        let header = HeaderView()
        header.title = "Overmind"
        header.onClosePressed = {
            print("Close Pressed")
        }
        header.onBackPressed = { [weak self] in
            guard let container = self?.container else { return }
            self?.header?.showBack = false
            self?.cleanContainer()
            self?.layoutMainScreen(container)
        }
        header.showClose = true
        self.view.addSubview(header)

        header.topAnchor.constraintEqualToAnchor(self.view.topAnchor).active = true
        header.leftAnchor.constraintEqualToAnchor(self.view.leftAnchor).active = true
        header.rightAnchor.constraintEqualToAnchor(self.view.rightAnchor).active = true
        header.translatesAutoresizingMaskIntoConstraints = false
        self.header = header

        let containerView = UIView()

        self.view.addSubview(containerView)

        containerView.leftAnchor.constraintEqualToAnchor(self.view.leftAnchor).active = true
        containerView.topAnchor.constraintEqualToAnchor(header.bottomAnchor).active = true
        containerView.rightAnchor.constraintEqualToAnchor(self.view.rightAnchor).active = true
        containerView.bottomAnchor.constraintEqualToAnchor(self.view.bottomAnchor).active = true
        containerView.translatesAutoresizingMaskIntoConstraints = false
        self.container = containerView

        self.layoutMainScreen(containerView)
    }

    private func layoutMainScreen(containerView: UIView) {
        self.layoutPrimaryButton(containerView)
        self.layoutSwitcher(containerView)
        self.layoutSecondaryButton(containerView)
        self.layoutCenterGuide(containerView)

        self.layoutLogin(containerView)
    }

    private func layout(view view: UIView, withGuide guide: UILayoutGuide) {
        view.leftAnchor.constraintEqualToAnchor(guide.leftAnchor).active = true
        view.rightAnchor.constraintEqualToAnchor(guide.rightAnchor).active = true
        view.centerYAnchor.constraintEqualToAnchor(guide.centerYAnchor).active = true
        view.translatesAutoresizingMaskIntoConstraints = false
    }

    private func layoutPrimaryButton(containerView: UIView) {
        let button = PrimaryButton()
        button.onPress = { button in
            button.inProgress = true
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                button.inProgress = false
            }
        }
        containerView.addSubview(button)

        button.leftAnchor.constraintEqualToAnchor(containerView.leftAnchor).active = true
        button.rightAnchor.constraintEqualToAnchor(containerView.rightAnchor).active = true
        button.bottomAnchor.constraintEqualToAnchor(containerView.bottomAnchor).active = true
        button.translatesAutoresizingMaskIntoConstraints = false
        self.primaryButton = button
    }

    private func layoutSwitcher(containerView: UIView) {
        let switcher = DatabaseModeSwitcher()
        switcher.selected = .Login
        switcher.onSelectionChange = { [weak self] switcher in
            guard let containerView = self?.container else { return }
            switch switcher.selected {
            case .Login:
                self?.layoutLogin(containerView)
                self?.signup?.removeFromSuperview()
            case .Signup:
                self?.layoutSignup(containerView)
                self?.login?.removeFromSuperview()
            default:
                print("Mode: \(switcher.selected)")
            }
        }
        containerView.addSubview(switcher)

        switcher.topAnchor.constraintEqualToAnchor(containerView.topAnchor).active = true
        switcher.leftAnchor.constraintEqualToAnchor(containerView.leftAnchor, constant: 20).active = true
        switcher.rightAnchor.constraintEqualToAnchor(containerView.rightAnchor, constant: -20).active = true
        switcher.translatesAutoresizingMaskIntoConstraints = false

        self.switcher = switcher
    }

    private func layoutSecondaryButton(containerView: UIView) {
        let secondaryButton = SecondaryButton()
        secondaryButton.title = DatabaseModes.ForgotPassword.title
        secondaryButton.onPress = { [weak self] _ in
            guard let container = self?.container else { return }
            self?.cleanContainer()
            self?.layoutPrimaryButton(container)
            let forgot = ForgotPasswordView()
            container.addSubview(forgot)
            let guide = self!.layoutCenterGuide(container)
            self?.layout(view: forgot, withGuide: guide)
            self?.header?.showBack = true
        }
        containerView.addSubview(secondaryButton)

        secondaryButton.bottomAnchor.constraintEqualToAnchor(self.primaryButton?.topAnchor ?? self.view.topAnchor).active = true
        secondaryButton.leftAnchor.constraintEqualToAnchor(containerView.leftAnchor).active = true
        secondaryButton.rightAnchor.constraintEqualToAnchor(containerView.rightAnchor).active = true
        secondaryButton.translatesAutoresizingMaskIntoConstraints = false
        self.secondaryButton = secondaryButton
    }

    private func layoutCenterGuide(containerView: UIView) -> UILayoutGuide {
        let centerGuide = UILayoutGuide()

        containerView.addLayoutGuide(centerGuide)
        centerGuide.topAnchor.constraintEqualToAnchor(self.switcher?.bottomAnchor ?? self.header?.bottomAnchor).active = true
        centerGuide.leftAnchor.constraintEqualToAnchor(containerView.leftAnchor, constant: 20).active = true
        centerGuide.rightAnchor.constraintEqualToAnchor(containerView.rightAnchor, constant: -20).active = true
        centerGuide.bottomAnchor.constraintEqualToAnchor(self.secondaryButton?.topAnchor ?? self.primaryButton?.topAnchor).active = true
        self.guide = centerGuide
        return centerGuide
    }

    private func layoutLogin(containerView: UIView) {
        let form = CredentialView()
        form.onValueChange = { input in
            switch input.type {
            case .Email where !(input.text?.containsString("@") ?? false):
                input.showError("Must supply an email!")
            case .Password where input.text?.characters.count == 0:
                input.showError("Must not be empty!")
            default:
                input.hideError()
                print("Nothing to do")
            }
        }
        containerView.addSubview(form)
        layout(view: form, withGuide: self.guide!) //FIME:
        self.login = form
    }

    private func layoutSignup(containerView: UIView) {
        let signupForm = SignUpView()
        signupForm.showUsername = true
        signupForm.onValueChange = { input in
            switch input.type {
            case .Email where !(input.text?.containsString("@") ?? false):
                input.showError("Must supply an email!")
            case .Password where input.text?.characters.count == 0:
                input.showError("Must not be empty!")
            case .Username where input.text?.characters.count == 0:
                input.showError("Must not be empty!")
            default:
                input.hideError()
                print("Nothing to do")
            }
        }
        containerView.addSubview(signupForm)
        layout(view: signupForm, withGuide: self.guide!) //FIME:
        self.signup = signupForm
    }

    private func cleanContainer() {
        self.container?.subviews.forEach { $0.removeFromSuperview() }
        let guides = container?.layoutGuides
        guides?.forEach { container?.removeLayoutGuide($0) }
        self.switcher = nil
        self.secondaryButton = nil
        self.primaryButton = nil
    }
}

