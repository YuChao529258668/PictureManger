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

- (void)didEndDisplaying;

@end

NS_ASSUME_NONNULL_END
