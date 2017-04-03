// UnrecoverableErrorPresenterSpec.swift

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

class UnrecoverableErrorPresenterSpec: QuickSpec {

    override func spec() {

        var presenter: UnrecoverableErrorPresenter!
        var navigator: MockNavigator!
        var error: UnrecoverableError!
        var view: UnrecoverableErrorView!
        var options: OptionBuildable!

        beforeEach {
            options = LockOptions()
            error = UnrecoverableError.connectionTimeout
            navigator = MockNavigator()
            presenter = UnrecoverableErrorPresenter(error: error, navigator: navigator, options: options)
            view = presenter.view as? UnrecoverableErrorView
        }

        describe("init") {

            it("should build UnrecoverableErrorView") {
                expect(presenter.view as? UnrecoverableErrorView).toNot(beNil())
            }

            context("retry error") {

                beforeEach {
                    presenter = UnrecoverableErrorPresenter(error: .connectionTimeout, navigator: navigator, options: options)
                    view = presenter.view as? UnrecoverableErrorView
                }

                it("should have relevant retry button title") {
                    expect(view.secondaryButton?.title?.contains("Retry")) == true
                }
            }

            context("support error with no page (default)") {

                beforeEach {
                    presenter = UnrecoverableErrorPresenter(error: .invalidClientOrDomain, navigator: navigator, options: options)
                    view = presenter.view as? UnrecoverableErrorView
                }

                it("should not display support button") {
                    expect(view.secondaryButton?.isHidden) == true
                }
            }

            context("support error with support page provided") {

                beforeEach {
                    options.supportPage = "http://auth0.com/docs"
                    presenter = UnrecoverableErrorPresenter(error: .invalidClientOrDomain, navigator: navigator, options: options)
                    view = presenter.view as? UnrecoverableErrorView
                }

                it("should have a support button title") {
                    expect(view.secondaryButton?.title?.contains("Contact")) == true
                }

                it("should have a visible support button") {
                    expect(view.secondaryButton?.isHidden) == false
                }
            }
        }

        describe("action") {

            context("retry error") {

                beforeEach {
                    presenter = UnrecoverableErrorPresenter(error: .connectionTimeout, navigator: navigator, options: options)
                    view = presenter.view as? UnrecoverableErrorView
                }

                it("should trigger retry on button press") {
                    view.secondaryButton?.onPress(view.secondaryButton!)
                    expect(navigator.route) == Route.root
                }
            }

            context("support error") {

                beforeEach {
                    presenter = UnrecoverableErrorPresenter(error: .invalidClientOrDomain, navigator: navigator, options: options)
                    view = presenter.view as? UnrecoverableErrorView
                }

                it("should not trigger retry on button press") {
                    view.secondaryButton?.onPress(view.secondaryButton!)
                    expect(navigator.route).to(beNil())
                }
            }
            
        }
        
    }
}
