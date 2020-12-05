//
//  AppDelegate.m
//  YCPictureManager
//
//  Created by 余超 on 2020/11/11.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end


@implementation AppDelegate


#pragma mark - AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [self createAppWindow:application];
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


#pragma mark - Window

- (UIWindow *)getKeyWindow
{
    if (@available(iOS 13.0, *))
    {
        for (UIWindowScene* windowScene in [UIApplication sharedApplication].connectedScenes) {
            if (windowScene.activationState == UISceneActivationStateForegroundActive)
            {
                for (UIWindow *window in windowScene.windows)
                {
                    if (window.isKeyWindow)
                    {
                        return window;
                    }
                }
            }
        }
    }
    else
    {
        return [UIApplication sharedApplication].keyWindow;
    }
    return nil;
}

- (void)createAppWindow:(UIApplication *)application {
    if (@available(iOS 13.0, *)) {
  
    } else {
      
        if (application.keyWindow) {
            self.window = application.keyWindow;
        } else {
            self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
            self.window.rootViewController = [[UITabBarController alloc]init];
            self.window.backgroundColor = [UIColor whiteColor];
            [self.window makeKeyAndVisible];
        }
    }
}

#pragma mark -


@end
