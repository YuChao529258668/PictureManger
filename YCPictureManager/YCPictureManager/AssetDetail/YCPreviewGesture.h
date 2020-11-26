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

//@class YCAssetPreviewVC;
@class YCAssetPreviewCell;



@interface YCPreviewGesture : NSObject <UIGestureRecognizerDelegate>

@property (nonatomic, weak) YCAssetPreviewVC *vc;
@property (nonatomic, weak) UIView *view;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, weak) id<YCAssetPreviewVCDelegate> delegate;

@property (nonatomic, assign) BOOL isPanDown; // 标记上滑还是下滑
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UIImageView *snapView;

@property (nonatomic, strong) PHFetchResult *fetchResult;
@property (nonatomic, strong) PHAsset *selectedAsset;

@end

