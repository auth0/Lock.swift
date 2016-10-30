// PasswordPolicyView.swift
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

class PolicyView: UIStackView {

    let views: [RuleView]

    init(rules: [Rule]) {
        self.views = rules.flatMap { (rule: Rule) -> [RuleView] in
            var views = [RuleView(message: rule.message)]
            if let composed = rule as? AtLeastRule {
                composed.rules.forEach { views.append(RuleView(message: $0.message, level: 1)) }
            }
            return views
        }
        super.init(frame: .zero)
        self.views.forEach { self.addArrangedSubview($0) }
        self.axis = .Vertical
        self.distribution = .EqualSpacing
        self.alignment = .Fill
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(withRules rules: [RuleResult]) {
        let statuses = rules.flatMap { (rule: RuleResult) -> [RuleView.Status] in
            let valid: RuleView.Status = rule.valid ? .ok : .error
            var statuses = [valid]
            rule.conditions.forEach { statuses.append($0.valid ? .ok : .none) }
            return statuses
        }
        for (index, status) in statuses.enumerate() {
            guard index < self.views.count else { break }
            self.views[index].status = status
        }
    }

    override func intrinsicContentSize() -> CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: CGFloat(self.views.count * 24))
    }
}

class RuleView: UIView {

    let message: String
    var status: Status = .none {
        didSet {
            self.render(text: self.message, withStatus: self.status)
        }
    }
    let label: UILabel

    init(message: String, level: Int = 0) {
        self.message = message
        self.label = UILabel()
        super.init(frame: .zero)

        self.label.numberOfLines = 3
        self.render(text: message, withStatus: self.status)

        self.addSubview(self.label)
        let margin = 20 * level
        NSLayoutConstraint.activateConstraints([
            self.label.leftAnchor.constraintEqualToAnchor(self.leftAnchor, constant: CGFloat(margin)),
            self.label.topAnchor.constraintEqualToAnchor(self.topAnchor),
            self.label.rightAnchor.constraintEqualToAnchor(self.rightAnchor),
            self.label.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor),
            ])

        self.label.translatesAutoresizingMaskIntoConstraints = false
        self.translatesAutoresizingMaskIntoConstraints = false
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    enum Status {
        case ok
        case error
        case none

        var icon: UIImage? {
            switch self {
            case .ok:
                return UIImage(named: "ic_pwd_policy_ok")
            case .error:
                return UIImage(named: "ic_pwd_policy_error")
            case .none:
                return UIImage(named: "ic_pwd_policy_none")
            }
        }

        var color: UIColor {
            switch self {
            case .ok:
                return UIColor(red:0.494, green:0.827, blue:0.129, alpha:1)
            case .error:
                return UIColor(red:0.867, green:0.294, blue:0.224, alpha:1)
            case .none:
                return .blackColor()

            }
        }
    }

    private func render(text text: String, withStatus status: Status) {
        //        let attachment = NSTextAttachment()
        //        attachment.image = UIImage(named: "ic_pwd_policy_error")
        let attributedText = NSMutableAttributedString()
        //        attributedText.append(NSAttributedString(attachment: attachment))
        attributedText.appendAttributedString(NSAttributedString(
            string: text,
            attributes: [
                NSForegroundColorAttributeName: status.color,
                NSFontAttributeName: UIFont.systemFontOfSize(13),
            ]
            ))
        self.label.attributedText = attributedText
    }
}
