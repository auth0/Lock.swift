//: Playground - noun: a place where people can play

import UIKit
import LockUI
import XCPlayground

func wrap(button: AuthButton) -> UIView {
    let wrapper = UIView()
    wrapper.backgroundColor = .whiteColor()
    wrapper.addSubview(button)

    button.leftAnchor.constraintEqualToAnchor(wrapper.leftAnchor).active = true
    button.rightAnchor.constraintEqualToAnchor(wrapper.rightAnchor).active = true
    button.centerYAnchor.constraintEqualToAnchor(wrapper.centerYAnchor).active = true
    button.translatesAutoresizingMaskIntoConstraints = false

    wrapper.setContentCompressionResistancePriority(UILayoutPriorityRequired, forAxis: .Vertical)
    wrapper.setContentCompressionResistancePriority(UILayoutPriorityRequired, forAxis: .Vertical)
    return wrapper
}

let social = AuthButton(style: .Big)
social.title = "SIGNUP WITH AUTH0"
social.onPress = { _ in print("SIGNUP!") }
let social2 = AuthButton(style: .Big)
social2.title = "LOGIN WITH AUTH0"

let view = UIView()
let container = UIStackView(frame: CGRect(x: 0, y: 0, width: 320, height: 400))
container.addArrangedSubview(wrap(social))
container.addArrangedSubview(wrap(social2))
container.axis = .Vertical
container.alignment = .Fill
container.distribution = .FillEqually
container.spacing = 0

XCPlaygroundPage.currentPage.liveView = container