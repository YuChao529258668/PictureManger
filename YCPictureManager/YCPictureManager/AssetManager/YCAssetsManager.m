//
//  YCAssetsManager.m
//  YCPictureManager
//
//  Created by 余超 on 2020/11/12.
//

#import "YCAssetsManager.h"

@interface YCAssetsManager ()

//@property (nonatomic, strong) PHFetchResult *assetResult;
//@property (nonatomic, strong) PHFetchResult *assetCollectionResult;
@property (nonatomic, strong) PHFetchOptions *assetsFetchOption;
@property (nonatomic, strong) PHFetchOptions *oneFetchOption; // 只拿 1 个
@property (nonatomic, strong) PHCachingImageManager *imageManager;
@property (nonatomic, strong) PHImageRequestOptions *lowImgOptions; // 低质量小图片
@property (nonatomic, strong) PHImageRequestOptions *highImgOptions; // 高质量大图片
@property (nonatomic, assign) CGSize imageSize;
@end


@implementation YCAssetsManager

static YCAssetsManager *manager;

+ (void)load {
    manager = [YCAssetsManager shareManager];
}

+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [YCAssetsManager new];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self readyForAssets];
    }
    return self;
}


#pragma mark -

- (void)readyForAssets {
    self.imageManager = [PHCachingImageManager new];

    PHFetchOptions *opts = [PHFetchOptions new];
    opts.fetchLimit = 1;
    self.oneFetchOption = opts;
    
    PHFetchOptions *options = [PHFetchOptions new];
    options.fetchLimit = 1000;
//    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"modificationDate" ascending:YES]];
    self.assetsFetchOption = options;
    
    // low
    PHImageRequestOptions *lowOptions = [PHImageRequestOptions new];
    lowOptions.networkAccessAllowed = NO;
    lowOptions.synchronous = YES;
    lowOptions.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    lowOptions.resizeMode = PHImageRequestOptionsResizeModeNone;
    self.lowImgOptions = lowOptions;
//    lowOptions.resizeMode = PHImageRequestOptionsResizeModeFast;
//    lowOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
//    lowOptions.synchronous = NO;
//    lowOptions.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
//    lowOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    
    // high
    PHImageRequestOptions *highOptions = [PHImageRequestOptions new];
    highOptions.networkAccessAllowed = NO;
    highOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
    highOptions.synchronous = NO;
    highOptions.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    self.highImgOptions = highOptions;
}

+ (PHFetchResult<PHAsset *> *)fetchLowAssets {
    PHAssetMediaType type = PHAssetMediaTypeImage;
    PHFetchResult *result = [PHAsset fetchAssetsWithMediaType:type options:manager.assetsFetchOption];
    return result;
}


#pragma mark -

+ (PHImageRequestID)requestLowImage:(PHAsset *)asset size:(CGSize)targetSize handler:(void (^)(UIImage *_Nullable result, NSDictionary *_Nullable info))resultHandler {
    return [self requestImageForAsset:asset
                                 size:targetSize
                          contentMode:PHImageContentModeDefault
                              options:manager.lowImgOptions
                              handler:^(UIImage * _Nullable result, BOOL isLow, PHAsset *asset, NSDictionary * _Nullable info) {
        
        if (resultHandler) {
            resultHandler(result, info);
        }
    }];
}

+ (PHImageRequestID)requestHighImage:(PHAsset *)asset size:(CGSize)targetSize handler:(void (^)(UIImage *_Nullable result, BOOL isLow, PHAsset *asset, NSDictionary *_Nullable info))resultHandler {
    return [self requestImageForAsset:asset
                                 size:targetSize
                          contentMode:PHImageContentModeDefault
                              options:manager.highImgOptions
                              handler:resultHandler];
}

+ (PHImageRequestID)requestImageForAsset:(PHAsset *)asset size:(CGSize)targetSize contentMode:(PHImageContentMode)contentMode options:(nullable PHImageRequestOptions *)options handler:(void (^)(UIImage *_Nullable result, BOOL isLow, PHAsset *asset, NSDictionary *_Nullable info))resultHandler {
    
    if (!asset) {
        if (resultHandler) {
            resultHandler(nil, NO, asset, nil);
        }
        return 0;
    }
    
    PHImageRequestID rid = [manager.imageManager
                            requestImageForAsset:asset
                            targetSize:targetSize
                            contentMode:contentMode
                            options:options
                            resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
        BOOL isLow = info[PHImageResultIsDegradedKey];
        if (resultHandler) {
            resultHandler(result, isLow, asset, info);
        }
    }];
    return rid;
}


#pragma mark - AssetCollection

+ (PHFetchResult<PHAssetCollection *> *)fetchAssetCollections {
//    PHAssetCollectionType type = PHAssetCollectionTypeAlbum; // PHAssetCollectionTypeSmartAlbum
//    PHAssetCollectionSubtype subtype = PHAssetCollectionSubtypeAlbumRegular; // 很多类型
//    PHFetchOptions *options = [PHFetchOptions new]; // sortDescriptors
    
    PHFetchResult<PHAssetCollection *> *collections =
    [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum
                                             subtype:PHAssetCollectionSubtypeAlbumRegular
                                             options:nil];
    return collections;
}

//+ (PHFetchResult<PHAssetCollection *> *)fetchAssetCollectionsWithType:(PHAssetCollectionType)type
//                                                              subtype:(PHAssetCollectionSubtype)subtype
//                                                              options:(PHFetchOptions *)options {


//+ (PHFetchResult<PHAsset *> *)fetchAssetsInAssetCollection:(PHAssetCollection *)assetCollection
//                                                   options:(PHFetchOptions *)options;

+ (PHAsset *)fetchFirstAssetInCollection:(PHAssetCollection *)collection {
    PHFetchResult<PHAsset *> *result = [PHAsset fetchAssetsInAssetCollection:collection options:manager.oneFetchOption];
    PHAsset *asset = result.firstObject;
    return asset;
}

+ (PHFetchResult<PHAsset *> *)fetchAssetsInCollection:(PHAssetCollection *)collection {
    PHFetchResult<PHAsset *> *result = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
    return result;
}

@end
