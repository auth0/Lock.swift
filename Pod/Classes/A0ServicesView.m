//
//  A0ServicesView.m
//  Pods
//
//  Created by Hernan Zalazar on 6/30/14.
//
//

#import "A0ServicesView.h"

#import "A0ServiceCollectionViewCell.h"

#define UIColorFromRGBA(rgbValue, alphaValue) ([UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 \
green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0 \
blue:((float)(rgbValue & 0xFF)) / 255.0 \
alpha:alphaValue])

#define UIColorFromRGB(rgbValue) (UIColorFromRGBA((rgbValue), 1.0))

#define kCellIdentifier @"ServiceCell"

@interface A0ServicesView () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) NSDictionary *services;

@end

@implementation A0ServicesView

- (void)awakeFromNib {
    [super awakeFromNib];

    UINib *cellNib = [UINib nibWithNibName:@"A0ServiceCollectionViewCell" bundle:nil];
    [self.serviceCollectionView registerNib:cellNib forCellWithReuseIdentifier:kCellIdentifier];
    self.services = [A0ServicesView servicesDictionary];
}

#pragma mark - UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}


#pragma mark - UICollectionViewDelegateFlowLayout

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    NSInteger numberOfCells = self.serviceNames.count;
    CGFloat cellsWidth = (numberOfCells * 40) + MAX(0, (numberOfCells - 1) * 10);

    NSInteger edgeInsets = (self.frame.size.width - cellsWidth) / 2;

    return UIEdgeInsetsMake(0, edgeInsets, 0, edgeInsets);
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.serviceNames.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    A0ServiceCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
    NSString *serviceName = self.serviceNames[indexPath.row];
    NSDictionary *serviceInfo = self.services[serviceName];
    UIColor *background = [A0ServicesView colorFromString:serviceInfo[@"background_color"]];
    UIColor *selectedBackground = [A0ServicesView colorFromString:serviceInfo[@"selected_background_color"]];
    cell.backgroundColor = background;
    cell.selectedBackgroundView.backgroundColor = selectedBackground;
    NSString *imageName = [@"Auth0.bundle" stringByAppendingPathComponent:serviceInfo[@"icon_name"]];
    cell.serviceIcon.image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    cell.serviceIcon.tintColor = [UIColor whiteColor];
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
