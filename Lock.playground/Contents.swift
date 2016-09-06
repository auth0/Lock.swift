//: Playground - noun: a place where people can play

import UIKit
@testable import LockUI
import XCPlayground

let header = HeaderView(frame: CGRect(x: 0, y: 0, width: 320, height: 140))
header.blurred = false
header.showClose = false
header.layoutIfNeeded()
header

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

let linkedin = social(size: .Big, style: .Linkedin)
let linkedinSmall = social(size: .Small, style: .Linkedin)





