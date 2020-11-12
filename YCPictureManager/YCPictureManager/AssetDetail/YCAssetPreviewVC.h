//
//  YCAssetPreviewVC.h
//  YCPictureManager
//
//  Created by 余超 on 2020/11/12.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface YCAssetPreviewVC : UIViewController
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) PHFetchResult *fetchResult;
@end

NS_ASSUME_NONNULL_END
