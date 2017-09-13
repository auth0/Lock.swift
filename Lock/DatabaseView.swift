// DatabaseView.swift
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

protocol DatabaseView: class, View {
    weak var form: Form? { get }
    weak var secondaryButton: SecondaryButton? { get }
    weak var primaryButton: PrimaryButton? { get }
    weak var switcher: DatabaseModeSwitcher? { get }
    weak var passwordManagerButton: IconButton? { get }
    weak var showPasswordButton: IconButton? { get }
    weak var identityField: InputField? { get }
    weak var passwordField: InputField? { get }
    var allFields: [InputField]? { get }

    var traitCollection: UITraitCollection { get }

    var allowedModes: DatabaseMode { get }

    func showLogin(withIdentifierStyle style: DatabaseIdentifierStyle, identifier: String?, authCollectionView: AuthCollectionView?, showPassswordManager: Bool, showPassword: Bool)
    // swiftlint:disable:next function_parameter_count
    func showSignUp(withUsername showUsername: Bool, username: String?, email: String?, authCollectionView: AuthCollectionView?, additionalFields: [CustomTextField], passwordPolicyValidator: PasswordPolicyValidator?, showPassswordManager: Bool, showPassword: Bool)
}
