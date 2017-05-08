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

private let lowercase = "Lower case letters (a-z)".i18n(key: "com.auth0.lock.error.password.lowercase_letters", comment: "Lowercase letters")
private let upperCase = "Upper case letters (A-Z)".i18n(key: "com.auth0.lock.error.password.uppercase_letters", comment: "Uppercase letters")
private let numbers = "Numbers (i.e. 0-9)".i18n(key: "com.auth0.lock.error.password.numbers", comment: "Numbers")
private let specialCharacters = "Special characters (e.g. !@#$%^&*)".i18n(key: "com.auth0.lock.error.password.special_characters", comment: "Special Characters")
private let containAtLeast = "Contain at least %d of the following %d types of characters:".i18n(key: "com.auth0.lock.error.password.contain_at_least", comment: "At least n groups")
private let shouldContain = "Should contain:".i18n(key: "com.auth0.lock.error.password.should_contain", comment: "N groups")
private let nonEmpty = "Non-empty password required".i18n(key: "com.auth0.lock.error.password.non_empty", comment: "Must no be empty")
private let atLeast = "At least %d characters in length".i18n(key: "com.auth0.lock.error.password.at_least_length", comment: "At least N characters")
private let noMoreThanSimilar = "No more than %1$d identical characters in a row (e.g., \"%2$@\" not allowed)".i18n(key: "com.auth0.lock.error.password.no_more_identical", comment: "No more than %@{count} identical characters in a row (e.g., \"%@{identical sample}\" not allowed)")

public struct PasswordPolicy {

    let name: String
    let rules: [Rule]

    enum Auth0: String {
        case none
        case low
        case fair
        case good
        case excellent
    }

    func on(_ password: String?) -> [RuleResult] {
        return rules.map { $0.evaluate(on: password) }
    }

    public static var none: PasswordPolicy {
        return PasswordPolicy(name: Auth0.none.rawValue, rules: [withPassword(lengthInRange: 1...Int.max, message: nonEmpty)])
    }

    public static var low: PasswordPolicy {
        let message = String(format: atLeast, 6)
        return PasswordPolicy(name: Auth0.low.rawValue, rules: [withPassword(lengthInRange: 6...Int.max, message: message)])
    }

    public static var fair: PasswordPolicy {
        return PasswordPolicy(name: Auth0.fair.rawValue, rules: [
            withPassword(lengthInRange: 8...Int.max, message: String(format: atLeast, 8)),
            AtLeastRule(minimum: 3, rules: [
                withPassword(havingCharactersIn: .lowercaseLetters, message: lowercase),
                withPassword(havingCharactersIn: .uppercaseLetters, message: upperCase),
                withPassword(havingCharactersIn: .decimalDigits, message: numbers)
                ], message: shouldContain)
            ])
    }

    public static var good: PasswordPolicy {
        var specialCharacterSet = CharacterSet.punctuationCharacters
        specialCharacterSet.formUnion(.symbols)
        return PasswordPolicy(name: Auth0.good.rawValue, rules: [
            withPassword(lengthInRange: 8...Int.max, message: String(format: atLeast, 8)),
            AtLeastRule(minimum: 3, rules: [
                withPassword(havingCharactersIn: .lowercaseLetters, message: lowercase),
                withPassword(havingCharactersIn: .uppercaseLetters, message: upperCase),
                withPassword(havingCharactersIn: .decimalDigits, message: numbers),
                withPassword(havingCharactersIn: specialCharacterSet, message: specialCharacters)
                ], message: String(format: containAtLeast, 3, 4))
            ])
    }

    public static var excellent: PasswordPolicy {
        var specialCharacterSet = CharacterSet.punctuationCharacters
        specialCharacterSet.formUnion(.symbols)
        return PasswordPolicy(name: Auth0.excellent.rawValue, rules: [
            withPassword(lengthInRange: 10...128, message: String(format: atLeast, 10)),
            AtLeastRule(minimum: 3, rules: [
                withPassword(havingCharactersIn: .lowercaseLetters, message: lowercase),
                withPassword(havingCharactersIn: .uppercaseLetters, message: upperCase),
                withPassword(havingCharactersIn: .decimalDigits, message: numbers),
                withPassword(havingCharactersIn: specialCharacterSet, message: specialCharacters)
                ], message: String(format: containAtLeast, 3, 4)),
            withPassword(havingMaxConsecutiveRepeats: 2, message: String(format: noMoreThanSimilar, 2, "aaa"))
            ])
    }

}

extension PasswordPolicy {
    func onePasswordRules() -> [String: Any] {
        // Excellent
        return [ AppExtensionGeneratedPasswordMinLengthKey: "10",
                 AppExtensionGeneratedPasswordMaxLengthKey: "128",
                 AppExtensionGeneratedPasswordRequireDigitsKey: true,
                 AppExtensionGeneratedPasswordRequireSymbolsKey: true ]
    }
}
