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

    public var selected: DatabaseModes {
        get {
            guard
                let index = self.segmentedControl?.selectedSegmentIndex,
                let mode = DatabaseModes(rawValue: index)
                where index < 3
                else { return .Login }
            return mode
        }
        set {
            guard newValue.rawValue < 3 else { return }
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
        let segmented = UISegmentedControl(items: [DatabaseModes.Login.title, DatabaseModes.Signup.title])

        self.addSubview(segmented)

        constraintEqual(anchor: segmented.centerYAnchor, toAnchor: self.centerYAnchor)
        constraintEqual(anchor: segmented.rightAnchor, toAnchor: self.rightAnchor)
        constraintEqual(anchor: segmented.leftAnchor, toAnchor: self.leftAnchor)
        dimension(segmented.heightAnchor, withValue: 40)
        segmented.translatesAutoresizingMaskIntoConstraints = false

        segmented.setDividerImage(image(named: "ic_switcher_left", compatibleWithTraitCollection: self.traitCollection), forLeftSegmentState: .Selected, rightSegmentState: .Normal, barMetrics: .Default)
        segmented.setDividerImage(image(named: "ic_switcher_right", compatibleWithTraitCollection: nil), forLeftSegmentState: .Normal, rightSegmentState: .Selected, barMetrics: .Default)
        segmented.setBackgroundImage(image(named: "ic_switcher_selected", compatibleWithTraitCollection: nil), forState: .Selected, barMetrics: .Default)
        segmented.setBackgroundImage(image(named: "ic_switcher_normal", compatibleWithTraitCollection: nil), forState: .Normal, barMetrics: .Default)
        segmented.setTitleTextAttributes([
            NSForegroundColorAttributeName: UIColor ( red: 0.3608, green: 0.4, blue: 0.4353, alpha: 0.6 ),
            NSFontAttributeName: mediumSystemFont(size: 13),
            ], forState: .Normal)
        segmented.setTitleTextAttributes([
            NSForegroundColorAttributeName: UIColor ( red: 0.3608, green: 0.4, blue: 0.4353, alpha: 1.0 ),
            NSFontAttributeName: semiBoldSystemFont(size: 13),
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
