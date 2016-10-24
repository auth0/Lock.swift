// PasswordPolicy.swift
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

private let lowercase = "Lower case letters (a-z)".i18n(key: "com.auth0.lock.error.password.lowercase-letters", comment: "Lowercase letters")
private let upperCase = "Upper case letters (A-Z)".i18n(key: "com.auth0.lock.error.password.uppercase-letters", comment: "Uppercase letters")
private let numbers = "Numbers (i.e. 0-9)".i18n(key: "com.auth0.lock.error.password.numbers", comment: "Numbers")
private let specialCharacters = "Special characters (e.g. !@#$%^&*)".i18n(key: "com.auth0.lock.error.password.special-characters", comment: "Special Characters")
private let containAtLeast = "Contain at least %d of the following %d types of characters:".i18n(key: "com.auth0.lock.error.password.contain-at-least", comment: "At least n groups")
private let shouldContain = "Should contain:".i18n(key: "com.auth0.lock.error.password.should-contain", comment: "N groups")
private let nonEmpty = "Non-empty password required".i18n(key: "com.auth0.lock.error.password.non-empty", comment: "Must no be empty")
private let atLeast = "At least %d characters in length".i18n(key: "com.auth0.lock.error.password.at-least-length", comment: "At least N characters")
private let noMoreThanSimilar = "No more than %d identical characters in a row (e.g., \"%s\" not allowed)".i18n(key: "com.auth0.lock.error.password.no-more-identical", comment: "No more than N identical characters")

public struct PasswordPolicy {

    let rules: [Rule]

    public func on(password: String?) -> [RuleResult] {
        return rules.map { $0.evaluate(on: password) }
    }

    public static var none: PasswordPolicy {
        return PasswordPolicy(rules: [withPassword(lengthInRange: 1..<Int.max, message: nonEmpty)])
    }

    public static var low: PasswordPolicy {
        let message = String(format: atLeast, 6)
        return PasswordPolicy(rules: [withPassword(lengthInRange: 6..<Int.max, message: message)])
    }

    public static var fair: PasswordPolicy {
        return PasswordPolicy(rules: [
            withPassword(lengthInRange: 8..<Int.max, message: String(format: atLeast, 8)),
            AtLeastRule(minimum: 3, rules: [
                    withPassword(havingCharactersIn: .lowercaseLetterCharacterSet(), message: lowercase),
                    withPassword(havingCharactersIn: .uppercaseLetterCharacterSet(), message: upperCase),
                    withPassword(havingCharactersIn: .decimalDigitCharacterSet(), message: numbers),
                ], message: shouldContain),
            ])
    }

    public static var good: PasswordPolicy {
        let specialCharacterSet = NSMutableCharacterSet.punctuationCharacterSet()
        specialCharacterSet.formUnionWithCharacterSet(.symbolCharacterSet())
        return PasswordPolicy(rules: [
            withPassword(lengthInRange: 8..<Int.max, message: String(format: atLeast, 8)),
            AtLeastRule(minimum: 3, rules: [
                    withPassword(havingCharactersIn: .lowercaseLetterCharacterSet(), message: lowercase),
                    withPassword(havingCharactersIn: .uppercaseLetterCharacterSet(), message: upperCase),
                    withPassword(havingCharactersIn: .decimalDigitCharacterSet(), message: numbers),
                    withPassword(havingCharactersIn: specialCharacterSet, message: specialCharacters),
                ], message: String(format: containAtLeast, 3, 4)),
            ])
    }

    public static var excellent: PasswordPolicy {
        let specialCharacterSet = NSMutableCharacterSet.punctuationCharacterSet()
        specialCharacterSet.formUnionWithCharacterSet(.symbolCharacterSet())
        return PasswordPolicy(rules: [
            withPassword(lengthInRange: 10...128, message: String(format: atLeast, 10)),
            AtLeastRule(minimum: 3, rules: [
                    withPassword(havingCharactersIn: .lowercaseLetterCharacterSet(), message: lowercase),
                    withPassword(havingCharactersIn: .uppercaseLetterCharacterSet(), message: upperCase),
                    withPassword(havingCharactersIn: .decimalDigitCharacterSet(), message: numbers),
                    withPassword(havingCharactersIn: specialCharacterSet, message: specialCharacters),
            ], message: String(format: containAtLeast, 3, 4)),
            withPassword(havingMaxConsecutiveRepeats: 2, message: String(format: noMoreThanSimilar, 2, "aaa"))
            ])
    }

}
