//: Playground - noun: a place where people can play

import UIKit
@testable import LockUI
import XCPlayground

func small(style: AuthStyle) -> AuthButton {
    let button = AuthButton(size: .Small)
    button.title = style.localizedLoginTitle.uppercaseString
    button.color = style.color
    button.iconView?.image = style.image.image()
    return button
}

func social(size size: AuthButton.Size, style: AuthStyle) -> UIView {
    let button = AuthButton(size: size)
    button.title = style.localizedLoginTitle.uppercaseString
    button.color = style.color
    button.iconView?.image = style.image.image()
    let view = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
    view.addSubview(button)
    button.translatesAutoresizingMaskIntoConstraints = false
    view.layoutIfNeeded()
    return view
}
let array = (1...33).map { return $0 }
0.stride(to: array.count, by: 5)
    .map { return array[$0..<(min($0 + 5, array.count))] }
    .forEach { print($0) }
let buttons = [
    small(.Facebook),
    small(.Google),
    small(.Instagram),
    small(.Fitbit),
    small(.Amazon),
]
let guide = UILayoutGuide()
let container = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
container.addLayoutGuide(guide)
buttons.forEach {
    container.addSubview($0)
    $0.translatesAutoresizingMaskIntoConstraints = false
    $0.centerYAnchor.constraintEqualToAnchor(guide.centerYAnchor).active = true
}

NSLayoutConstraint.activateConstraints([
    guide.centerYAnchor.constraintEqualToAnchor(container.centerYAnchor),
    guide.centerXAnchor.constraintEqualToAnchor(container.centerXAnchor),
    ])

buttons.enumerate().forEach { index, button in
    let nextIndex = index + 1
    guard buttons.count > nextIndex else { return }
    let next = buttons[nextIndex]
    next.leftAnchor.constraintEqualToAnchor(button.rightAnchor, constant: 10).active = true

}

buttons.first?.leftAnchor.constraintEqualToAnchor(guide.leftAnchor).active = true
buttons.last?.rightAnchor.constraintEqualToAnchor(guide.rightAnchor).active = true

container.layoutIfNeeded()
container

let amazon = social(size: .Big, style: .Amazon)
let amazonSmall = social(size: .Small, style: .Amazon)

let aol = social(size: .Big, style: .Aol)
let aolSmall = social(size: .Small, style: .Aol)

let baidu = social(size: .Big, style: .Baidu)
let baiduSmall = social(size: .Small, style: .Baidu)

let bitbucket = social(size: .Big, style: .Bitbucket)
let bitbucketSmall = social(size: .Small, style: .Bitbucket)

let facebook = social(size: .Big, style: .Facebook)
let facebookSmall = social(size: .Small, style: .Facebook)



