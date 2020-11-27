//
//  YCAssetsManager.h
//  YCPictureManager
//
//  Created by 余超 on 2020/11/12.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import <PhotosUI/PHPhotoLibrary+PhotosUISupport.h>

NS_ASSUME_NONNULL_BEGIN

@interface YCAssetsManager : NSObject

+ (instancetype)shareManager;


#pragma mark - Asset

+ (PHFetchResult<PHAsset *> *)fetchLowAssets;
+ (PHFetchResult<PHAsset *> *)fetchLowAssetsWithCount:(NSUInteger)count;

#pragma mark - Image

+ (PHImageRequestID)requestLowImage:(PHAsset *)asset size:(CGSize)targetSize handler:(void (^)(UIImage *_Nullable result, NSDictionary *_Nullable info))resultHandler;

+ (PHImageRequestID)requestHighImage:(PHAsset *)asset size:(CGSize)targetSize handler:(void (^)(UIImage *_Nullable result, BOOL isLow, PHAsset *asset, NSDictionary *_Nullable info))resultHandler;

+ (PHImageRequestID)requestImageForAsset:(PHAsset *)asset size:(CGSize)targetSize contentMode:(PHImageContentMode)contentMode options:(nullable PHImageRequestOptions *)options handler:(void (^)(UIImage *_Nullable result, BOOL isLow, PHAsset *asset, NSDictionary *_Nullable info))resultHandler;



#pragma mark - AssetCollection

+ (PHFetchResult<PHAssetCollection *> *)fetchAssetCollections;
+ (PHAsset *)fetchFirstAssetInCollection:(PHAssetCollection *)collection;
+ (PHFetchResult<PHAsset *> *)fetchAssetsInCollection:(PHAssetCollection *)collection;

#pragma mark - Change

+ (void)deleteAssets:(id<NSFastEnumeration>)assets complete:(void(^)(BOOL success, NSError *error))block;
+ (void)deleteAssets:(id<NSFastEnumeration>)assets assetCollection:(PHAssetCollection *)collection complete:(void(^)(BOOL success, NSError *error))block;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
