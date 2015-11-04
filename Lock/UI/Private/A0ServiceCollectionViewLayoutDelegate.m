// A0ServiceCollectionViewLayoutDelegate.m
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

#import "A0ServiceCollectionViewLayoutDelegate.h"

@implementation A0ServiceCollectionViewLayoutDelegate

- (instancetype)initWithServiceCount:(NSUInteger)serviceCount {
    self = [super init];
    if (self) {
        _serviceCount = serviceCount;
        _shouldScroll = serviceCount > 5;
    }
    return self;
}

#pragma mark - UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


#pragma mark - UICollectionViewDelegateFlowLayout

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    NSInteger numberOfCells = self.serviceCount;
    UIEdgeInsets insets;
    if (self.shouldScroll) {
        insets = UIEdgeInsetsZero;
    } else {
        UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)collectionViewLayout;
        CGFloat cellsWidth = (numberOfCells * layout.itemSize.width) + MAX(0, (numberOfCells - 1) * 5);
        NSInteger edgeInsets = (collectionView.frame.size.width - cellsWidth) / 2;
        insets = UIEdgeInsetsMake(0, edgeInsets, 0, edgeInsets);
    }
    return insets;
}

@end
