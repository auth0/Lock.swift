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
    var counter: Int = 0
    var prefix: String = ""

    override func setUp() {
        super.setUp()
        setupSnapshot(app)
        app.launch()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testClassicScreenshots() {
        // 3 Social, Database, Password Policy Fair, Enterprise AD `bar.com` with ActiveAuth
        let app = XCUIApplication()
        self.prefix = "A"
        self.counter = 0

        app.buttons["LOGIN WITH CDN CLASSIC"].tap()
        screenshot("Database Social Login")

        app.textFields["Email"].tap()
        app.textFields["Email"].clearAndEnter(text: "foo")
        screenshot("Database Login Email Input Error")

        app.textFields["Email"].clearAndEnter(text: "foo@foobar.com")
        let passwordLoginSecureTextField = XCUIApplication().scrollViews.otherElements.secureTextFields["Password"]
        passwordLoginSecureTextField.tap()
        passwordLoginSecureTextField.clearAndEnter(text: " ")
        screenshot("Database Login Password Input Error")

        passwordLoginSecureTextField.clearAndEnter(text: "Password")
        XCUIApplication().scrollViews.otherElements.buttons["LOG IN  ￼"].tap()
        sleep(1)
        screenshot("Database Login Failed")

        sleep(3)
        app.scrollViews.otherElements/*@START_MENU_TOKEN@*/.buttons["Sign Up"]/*[[".segmentedControls.buttons[\"Sign Up\"]",".buttons[\"Sign Up\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        screenshot("Database Signup")

        app.textFields["Email"].tap()
        app.textFields["Email"].clearAndEnter(text: "foo")
        screenshot("Database Signup Input Error")

        let passwordSignupSecureTextField = XCUIApplication().scrollViews.otherElements.secureTextFields["Password"]
        passwordSignupSecureTextField.tap()
        screenshot("Database Social Password Policy Empty")

        passwordSignupSecureTextField.clearAndEnter(text: "test1")
        screenshot("Database Social Password Policy Validation")

        app.scrollViews.otherElements.buttons["Log In"].tap()
        app.scrollViews.otherElements.buttons["Don’t remember your password?"].tap()
        screenshot("Database Forgot Password")

        app.textFields["Email"].tap()
        app.textFields["Email"].clearAndEnter(text: "foo")
        screenshot("Database Forgot Password Email Error")

        app.textFields["Email"].clearAndEnter(text: "foo@foobar.com")
        XCUIApplication().scrollViews.otherElements.buttons["SEND EMAIL  ￼"].tap()
        screenshot("Database Forgot Password Send Email Success")

        sleep(3)
        app.textFields["Email"].tap()
        app.textFields["Email"].clearAndEnter(text: "foo@bar.com")
        screenshot("Database Enterprise SSO")

        app.scrollViews.otherElements.buttons["LOG IN  ￼"].tap()
        screenshot("Database Enterprise ActiveAuth")
    }

    func testPasswordlessScreenshots() {
        // Passwordless SMS
        let app = XCUIApplication()
        self.prefix = "Y"
        self.counter = 0

        app.buttons["LOGIN WITH CDN PASSWORDLESS"].tap()
        screenshot("Passwordless SMS")

        app.scrollViews.otherElements.staticTexts["United States"].tap()
        screenshot("Passwordless SMS Country Table")

        let tablesQuery = app.tables
        tablesQuery.searchFields["Search"].tap()
        app.searchFields["Search"].typeText("united kingdom")
        screenshot("Passwordless SMS Country Table Search")

        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["United Kingdom"]/*[[".cells.staticTexts[\"United Kingdom\"]",".staticTexts[\"United Kingdom\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()

        let phoneNumberTextField = app.scrollViews.otherElements.textFields["Phone Number"]
        phoneNumberTextField.tap()
        phoneNumberTextField.clearAndEnter(text: "07")
        screenshot("Passwordless SMS Error")

        phoneNumberTextField.clearAndEnter(text: "07966000000")
        let button = app.scrollViews.children(matching: .other).element(boundBy: 1).children(matching: .other).element(boundBy: 1).children(matching: .button).element
        button.tap()
        screenshot("Passwordless SMS Login Success")

        sleep(3)
        let codeTextField = app.scrollViews.otherElements.textFields["Code"]
        codeTextField.tap()
        codeTextField.typeText("12345")
        app.scrollViews.otherElements.buttons["ic submit"].tap()
        screenshot("Passwordless SMS Code Failed")
    }

    private func screenshot(_ description: String) {
        self.counter += 1
        snapshot("\(prefix)\(String(format: "%02d", counter))-\(description)")
    }

}

extension XCUIElement {
    func clearAndEnter(text: String) {
        guard let stringValue = self.value as? String else {
            XCTFail("Tried to clear and enter text into a non string value")
            return
        }

        self.tap()
        let deleteString = stringValue.characters.map { _ in XCUIKeyboardKeyDelete }.joined(separator: "")
        self.typeText(deleteString)
        self.typeText(text)
    }
}
