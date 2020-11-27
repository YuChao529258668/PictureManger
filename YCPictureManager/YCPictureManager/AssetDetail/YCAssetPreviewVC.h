//
//  YCAssetPreviewVC.h
//  YCPictureManager
//
//  Created by 余超 on 2020/11/12.
//

#import <UIKit/UIKit.h>
#import "YCAssetsManager.h"

NS_ASSUME_NONNULL_BEGIN

@protocol YCAssetPreviewVCDelegate;



@interface YCAssetPreviewVC : UIViewController
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, assign) NSInteger index;

@property (nonatomic, strong) PHFetchResult *fetchResult;
@property (nonatomic, strong) NSMutableArray<PHAsset *> *assetArray; // 用于显示
@property (nonatomic, strong) NSMutableArray<PHAsset *> *selectArray; // 选中的图片

@property (nonatomic, weak) id<YCAssetPreviewVCDelegate> delegate;
@property (nonatomic, strong) PHAsset *selectedAsset;

@end


// 协议
@protocol YCAssetPreviewVCDelegate <NSObject>

@required
- (void)panDownAsset:(PHAsset *)asset;
- (void)panDownAssetFinish:(PHAsset *)asset;
- (UIView *)targetViewForAsset:(PHAsset *)asset;
@end

NS_ASSUME_NONNULL_END
