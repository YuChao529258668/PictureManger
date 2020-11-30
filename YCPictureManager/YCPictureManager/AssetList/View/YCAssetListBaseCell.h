//
//  YCAssetListBaseCell.h
//  YCPictureManager
//
//  Created by 余超 on 2020/11/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YCAssetListBaseCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *infoL;
@property (nonatomic, strong) UIView *blurView;
@end

NS_ASSUME_NONNULL_END
