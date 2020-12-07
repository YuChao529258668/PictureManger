//
//  YCAssetPreviewCell.h
//  YCPictureManager
//
//  Created by 余超 on 2020/11/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YCAssetPreviewCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UILabel *testL;

@property (nonatomic, strong) UITapGestureRecognizer *doubleTap;
@property (nonatomic, assign) float maxScale; // default is 4


- (void)didEndDisplaying;
- (void)setXOffset:(float)x;

@end

NS_ASSUME_NONNULL_END
