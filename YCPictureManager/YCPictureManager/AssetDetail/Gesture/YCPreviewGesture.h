//
//  YCPreviewGesture.h
//  YCPictureManager
//
//  Created by 余超 on 2020/11/26.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "YCAssetPreviewVC.h"
#import "YCAssetPreviewCell.h"
#import "UIImageView+YCImageView.h"
#import "YCUtil.h"


@interface YCPreviewGesture : NSObject <UIGestureRecognizerDelegate>

@property (nonatomic, weak) YCAssetPreviewVC *vc;
@property (nonatomic, weak) UIView *view;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, weak) id<YCAssetPreviewVCDelegate> delegate;

@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) PHFetchResult *fetchResult;
@property (nonatomic, strong) NSMutableArray<PHAsset *> *assetArray; // 用于显示
@property (nonatomic, strong) NSMutableArray<PHAsset *> *selectArray; // 选中的图片
@property (nonatomic, strong) PHAsset *selectedAsset;
@property (nonatomic, strong) NSIndexPath *selectIndexPath;
@property (nonatomic, weak) UIImageView *selectImageView;

@property (nonatomic, assign) BOOL isPanDown; // 标记上滑还是下滑
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UIView *snapView;


@end

