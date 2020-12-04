//
//  YCResultSetBaseVC.m
//  YCPictureManager
//
//  Created by 余超 on 2020/11/27.
//

#import "YCResultSetBaseVC.h"
#import "YCAssetsManager.h"

// 默认状态，导航栏：添加至，全部删除，更多（分享，清空结果集）
// 长按选中1个，导航栏：全选，删除(1)，分享，编辑，添加至，移出结果集，

// 简化版
// 默认状态，导航栏：全部删除。
// 底部栏：添加至，分享，全部清空。
// 编辑状态，导航栏：全选，取消。
// 底部栏：删除，移出，分享，添加至。
// 长按，长按选中1个，滑动选中多个，添加勾勾和毛玻璃
// 点击，进入预览页。下滑返回结果集，上滑选中并移除，结果集进入编辑状态。顶部栏、底部栏和列表预览页一样，多一个移出选项



@interface YCResultSetBaseVC ()
@property (nonatomic, assign) BOOL isEditing;

@property (nonatomic, strong) UIButton *deleteBtn;
@property (nonatomic, strong) UIButton *saveBtn;
@end

@implementation YCResultSetBaseVC

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupNav];
}

- (void)setupBottomBar {
    
}

- (void)setupNav {
    self.title = @"已选择";

    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteBtn setTitle:@"全部删除" forState:UIControlStateNormal];
    [deleteBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [deleteBtn addTarget:self action:@selector(clickDeleteBtn) forControlEvents:UIControlEventTouchUpInside];
    self.deleteBtn = deleteBtn;
    UIBarButtonItem *deleteItem = [[UIBarButtonItem alloc] initWithCustomView:deleteBtn];
    
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveBtn setTitle:@"添加至" forState:UIControlStateNormal];
    [saveBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(clickSaveBtn) forControlEvents:UIControlEventTouchUpInside];
    self.saveBtn = saveBtn;
    
    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithCustomView:saveBtn];
    self.navigationItem.rightBarButtonItems = @[deleteItem, saveItem];

}

- (void)clickDeleteBtn {
    [YCAssetsManager deleteAssets:self.fetchResult complete:^(BOOL success, NSError * _Nonnull error) {
        if (success) {
            NSLog(@"删除成功");
        } else {
            NSLog(@"删除失败 %@", error.localizedDescription);
        }
    }];
}

- (void)clickSaveBtn {
    
}
@end
