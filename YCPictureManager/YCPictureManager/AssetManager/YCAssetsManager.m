//
//  YCAssetsManager.m
//  YCPictureManager
//
//  Created by 余超 on 2020/11/12.
//

#import "YCAssetsManager.h"

@interface YCAssetsManager ()

@property (nonatomic, strong) PHFetchResult *assetResult;
@property (nonatomic, strong) PHFetchResult *assetCollectionResult;
@property (nonatomic, strong) PHFetchOptions *assetsOption;
@property (nonatomic, strong) PHCachingImageManager *imageManager;
@property (nonatomic, strong) PHImageRequestOptions *lowOptions; // 低质量小图片
@property (nonatomic, strong) PHImageRequestOptions *highOptions; // 高质量大图片
@property (nonatomic, assign) CGSize imageSize;

@end


@implementation YCAssetsManager

+ (instancetype)shareManager {
    static YCAssetsManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [YCAssetsManager new];
    });
    return manager;
}

- (void)readyForAssets {
    PHCachingImageManager *manager = [PHCachingImageManager new];
    self.imageManager = manager;

    PHFetchOptions *options = [PHFetchOptions new];
    options.fetchLimit = 300;
//    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"modificationDate" ascending:YES]];
    self.assetsOption = options;
    
    
    PHImageRequestOptions *lowOptions = [PHImageRequestOptions new];
    lowOptions.networkAccessAllowed = NO;
//    lowOptions.resizeMode = PHImageRequestOptionsResizeModeFast;
//    lowOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
    lowOptions.resizeMode = PHImageRequestOptionsResizeModeNone;
//    lowOptions.synchronous = NO;
//    lowOptions.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
    lowOptions.synchronous = YES;
    lowOptions.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
//    lowOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;

    self.lowOptions = lowOptions;
    
    
}

@end
