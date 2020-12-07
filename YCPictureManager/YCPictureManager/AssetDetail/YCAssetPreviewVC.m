//
//  YCAssetPreviewVC.m
//  YCPictureManager
//
//  Created by 余超 on 2020/11/12.
//

#import "YCAssetPreviewVC.h"
#import "YCAssetPreviewCell.h"
#import "UIImageView+YCImageView.h"
#import "YCPreviewGesture.h"
#import "YCPreviewGestureScaleNext.h"
#import "YCPreviewGestureHintNext.h"
#import "YCResultSetBaseVC.h"

#define kGestureKind 1

@interface YCAssetPreviewVC ()
<UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate>
@property (nonatomic, assign) CGSize imageSize;
@property (nonatomic, assign) BOOL isFitstTime;
@property (nonatomic, assign) BOOL isPanDown; // 标记上滑还是下滑
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UIImageView *snapView;
@property (nonatomic, strong) YCPreviewGesture *gesture;
@property (nonatomic, strong) UITapGestureRecognizer *tap;

@property (nonatomic, strong) UIButton *selectCountBtn;

@property (nonatomic, strong) UIColor *viewColor;
@end

@implementation YCAssetPreviewVC

// 删除、分享、编辑、收藏，添加到、
- (void)setupBottomBar {
    UIToolbar *bar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 100, 80)];
    self.bottomBar = bar;
    [self.view addSubview:bar];
    
    // 隐藏显示导航栏，会触发布局，影响隐藏底部栏动画，所以放这里
    float barY = self.view.frame.size.height - 46;
    self.bottomBar.frame = CGRectMake(0, barY, self.view.frame.size.width, 46);
    
//    UIMenuElement *element = [[UIMenuElement alloc] initWithCoder:nil];
//    UIMenu *menu = [UIMenu menuWithTitle:@"my menu" children:@[element]];
//    UIBarButtonItem *test = [[UIBarButtonItem alloc] initWithTitle:@"测试" menu:menu];
    
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *delete = [self itemWithTitle:@"删除" cmd:@selector(clickDeleteBtn)];
    UIBarButtonItem *share = [self itemWithTitle:@"分享" cmd:@selector(clickShareBtn:)];
    UIBarButtonItem *edit = [self itemWithTitle:@"编辑" cmd:@selector(clickEditBtn)];
//    UIBarButtonItem *love = [self itemWithTitle:@"收藏" cmd:@selector(clickLoveBtn)];
//    UIBarButtonItem *addTo = [self itemWithTitle:@"添加到" cmd:@selector(clickAddToBtn)];

//    UIBarButtonItem *delete = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(clickDeleteBtn)];
//    UIBarButtonItem *share = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(clickShareBtn:)];
//    UIBarButtonItem *edit = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(clickEditBtn)];
//    UIBarButtonItem *love = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(clickLoveBtn)];
//    UIBarButtonItem *addTo = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemClose target:self action:@selector(clickAddToBtn)];

    [bar setItems:@[space, delete, space, share, space, edit, space] animated:YES];
//    [bar setItems:@[ delete, space, share, space, edit] animated:YES];
}

- (UIBarButtonItem *)itemWithTitle:(NSString *)title cmd:(SEL)cmd {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    btn.frame = CGRectMake(0, 0, 100, 50);
    [btn setTitle:title forState:UIControlStateNormal];
    [btn addTarget:self action:cmd forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    return item;
}

// 删除
- (void)clickDeleteBtn {
    
    PHAsset *asset = [self getCurrentShowAsset];
    
    [YCAssetsManager deleteAssets:@[asset] complete:^(BOOL success, NSError * _Nonnull error) {
        // yctodo toast 失败
        if (success) {
            // self.fetchResult 需要更新吗？
            NSIndexPath *ip = [self getCurrentShowIndexPath];
            [self.assetArray removeObject:asset];
            [self.collectionView deleteItemsAtIndexPaths:@[ip]];
            [SVProgressHUD showErrorWithStatus:@"删除成功"];
        } else {
            [SVProgressHUD showErrorWithStatus:@"删除失败"];
            NSLog(@"删除失败 %@", error.localizedDescription);
        }
    }];
}

// 分享
- (void)clickShareBtn:(UIView *)view {
    [self openShare:view];
}

// 编辑
- (void)clickEditBtn {
    
}

// 收藏
- (void)clickLoveBtn {
    
}

// 添加到
- (void)clickAddToBtn {
    
}




#pragma mark -


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isFitstTime = YES;
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"预览";
    self.viewColor = [UIColor blackColor];
    
    CGSize size = [UIScreen mainScreen].bounds.size;
    int itemWidth = MAX(size.width, size.height);
    self.imageSize = CGSizeMake(itemWidth, itemWidth);

    [self setupCollectionView];
    [self setupGesture];
    [self setupNav];
    [self setupBottomBar];
    
    // 延伸到 bar
    if (@available(iOS 11.0, *)) {
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.extendedLayoutIncludesOpaqueBars = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self appearAnimation];
    self.isFitstTime = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.isFitstTime) {
        NSIndexPath *ip = [NSIndexPath indexPathForItem:self.index inSection:0];
        [self.collectionView scrollToItemAtIndexPath:ip atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
            
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    if ([layout isKindOfClass:UICollectionViewFlowLayout.class]) {
        layout.itemSize = self.view.frame.size;
    }
    
    self.collectionView.frame = self.view.bounds;
}

- (void)setupNav {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(clickRightBtn) forControlEvents:UIControlEventTouchUpInside];
    self.selectCountBtn = btn;
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)setFetchResult:(PHFetchResult *)fetchResult {
    _fetchResult = fetchResult;
    
    self.assetArray = [NSMutableArray arrayWithCapacity:fetchResult.count];
    self.selectArray = [NSMutableArray array];
    
    [fetchResult enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.assetArray addObject:obj];
    }];
    
    [self.collectionView reloadData];
}

