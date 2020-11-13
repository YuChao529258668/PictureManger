//
//  YCAssetListBaseVC.h
//  YCPictureManager
//
//  Created by 余超 on 2020/11/11.
//

#import <UIKit/UIKit.h>
#import "YCAssetsManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface YCAssetListBaseVC : UIViewController
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) PHFetchResult *fetchResult;
@property (nonatomic, assign) CGSize imageSize;

@end

NS_ASSUME_NONNULL_END
