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
    let onAction: (String) -> Void
    let customStyle: [String : AuthStyle]

    enum Mode {
        case expanded(isLogin: Bool)
        case compact
    }

    // MARK: - Initialisers

    init(connections: [OAuth2Connection], mode: Mode, insets: UIEdgeInsets, customStyle: [String: AuthStyle], onAction: @escaping (String) -> Void) {
        self.connections = connections
        self.mode = mode
        self.onAction = onAction
        self.customStyle = customStyle
        super.init(frame: CGRect.zero)
        self.layout(connections, mode: mode, insets: insets)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    var height: CGFloat {
        guard !connections.isEmpty else { return 0 }
        let sample = AuthButton(size: .big)
        let buttonHeight = Int(sample.intrinsicContentSize.height)
        let count: Int
        switch self.mode {
        case .expanded:
            count = connections.count
        case .compact:
            count = Int(ceil(Double(connections.count) / 5))
        }
        return CGFloat(buttonHeight * count + (8 * (count - 1)))
    }

    public override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: self.height)
    }

    private func layout(_ connections: [OAuth2Connection], mode: Mode, insets: UIEdgeInsets) {
        let stack: UIStackView
        switch mode {
        case .compact:
            stack = compactStack(forButtons: oauth2Buttons(forConnections: connections, customStyle: self.customStyle, isLogin: true, onAction: self.onAction))
        case .expanded(let login):
            stack = expandedStack(forButtons: oauth2Buttons(forConnections: connections, customStyle: self.customStyle, isLogin: login, onAction: self.onAction))
        }
        self.addSubview(stack)

        constraintEqual(anchor: stack.leftAnchor, toAnchor: self.leftAnchor, constant: insets.left)
        constraintGreaterOrEqual(anchor: stack.topAnchor, toAnchor: self.topAnchor, constant: insets.top)
        constraintEqual(anchor: stack.rightAnchor, toAnchor: self.rightAnchor, constant: -insets.right)
        constraintGreaterOrEqual(anchor: stack.bottomAnchor, toAnchor: self.bottomAnchor, constant: -insets.bottom)
        constraintEqual(anchor: stack.centerYAnchor, toAnchor: self.centerYAnchor)
        dimension(dimension: stack.heightAnchor, withValue: self.height)
        stack.translatesAutoresizingMaskIntoConstraints = false
    }

    private func expandedStack(forButtons buttons: [AuthButton]) -> UIStackView {
        buttons.forEach { $0.size = .big }
        let stack = UIStackView(arrangedSubviews: buttons)
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .equalSpacing
        return stack
    }

    private func compactStack(forButtons buttons: [AuthButton]) -> UIStackView {
        let rows = stride(from: 0, to: buttons.count, by: 5).map { return Array(buttons[$0..<(min($0 + 5, buttons.count))]) }.map(rowView)
        let stack = UIStackView(arrangedSubviews: rows)
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 8
        return stack
    }

    private func rowView(from buttons: [AuthButton]) -> UIView {
        let container = UIView()
        let guide = UILayoutGuide()
        container.addLayoutGuide(guide)
        buttons.forEach {
            $0.size = .small
            container.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.centerYAnchor.constraint(equalTo: guide.centerYAnchor).isActive = true
        }

        NSLayoutConstraint.activate([
            guide.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            guide.centerXAnchor.constraint(equalTo: container.centerXAnchor)
            ])

        buttons.enumerated().forEach { index, button in
            let nextIndex = index + 1
            guard buttons.count > nextIndex else { return }
            let next = buttons[nextIndex]
            next.leftAnchor.constraint(equalTo: button.rightAnchor, constant: 8).isActive = true

        }

        buttons.first?.leftAnchor.constraint(equalTo: guide.leftAnchor).isActive = true
        buttons.last?.rightAnchor.constraint(equalTo: guide.rightAnchor).isActive = true
        return container
    }

    func apply(style: Style) {
    }
}

func oauth2Buttons(forConnections connections: [OAuth2Connection], customStyle: [String: AuthStyle], isLogin login: Bool, onAction: @escaping (String) -> Void) -> [AuthButton] {
    return connections.map { connection -> AuthButton in
        let style = customStyle[connection.name] ?? connection.style
        let button = AuthButton(size: .big)
        button.title = login ? style.localizedLoginTitle : style.localizedSignUpTitle
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
