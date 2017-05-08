// LockUITests.swift
//
// Copyright (c) 2017 Auth0 (http://auth0.com)
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

import XCTest
@testable import Lock

class LockUITests: XCTestCase {

    let app = XCUIApplication()

    override func setUp() {
        super.setUp()
        setupSnapshot(app)
        app.launch()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testClassic() {
        
        let app = XCUIApplication()

        app.buttons["LOGIN WITH CDN CLASSIC"].tap()
        snapshot("A1-Lock-Classic-Database-Social-Login")

        app.textFields["Email"].tap()
        app.textFields["Email"].typeText("foo")
        snapshot("A2-Lock-Classic-Database-Social-Login-Input-Error")

        app.scrollViews.otherElements.buttons["Sign Up"].tap()
        snapshot("A3-Lock-Classic-Database-Social-Signup")

        app.textFields["Email"].tap()
        app.textFields["Email"].typeText("foo")
        snapshot("A4-Lock-Classic-Database-Social-Signup-Input-Error")

        app.scrollViews.otherElements.buttons["Log In"].tap()
        app.scrollViews.otherElements.buttons["Don’t remember your password?"].tap()
        snapshot("A5-Lock-Classic-Database-Social-Forgot-Password")

        app.scrollViews.otherElements.containing(.staticText, identifier:"Reset Password").children(matching: .button).element(boundBy: 0).tap()
        app.textFields["Email"].tap()
        app.textFields["Email"].typeText("foo@bar.com")
        snapshot("A6-Lock-Classic-Database-Social-Enterprise")

        app.scrollViews.otherElements.buttons["LOG IN  ￼"].tap()
        snapshot("A7-Lock-Classic-Database-Social-Enterprise-ActiveAuth")

    }

    func testClassicCustom() {

        let app = XCUIApplication()

        app.buttons["LOGIN WITH CDN CUSTOM STYLE"].tap()
        snapshot("A1B-Lock-Classic-Custom-Database-Social-Login")

        app.textFields["Email"].tap()
        app.textFields["Email"].typeText("foo")
        snapshot("A2B-Lock-Classic-Custom-Database-Social-Login-Input-Error")

        app.scrollViews.otherElements.buttons["Sign Up"].tap()
        snapshot("A3B-Lock-Classic-Custom-Database-Social-Signup")

        app.textFields["Email"].tap()
        app.textFields["Email"].typeText("foo")
        snapshot("A4B-Lock-Classic-Custom-Database-Social-Signup-Input-Error")

        app.scrollViews.otherElements.buttons["Log In"].tap()
        app.scrollViews.otherElements.buttons["Don’t remember your password?"].tap()
        snapshot("A5B-Lock-Classic-Custom-Database-Social-Forgot-Password")

        app.scrollViews.otherElements.containing(.staticText, identifier:"Reset Password").children(matching: .button).element(boundBy: 0).tap()
        app.textFields["Email"].tap()
        app.textFields["Email"].typeText("foo@bar.com")
        snapshot("A6B-Lock-Classic-Custom-Database-Social-Enterprise")

        app.scrollViews.otherElements.buttons["LOG IN  ￼"].tap()
        snapshot("A7B-Lock-Classic-Custom-Database-Social-Enterprise-ActiveAuth")
    }

    func testPasswordless() {

        let app = XCUIApplication()

        app.buttons["LOGIN WITH CDN PASSWORDLESS"].tap()
        snapshot("B1-Lock-Passwordless")

        app.scrollViews.otherElements.staticTexts["United States"].tap()
        snapshot("B2-Lock-Passwordless-Country")
    }

    func testPasswordlessCustom() {

        let app = XCUIApplication()

        app.buttons["LOGIN WITH CDN PASSWORDLESS CUSTOM STYLE"].tap()
        snapshot("B1C-Lock-Passwordless-Custom")

        app.scrollViews.otherElements.staticTexts["United States"].tap()
        snapshot("B2C-Lock-Passwordless-Country")
    }

}
