//
//  YCAlbumListBaseCell.h
//  YCPictureManager
//
//  Created by 余超 on 2020/11/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YCAlbumListBaseCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *nameL;
@property (nonatomic, strong) UILabel *countL;
@end

NS_ASSUME_NONNULL_END
