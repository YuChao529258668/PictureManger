//
//  YCUtil.h
//  YCPictureManager
//
//  Created by 余超 on 2020/11/11.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import <PhotosUI/PHPhotoLibrary+PhotosUISupport.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YCUtil : NSObject

// 毛玻璃
+ (void)addBlurTo:(UIView *)view style:(UIBlurEffectStyle)style;

+ (BOOL)isPhotoAuthorized;

+ (void)powerPhotoWithVC:(UIViewController *)avc callBack:(void (^)(BOOL succ))callback;

@end

NS_ASSUME_NONNULL_END
