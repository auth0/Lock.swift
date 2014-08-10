//
//  A0ServicesView.m
//  Pods
//
//  Created by Hernan Zalazar on 6/30/14.
//
//

#import "A0ServicesView.h"
#import "A0Strategy.h"
#import "A0ServiceCollectionViewCell.h"
#import "A0SocialAuthenticator.h"
#import "UIButton+A0SolidButton.h"
#import "A0ServiceTableViewCell.h"

#define UIColorFromRGBA(rgbValue, alphaValue) ([UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 \
green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0 \
blue:((float)(rgbValue & 0xFF)) / 255.0 \
alpha:alphaValue])

#define UIColorFromRGB(rgbValue) (UIColorFromRGBA((rgbValue), 1.0))

#define kCellIdentifier @"ServiceCell"

@interface A0ServicesView () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDataSource>

@property (strong, nonatomic) NSDictionary *services;

@end

@implementation A0ServicesView

- (void)awakeFromNib {
    [super awakeFromNib];

    if (self.serviceCollectionView) {
        UINib *cellNib = [UINib nibWithNibName:@"A0ServiceCollectionViewCell" bundle:nil];
        [self.serviceCollectionView registerNib:cellNib forCellWithReuseIdentifier:kCellIdentifier];
    }
    if (self.serviceTableView) {
        UINib *cellNib = [UINib nibWithNibName:@"A0ServiceTableViewCell" bundle:nil];
        [self.serviceTableView registerNib:cellNib forCellReuseIdentifier:kCellIdentifier];
    }
    self.services = [A0ServicesView servicesDictionary];
}

- (void)triggerAuth:(UIButton *)sender {
    if (self.authenticateBlock) {
        self.authenticateBlock(sender.tag);
    }
}

- (CGRect)rectToKeepVisibleInView:(UIView *)view {
    return CGRectZero;
}

- (void)hideKeyboard {}

- (void)showInProgress {}

- (void)hideInProgress {}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.availableServicesCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *serviceName = self.nameBlock ? self.nameBlock(indexPath.row) : nil;
    NSDictionary *serviceInfo = self.services[serviceName];
    UIColor *background = [A0ServicesView colorFromString:serviceInfo[@"background_color"]];
    UIColor *selectedBackground = [A0ServicesView colorFromString:serviceInfo[@"selected_background_color"]];
    A0ServiceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    [cell configureWithBackground:background highlighted:selectedBackground symbol:serviceInfo[@"icon_character"] name:serviceName];
    [cell.button addTarget:self action:@selector(triggerAuth:) forControlEvents:UIControlEventTouchUpInside];
    cell.button.tag = indexPath.row;
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


#pragma mark - UICollectionViewDelegateFlowLayout

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    NSInteger numberOfCells = self.availableServicesCount;
    CGFloat cellsWidth = (numberOfCells * 40) + MAX(0, (numberOfCells - 1) * 10);

    NSInteger edgeInsets = (self.frame.size.width - cellsWidth) / 2;

    return UIEdgeInsetsMake(0, edgeInsets, 0, edgeInsets);
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.availableServicesCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    A0ServiceCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
    NSString *serviceName = self.nameBlock ? self.nameBlock(indexPath.item) : nil;
    NSDictionary *serviceInfo = self.services[serviceName];
    UIColor *background = [A0ServicesView colorFromString:serviceInfo[@"background_color"]];
    UIColor *selectedBackground = [A0ServicesView colorFromString:serviceInfo[@"selected_background_color"]];
    cell.serviceButton.titleLabel.font = [UIFont fontWithName:@"connections" size:14.0f];
    cell.serviceButton.titleLabel.tintColor = [UIColor whiteColor];
    [cell.serviceButton setTitle:serviceInfo[@"icon_character"] forState:UIControlStateNormal];
    [cell.serviceButton setBackgroundColor:background forState:UIControlStateNormal];
    [cell.serviceButton setBackgroundColor:selectedBackground forState:UIControlStateHighlighted];
    [cell.serviceButton addTarget:self action:@selector(triggerAuth:) forControlEvents:UIControlEventTouchUpInside];
    cell.serviceButton.tag = indexPath.item;
    return cell;
}

#pragma mark - Utility methods

+ (UIColor *)colorFromString:(NSString *)hexString {
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    unsigned hex;
    BOOL success = [scanner scanHexInt:&hex];

    if (!success) return nil;
    if ([hexString length] <= 6) {
        return UIColorFromRGB(hex);
    } else {
        unsigned color = (hex & 0xFFFFFF00) >> 8;
        CGFloat alpha = 1.0 * (hex & 0xFF) / 255.0;
        return UIColorFromRGBA(color, alpha);
    }
}

+ (NSDictionary *)servicesDictionary {
    NSString *resourceBundlePath = [[NSBundle mainBundle] pathForResource:@"Auth0" ofType:@"bundle"];
    NSBundle *resourceBundle = [NSBundle bundleWithPath:resourceBundlePath];
    NSString *plistPath = [resourceBundle pathForResource:@"Services" ofType:@"plist"];
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    return dictionary;
}
@end
