//
//  YCTabBarVC.m
//  YCPictureManager
//
//  Created by 余超 on 2020/11/11.
//

#import "YCTabBarVC.h"
#import "YCAssetListBaseVC.h"
#import "YCMineVC.h"

@interface YCTabBarVC ()

@end

@implementation YCTabBarVC

- (void)viewDidLoad {
    [super viewDidLoad];

//    self.view.backgroundColor = [UIColor blueColor];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupViewControllers];
}

- (void)setupViewControllers {
    YCAssetListBaseVC *alistVc = [YCAssetListBaseVC new];
    
    YCMineVC *mineVc = [YCMineVC new];
    
    UINavigationController *listNc = [[UINavigationController alloc] initWithRootViewController:alistVc];
    listNc.tabBarItem.title = @"图库";

    UINavigationController *mineNc = [[UINavigationController alloc] initWithRootViewController:mineVc];
    mineNc.tabBarItem.title = @"我的";

    self.viewControllers = @[listNc, mineNc];

}


@end
