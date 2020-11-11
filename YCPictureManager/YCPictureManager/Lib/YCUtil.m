//
//  YCUtil.m
//  YCPictureManager
//
//  Created by 余超 on 2020/11/11.
//

#import "YCUtil.h"
#import "NSObject+PerformBlockAfterDelay.h"

@implementation YCUtil


#pragma mark - 照片权限

+ (void)powerPhotoWithVC:(UIViewController *)avc callBack:(void (^)(BOOL succ))callback {
    PHAuthorizationStatus authStatus;
    
    if (@available(iOS 14.0, *)) {
        PHAccessLevel level = PHAccessLevelReadWrite;
        authStatus = [PHPhotoLibrary authorizationStatusForAccessLevel:level];
    } else {
        authStatus = [PHPhotoLibrary authorizationStatus];
    }
    
    switch (authStatus) {
        case PHAuthorizationStatusAuthorized:
            SB(callback,YES);
            break;
        case PHAuthorizationStatusLimited:
        {
            SB(callback,YES);
            break;
        }
        case PHAuthorizationStatusNotDetermined:
        {
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
        }
            break;
        case PHAuthorizationStatusDenied:
        case PHAuthorizationStatusRestricted:
        {
            SB(callback,NO);

            UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"权限申请" message:@"请允许访问所有照片" preferredStyle:UIAlertControllerStyleAlert];
            [vc addAction:[UIAlertAction actionWithTitle:@"前往设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                [[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
            }]];
            [vc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            }]];
            
            [avc presentViewController:vc animated:YES completion:nil];

        }
            break;
            
        default:
            callback(NO);
            break;
    }
}

+ (BOOL)isPhotoLimitAuAuthorization {
    if (@available(iOS 14.0, *)) {
        PHAccessLevel level = PHAccessLevelReadWrite;
        PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatusForAccessLevel:level];
        return  authStatus == PHAuthorizationStatusLimited;
    }
    return NO;;
}

+ (void)presentLimitPhotoLibraryWithController:(UIViewController *)controller {
    if (@available(iOS 14.0, *)) {
        [[PHPhotoLibrary sharedPhotoLibrary] presentLimitedLibraryPickerFromViewController:controller];
    }
}


#pragma mark -

@end
