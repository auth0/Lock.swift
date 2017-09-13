// Matchers.swift
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
import Nimble
@testable import Lock

func beExpandedMode(isLogin login: Bool = true) -> Predicate<AuthCollectionView.Mode> {
        return Predicate<AuthCollectionView.Mode>.define("be with expanded mode with isLogin: <\(login)>") { expression, failureMessage -> PredicateResult in
        if let actual = try expression.evaluate(), case .expanded(let isLogin) = actual, isLogin == login {
            return PredicateResult(status: .matches, message: failureMessage)
        }
         return PredicateResult(status: .doesNotMatch, message: failureMessage)
    }
}

func beCompactMode() -> Predicate<AuthCollectionView.Mode> {
    return Predicate<AuthCollectionView.Mode>.define("be with compact mode") { expression, failureMessage -> PredicateResult in
        if let actual = try expression.evaluate(), case .compact = actual {
            return PredicateResult(status: .matches, message: failureMessage)
        }
        return PredicateResult(status: .doesNotMatch, message: failureMessage)
    }
}

func beError(error: LocalizableError) -> Predicate<LocalizableError> {
    return Predicate<LocalizableError>.define("be error with message \(error.localizableMessage)") { expression, failureMessage -> PredicateResult in
        if let actual = try expression.evaluate(), actual.localizableMessage == error.localizableMessage && actual.userVisible == error.userVisible {
            return PredicateResult(status: .matches, message: failureMessage)
        }
        return PredicateResult(status: .doesNotMatch, message: failureMessage)
    }
}


func beErrorResult() -> Predicate<Result> {
    return Predicate<Result>.define("be an error result") { expression, failureMessage -> PredicateResult in
        if let actual = try expression.evaluate(), case .error = actual {
            return PredicateResult(status: .matches, message: failureMessage)
        }
        return PredicateResult(status: .doesNotMatch, message: failureMessage)
    }
}

func beExcellentPassword() -> Predicate<[String: Any]> {
    return Predicate<[String: Any]>.define("be an excellent strength password recipe") { expression, failureMessage -> PredicateResult in
        if let actual = try expression.evaluate(),
            actual[AppExtensionGeneratedPasswordMinLengthKey] as? String == "10",
            actual[AppExtensionGeneratedPasswordMaxLengthKey] as? String == "128",
            actual[AppExtensionGeneratedPasswordRequireDigitsKey] as? Bool == true,
            actual[AppExtensionGeneratedPasswordRequireSymbolsKey] as? Bool == true
        {
            return PredicateResult(status: .matches, message: failureMessage)
        }
        return PredicateResult(status: .doesNotMatch, message: failureMessage)    }
}
