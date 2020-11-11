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

    self.view.backgroundColor = [UIColor blueColor];
    [self setupViewControllers];
}

- (void)setupViewControllers {
    YCAssetListBaseVC *alistVc = [YCAssetListBaseVC new];
    alistVc.tabBarItem.title = @"图库";
    
    YCMineVC *mineVc = [YCMineVC new];
    mineVc.tabBarItem.title = @"我的";
    
    self.viewControllers = @[alistVc, mineVc];

}


@end
