// Layout.swift
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

import Foundation

// MARK: - NSLayoutXAxisAnchor
@discardableResult func constraintEqual<C: NSLayoutAnchor<NSLayoutXAxisAnchor>>(anchor: C, toAnchor anotherAnchor: C, constant: CGFloat? = nil, priority: UILayoutPriority = UILayoutPriorityRequired) -> NSLayoutConstraint {
    let constraint: NSLayoutConstraint
    if let value = constant {
        constraint = anchor.constraint(equalTo: anotherAnchor, constant: value)
    } else {
        constraint = anchor.constraint(equalTo: anotherAnchor)
    }
    constraint.priority = priority
    constraint.isActive = true
    return constraint
}

@discardableResult func constraintGreaterOrEqual<C: NSLayoutAnchor<NSLayoutXAxisAnchor>>(anchor: C, toAnchor anotherAnchor: C, constant: CGFloat? = nil, priority: UILayoutPriority = UILayoutPriorityRequired) -> NSLayoutConstraint {
    let constraint: NSLayoutConstraint
    if let value = constant {
        constraint = anchor.constraint(greaterThanOrEqualTo: anotherAnchor, constant: value)
    } else {
        constraint = anchor.constraint(greaterThanOrEqualTo: anotherAnchor)
    }
    constraint.priority = priority
    constraint.isActive = true
    return constraint
}

// MARK: - NSLayoutYAxisAnchor
@discardableResult func constraintEqual<C: NSLayoutAnchor<NSLayoutYAxisAnchor>>(anchor: C, toAnchor anotherAnchor: C, constant: CGFloat? = nil, priority: UILayoutPriority = UILayoutPriorityRequired) -> NSLayoutConstraint {
    let constraint: NSLayoutConstraint
    if let value = constant {
        constraint = anchor.constraint(equalTo: anotherAnchor, constant: value)
    } else {
        constraint = anchor.constraint(equalTo: anotherAnchor)
    }
    constraint.priority = priority
    constraint.isActive = true
    return constraint
}

@discardableResult func constraintGreaterOrEqual<C: NSLayoutAnchor<NSLayoutYAxisAnchor>>(anchor: C, toAnchor anotherAnchor: C, constant: CGFloat? = nil, priority: UILayoutPriority = UILayoutPriorityRequired) -> NSLayoutConstraint {
    let constraint: NSLayoutConstraint
    if let value = constant {
        constraint = anchor.constraint(greaterThanOrEqualTo: anotherAnchor, constant: value)
    } else {
        constraint = anchor.constraint(greaterThanOrEqualTo: anotherAnchor)
    }
    constraint.priority = priority
    constraint.isActive = true
    return constraint
}

// MARK: - NSLayoutDimension
@discardableResult func constraintEqual<C: NSLayoutAnchor<NSLayoutDimension>>(anchor: C, toAnchor anotherAnchor: C, constant: CGFloat? = nil, priority: UILayoutPriority = UILayoutPriorityRequired) -> NSLayoutConstraint {
    let constraint: NSLayoutConstraint
    if let value = constant {
        constraint = anchor.constraint(equalTo: anotherAnchor, constant: value)
    } else {
        constraint = anchor.constraint(equalTo: anotherAnchor)
    }
    constraint.priority = priority
    constraint.isActive = true
    return constraint
}

// MARK: - NSLayoutDimension
@discardableResult func dimension(dimension: NSLayoutDimension, withValue value: CGFloat) -> NSLayoutConstraint {
    let constraint = dimension.constraint(equalToConstant: value)
    constraint.isActive = true
    return constraint
}

@discardableResult func dimension(dimension: NSLayoutDimension, greaterThanOrEqual value: CGFloat) -> NSLayoutConstraint {
    let constraint = dimension.constraint(greaterThanOrEqualToConstant: value)
    constraint.isActive = true
    return constraint
}

func strutView(withHeight height: CGFloat = 50) -> UIView {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    dimension(dimension:view.heightAnchor, withValue: height)
    return view
}
