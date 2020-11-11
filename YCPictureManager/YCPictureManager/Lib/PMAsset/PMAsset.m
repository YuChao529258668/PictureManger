//
//  PMAsset.m
//  139PushMail
//
//  Created by 余超 on 2018/11/12.
//  Copyright © 2018 139. All rights reserved.
//

#import "PMAsset.h"
#import "NSObject+PerformBlockAfterDelay.h"

@interface PMAsset ()

@property (nonatomic, strong) PHImageManager *manager;

@property (nonatomic, strong) PHImageRequestOptions *options;

@property (nonatomic, strong) PHAsset *asset;

@end


@implementation PMAsset

+ (instancetype)assetWithPHAsset:(PHAsset *)asset {
    PMAsset *as = [PMAsset new];
    as.asset = asset;
    return as;
}

// identifier 类似 E5697252-DDF6-42AC-9724-0F6B304C60DE/L0/001，可以有 assets-library://asset/PH 前缀
+ (instancetype)assetWithLocalIdentifier:(NSString *)identifier {
    NSString *path = [self localIdentifierWithString:identifier];
    PHAsset *phasset = [PHAsset fetchAssetsWithLocalIdentifiers:@[path] options:nil].firstObject;
    if (!phasset) {
        return nil;
    }
    PMAsset *asset = [PMAsset assetWithPHAsset:phasset];
    return asset;
}

+ (NSString *)localIdentifierWithString:(NSString *)string {
    NSString *path = [string copy];

    if ([path containsString:@"assets-library://asset/PH"]) {
        path = [path stringByReplacingOccurrencesOfString:@"assets-library://asset/PH" withString:@""];
    } else {
        path = [path stringByReplacingOccurrencesOfString:@"assets-library://asset/" withString:@""];
    }
    return path;
}

/// 根据是否包含 assets-library:// 来判断
+ (BOOL)isAssetFile:(NSString *)path {
    if ([path containsString:@"assets-library://"]) {
        return YES;
    }
    return NO;
}

- (PHAsset *)getasset {
    return _asset;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
//        self.manager = [PHImageManager defaultManager];
        self.manager = [self.class cachingManager];
    }
    return self;
}

- (PHImageRequestOptions *)options {
    if (_options) {
        return _options;
    }
    
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    
    options.synchronous = YES;
    options.networkAccessAllowed = NO;
    
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
//    options.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat; // synchronous = YES 时，无效
    
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    //        options.resizeMode = PHImageRequestOptionsResizeModeNone;
    //        options.resizeMode = PHImageRequestOptionsResizeModeExact;
    //        options.normalizedCropRect = CGRectMake(0.25, 0.25, 0.5, 0.5);
    
    _options = options;

    return _options;
}


#pragma mark -

- (UIImage *)image {
    return [self imageWithSize:PHImageManagerMaximumSize];
}

- (UIImage *)imageWithSize:(CGSize)size {
    __block UIImage *image;
    [self.manager requestImageForAsset:self.asset targetSize:size contentMode:PHImageContentModeAspectFit options:self.options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        image = result;
        NSLog(@"requestImageForAsset %@", NSStringFromCGSize(result.size));
    }];
    return image;
}

- (UIImage *)imageWithSize:(CGSize)size isAspectFit:(BOOL)fit isResizeExact:(BOOL)exact {
    
    PHImageContentMode mode = fit? PHImageContentModeAspectFit :PHImageContentModeAspectFill;
    self.options.resizeMode = exact? PHImageRequestOptionsResizeModeExact: PHImageRequestOptionsResizeModeFast;
    
    __block UIImage *image;
    
    [self.manager requestImageForAsset:self.asset targetSize:size contentMode:mode options:self.options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        self.options.resizeMode = PHImageRequestOptionsResizeModeFast; // 初始化时设置的值
        image = result;
        NSLog(@"requestImageForAsset %@", NSStringFromCGSize(result.size));
    }];
    return image;
}

