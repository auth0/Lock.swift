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

class PasswordPolicyHelperView : UIView {

    weak var policyView: PolicyView!
    let cornerRadius: CGFloat = 10
    let arrowSize = CGSize(width: 20, height: 10)
    let arrowPoint = CGPoint(x:20, y:0)

    init(rules: [Rule]) {
        super.init(frame: CGRect.zero)
        self.isOpaque = false

        let policyView = PolicyView(rules: rules)
        policyView.axis = .vertical
        policyView.alignment = .leading
        policyView.distribution = .fillEqually
        self.addSubview(policyView)

        constraintEqual(anchor: policyView.topAnchor, toAnchor: self.topAnchor, constant: 5)
        constraintEqual(anchor: policyView.leftAnchor, toAnchor: self.leftAnchor, constant: 20)
        constraintEqual(anchor: policyView.rightAnchor, toAnchor: self.rightAnchor, constant: -20)
        constraintEqual(anchor: policyView.bottomAnchor, toAnchor: self.bottomAnchor, constant: -20)
        policyView.translatesAutoresizingMaskIntoConstraints = false
        self.policyView = policyView
    }

    override var intrinsicContentSize : CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: self.policyView.intrinsicContentSize.height)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        let arrow = UIBezierPath()
        let color = UIColor(red: 0.122, green: 0.141, blue: 0.180, alpha: 1.00)

        arrow.move(to: CGPoint(x: arrowPoint.x, y: self.bounds.height))
        arrow.addLine(
            to: CGPoint(
                x: arrowPoint.x - self.arrowSize.width * 0.5,
                y: self.bounds.height - self.arrowSize.height
            )
        )

        arrow.addLine(to: CGPoint(x: self.cornerRadius, y: self.bounds.height - self.arrowSize.height))
        arrow.addArc(
            withCenter: CGPoint(
                x: self.cornerRadius,
                y: self.bounds.height - self.arrowSize.height - self.cornerRadius
            ),
            radius: self.cornerRadius,
            startAngle: self.radians(90),
            endAngle: self.radians(180),
            clockwise: true)

        arrow.addLine(to: CGPoint(x: 0, y: self.cornerRadius))
        arrow.addArc(
            withCenter: CGPoint(
                x: self.cornerRadius,
                y: self.cornerRadius
            ),
            radius: self.cornerRadius,
            startAngle: self.radians(180),
            endAngle: self.radians(270),
            clockwise: true)

        arrow.addLine(to: CGPoint(x: self.bounds.width - self.cornerRadius, y: 0))
        arrow.addArc(
            withCenter: CGPoint(
                x: self.bounds.width - self.cornerRadius,
                y: self.cornerRadius
            ),
            radius: self.cornerRadius,
            startAngle: self.radians(270),
            endAngle: self.radians(0),
            clockwise: true)

        arrow.addLine(to: CGPoint(x: self.bounds.width, y: self.bounds.height - self.arrowSize.height - self.cornerRadius))
        arrow.addArc(
            withCenter: CGPoint(
                x: self.bounds.width - self.cornerRadius,
                y: self.bounds.height - self.arrowSize.height - self.cornerRadius
            ),
            radius: self.cornerRadius,
            startAngle: self.radians(0),
            endAngle: self.radians(90),
            clockwise: true)

        arrow.addLine(to: CGPoint(x: arrowPoint.x + self.arrowSize.width * 0.5,
                                  y: self.bounds.height - self.arrowSize.height))

        color.setFill()
        arrow.fill()
    }

    fileprivate func radians(_ degrees: CGFloat) -> CGFloat {
        return (CGFloat(M_PI) * degrees / 180)
    }
}

class PolicyView: UIStackView, PasswordPolicyValidatorDelegate {

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
        self.axis = .vertical
        self.distribution = .equalSpacing
        self.alignment = .fill
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
        for (index, status) in statuses.enumerated() {
            guard index < self.views.count else { break }
            self.views[index].status = status
        }
    }

    override var intrinsicContentSize : CGSize {
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
        NSLayoutConstraint.activate([
            self.label.leftAnchor.constraint(equalTo: self.leftAnchor, constant: CGFloat(margin)),
            self.label.topAnchor.constraint(equalTo: self.topAnchor),
            self.label.rightAnchor.constraint(equalTo: self.rightAnchor),
            self.label.bottomAnchor.constraint(equalTo: self.bottomAnchor)
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
                return LazyImage(name: "ic_pwd_policy_ok", bundle: bundleForLock()).image()
            case .error:
                return LazyImage(name: "ic_pwd_policy_error", bundle: bundleForLock()).image()
            case .none:
                return LazyImage(name: "ic_pwd_policy_none", bundle: bundleForLock()).image()
            }
        }

        var color: UIColor {
            switch self {
            case .ok:
                return UIColor(red: 0.502, green: 0.820, blue: 0.208, alpha: 1)
            case .error:
                return UIColor(red: 0.745, green: 0.271, blue: 0.153, alpha: 1)
            case .none:
                return .white

            }
        }
    }

    fileprivate func render(text: String, withStatus status: Status) {
        let font = UIFont.systemFont(ofSize: 13)

        let attachment = NSTextAttachment()
        attachment.image = status.icon
        attachment.bounds = CGRect(x: 0.0, y: font.descender / 2.0, width: attachment.image!.size.width, height: attachment.image!.size.height)

        let attributedText = NSMutableAttributedString()
        attributedText.append(NSAttributedString(attachment: attachment))
        attributedText.append(NSAttributedString(
            string: " " + text,
            attributes: [
                NSForegroundColorAttributeName: status.color,
                NSFontAttributeName: font
            ]
            ))
        self.label.attributedText = attributedText
    }
}
