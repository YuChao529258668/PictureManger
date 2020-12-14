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
@property (nonatomic, strong) PHAsset *asset; // 外面传进来,滑动 collection view 不会变
@property (nonatomic, assign) NSInteger index;

@property (nonatomic, strong) PHFetchResult *fetchResult;
@property (nonatomic, strong) NSMutableArray<PHAsset *> *assetArray; // 用于显示
@property (nonatomic, strong) NSMutableArray<PHAsset *> *selectArray; // 选中的图片

@property (nonatomic, weak) id<YCAssetPreviewVCDelegate> delegate;
@property (nonatomic, strong) PHAsset *selectedAsset; // 手势作用的 asset，默认为空。可以通过 getCurrentShowAsset 获取当前显示的 asset

@property (nonatomic, strong) UIToolbar *bottomBar;

- (void)updateSelectCount:(NSInteger)count;

@end


// 协议
@protocol YCAssetPreviewVCDelegate <NSObject>

@required
- (void)panDownAsset:(PHAsset *)asset;
- (void)panDownAssetFinish:(PHAsset *)asset;
- (UIView *)targetViewForAsset:(PHAsset *)asset;
@end

NS_ASSUME_NONNULL_END