#pragma mark - UICollectionView

- (void)setupCollectionView {
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = self.view.frame.size;
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    
    
    UICollectionView *cv = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    cv.hidden = YES;
    cv.dataSource = self;
    cv.delegate = self;
    cv.alwaysBounceHorizontal = YES;
    cv.pagingEnabled = YES;
//    cv.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
//    cv.contentInset = UIEdgeInsetsMake(20, 0, 20, 0);
    self.collectionView = cv;
    [self.view addSubview:cv];
    
    [cv registerClass:YCAssetPreviewCell.class forCellWithReuseIdentifier:@"YCAssetPreviewCell"];
    cv.backgroundColor = self.viewColor;
    
}
 

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.assetArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    YCAssetPreviewCell *cell = (YCAssetPreviewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"YCAssetPreviewCell" forIndexPath:indexPath];
    
    cell.testL.text = [NSString stringWithFormat:@"%@", @(indexPath.item)];
    cell.imageView.image = nil;
//    cell.contentView.backgroundColor = [UIColor greenColor];
    
    // 手势冲突 单击双击
    [self.tap requireGestureRecognizerToFail:cell.doubleTap];
        
    PHAsset *as = [self.assetArray objectAtIndex:indexPath.item];
    
    [YCAssetsManager requestHighImage:as size:self.imageSize handler:^(UIImage * _Nullable result, BOOL isLow, PHAsset *asset, NSDictionary * _Nullable info) {
        
        if (as != asset) {
            return;
        }
        cell.imageView.image = result;
    }];
    return cell;
}

//- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
//
//}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [(YCAssetPreviewCell *)cell didEndDisplaying];
}

//- (UICollectionViewTransitionLayout *)collectionView:(UICollectionView *)collectionView transitionLayoutForOldLayout:(UICollectionViewLayout *)fromLayout newLayout:(UICollectionViewLayout *)toLayout {
//    return self.tranLayout;
//}

#pragma mark - 手势

- (void)setupGesture {
    // pan
    if (kGestureKind == 0) {
        self.gesture = [YCPreviewGestureScaleNext new];
    } else if (kGestureKind == 1) {
        self.gesture = [YCPreviewGestureHintNext new];
    }
    self.gesture.vc = self;
    
    
    // 单击手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    self.tap = tap;
    [self.view addGestureRecognizer:tap];

}

- (void)handleTap:(UITapGestureRecognizer *)tap {
    BOOL toHide = !self.bottomBar.isHidden;
    
    [self showBottomBar:!toHide animated:YES];
    [self.navigationController setNavigationBarHidden:toHide animated:YES];
}

- (void)showBottomBar:(BOOL)show animated:(BOOL)animated {
    float ty = show? 0: self.bottomBar.height;
    
    // 显示才能看到动画
    if (show) {
        self.bottomBar.hidden = NO;
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        self.bottomBar.transform = CGAffineTransformMakeTranslation(0, ty);
    } completion:^(BOOL finished) {
        self.bottomBar.hidden = !show;
    }];
}

#pragma mark - 动画

