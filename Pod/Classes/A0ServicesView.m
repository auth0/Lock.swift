//
//  A0ServicesView.m
//  Pods
//
//  Created by Hernan Zalazar on 6/30/14.
//
//

#import "A0ServicesView.h"

#define kCellIdentifier @"ServiceCell"
#define kServiceCount 1

@interface A0ServicesView () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@end

@implementation A0ServicesView

- (void)awakeFromNib {
    [super awakeFromNib];

    UINib *cellNib = [UINib nibWithNibName:@"A0ServiceCollectionViewCell" bundle:nil];
    [self.serviceCollectionView registerNib:cellNib forCellWithReuseIdentifier:kCellIdentifier];
}

#pragma mark - UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}


#pragma mark - UICollectionViewDelegateFlowLayout

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    NSInteger numberOfCells = kServiceCount;
    CGFloat cellsWidth = (numberOfCells * 40) + MAX(0, (numberOfCells - 1) * 10);

    NSInteger edgeInsets = (self.frame.size.width - cellsWidth) / 2;

    return UIEdgeInsetsMake(0, edgeInsets, 0, edgeInsets);
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return kServiceCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
    return cell;
}

@end
