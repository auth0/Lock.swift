// CountryTableViewController.swift
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

import UIKit

class CountryTableViewController: UITableViewController, Stylable {

    var dataStore: CountryCodes
    let cellReuseIdentifier = "CountryCodeCell"
    var search: UISearchController

    var onDidSelect: (CountryCode) -> Void = { _ in }

    private var cellTextColor: UIColor = Style.Auth0.inputTextColor
    private var cellBackgroundColor: UIColor = Style.Auth0.backgroundColor

    init(withData dataStore: CountryCodes, onSelect: @escaping (CountryCode) -> Void) {
        self.dataStore = dataStore
        self.search = UISearchController(searchResultsController: nil)
        self.onDidSelect = onSelect
        super.init(style: .grouped)

        search.searchResultsUpdater = self
        search.dimsBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Search".i18n(key: "com.auth0.lock.passwordless.sms.country.search", comment: "CountryCodes TableView searchbar placeholder")
        definesPresentationContext = true
        tableView.tableHeaderView = search.searchBar

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action:#selector(close))
        navigationItem.title = "Select your Country".i18n(key: "com.auth0.lock.passwordless.sms.country.header", comment: "Country tableview navigation header")

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func close() {
        self.dismiss(animated: true, completion:  nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataStore.filteredData().count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellData = dataStore.filteredData()[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) ??
            UITableViewCell(style: .value1, reuseIdentifier: cellReuseIdentifier)
        cell.backgroundColor = self.cellBackgroundColor
        cell.textLabel?.textColor = self.cellTextColor
        cell.detailTextLabel?.textColor = self.cellTextColor.withAlphaComponent(0.50)
        cell.textLabel?.text = String(format: "%1$@".i18n(key: "com.auth0.passwordless.sms.country.cell.label", comment: "CountryCodes TableViewCell label %@{localizedName}"),
                                      cellData.localizedName)
        cell.detailTextLabel?.text = String(format: "%1$@".i18n(key: "com.auth0.passwordless.sms.country.cell.detail", comment: "CountryCodes TableViewCell detail %@{phoneCode}"),
                                            cellData.phoneCode)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellData = dataStore.filteredData()[indexPath.row]
        self.onDidSelect(cellData)
        self.search.dismiss(animated: false)
        self.dismiss(animated: true)
    }

    func apply(style: Style) {
        self.navigationController!.navigationBar.barTintColor = style.headerColor
        self.navigationController!.navigationBar.tintColor = style.titleColor
        self.search.searchBar.searchBarStyle = style.searchBarStyle
        self.tableView.separatorColor = style.inputBorderColor
        self.cellTextColor = style.inputTextColor
        self.tableView.backgroundColor = style.backgroundColor
        self.cellBackgroundColor = style.backgroundColor
    }
}

extension CountryTableViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        dataStore.filter = searchText
        self.tableView.reloadData()
    }
}
