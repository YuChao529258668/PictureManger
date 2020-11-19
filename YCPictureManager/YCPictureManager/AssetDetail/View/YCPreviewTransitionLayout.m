//
//  YCPreviewTransitionLayout.m
//  YCPictureManager
//
//  Created by 余超 on 2020/11/19.
//

#import "YCPreviewTransitionLayout.h"

@interface YCPreviewTransitionLayout ()
@property (nonatomic, strong) NSMutableArray<UICollectionViewLayoutAttributes *> *abs;
@end

@implementation YCPreviewTransitionLayout

- (CGSize)collectionViewContentSize {
    float width = [UIScreen mainScreen].bounds.size.width;
    NSInteger count = [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:0];

    return CGSizeMake(width * (count - 1), 0);
//    return CGSizeZero;
}

- (void)prepareLayout {
    NSLog(@"prepareLayout");
    NSInteger count = [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:0];
    self.abs = [NSMutableArray arrayWithCapacity:count];
    
    float x = 0;
    float width = [UIScreen mainScreen].bounds.size.width;
    float height = [UIScreen mainScreen].bounds.size.height;
    
    for (int i  = 0; i < count; i ++) {
        UICollectionViewLayoutAttributes *ab = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
        x = i * width;
        if (i >= self.indexPath.item) {
            x -= width * self.transitionProgress;
        }
        ab.frame = CGRectMake(x, 0, width, height);
        [self.abs addObject:ab];
    }
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset {
    NSLog(@"targetContentOffset %@", NSStringFromCGPoint(proposedContentOffset));
    return proposedContentOffset;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"layoutAttributesForItemAtIndexPath %ld", indexPath.item);
    UICollectionViewLayoutAttributes *ab = self.abs[indexPath.item];
    return ab;
}

- (NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSLog(@"layoutAttributesForElementsInRect: %@", NSStringFromCGRect(rect));

    NSMutableArray<UICollectionViewLayoutAttributes *> *array = [NSMutableArray array];
    NSInteger item = self.indexPath.item;
    
    if (item + 1 < self.abs.count) {
        [array addObject:self.abs[item + 1]];
        return array;
    }
    
    if (item - 1 >= 0) {
        [array addObject:self.abs[item - 1]];
        return array;
    }
    
    [array addObject:self.abs[item]];
    
//    return self.abs;
    return array;

}

@end
