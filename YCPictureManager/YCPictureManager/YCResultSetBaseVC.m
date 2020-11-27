//
//  YCResultSetBaseVC.m
//  YCPictureManager
//
//  Created by 余超 on 2020/11/27.
//

#import "YCResultSetBaseVC.h"
#import "YCAssetsManager.h"

@interface YCResultSetBaseVC ()
@property (nonatomic, strong) UIButton *deleteBtn;
@property (nonatomic, strong) UIButton *saveBtn;
@end

@implementation YCResultSetBaseVC

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupNav];
}

- (void)setupNav {
    self.title = @"已选择";

    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
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
