// BannerMessagePresenterSpec.swift
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

import Quick
import Nimble

@testable import Lock

class BannerMessagePresenterSpec: QuickSpec {

    override func spec() {

        var root: UIView!
        var presenter: BannerMessagePresenter!

        beforeEach {
            root = UIView(frame: .zero)
            presenter = BannerMessagePresenter(root: root, messageView: nil)
        }

        describe("message presenter") {

            it("should show success message") {
                let message = "I.O.U. a message"
                presenter.showSuccess(message)
                expect(presenter.messageView?.message) == message
                expect(presenter.messageView?.type) == .success
            }

            it("should show error message") {
                let error = CredentialAuthError.couldNotLogin
                presenter.showError(error)
                expect(presenter.messageView?.message) == error.localizableMessage
                expect(presenter.messageView?.type) == .failure
            }

            it("should hide message") {
                let error = CredentialAuthError.couldNotLogin
                presenter.showError(error)
                presenter.hideCurrent()
                expect(presenter.messageView).toEventually(beNil())
            }
        }

    }
}
