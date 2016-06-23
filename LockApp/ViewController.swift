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

    var login: CredentialView?
    var signup: SignUpView?
    weak var guide: UILayoutGuide?

    override func viewDidLoad() {
        super.viewDidLoad()

        let header = HeaderView()
        header.title = "Overmind"
        header.onClosePressed = {
            print("Close Pressed")
        }
        header.showClose = true
        self.view.addSubview(header)

        header.topAnchor.constraintEqualToAnchor(self.view.topAnchor).active = true
        header.leftAnchor.constraintEqualToAnchor(self.view.leftAnchor).active = true
        header.rightAnchor.constraintEqualToAnchor(self.view.rightAnchor).active = true
        header.translatesAutoresizingMaskIntoConstraints = false

        let button = PrimaryButton()
        button.onPress = { button in
            button.inProgress = true
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                button.inProgress = false
            }
        }
        self.view.addSubview(button)

        button.leftAnchor.constraintEqualToAnchor(self.view.leftAnchor).active = true
        button.rightAnchor.constraintEqualToAnchor(self.view.rightAnchor).active = true
        button.bottomAnchor.constraintEqualToAnchor(self.view.bottomAnchor).active = true
        button.translatesAutoresizingMaskIntoConstraints = false

        let switcher = DatabaseModeSwitcher()
        switcher.selected = .Login
        switcher.onSelectionChange = { [weak self] switcher in
            guard
                let login = self?.login,
                let signup = self?.signup,
                let guide = self?.guide
                else { return }
            switch switcher.selected {
            case .Login:
                self?.view.addSubview(login)
                self?.layout(view: login, withGuide: guide)
                signup.removeFromSuperview()
            case .Signup:
                self?.view.addSubview(signup)
                self?.layout(view: signup, withGuide: guide)
                login.removeFromSuperview()
            default:
                print("Mode: \(switcher.selected)")
            }
        }
        self.view.addSubview(switcher)

        switcher.topAnchor.constraintEqualToAnchor(header.bottomAnchor).active = true
        switcher.leftAnchor.constraintEqualToAnchor(self.view.leftAnchor, constant: 20).active = true
        switcher.rightAnchor.constraintEqualToAnchor(self.view.rightAnchor, constant: -20).active = true
        switcher.translatesAutoresizingMaskIntoConstraints = false

        let secondaryButton = SecondaryButton()
        secondaryButton.title = DatabaseModes.ForgotPassword.title
        self.view.addSubview(secondaryButton)

        secondaryButton.bottomAnchor.constraintEqualToAnchor(button.topAnchor).active = true
        secondaryButton.leftAnchor.constraintEqualToAnchor(self.view.leftAnchor).active = true
        secondaryButton.rightAnchor.constraintEqualToAnchor(self.view.rightAnchor).active = true
        secondaryButton.translatesAutoresizingMaskIntoConstraints = false

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
        let signupForm = SignUpView()
        signupForm.showUsername = true
        let centerGuide = UILayoutGuide()

        self.view.addLayoutGuide(centerGuide)
        self.view.addSubview(form)

        centerGuide.topAnchor.constraintEqualToAnchor(switcher.bottomAnchor).active = true
        centerGuide.leftAnchor.constraintEqualToAnchor(self.view.leftAnchor, constant: 20).active = true
        centerGuide.rightAnchor.constraintEqualToAnchor(self.view.rightAnchor, constant: -20).active = true
        centerGuide.bottomAnchor.constraintEqualToAnchor(secondaryButton.topAnchor).active = true

        layout(view: form, withGuide: centerGuide)
        self.guide = centerGuide
        self.signup = signupForm
        self.login = form
    }

    private func layout(view view: UIView, withGuide guide: UILayoutGuide) {
        view.leftAnchor.constraintEqualToAnchor(guide.leftAnchor).active = true
        view.rightAnchor.constraintEqualToAnchor(guide.rightAnchor).active = true
        view.centerYAnchor.constraintEqualToAnchor(guide.centerYAnchor).active = true
        view.translatesAutoresizingMaskIntoConstraints = false
    }

}

