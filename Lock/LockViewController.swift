// LockViewController.swift
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

public class LockViewController: UIViewController {

    weak var headerView: HeaderView!

    public required init() {
        super.init(nibName: nil, bundle: nil)
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        self.init()
    }

    public override func loadView() {
        let root = UIView()
        root.backgroundColor = .whiteColor()
        self.view = root

        let header = HeaderView()
        root.addSubview(header)
        constraintEqual(anchor: header.leftAnchor, toAnchor: root.leftAnchor)
        constraintEqual(anchor: header.topAnchor, toAnchor: root.topAnchor)
        constraintEqual(anchor: header.rightAnchor, toAnchor: root.rightAnchor)
        header.translatesAutoresizingMaskIntoConstraints = false

        self.headerView = header
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.layoutDatabaseLogin(inView: self.view, below: self.headerView)
    }

    private func layoutDatabaseLogin(inView root: UIView, below view: UIView) {
        let container = UIStackView()
        let switcher = DatabaseModeSwitcher()
        let loginForm = CredentialView()
        let secondaryButton = SecondaryButton()
        let primaryButton = PrimaryButton()

        root.addSubview(container)
        root.addSubview(primaryButton)

        container.alignment = .Fill
        container.axis = .Vertical
        container.distribution = .EqualCentering

        constraintEqual(anchor: container.leftAnchor, toAnchor: root.leftAnchor, constant: 20)
        constraintEqual(anchor: container.topAnchor, toAnchor: view.bottomAnchor)
        constraintEqual(anchor: container.rightAnchor, toAnchor: root.rightAnchor, constant: -20)
        constraintEqual(anchor: container.bottomAnchor, toAnchor: primaryButton.topAnchor)
        container.translatesAutoresizingMaskIntoConstraints = false

        container.addArrangedSubview(switcher)
        container.addArrangedSubview(loginForm)
        container.addArrangedSubview(secondaryButton)

        constraintEqual(anchor: primaryButton.leftAnchor, toAnchor: root.leftAnchor)
        constraintEqual(anchor: primaryButton.rightAnchor, toAnchor: root.rightAnchor)
        constraintEqual(anchor: primaryButton.bottomAnchor, toAnchor: root.bottomAnchor)
        primaryButton.translatesAutoresizingMaskIntoConstraints = false
    }
}