- (void)imageWithSize:(CGSize)size isAspectFit:(BOOL)fit isResizeExact:(BOOL)exact onlyLowQuality:(BOOL)onlyLow asyncronize:(void (^)(UIImage *__nullable image, BOOL isLowQuality, NSString *localIdentifier, NSDictionary *__nullable info))resultHandler {
    
    PHImageContentMode mode = fit? PHImageContentModeAspectFit :PHImageContentModeAspectFill;
    
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.synchronous = NO;
    options.networkAccessAllowed = YES;
    options.resizeMode = exact? PHImageRequestOptionsResizeModeExact: PHImageRequestOptionsResizeModeFast;
    options.deliveryMode = onlyLow? PHImageRequestOptionsDeliveryModeFastFormat: PHImageRequestOptionsDeliveryModeOpportunistic;

    [self.manager requestImageForAsset:self.asset targetSize:size contentMode:mode options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
        BOOL isLowQuality = [(NSNumber *)info[PHImageResultIsDegradedKey] boolValue];
//        PHImageRequestID rid = [(NSNumber *)info[PHImageResultIsDegradedKey] intValue];

        [self doUIBlock:^{
            if (resultHandler) {
                resultHandler(result, isLowQuality, self.localIdentifier, info);
            }
        }];
    }];
}



#pragma mark -

- (NSUInteger)size {
//    if (_size) {
//        return _size;
//    }
//    return self.imageData.length;

        // 视频、图片的大小都能获取到
        NSUInteger size = 0;
        PHAssetResource *resource = [[PHAssetResource assetResourcesForAsset:self.phasset] firstObject];
    
        if ([resource respondsToSelector:@selector(fileSize)]) {
            size = [[resource valueForKey:@"fileSize"] longLongValue];
        }
        return size;
}

- (NSData *)imageData {
    
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.synchronous = YES;
    options.networkAccessAllowed = NO;
    
    __block NSData *data;
    
    [self.manager requestImageDataForAsset:self.asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        data = imageData;
        self.size = imageData.length;
        self.url = [info objectForKey:@"PHImageFileURLKey"]; // file:///var/mobile/Media/DCIM/101APPLE/IMG_1188.PNG
        self.sandboxExtensionTokenKey = [info objectForKey:@"PHImageFileSandboxExtensionTokenKey"];
    }];
    return data;
}

- (void)imageDataWithOptions:(nullable PHImageRequestOptions *)options resultHandler:(void(^)(NSData *__nullable imageData, NSString *__nullable dataUTI, UIImageOrientation orientation, NSDictionary *__nullable info))resultHandler {
    [self.manager requestImageDataForAsset:self.asset options:options resultHandler:resultHandler];
}


#pragma mark -

/// 获取相册视频数据。要注意回调线程可能是当前线程。
/// @param path 视频数据保存的路径
/// @param block 可以通过 exportSession.status, exportSession.error 获取相关信息
- (void)getVideoDataWithSavePath:(NSString *)path completion:(void(^)(BOOL success, AVAssetExportSession *session))block {
    
    NSURL *url = [NSURL fileURLWithPath:path];
    if (!url || path.length == 0) {
        SB(block, NO, nil);
        return;
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        if (!image) {
            SB(block, YES, nil);
            return;
        } else {
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        }
    }
    
    PHVideoRequestOptions *options = [PHVideoRequestOptions new];
    options.networkAccessAllowed = NO;
    
    [self.manager requestExportSessionForVideo:self.asset options:options exportPreset:AVAssetExportPresetHighestQuality  resultHandler:^(AVAssetExportSession * _Nullable exportSession, NSDictionary * _Nullable info) {
        
        // 要注意这里的回调线程可能是外面调用本函数的线程
        exportSession.outputURL = url;
        exportSession.shouldOptimizeForNetworkUse = NO;
        exportSession.outputFileType = AVFileTypeQuickTimeMovie;
        
        __block BOOL isFirstTime = YES;

        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            if (!isFirstTime) {
                return ;
            }
            isFirstTime = NO;

            switch (exportSession.status) {
                case AVAssetExportSessionStatusCompleted: {
                    SB(block, YES, exportSession);
                    break;
                }
                case AVAssetExportSessionStatusFailed: {
                    // 失败可能会调用多次，比如 Cannot Save，Try saving again
                    SB(block, NO, exportSession);
                    break;
                }
                case AVAssetExportSessionStatusCancelled: {
                    SB(block, NO, exportSession);
                    break;
                }
                default:
                    SB(block, NO, exportSession);
                    break;
            }
        }];
    }];
}

