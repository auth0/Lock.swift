// ModalNavigiationControllerSpec.swift
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

class CountryTableViewControllerSpec: QuickSpec {

    override func spec() {

        let countryData = CountryCodes()

        describe("init") {

            it("should init with country data") {
                var controller: CountryTableViewController?
                controller = CountryTableViewController(withData: countryData, onSelect: ({ _ in }) )
                expect(controller).to(beAnInstanceOf(CountryTableViewController.self))
            }
        }

        describe("tableview data") {
            var controller: CountryTableViewController!
            var tableView: UITableView!

            beforeEach {
                controller = CountryTableViewController(withData: countryData, onSelect: ({ _ in }) )
                tableView = controller.tableView
            }

            it("should return cell count equal to datastore records") {
                expect(controller.tableView(tableView, numberOfRowsInSection: 0)) == 229
            }

            it("should return cell info for Argentina") {
                let index = IndexPath(item: 8, section: 0)
                expect(tableView.cellForRow(at: index)?.textLabel?.text) == "Argentina    +54"
            }


            describe("tableview action") {

                var countryCode: CountryCode?

                beforeEach {
                    countryCode = nil
                    controller = CountryTableViewController(withData: countryData, onSelect: ({ _ in }) )
                    controller.onDidSelect = { countryCode = $0 }
                    tableView = controller.tableView
                }

                it("should select cell and return countryInfo") {
                    let index = IndexPath(item: 9, section: 0)
                    tableView.delegate?.tableView!(tableView, didSelectRowAt: index)
                    expect(countryCode).toNot(beNil())
                }

            }
        }
        
    }
}
