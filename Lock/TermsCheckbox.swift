//
//  TermsCheckbox.swift
//  Lock
//
//  Created by Yo on 11/6/20.
//

import Foundation
import UIKit


class TermsCheckbox: UIView, Stylable {

    weak var button: UIButton?
    var selected: Bool = false

    private weak var textColor: UIColor?

    var hideTitle: Bool = false {
        didSet {
            guard let button = self.button else { return }
            self.layout(title: self.title, inButton: button)
        }
    }

    var title: String? = nil {
        didSet {
            guard let button = self.button else { return }
            self.layout(title: self.title, inButton: button)
        }
    }

    var onPress: (TermsCheckbox) -> Void = {_ in }



    convenience init() {
        self.init(frame: CGRect.zero)
    }

    required override init(frame: CGRect) {
        super.init(frame: frame)
        self.layoutButton()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layoutButton()
    }

    private func layoutButton() {
        let button = UIButton(type: .custom)

        self.addSubview(button)

        constraintEqual(anchor: button.leftAnchor, toAnchor: self.leftAnchor)
        constraintEqual(anchor: button.topAnchor, toAnchor: self.topAnchor)
        constraintEqual(anchor: button.rightAnchor, toAnchor: self.rightAnchor)
        constraintEqual(anchor: button.bottomAnchor, toAnchor: self.bottomAnchor)
        button.translatesAutoresizingMaskIntoConstraints = false

        layout(title: self.title, inButton: button)
        button.addTarget(self, action: #selector(pressed), for: .touchUpInside)
        button.isEnabled = true

        apply(style: Style.Auth0)
        self.button = button
    }

    private func layout(title: String?, inButton button: UIButton) {
            button.setImage(UIImage(named: "checkbox.selected", in: bundleForLock(), compatibleWith: self.traitCollection), for: .selected)
            button.setImage(UIImage(named: "checkbox", in: bundleForLock(), compatibleWith: self.traitCollection), for: .normal)
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.viewNoIntrinsicMetric, height: 95)
    }

    @objc func pressed(_ sender: Any) {
        self.button?.isSelected = !(self.button?.isSelected ?? true)
        self.onPress(self)

    }

    func apply(style: Style) {
        self.hideTitle = style.hideButtonTitle
    }
}