/// 同步获取相册视频数据。注意不要在主线程调用，会卡死
/// @param path 视频数据保存的路径
/// @param block 可以通过 exportSession.status, exportSession.error 获取相关信息
- (void)getVideoDataSyncWithSavePath:(NSString *)path completion:(void(^)(BOOL success, AVAssetExportSession *session))block {
    
    NSURL *url = [NSURL fileURLWithPath:path];
    if (!url || path.length == 0) {
        SB(block, NO, nil);
        return;
    }
    
    // 处理同名 mov 文件其实是个图片的情况
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        if (!image) {
            SB(block, YES, nil);
            return;
        } else {
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        }
    }
    
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    __block BOOL succ = NO;
    __block AVAssetExportSession *session = nil;
    
    [self doAsyncBlock:^{
        PHVideoRequestOptions *options = [PHVideoRequestOptions new];
        options.networkAccessAllowed = YES;
        
        [self.manager requestExportSessionForVideo:self.asset options:options exportPreset:AVAssetExportPresetHighestQuality  resultHandler:^(AVAssetExportSession * _Nullable exportSession, NSDictionary * _Nullable info) {
            
            // 要注意这里的回调线程可能是外面调用本函数的线程
            exportSession.outputURL = url;
            exportSession.shouldOptimizeForNetworkUse = NO;
            exportSession.outputFileType = AVFileTypeQuickTimeMovie;
            session = exportSession;
            
            __block BOOL isFirstTime = YES;
            
            [exportSession exportAsynchronouslyWithCompletionHandler:^{
                if (!isFirstTime) {
                    return ;
                }
                isFirstTime = NO;

                switch (exportSession.status) {
                    case AVAssetExportSessionStatusCompleted: {
                        succ = YES;
                        break;
                    }
                    case AVAssetExportSessionStatusFailed: {
                        // 失败可能会调用多次，比如 Cannot Save，Try saving again
                        succ = NO;
                        break;
                    }
                    case AVAssetExportSessionStatusCancelled: {
                        succ = NO;
                        break;
                    }
                    default:
                        succ = NO;
                        break;
                } // end of switch
                
                dispatch_semaphore_signal(sem);
            }];
        }];
    }];

    dispatch_time_t time;
    if ([NSThread currentThread].isMainThread) {
        // 主线程的话，改为允许阻塞 5 秒
        time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC));
        NSLog(@"主线程读取相册视频");
    } else {
        time = DISPATCH_TIME_FOREVER;
    }

    dispatch_semaphore_wait(sem, time);
    SB(block, succ, session);
}


#pragma mark -

- (BOOL)isPhoto {
    return self.asset.mediaType == PHAssetMediaTypeImage;
}

- (BOOL)isVideo {
    return self.asset.mediaType == PHAssetMediaTypeVideo;
}

- (NSTimeInterval)duration {
    return self.asset.duration;
}

- (BOOL)isAudio {
    return self.asset.mediaType == PHAssetMediaTypeAudio;
}

- (NSDate *)creationDate {
    return self.asset.creationDate;
}

- (NSString *)localIdentifier {
    return self.asset.localIdentifier;
}

- (NSURL *)url {
    if (_url) {
        return _url;
    }
    [self imageData];
    return _url;
}

- (NSString *)urlForPHAsset {
    // asset.localIdentifier ADF1CDB3-CDC4-413D-947D-AF1E390D3210/L0/001
    NSString *url = [NSString stringWithFormat:@"%@%@", ASSET_URL_PATH_PH, self.localIdentifier];
    return url;
}

- (NSString *)urlForALAsset {
    // 旧版 @"assets-library://asset/asset.PNG?id=ADF1CDB3-CDC4-413D-947D-AF1E390D3210&ext=PNG"
    // 新版 file:///var/mobile/Media/DCIM/101APPLE/IMG_1188.PNG
    // 新版 self.asset.localIdentifier ADF1CDB3-CDC4-413D-947D-AF1E390D3210/L0/001
    
    NSString *ext = [[self.name componentsSeparatedByString:@"."].lastObject uppercaseString];
    NSString *aid = [self.localIdentifier componentsSeparatedByString:@"/"].firstObject;
    NSString *url = [NSString stringWithFormat:@"assets-library://asset/asset.%@?id=%@&ext=%@", ext, aid, ext];
    return url;
}