- (void)appearAnimation {
    if (!self.isFitstTime) {
        return;
    }
    
    UIImageView *snapView = [UIImageView new];
    PHAsset *asset = [self.assetArray objectAtIndex:self.index];
    UIView *targetView = [self.delegate targetViewForAsset:asset];
    YCAssetPreviewCell *cell = (YCAssetPreviewCell *)self.collectionView.visibleCells.firstObject;

    // 起始位置
    CGRect frame = [targetView.superview convertRect:targetView.frame toView:self.view];
    snapView.frame = frame;

    // 结束位置
    CGRect endFrame;

//    if (targetView.contentMode == UIViewContentModeScaleAspectFit) {
//        endFrame = cell.imageView.frame;
//    } else {
////        CGRect cellImageViewFrame = cell.imageView.frame;
//        CGRect cellImageViewFrame = cell.scrollView.bounds;
//        float hfactor = asset.pixelWidth / cellImageViewFrame.size.width;
//        float vfactor = asset.pixelHeight / cellImageViewFrame.size.height;
//        float factor = fmax(hfactor, vfactor);
//        float newWidth = asset.pixelWidth / factor;
//        float newHeight = asset.pixelHeight / factor;
//        float x = (cellImageViewFrame.size.width - newWidth) /2;
//        float y = (cellImageViewFrame.size.height - newHeight)/2;
//
//        endFrame = CGRectMake(x, y, newWidth, newHeight);
//    }
    endFrame = cell.imageView.frame;
    endFrame = [cell.imageView.superview convertRect:endFrame toView:self.view];
    
    // 图片内容
    snapView.layer.masksToBounds = YES;
    snapView.contentMode = targetView.contentMode;
//    snapView.backgroundColor = [UIColor redColor];

    [YCAssetsManager requestHighImage:asset size:self.imageSize handler:^(UIImage * _Nullable result, BOOL isLow, PHAsset * _Nonnull asset, NSDictionary * _Nullable info) {
        snapView.image = result;
    }];
    
    
    // 动画
    self.collectionView.hidden = YES;
    [self.view insertSubview:snapView belowSubview:self.bottomBar];

    NSTimeInterval duration = 0.44;
    self.view.backgroundColor = [UIColor clearColor];
//    [UIView animateWithDuration:duration animations:^{
////            self.view.backgroundColor = [UIColor blackColor];
//        self.view.backgroundColor = [UIColor whiteColor];
//    }];

    [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:0.76 initialSpringVelocity:0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        snapView.frame = endFrame;
        self.view.backgroundColor = self.viewColor;
        
    } completion:^(BOOL finished) {
        [snapView removeFromSuperview];
        self.collectionView.hidden = NO;
    }];

}


#pragma mark -

- (void)test {
    UIView *view = [UIView new];
    view.frame = self.view.frame;
    view.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
    view.userInteractionEnabled = NO;
    [self.view addSubview:view];
    
    UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(20, 80, 400, 200)];
    iv.image = [(YCAssetPreviewCell *)self.collectionView.visibleCells.firstObject imageView].image;
    iv.contentMode = UIViewContentModeScaleAspectFit;
    iv.contentMode = UIViewContentModeScaleAspectFill;

    iv.backgroundColor = [UIColor greenColor];
    iv.layer.masksToBounds = YES;
    [view addSubview:iv];
    
    UIView *snap = [iv snapshotViewAfterScreenUpdates:YES];
    snap.frame = iv.frame;
    [view insertSubview:snap belowSubview:iv];
    
    [UIView animateWithDuration:2 animations:^{
        iv.frame = CGRectMake(20, 300, 200, 200);
        iv.contentMode = UIViewContentModeScaleAspectFill;
    }];
}

- (void)testTableView {
    CGRect rect = self.view.bounds;
//    rect.origin.y = 50;
    UIScrollView *sv = [[UIScrollView alloc] initWithFrame:rect];
    
    CGRect frame = self.view.bounds;
    frame.size.height = 1000;
//    frame.origin.y = 100;
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.tag = 11;
    
    [sv addSubview:view];
    sv.contentSize = frame.size;
    sv.alwaysBounceVertical = YES;
    sv.backgroundColor = [UIColor lightGrayColor];
    view.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:sv];
    
    sv.delegate = self;
//    sv.contentInset = UIEdgeInsetsMake(100, 0, 0, 0);
//    sv.contentInset = UIEdgeInsetsMake(100, 0, 0, -100);
    sv.contentInset = UIEdgeInsetsMake(100, 0, 200, 0);
