//
//  YCAssetListBaseVC.h
//  YCPictureManager
//
//  Created by 余超 on 2020/11/11.
//

#import <UIKit/UIKit.h>
#import "YCAssetListBaseCell.h"
#import "YCUtil.h"

NS_ASSUME_NONNULL_BEGIN

@interface YCAssetListBaseVC : UIViewController
@property (nonatomic, strong) UICollectionView *collectionView;


@property (nonatomic, strong) PHFetchResult *fetchResult;
@property (nonatomic, strong) PHFetchOptions *assetsOption;
@property (nonatomic, strong) PHCachingImageManager *imageManager;
@property (nonatomic, strong) PHImageRequestOptions *imageOption;
@property (nonatomic, assign) CGSize imageSize;

@end

NS_ASSUME_NONNULL_END