- (NSString *)sandboxExtensionTokenKey {
    if (_sandboxExtensionTokenKey) {
        return _sandboxExtensionTokenKey;
    }
    [self imageData];
    return _sandboxExtensionTokenKey;
}

- (PHAsset *)phasset {
    return self.asset;
}

- (NSString *)name {
    if (_name) {
        return _name;
    }
        
    if ([self.asset respondsToSelector:NSSelectorFromString(@"filename")]) {
        _name = [self.asset valueForKey:@"filename"];
    } else {
        // 有时候返回 nil。。。
        PHAssetResource *resource = [PHAssetResource assetResourcesForAsset:self.asset].firstObject;
        _name = resource.originalFilename;
    }
    
    return _name;
}

- (CGSize)dimension {
    return CGSizeMake(self.asset.pixelWidth, self.asset.pixelHeight);
}

#pragma mark -


/// 获取照片的选选
/// @param only NO 会获取图片和视频
/// @param modify YES 是按修改日期降序，NO 是按创建日期降序
+ (PHFetchOptions *)fetchOptionsForOnlyPhoto:(BOOL)only orderByModifyDate:(BOOL)modify {
    PHFetchOptions *options = [PHFetchOptions new];
    
    if (only) {
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
    } else {
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld || mediaType == %ld", PHAssetMediaTypeImage, PHAssetMediaTypeVideo];
    }
    
    if (modify) {
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"modificationDate" ascending:NO]];
    } else {
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    }
    
    return options;
}

/// 默认排序
+ (PHFetchOptions *)fetchOptionsForOnlyPhoto:(BOOL)only {
    PHFetchOptions *options = [self fetchOptionsForOnlyPhoto:only orderByModifyDate:NO];
    options.sortDescriptors = nil;
    return options;
}

static PHCachingImageManager *cmanager;
+ (PHCachingImageManager *)cachingManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cmanager = [PHCachingImageManager new];
    });
    return cmanager;
}

- (id)valueForProperty:(NSString *)property {
    // valueForProperty 是 ALAsset 的方法，请替换掉
    return @"";
}

#pragma mark - Save

+ (void)saveImageWithURLString:(NSString *)urlStr complete:(void(^)(BOOL success, NSError *error))complete {
    NSURL *url = [NSURL fileURLWithPath:urlStr];
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:url];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        [self doSyncUIBlock:^{
            if (error) {
                NSLog(@"saveImageWithURLString：保存图片失败 %@", error);
            }
            SB(complete, success, error);
        }];
    }];
}

+ (void)saveImage:(UIImage *)image complete:(void(^)(BOOL success, NSError *error))complete {
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [PHAssetChangeRequest creationRequestForAssetFromImage:image];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        [self doSyncUIBlock:^{
            if (error) {
                NSLog(@"saveImage：保存图片失败 %@", error);
            }
            SB(complete, success, error);
        }];
    }];
}

+ (void)saveVideoWithFileURL:(id)urlOrString complete:(void(^)(BOOL success, NSError *error))complete {
    NSURL *url;
    if ([urlOrString isKindOfClass:NSURL.class]) {
        url = urlOrString;
    } else {
        url = [NSURL fileURLWithPath:urlOrString];
    }

    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:url];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (error) {
            NSLog(@"saveVideoWithURLString：保存视频失败 %@", error);
        }
        SB(complete, success, error);
    }];
}

#pragma mark -

+ (void)testAsset:(PMAsset *)ass {
    NSData *data = [ass imageData];
    
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.synchronous = YES;
    options.networkAccessAllowed = YES;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    [[PHImageManager defaultManager] requestImageDataForAsset:ass.phasset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        NSLog(@"%@", info);
        NSLog(@"%@", imageData);
        
    }];
    
    
    
    
    [ass imageDataWithOptions:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        NSLog(@"%@", info);
        NSLog(@"%@", imageData);
    }];
    
    [ass imageWithSize:CGSizeMake(200, 200) isAspectFit:YES isResizeExact:YES onlyLowQuality:NO asyncronize:^(UIImage * _Nullable image, BOOL isLowQuality, NSString * _Nonnull localIdentifier, NSDictionary * _Nullable info) {
        NSLog(@"%@", info);
        NSLog(@"%@", image);
        NSData *data = UIImageJPEGRepresentation(image, 0.5);
        NSLog(@"%@", data);
        
    }];
    NSLog(@"%@" ,data);
}

@end
