// DatabaseModeSwitcher.swift
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

class DatabaseModeSwitcher: UIView {

    weak var segmentedControl: UISegmentedControl?

    var onSelectionChange: (DatabaseModeSwitcher) -> Void = { _ in }

    enum Mode: Int {
        case login = 0
        case signup

        var title: String {
            switch self {
            case .login:
                return "Log In".i18n(key: "com.auth0.lock.database.mode.switcher.login", comment: "Login Switch")
            case .signup:
                return "Sign Up".i18n(key: "com.auth0.lock.database.mode.switcher.signup", comment: "Signup Switch")
            }
        }
    }

    var selected: Mode {
        get {
            guard
                let index = self.segmentedControl?.selectedSegmentIndex,
                let mode = Mode(rawValue: index)
                else { return .login }
            return mode
        }
        set {
            self.segmentedControl?.selectedSegmentIndex = newValue.rawValue
        }
    }

    // MARK: - Initialisers

    convenience init() {
        self.init(frame: CGRect.zero)
    }

    required override init(frame: CGRect) {
        super.init(frame: frame)
        self.layoutSwitcher()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layoutSwitcher()
    }

    // MARK: - Layout

    private func layoutSwitcher() {
        let segmented = UISegmentedControl(items: [Mode.login.title, Mode.signup.title])

        self.addSubview(segmented)

        constraintEqual(anchor: segmented.topAnchor, toAnchor: self.topAnchor)
        constraintEqual(anchor: segmented.rightAnchor, toAnchor: self.rightAnchor)
        constraintEqual(anchor: segmented.leftAnchor, toAnchor: self.leftAnchor)
        dimension(dimension: segmented.heightAnchor, withValue: 45)
        segmented.translatesAutoresizingMaskIntoConstraints = false

        segmented.setDividerImage(image(named: "ic_switcher_left", compatibleWithTraitCollection: self.traitCollection), forLeftSegmentState: .selected, rightSegmentState: UIControlState(), barMetrics: .default)
        segmented.setDividerImage(image(named: "ic_switcher_right", compatibleWithTraitCollection: self.traitCollection), forLeftSegmentState: UIControlState(), rightSegmentState: .selected, barMetrics: .default)
        segmented.setDividerImage(image(named: "ic_switcher_both", compatibleWithTraitCollection: self.traitCollection), forLeftSegmentState: .selected, rightSegmentState: .selected, barMetrics: .default)
        segmented.setDividerImage(image(named: "ic_switcher_both", compatibleWithTraitCollection: self.traitCollection), forLeftSegmentState: .highlighted, rightSegmentState: .selected, barMetrics: .default)
        segmented.setDividerImage(image(named: "ic_switcher_both", compatibleWithTraitCollection: self.traitCollection), forLeftSegmentState: .selected, rightSegmentState: .highlighted, barMetrics: .default)
        segmented.setDividerImage(image(named: "ic_switcher_none", compatibleWithTraitCollection: self.traitCollection), forLeftSegmentState: UIControlState(), rightSegmentState: UIControlState(), barMetrics: .default)
        segmented.setBackgroundImage(image(named: "ic_switcher_selected", compatibleWithTraitCollection: self.traitCollection), for: .selected, barMetrics: .default)
        segmented.setBackgroundImage(image(named: "ic_switcher_selected", compatibleWithTraitCollection: self.traitCollection), for: .highlighted, barMetrics: .default)
        segmented.setBackgroundImage(image(named: "ic_switcher_normal", compatibleWithTraitCollection: self.traitCollection), for: UIControlState(), barMetrics: .default)
        segmented.setTitleTextAttributes([
            NSForegroundColorAttributeName: Style.Auth0.tabTextColor,
            NSFontAttributeName: mediumSystemFont(size: 15)
            ], for: UIControlState())
        segmented.setTitleTextAttributes([
            NSForegroundColorAttributeName: Style.Auth0.tabTextColor,
            NSFontAttributeName: semiBoldSystemFont(size: 15)
            ], for: .selected)
        segmented.tintColor = Style.Auth0.tabTintColor
        segmented.addTarget(self, action: #selector(selectedIndex), for: .valueChanged)

        self.segmentedControl = segmented
        self.selected = .login
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: 55)
    }

    // MARK: - Internal

    func selectedIndex(_ sender: UISegmentedControl) {
        self.onSelectionChange(self)
    }
}

extension DatabaseModeSwitcher: Stylable {

    func apply(style: Style) {
        self.segmentedControl?.tintColor = style.tabTintColor
        self.segmentedControl?.setTitleTextAttributes([
            NSForegroundColorAttributeName: style.tabTextColor,
            NSFontAttributeName: mediumSystemFont(size: 15)
            ], for: UIControlState())
        self.segmentedControl?.setTitleTextAttributes([
            NSForegroundColorAttributeName: style.tabTextColor,
            NSFontAttributeName: semiBoldSystemFont(size: 15)
            ], for: .selected)
    }
}
