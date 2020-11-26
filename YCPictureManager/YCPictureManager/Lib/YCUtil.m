//
//  YCUtil.m
//  YCPictureManager
//
//  Created by 余超 on 2020/11/11.
//

#import "YCUtil.h"
#import "NSObject+PerformBlockAfterDelay.h"

@implementation YCUtil

// 毛玻璃
+ (void)addBlurTo:(UIView *)view style:(UIBlurEffectStyle)style {
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:style];
    UIVisualEffectView *effectview = [[UIVisualEffectView alloc] initWithEffect:blur];
    effectview.frame = view.bounds;
    [view addSubview:effectview];
}

#pragma mark - 照片权限

+ (BOOL)isPhotoAuthorized {
    PHAuthorizationStatus status = [self getPhotoAuthorizationStatus];

    if (status == PHAuthorizationStatusAuthorized) {
        return YES;
    } else {
        
        if (@available(ios 14.0, *)) {
            if (status == PHAuthorizationStatusLimited) {
                return YES;
            }
        }
        
        return NO;
    }
}

+ (PHAuthorizationStatus)getPhotoAuthorizationStatus {
    PHAuthorizationStatus status;
    if (@available(ios 14.0, *)) {
        status = [PHPhotoLibrary authorizationStatusForAccessLevel:PHAccessLevelReadWrite];
    } else {
        status = [PHPhotoLibrary authorizationStatus];
    }
    return status;
}

+ (void)powerPhotoWithVC:(UIViewController *)avc callBack:(void (^)(BOOL succ))callback {

    // 已授权
    if ([self isPhotoAuthorized]) {
        SB(callback,YES);
        return;
    }
    
    PHAuthorizationStatus authStatus = [self getPhotoAuthorizationStatus];

    // 请求权限
    if (authStatus == PHAuthorizationStatusNotDetermined) {
        if (@available(iOS 14.0, *)) {
            
            [PHPhotoLibrary requestAuthorizationForAccessLevel:PHAccessLevelReadWrite handler:^(PHAuthorizationStatus status) {
                [self doUIBlock:^{
                    if (status == PHAuthorizationStatusAuthorized || status == PHAuthorizationStatusLimited) {
                        SB(callback, YES);
                    } else {
                        SB(callback, NO);
                    }
                }];
            }];
        }else {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                [self doUIBlock:^{
                    if (status == PHAuthorizationStatusAuthorized) {
                        SB(callback, YES);
                    } else {
                        SB(callback, NO);
                    }
                }];
            }];
        }
        return;
    }
    
    // 前往设置
    if (authStatus == PHAuthorizationStatusDenied || authStatus == PHAuthorizationStatusRestricted) {
        SB(callback,NO);

        UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"权限申请" message:@"请允许访问所有照片" preferredStyle:UIAlertControllerStyleAlert];
        [vc addAction:[UIAlertAction actionWithTitle:@"前往设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            if (@available(iOS 10.0, *)) {
                [[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
            } else {
                [[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }
        }]];
        [vc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }]];
        
        [avc presentViewController:vc animated:YES completion:nil];
        return;
    }
}

+ (BOOL)isPhotoLimitAuthorization {
    if (@available(iOS 14.0, *)) {
        return  [self getPhotoAuthorizationStatus] == PHAuthorizationStatusLimited;
    }
    return NO;
}

+ (void)presentLimitPhotoLibraryWithController:(UIViewController *)controller {
    if (@available(iOS 14.0, *)) {
        [[PHPhotoLibrary sharedPhotoLibrary] presentLimitedLibraryPickerFromViewController:controller];
    }
}


#pragma mark -

@end
