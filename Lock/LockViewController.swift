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
    weak var scrollView: UIScrollView!
    weak var messageView: MessageView?
    weak var scrollContentView: UIView!
    var current: View?
    var keyboard: Bool = false
    var routes: Routes = Routes()

    var anchorConstraint: NSLayoutConstraint?

    var messagePresenter: MessagePresenter!
    var router: Router!
    let lock: Lock

    public required init(lock: Lock) {
        self.lock = lock
        super.init(nibName: nil, bundle: nil)
        lock.observerStore.controller = self
        if self.lock.style.modalPopup && UIDevice.current.userInterfaceIdiom == .pad {
            self.modalPresentationStyle = .formSheet
            self.preferredContentSize = CGSize(width: 375, height: 667)
        } else {
            self.modalPresentationStyle = .fullScreen
        }
        self.router = lock.classicMode ? ClassicRouter(lock: lock, controller: self) : PasswordlessRouter(lock: lock, controller: self)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("Storyboard currently not supported")
    }

    public override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return self.lock.style.statusBarUpdateAnimation
    }

    public override var prefersStatusBarHidden: Bool {
        return self.lock.style.statusBarHidden
    }

    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.lock.style.statusBarStyle
    }

    public override func loadView() {
        let root = UIView()
        let style = self.lock.style
        root.backgroundColor = style.backgroundColor
        self.view = root

        if let backgroundImage = style.backgroundImage?.image(compatibleWithTraits: self.traitCollection) {
            let bgImageView = UIImageView(image: backgroundImage)
            self.view.addSubview(bgImageView)
        }

        let scrollView = UIScrollView()
        scrollView.bounces = false
        scrollView.keyboardDismissMode = .interactive
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        self.view.addSubview(scrollView)
        constraintEqual(anchor: scrollView.leftAnchor, toAnchor: self.view.leftAnchor)
        constraintEqual(anchor: scrollView.topAnchor, toAnchor: self.view.topAnchor)
        constraintEqual(anchor: scrollView.rightAnchor, toAnchor: self.view.rightAnchor)
        constraintEqual(anchor: scrollView.bottomAnchor, toAnchor: self.view.bottomAnchor)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView = scrollView

        let scrollContentView = UIView()
        self.scrollView.addSubview(scrollContentView)
        constraintEqual(anchor: scrollContentView.leftAnchor, toAnchor: scrollView.leftAnchor)
        constraintEqual(anchor: scrollContentView.topAnchor, toAnchor: scrollView.topAnchor)
        constraintEqual(anchor: scrollContentView.rightAnchor, toAnchor: scrollView.rightAnchor)
        constraintEqual(anchor: scrollContentView.bottomAnchor, toAnchor: scrollView.bottomAnchor)
        constraintEqual(anchor: scrollContentView.widthAnchor, toAnchor: scrollView.widthAnchor)
        constraintEqual(anchor: scrollContentView.heightAnchor, toAnchor: view.heightAnchor, priority: .defaultLow)
        scrollContentView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollContentView = scrollContentView

        let header = HeaderView()
        self.scrollContentView.addSubview(header)
        constraintEqual(anchor: header.leftAnchor, toAnchor: scrollContentView.leftAnchor)
        constraintEqual(anchor: header.topAnchor, toAnchor: scrollContentView.topAnchor)
        constraintEqual(anchor: header.rightAnchor, toAnchor: scrollContentView.rightAnchor)
        header.translatesAutoresizingMaskIntoConstraints = false

        header.showClose = self.lock.options.closable
        header.onClosePressed = { [weak self] in
            self?.lock.observerStore.dispatch(result: .cancel)
        }
        header.apply(style: style)

        self.headerView = header
        self.messagePresenter = BannerMessagePresenter(root: root, messageView: nil)
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let superview = self.view.superview {
            superview.layer.cornerRadius  = 4.0
        }
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWasShown), name: UIResponder.responderKeyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: #selector(keyboardWasHidden), name: UIResponder.responderKeyboardWillHideNotification, object: nil)

        self.present(self.router.root, title: Route.root.title(withStyle: self.lock.style))
    }

    func present(_ presentable: Presentable?, title: String?) {
        guard var presenter = presentable else { return }
        self.current?.remove()
        let view = presenter.view
        view.applyAll(withStyle: self.lock.style)
        self.anchorConstraint = view.layout(inView: self.scrollContentView, below: self.headerView)
        presenter.messagePresenter = self.messagePresenter
        self.current = view
        self.headerView.title = title

        self.headerView.showBack = !self.routes.history.isEmpty
        self.headerView.onBackPressed = self.router.onBack
        self.scrollView.setContentOffset(CGPoint.zero, animated: false)
    }

    func reload(connections: Connections) {
        self.lock.clientConnections = connections
        let connections = self.lock.connections
        self.lock.logger.debug("Reloaded Lock with connections \(connections).")
        guard !self.lock.connections.isEmpty else { return router.exit(withError: UnrecoverableError.clientWithNoConnections) }
        self.routes.reset()
        self.present(self.router.root, title: self.routes.current.title(withStyle: self.lock.style))
    }

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        guard !self.keyboard else { return }
        self.anchorConstraint?.isActive = self.traitCollection.verticalSizeClass != .compact
        self.scrollView.setContentOffset(CGPoint.zero, animated: true)
        self.view.layoutIfNeeded()
    }

    // MARK: - Keyboard

    @objc func keyboardWasShown(_ notification: Notification) {
        guard
            let value = notification.userInfo?[UIResponder.responderKeyboardFrameEndUserInfoKey] as? NSValue,
            let duration = notification.userInfo?[UIResponder.responderKeyboardAnimationDurationUserInfoKey] as? NSNumber,
            let curveValue = notification.userInfo?[UIResponder.responderKeyboardAnimationCurveUserInfoKey] as? NSNumber
            else { return }
        let frame = value.cgRectValue
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: frame.height, right: 0)

        self.keyboard = true
        self.scrollView.contentInset = insets
        let options = A0ViewAnimationOptions(rawValue: UInt(curveValue.intValue << 16))
        UIView.animate(
            withDuration: duration.doubleValue,
            delay: 0,
            options: options,
            animations: {
                self.anchorConstraint?.isActive = false
        },
            completion: nil)
    }

    @objc func keyboardWasHidden(_ notification: Notification) {
        guard
            let duration = notification.userInfo?[UIResponder.responderKeyboardAnimationDurationUserInfoKey] as? NSNumber,
            let curveValue = notification.userInfo?[UIResponder.responderKeyboardAnimationCurveUserInfoKey] as? NSNumber
            else { return }
        self.scrollView.contentInset = UIEdgeInsets.zero

        self.keyboard = false
        let options = A0ViewAnimationOptions(rawValue: UInt(curveValue.intValue << 16))
        UIView.animate(
            withDuration: duration.doubleValue,
            delay: 0,
            options: options,
            animations: {
                self.traitCollectionDidChange(nil)
        },
            completion: nil)
    }

}