//    sv.adjustedContentInset = UIEdgeInsetsMake(200, 0, 0, 0);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 视差效果
    for (YCAssetPreviewCell *cell in self.collectionView.visibleCells) {
        // 计算相对于屏幕的位置
        UIImageView *iv = cell.imageView;
        CGRect frame = [cell convertRect:iv.frame toView:nil];
        // 计算 offset
        float x = -(frame.origin.x - self.view.frame.origin.x) / 4;
        [cell setXOffset:x];
    }

//    UIView *view = [scrollView viewWithTag:11];
//
//    UIScrollView *sv = scrollView;
//    CGPoint v = [sv.panGestureRecognizer velocityInView:sv.panGestureRecognizer.view];
//    if (v.y > 0) {
//        if (sv.contentOffset.y <= -(sv.adjustedContentInset.top)) {
//            NSLog(@"内容下滑到顶");
//            NSLog(@"手势 view.frame = %@", NSStringFromCGRect(view.frame));
//            NSLog(@"手势 srollView.frame = %@", NSStringFromCGRect(scrollView.frame));
//            NSLog(@"手势 contentSize = %@", NSStringFromCGSize(scrollView.contentSize));
//            NSLog(@"手势 contentOffset = %@", NSStringFromCGPoint(scrollView.contentOffset));
//            NSLog(@"手势 contentInset = %@", NSStringFromUIEdgeInsets(scrollView.contentInset));
//            NSLog(@"手势 adjustedContentInset = %@", NSStringFromUIEdgeInsets(scrollView.adjustedContentInset));
//            NSLog(@"-----------------");
//        }
//    } else {
//        if (sv.contentOffset.y + sv.frame.size.height >= sv.adjustedContentInset.bottom + sv.contentSize.height) {
//            NSLog(@"内容上滑到顶");
//            NSLog(@"手势 view.frame = %@", NSStringFromCGRect(view.frame));
//            NSLog(@"手势 srollView.frame = %@", NSStringFromCGRect(scrollView.frame));
//            NSLog(@"手势 contentSize = %@", NSStringFromCGSize(scrollView.contentSize));
//            NSLog(@"手势 contentOffset = %@", NSStringFromCGPoint(scrollView.contentOffset));
//            NSLog(@"手势 contentInset = %@", NSStringFromUIEdgeInsets(scrollView.contentInset));
//            NSLog(@"手势 adjustedContentInset = %@", NSStringFromUIEdgeInsets(scrollView.adjustedContentInset));
//            NSLog(@"-----------------");
//        }
//    }
}



#pragma mark - Actions

- (void)clickRightBtn {
    PHAssetCollection *ac = [PHAssetCollection transientAssetCollectionWithAssets:self.selectArray title:@"嘿嘿嘿"];
    YCResultSetBaseVC *vc = [YCResultSetBaseVC new];
    vc.album = ac;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)updateSelectCount:(NSInteger)count {
//    if (count) {
        [self.selectCountBtn setTitle:[NSString stringWithFormat:@"%ld", count] forState:UIControlStateNormal];
//        return;
//    }
    
}

- (NSIndexPath *)getCurrentShowIndexPath {
    CGPoint point = [self.view convertPoint:self.view.center toView:self.collectionView];
    NSIndexPath *ip = [self.collectionView indexPathForItemAtPoint:point];
    return ip;
}

- (PHAsset *)getCurrentShowAsset {
    NSIndexPath *ip = [self getCurrentShowIndexPath];
    PHAsset *asset = self.assetArray[ip.item];
    return asset;
}

- (void)openShare:(UIView *)view {
    PHAsset *asset = [self getCurrentShowAsset];
        
    [YCAssetsManager requestAssetFileURL:asset done:^(NSURL * _Nonnull url) {
        if (!url) {
            // yctodo 提示分享失败
            return;
        }
        
        NSURL *urlToShare = url;
                
        // 传 name 会导致失败：不支持的分享类型,无法分享到微信
        //    NSArray *activityItems = @[urlToShare, name];
        NSArray *activityItems = @[urlToShare];

        UIActivityViewController *vc = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
        
        vc.completionWithItemsHandler = ^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError)
        {
            NSLog(@"activityType :%@", activityType);
            // yctodo 提示分享成功

            if (completed) {
                NSLog(@"completed");
            } else {
                NSLog(@"cancel");
            }
        };
        
        UIPopoverPresentationController *popover = vc.popoverPresentationController;
        if (popover) {
            popover.sourceView = view;
            popover.sourceRect = view.bounds;
//                popover.permittedArrowDirections = UIPopoverArrowDirectionUp;
        }
        
        [self presentViewController:vc animated:YES completion:nil];
    }];
}

@end
