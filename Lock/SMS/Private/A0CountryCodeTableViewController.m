// A0CountryCodeTableViewController.m
//
// Copyright (c) 2014 Auth0 (http://auth0.com)
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

#import "A0CountryCodeTableViewController.h"
#import "A0Theme.h"

static NSString *CellIdentifier = @"CountryCell";
static NSString *CountryCode = @"Code";
static NSString *CountryDialCode = @"DialCode";
static NSString *CountryName = @"Name";

@interface A0CountryCodeTableViewController () <UISearchResultsUpdating>
@property (strong, nonatomic) NSArray *countryCodes;
@property (strong, nonatomic) NSArray *filteredCountryCodes;
@property (strong, nonatomic) UISearchController *searchController;
@end

@interface A0CountryCell : UITableViewCell

@end

@implementation A0CountryCodeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if (NSClassFromString(@"UISearchController")) {
        UISearchController *controller = [[UISearchController alloc] initWithSearchResultsController:nil];
        controller.searchResultsUpdater = self;
        controller.dimsBackgroundDuringPresentation = NO;
        controller.hidesNavigationBarDuringPresentation = NO;
        self.definesPresentationContext = YES;
        controller.searchBar.placeholder = NSLocalizedStringFromTable(@"Search", @"Auth0", @"Search Country Placeholder");
        self.navigationItem.titleView = controller.searchBar;
        self.searchController = controller;
        controller.searchBar.tintColor = [[A0Theme sharedInstance] colorForKey:A0ThemeCloseButtonTintColor];
    }

    NSArray *codes = [A0CountryCodeTableViewController loadCountryCodes];
    codes = [codes sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *left, NSDictionary *right) {
        NSComparisonResult order = NSOrderedAscending;
        if ([self.defaultCountry isEqualToString:right[CountryCode]]) {
            order = NSOrderedDescending;
        }
        return order;
    }];
    NSLocale *locale = [NSLocale currentLocale];
    NSMutableArray *countryCodes = [@[] mutableCopy];
    [codes enumerateObjectsUsingBlock:^(NSDictionary *country, NSUInteger idx, BOOL *stop) {
        NSMutableDictionary *countryWithName = [country mutableCopy];
        NSString *name = [locale displayNameForKey:NSLocaleCountryCode value:country[CountryCode]];
        if(name) {
            countryWithName[CountryName] = name;
        } else {
            countryWithName[CountryName] = [[NSLocale localeWithLocaleIdentifier:@"en_US"] displayNameForKey:NSLocaleCountryCode value:country[CountryCode]];
        }
        [countryCodes addObject:countryWithName];
    }];
    self.countryCodes = countryCodes;

    [self.tableView registerClass:[A0CountryCell class] forCellReuseIdentifier:CellIdentifier];
}

+ (NSString *)dialCodeForCountryWithCode:(NSString *)code {
    NSArray *codes = [self loadCountryCodes];
    __block NSDictionary *found;
    [codes enumerateObjectsUsingBlock:^(NSDictionary *country, NSUInteger idx, BOOL *stop) {
        *stop = [country[CountryCode] isEqualToString:code];
        if (*stop) {
            found = country;
        }
    }];
    return [self dialCodeForCountry:found];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.hidesBackButton = YES;
}


#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchString = searchController.searchBar.text;
    self.filteredCountryCodes = [self.countryCodes filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSDictionary *country, NSDictionary *bindings) {
        NSRange nameRange = [country[CountryName] rangeOfString:searchString options:NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch];
        NSRange codeRange = [country[CountryCode] rangeOfString:searchString options:NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch];
        return nameRange.location != NSNotFound || codeRange.location != NSNotFound;
    }]];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.searchController.active && self.searchController.searchBar.text.length != 0) {
        return self.filteredCountryCodes.count;
    }
    return [[self countryCodesSourceForTableView:tableView] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSArray *countries;
    if (self.searchController.active && self.searchController.searchBar.text.length != 0) {
        countries = self.filteredCountryCodes;
    } else {
        countries = [self countryCodesSourceForTableView:tableView];
    }
    NSDictionary *country = countries[indexPath.row];
    cell.textLabel.text = country[CountryName];
    cell.detailTextLabel.text = country[CountryDialCode];
    if ([self.defaultCountry isEqualToString:country[CountryCode]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *countries;
    if (self.searchController.active && self.searchController.searchBar.text.length != 0) {
        countries = self.filteredCountryCodes;
    } else {
        countries = [self countryCodesSourceForTableView:tableView];
    }
    NSDictionary *country = countries[indexPath.row];
    if (self.onCountrySelect) {
        self.onCountrySelect(country[CountryCode], [A0CountryCodeTableViewController dialCodeForCountry:country]);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Utility methods

+ (NSString *)dialCodeForCountry:(NSDictionary *)country {
    if ([country[CountryCode] isEqualToString:@"AR"]) {
        return [country[CountryDialCode] stringByAppendingString:@" 9 "];
    } else {
        return country[CountryDialCode];
    }
}

- (NSArray *)countryCodesSourceForTableView:(UITableView *)tableView {
    NSArray *countries = self.tableView == tableView ? self.countryCodes : self.filteredCountryCodes;
    return countries;
}

+ (NSArray *)loadCountryCodes {
    NSString *resourceBundlePath = [[NSBundle bundleForClass:A0CountryCodeTableViewController.class] pathForResource:@"Auth0" ofType:@"bundle"];
    NSBundle *resourceBundle = [NSBundle bundleWithPath:resourceBundlePath];
    NSString *plistPath = [resourceBundle pathForResource:@"CountryCodes" ofType:@"plist"];
    return [NSArray arrayWithContentsOfFile:plistPath];
}

@end

@implementation A0CountryCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    return [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
}

@end
