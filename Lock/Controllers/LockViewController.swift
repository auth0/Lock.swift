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
import Auth0

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
        Auth0.using(inLibrary: "Lock.swift", version: "2.0.0-alpha.1")
        let authentication = Auth0.authentication()
        let interactor = DatabaseInteractor(authentication: authentication)
        let presenter = DatabasePresenter(interactor: interactor)
        let view = presenter.view
        view.layout(inView: self.view, below: self.headerView)
    }

}
