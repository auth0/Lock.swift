//
//  TermsButton.swift
//  Lock
//
//  Created by Ravi Damani for Forme Life on 11/6/20.
//
//  Opt in to privacy and terms text

import Foundation

import UIKit

class TermsButton: UIView {

    weak var button: UIButton?

    var onPress: (TermsButton) -> Void = {_ in }

    var color: UIColor = .clear {
        didSet {
            self.backgroundColor = self.color
        }
    }

    var attributedTitle: NSAttributedString? {
        get {
            return self.button?.currentAttributedTitle
        }
        set {
            self.button?.setAttributedTitle(newValue, for: .normal)
//            self.button?.isEnabled = true
        }
    }
    
    var title: String? {
        get {
            return self.button?.currentTitle
        }
        set {
            self.button?.setTitle(newValue, for: .normal)
        }
    }

    // MARK: - Initialisers
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

    // MARK: - Layout

    private func layoutButton() {
        let button = UIButton(type: .system)
        self.addSubview(button)
        
        constraintEqual(anchor: button.leftAnchor, toAnchor: self.leftAnchor)
        constraintGreaterOrEqual(anchor: button.rightAnchor, toAnchor: self.rightAnchor)
        constraintEqual(anchor: button.centerYAnchor, toAnchor: self.centerYAnchor, constant: 0)
        button.translatesAutoresizingMaskIntoConstraints = false

        button.tintColor = Style.Auth0.secondaryButtonColor
        button.titleLabel?.font = UIFont(name: "Gotham-Medium", size: 15)
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.titleLabel?.textAlignment = .center
        button.addTarget(self, action: #selector(pressed), for: .touchUpInside)
        
        self.button = button
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.viewNoIntrinsicMetric, height: 76)
    }

    @objc func pressed(_ sender: Any) {
        self.onPress(self)
    }

}

extension TermsButton: Stylable {

    func apply(style: Style) {
        self.button?.tintColor = style.secondaryButtonColor
    }
}
