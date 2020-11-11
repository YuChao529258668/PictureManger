//
//  PMAsset.h
//
//  Created by 余超 on 2018/11/12.
//  Copyright © 2018 139. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

#define ASSET_URL_PATH_PH @"assets-library://asset/PH"

NS_ASSUME_NONNULL_BEGIN

@interface PMAsset : NSObject

+ (instancetype)assetWithPHAsset:(PHAsset *)asset;
+ (instancetype)assetWithLocalIdentifier:(NSString *)identifier;
/// 去掉 assets-library://asset/PH 或 assets-library://asset/ 前缀
+ (NSString *)localIdentifierWithString:(NSString *)string;
/// 根据是否包含 assets-library:// 来判断
+ (BOOL)isAssetFile:(NSString *)path;

- (PHAsset *)getasset;

#pragma mark - 获取照片

/**
 同步获取最大尺寸的 image
 */
@property (nonatomic, strong) UIImage *image;

/**
 同步获取

 @param size 返回的image等于或略大于这个尺寸
 */
- (UIImage *)imageWithSize:(CGSize)size;

/**
 同步获取。
 fit 和 imageView 的 contentMode 对应。要精确的size 就给 exact 传 YES。

 @param size 返回的image等于或略大于这个尺寸
 @param fit YES:PHImageContentModeAspectFit, NO: PHImageContentModeAspectFill
 @param exact YES: PHImageRequestOptionsResizeModeExact, NO: PHImageRequestOptionsResizeModeFast
 */
- (UIImage *)imageWithSize:(CGSize)size isAspectFit:(BOOL)fit isResizeExact:(BOOL)exact;


/**
 异步获取照片。可能回调2次，第一次返回低质量照片。
 fit y对应于 imageView 的 contentMode。要裁剪到精确的 size 就给 exact 传 YES。
 
 @param size 返回的image等于或略大于这个尺寸
 @param fit YES:PHImageContentModeAspectFit, NO: PHImageContentModeAspectFill
 @param exact YES: 返回的照片大小精确等于 size, 影响性能； NO: 返回的照片大小接近 size。
 @param onlyLow YES: 只返回低质量照片；NO：回调2次，第一次返回低质量照片。
 @param resultHandler isLowQuality 表示是否低质量照片；localIdentifier 用于判断是哪个 asset 的照片。
 */
- (void)imageWithSize:(CGSize)size isAspectFit:(BOOL)fit isResizeExact:(BOOL)exact onlyLowQuality:(BOOL)onlyLow asyncronize:(void (^)(UIImage *__nullable image, BOOL isLowQuality, NSString *localIdentifier, NSDictionary *__nullable info))resultHandler;


#pragma mark - 获取照片 data

/**
 同步获取 imageData.length
 */
@property (nonatomic, assign) NSUInteger size;

/**
 同步获取
 */
@property (nonatomic, strong) NSData *imageData;

/**
 可以异步获取
 */
- (void)imageDataWithOptions:(nullable PHImageRequestOptions *)options resultHandler:(void(^)(NSData *__nullable imageData, NSString *__nullable dataUTI, UIImageOrientation orientation, NSDictionary *__nullable info))resultHandler;



#pragma mark - 视频数据

/// 获取相册视频数据。要注意回调线程可能是当前线程。
/// @param path 视频数据保存的路径
/// @param block 可以通过 exportSession.status, exportSession.error 获取相关信息
- (void)getVideoDataWithSavePath:(NSString *)path completion:(void(^)(BOOL success, AVAssetExportSession *session))block;

/// 同步获取相册视频数据。尽量不要在主线程调用，主线程最多阻塞 5 秒读取数据。
/// @param path 视频数据保存的路径
/// @param block 可以通过 exportSession.status, exportSession.error 获取相关信息
- (void)getVideoDataSyncWithSavePath:(NSString *)path completion:(void(^)(BOOL success, AVAssetExportSession *session))block;

    
#pragma mark - 属性

@property (nonatomic, assign) BOOL isPhoto;
@property (nonatomic, assign) BOOL isVideo;
@property (nonatomic, assign) BOOL isAudio;

@property (nonatomic, strong, readonly, nullable) NSDate *creationDate;

// The duration, in seconds, of the video asset.
@property (nonatomic, assign, readonly) NSTimeInterval duration; // 相片的值为0

@property (nonatomic, assign) CGSize dimension; // 尺寸

@property (nonatomic, copy) NSString *localIdentifier;

@property (nonatomic, strong) NSURL *url; // file:///var/mobile/Media/DCIM/101APPLE/IMG_1188.PNG
@property (nonatomic,copy) NSString *urlForALAsset; // assets-library://asset/asset.PNG?id=ididididid&ext=PNG
@property (nonatomic,copy) NSString *urlForPHAsset; // assets-library://asset/PHidididid
@property (nonatomic,copy) NSString *sandboxExtensionTokenKey;

@property (nonatomic, strong) NSString *name; // 文件名

@property (nonatomic, strong, readonly) PHAsset *phasset;

#pragma mark -

/// 获取照片的选选
/// @param only NO 会获取图片和视频
/// @param modify YES 是按修改日期降序，NO 是按创建日期降序
+ (PHFetchOptions *)fetchOptionsForOnlyPhoto:(BOOL)only orderByModifyDate:(BOOL)modify;

/// 默认排序
+ (PHFetchOptions *)fetchOptionsForOnlyPhoto:(BOOL)only;

+ (PHCachingImageManager *)cachingManager;

// 模仿旧版的方法，防止崩溃
- (id)valueForProperty:(NSString *)property;

#pragma mark - 保存到相册

+ (void)saveImageWithURLString:(NSString *)urlStr complete:(void(^)(BOOL success, NSError *error))complete;
+ (void)saveImage:(UIImage *)image complete:(void(^)(BOOL success, NSError *error))complete;
+ (void)saveVideoWithFileURL:(id)urlOrString complete:(void(^)(BOOL success, NSError *error))complete;

#pragma mark -

+ (void)testAsset:(PMAsset *)ass;


@end

NS_ASSUME_NONNULL_END
