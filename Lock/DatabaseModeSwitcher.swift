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

public class DatabaseModeSwitcher: UIView {

    weak var segmentedControl: UISegmentedControl?

    public var onSelectionChange: (DatabaseModeSwitcher) -> () = { _ in }

    public enum Mode: Int {
        case Login = 0
        case Signup

        var title: String {
            switch self {
            case .Login:
                return "Log In".i18n(key: "com.auth0.lock.database.mode.switcher.login", comment: "Login Switch")
            case .Signup:
                return "Sign Up".i18n(key: "com.auth0.lock.database.mode.switcher.signup", comment: "Signup Switch")
            }
        }
    }

    public var selected: Mode {
        get {
            guard
                let index = self.segmentedControl?.selectedSegmentIndex,
                let mode = Mode(rawValue: index)
                else { return .Login }
            return mode
        }
        set {
            self.segmentedControl?.selectedSegmentIndex = newValue.rawValue
        }
    }

    // MARK:- Initialisers

    public convenience init() {
        self.init(frame: CGRectZero)
    }

    required override public init(frame: CGRect) {
        super.init(frame: frame)
        self.layoutSwitcher()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layoutSwitcher()
    }

    // MARK:- Layout

    private func layoutSwitcher() {
        let segmented = UISegmentedControl(items: [Mode.Login.title, Mode.Signup.title])

        self.addSubview(segmented)

        constraintEqual(anchor: segmented.topAnchor, toAnchor: self.topAnchor)
        constraintEqual(anchor: segmented.rightAnchor, toAnchor: self.rightAnchor)
        constraintEqual(anchor: segmented.leftAnchor, toAnchor: self.leftAnchor)
        dimension(segmented.heightAnchor, withValue: 45)
        segmented.translatesAutoresizingMaskIntoConstraints = false

        segmented.setDividerImage(image(named: "ic_switcher_left", compatibleWithTraitCollection: self.traitCollection), forLeftSegmentState: .Selected, rightSegmentState: .Normal, barMetrics: .Default)
        segmented.setDividerImage(image(named: "ic_switcher_right", compatibleWithTraitCollection: self.traitCollection), forLeftSegmentState: .Normal, rightSegmentState: .Selected, barMetrics: .Default)
        segmented.setDividerImage(image(named: "ic_switcher_both", compatibleWithTraitCollection: self.traitCollection), forLeftSegmentState: .Selected, rightSegmentState: .Selected, barMetrics: .Default)
        segmented.setDividerImage(image(named: "ic_switcher_both", compatibleWithTraitCollection: self.traitCollection), forLeftSegmentState: .Highlighted, rightSegmentState: .Selected, barMetrics: .Default)
        segmented.setDividerImage(image(named: "ic_switcher_both", compatibleWithTraitCollection: self.traitCollection), forLeftSegmentState: .Selected, rightSegmentState: .Highlighted, barMetrics: .Default)
        segmented.setDividerImage(image(named: "ic_switcher_none", compatibleWithTraitCollection: self.traitCollection), forLeftSegmentState: .Normal, rightSegmentState: .Normal, barMetrics: .Default)
        segmented.setBackgroundImage(image(named: "ic_switcher_selected", compatibleWithTraitCollection: self.traitCollection), forState: .Selected, barMetrics: .Default)
        segmented.setBackgroundImage(image(named: "ic_switcher_selected", compatibleWithTraitCollection: self.traitCollection), forState: .Highlighted, barMetrics: .Default)
        segmented.setBackgroundImage(image(named: "ic_switcher_normal", compatibleWithTraitCollection: self.traitCollection), forState: .Normal, barMetrics: .Default)
        segmented.setTitleTextAttributes([
            NSForegroundColorAttributeName: UIColor ( red: 0.3608, green: 0.4, blue: 0.4353, alpha: 0.6 ),
            NSFontAttributeName: mediumSystemFont(size: 15),
            ], forState: .Normal)
        segmented.setTitleTextAttributes([
            NSForegroundColorAttributeName: UIColor ( red: 0.3608, green: 0.4, blue: 0.4353, alpha: 1.0 ),
            NSFontAttributeName: semiBoldSystemFont(size: 15),
            ], forState: .Selected)
        segmented.tintColor = UIColor ( red: 0.3608, green: 0.4, blue: 0.4353, alpha: 1.0 )
        segmented.addTarget(self, action: #selector(selectedIndex), forControlEvents: .ValueChanged)

        self.segmentedControl = segmented

        self.selected = .Login
    }

    public override func intrinsicContentSize() -> CGSize {
        return CGSize(width: 280, height: 55)
    }

    // MARK:- Internal

    func selectedIndex(sender: UISegmentedControl) {
        self.onSelectionChange(self)
    }
}
