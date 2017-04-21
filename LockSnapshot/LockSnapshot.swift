// LockSnapshot.swift
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

class LockSnapshot: XCTestCase {

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
        snapshot("1A-Lock-Classic-Database-Social-Login")

        app.textFields["Email"].tap()
        app.textFields["Email"].typeText("foo")
        snapshot("2A-Lock-Classic-Database-Social-Login-Input-Error")

        app.scrollViews.otherElements.buttons["Sign Up"].tap()
        snapshot("3A-Lock-Classic-Database-Social-Signup")

        app.textFields["Email"].tap()
        app.textFields["Email"].typeText("foo")
        snapshot("4A-Lock-Classic-Database-Social-Signup-Input-Error")
    }

    func testClassicCustom() {

        let app = XCUIApplication()

        app.buttons["LOGIN WITH CUSTOM STYLE"].tap()
        snapshot("1B-Lock-Classic-Custom-Database-Social-Login")

        app.textFields["Email"].tap()
        app.textFields["Email"].typeText("foo")
        snapshot("2B-Lock-Classic-Custom-Database-Social-Login-Input-Error")

        app.scrollViews.otherElements.buttons["Sign Up"].tap()
        snapshot("3B-Lock-Classic-Custom-Database-Social-Signup")

        app.textFields["Email"].tap()
        app.textFields["Email"].typeText("foo")
        snapshot("4B-Lock-Classic-Custom-Database-Social-Signup-Input-Error")
    }

}
