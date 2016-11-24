// AuthCollectionView.swift
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

class AuthCollectionView: UIView, View {

    let connections: [OAuth2Connection]
    let mode: Mode
    let onAction: String -> ()
    let customStyle: [String : AuthStyle]

    enum Mode {
        case Expanded(isLogin: Bool)
        case Compact
    }

    // MARK:- Initialisers

    init(connections: [OAuth2Connection], mode: Mode, insets: UIEdgeInsets, customStyle: [String: AuthStyle], onAction: String -> ()) {
        self.connections = connections
        self.mode = mode
        self.onAction = onAction
        self.customStyle = customStyle
        super.init(frame: CGRectZero)
        self.layout(connections, mode: mode, insets: insets)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK:- Layout

    var height: CGFloat {
        guard !connections.isEmpty else { return 0 }
        let sample = AuthButton(size: .Big)
        let buttonHeight = Int(sample.intrinsicContentSize().height)
        let count: Int
        switch self.mode {
        case .Expanded:
            count = connections.count
        case .Compact:
            count = Int(ceil(Double(connections.count) / 5))
        }
        return CGFloat(buttonHeight * count + (8 * (count - 1)))
    }

    override func intrinsicContentSize() -> CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: self.height)
    }

    private func layout(connections: [OAuth2Connection], mode: Mode, insets: UIEdgeInsets) {
        let stack: UIStackView
        switch mode {
        case .Compact:
            stack = compactStack(forButtons: oauth2Buttons(forConnections: connections, customStyle: self.customStyle, isLogin: true, onAction: self.onAction))
        case .Expanded(let login):
            stack = expandedStack(forButtons: oauth2Buttons(forConnections: connections, customStyle: self.customStyle, isLogin: login, onAction: self.onAction))
        }
        self.addSubview(stack)

        constraintEqual(anchor: stack.leftAnchor, toAnchor: self.leftAnchor, constant: insets.left)
        constraintGreaterOrEqual(anchor: stack.topAnchor, toAnchor: self.topAnchor, constant: insets.top)
        constraintEqual(anchor: stack.rightAnchor, toAnchor: self.rightAnchor, constant: -insets.right)
        constraintGreaterOrEqual(anchor: stack.bottomAnchor, toAnchor: self.bottomAnchor, constant: -insets.bottom)
        constraintEqual(anchor: stack.centerYAnchor, toAnchor: self.centerYAnchor)
        dimension(stack.heightAnchor, withValue: self.height)
        stack.translatesAutoresizingMaskIntoConstraints = false
    }

    private func expandedStack(forButtons buttons: [AuthButton]) -> UIStackView {
        buttons.forEach { $0.size = .Big }
        let stack = UIStackView(arrangedSubviews: buttons)
        stack.axis = .Vertical
        stack.alignment = .Fill
        stack.distribution = .EqualSpacing
        return stack
    }

    private func compactStack(forButtons buttons: [AuthButton]) -> UIStackView {
        let rows = 0.stride(to: buttons.count, by: 5).map { return Array(buttons[$0..<(min($0 + 5, buttons.count))]) }.map(rowView)
        let stack = UIStackView(arrangedSubviews: rows)
        stack.axis = .Vertical
        stack.alignment = .Fill
        stack.distribution = .FillEqually
        stack.spacing = 8
        return stack
    }

    private func rowView(from buttons: [AuthButton]) -> UIView {
        let container = UIView()
        let guide = UILayoutGuide()
        container.addLayoutGuide(guide)
        buttons.forEach {
            $0.size = .Small
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
            next.leftAnchor.constraintEqualToAnchor(button.rightAnchor, constant: 8).active = true

        }

        buttons.first?.leftAnchor.constraintEqualToAnchor(guide.leftAnchor).active = true
        buttons.last?.rightAnchor.constraintEqualToAnchor(guide.rightAnchor).active = true
        return container
    }

    func apply(style style: Style) {
        
    }
}

func oauth2Buttons(forConnections connections: [OAuth2Connection], customStyle: [String: AuthStyle], isLogin login: Bool, onAction: String -> ()) -> [AuthButton] {
    return connections.map { connection -> AuthButton in
        let style = customStyle[connection.name] ?? connection.style
        let button = AuthButton(size: .Big)
        button.title = login ? style.localizedLoginTitle().uppercaseString : style.localizedSignUpTitle().uppercaseString
        button.normalColor = style.normalColor
        button.highlightedColor = style.highlightedColor
        button.titleColor = style.foregroundColor
        button.icon = style.image.image(compatibleWithTraits: button.traitCollection)
        button.onPress = { _ in
            onAction(connection.name)
        }
        return button
    }
}
