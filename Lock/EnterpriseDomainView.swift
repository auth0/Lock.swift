// EnterpriseDomainView.swift
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

class EnterpriseDomainView: UIView, View {
    
    weak var form: Form?
    weak var header: UILabel!
    weak var primaryButton: PrimaryButton?
    weak var authCollectionView: AuthCollectionView?
    
    private weak var container: UIStackView?
    
    init(email: String?, authCollectionView: AuthCollectionView? = nil) {
        let primaryButton = PrimaryButton()
        let domainView = EnterpriseSingleInputView()
        let container = UIStackView()
        let header = UILabel()
        
        self.primaryButton = primaryButton
        self.form = domainView
        self.container = container
        
        super.init(frame: CGRectZero)
        
        self.addSubview(header)
        self.addSubview(container)
        self.addSubview(primaryButton)
        
        header.text = "SINGLE SIGN-ON ENABLED".i18n(key: "com.auth0.lock.enterprise.sso", comment: "SSO Header")
        header.textAlignment = .Center
        header.textColor = UIColor ( red: 0.5725, green: 0.5804, blue: 0.5843, alpha: 1.0 )
        header.backgroundColor = UIColor ( red: 0.9333, green: 0.9333, blue: 0.9333, alpha: 1.0 )
        header.hidden = true
        self.header = header
        
        container.alignment = .Fill
        container.axis = .Vertical
        container.distribution = .EqualSpacing
        container.spacing = 5
        
        container.addArrangedSubview(strutView())
        if let authCollectionView = authCollectionView {
            self.authCollectionView = authCollectionView
            container.addArrangedSubview(authCollectionView)
            let label = UILabel()
            label.text = "or".i18n(key: "com.auth0.lock.database.separator", comment: "Social separator")
            label.font = mediumSystemFont(size: 13.75)
            label.textColor = UIColor ( red: 0.0, green: 0.0, blue: 0.0, alpha: 0.54 )
            label.textAlignment = .Center
            container.addArrangedSubview(label)
        }
        container.addArrangedSubview(domainView)
        container.addArrangedSubview(strutView())
        
        constraintEqual(anchor: header.topAnchor, toAnchor: self.topAnchor)
        constraintEqual(anchor: header.leftAnchor, toAnchor: self.leftAnchor, constant: 0)
        constraintEqual(anchor: header.rightAnchor, toAnchor: self.rightAnchor, constant: 0)
        constraintEqual(anchor: header.bottomAnchor, toAnchor: container.topAnchor)
        dimension(header.heightAnchor, greaterThanOrEqual: 30)
        header.translatesAutoresizingMaskIntoConstraints = false

        constraintEqual(anchor: container.topAnchor, toAnchor: header.bottomAnchor)
        constraintEqual(anchor: container.leftAnchor, toAnchor: self.leftAnchor, constant: 20)
        constraintEqual(anchor: container.rightAnchor, toAnchor: self.rightAnchor, constant: -20)
        constraintEqual(anchor: container.bottomAnchor, toAnchor: primaryButton.topAnchor)
        container.translatesAutoresizingMaskIntoConstraints = false
        
        constraintEqual(anchor: primaryButton.leftAnchor, toAnchor: self.leftAnchor)
        constraintEqual(anchor: primaryButton.rightAnchor, toAnchor: self.rightAnchor)
        constraintEqual(anchor: primaryButton.bottomAnchor, toAnchor: self.bottomAnchor)
        primaryButton.translatesAutoresizingMaskIntoConstraints = false
        
        
        domainView.type = .Email
        domainView.returnKey = .Done
        domainView.value = email
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func apply(style style: Style) {
        self.primaryButton?.apply(style: style)
    }
    
}

private func strutView(withHeight height: CGFloat = 50) -> UIView {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    dimension(view.heightAnchor, withValue: height)
    return view
}

public class EnterpriseSingleInputView : SingleInputView {
    
    public override func intrinsicContentSize() -> CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: 50)
    }
}
