//
//  YCAssetPreviewVC.m
//  YCPictureManager
//
//  Created by 余超 on 2020/11/12.
//

#import "YCAssetPreviewVC.h"
#import "YCAssetPreviewCell.h"
#import "UIImageView+YCImageView.h"

@interface YCAssetPreviewVC ()
<UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate>
@property (nonatomic, assign) CGSize imageSize;
@property (nonatomic, assign) BOOL isFitstTime;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UIImageView *snapView;
@end

@implementation YCAssetPreviewVC

- (void)appearAnimation {
    if (!self.isFitstTime) {
        return;
    }
    
    UIImageView *snapView = [UIImageView new];
    PHAsset *asset = [self.fetchResult objectAtIndex:self.index];
    UIView *targetView = [self.delegate targetViewForAsset:asset];
    
    // 起始位置
    CGRect frame = [targetView.superview convertRect:targetView.frame toView:self.view];
    snapView.frame = frame;

    // 结束位置
    YCAssetPreviewCell *cell = (YCAssetPreviewCell *)self.collectionView.visibleCells.firstObject;
    CGRect endFrame = [cell.imageView.superview convertRect:cell.imageView.yc_imageRect toView:self.view];
    
    // 图片内容
    snapView.layer.masksToBounds = YES;
    snapView.contentMode = targetView.contentMode;
    snapView.backgroundColor = [UIColor redColor];

    [YCAssetsManager requestHighImage:asset size:self.imageSize handler:^(UIImage * _Nullable result, BOOL isLow, PHAsset * _Nonnull asset, NSDictionary * _Nullable info) {
        snapView.image = result;
    }];
    
    
    // 动画
    self.collectionView.hidden = YES;
    [self.view addSubview:snapView];

    NSTimeInterval duration = 0.44;
    self.view.backgroundColor = [UIColor clearColor];
//    [UIView animateWithDuration:duration animations:^{
////            self.view.backgroundColor = [UIColor blackColor];
//        self.view.backgroundColor = [UIColor whiteColor];
//    }];

    [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:0.76 initialSpringVelocity:0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        snapView.frame = endFrame;
//            self.view.backgroundColor = [UIColor blackColor]; // 变黑之后会瞬间变白再变黑，bug
        self.view.backgroundColor = [UIColor whiteColor];

        
    } completion:^(BOOL finished) {
        [snapView removeFromSuperview];
        self.collectionView.hidden = NO;
    }];

}

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

    self.view.backgroundColor = [UIColor clearColor];
    
    CGSize size = [UIScreen mainScreen].bounds.size;
    int itemWidth = MAX(size.width, size.height);
    self.imageSize = CGSizeMake(itemWidth, itemWidth);

    [self setupCollectionView];
    [self setupGesture];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
//    [self test];// yctest
    [self appearAnimation];
    
    self.isFitstTime = NO;
}

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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.isFitstTime) {
        NSIndexPath *ip = [NSIndexPath indexPathForItem:self.index inSection:0];
        [self.collectionView scrollToItemAtIndexPath:ip atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
        
//        [self appearAnimation];
    }
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
//    [self appearAnimation];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGSize size = self.view.frame.size;
    UIEdgeInsets inset = self.collectionView.adjustedContentInset;
    float itemWidth = size.width;
    float itemHeight = size.height - (inset.top + inset.bottom);
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
//    layout.itemSize = self.view.frame.size;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    self.collectionView.frame = self.view.bounds;
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
//    cv.contentInset = UIEdgeInsetsMake(20, 0, 20, 0);
    self.collectionView = cv;
    [self.view addSubview:cv];
    
    [cv registerClass:YCAssetPreviewCell.class forCellWithReuseIdentifier:@"YCAssetPreviewCell"];
    cv.backgroundColor = [UIColor whiteColor];
}
 

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
//    return 20;
    return self.fetchResult.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    YCAssetPreviewCell *cell = (YCAssetPreviewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"YCAssetPreviewCell" forIndexPath:indexPath];
    
    cell.imageView.image = nil;
    cell.contentView.backgroundColor = [UIColor greenColor];
        
    PHAsset *as = [self.fetchResult objectAtIndex:indexPath.item];
    
    [YCAssetsManager requestHighImage:as size:self.imageSize handler:^(UIImage * _Nullable result, BOOL isLow, PHAsset *asset, NSDictionary * _Nullable info) {
        
        if (as != asset) {
            return;
        }
        cell.imageView.image = result;
    }];
    return cell;
}


#pragma mark - 下滑手势

- (void)setupGesture {
    UIPanGestureRecognizer *pan = [UIPanGestureRecognizer new];
    [pan addTarget:self action:@selector(handlePanGesture:)];
    pan.delegate = self;
//    [pan requireGestureRecognizerToFail:self.collectionView.panGestureRecognizer];

    [self.collectionView addGestureRecognizer:pan];
    self.panGesture = pan;
}


#pragma mark - Actions

- (void)handlePanGesture:(UIPanGestureRecognizer *)pan {
    float height = self.view.frame.size.height;
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        // 显示状态栏
//        self.shouldHideStatusBar = NO;
//        [self setNeedsStatusBarAppearanceUpdate];
        
        
        // 创建手势拖放的 view
        UIImageView *snapView = [UIImageView new];
        snapView.layer.masksToBounds = YES;
        {
            CGPoint location = [pan locationInView:pan.view];
            NSIndexPath *ip = [self.collectionView indexPathForItemAtPoint:location];
            YCAssetPreviewCell *cell = (YCAssetPreviewCell *)[self.collectionView cellForItemAtIndexPath:ip];
            snapView.image = cell.imageView.image;
            
            self.selectedAsset = [self.fetchResult objectAtIndex:ip.item];
            UIView *targetView = [self.delegate targetViewForAsset:self.selectedAsset];
            snapView.contentMode = targetView.contentMode;
            
            // frame
            if (targetView.contentMode == UIViewContentModeScaleAspectFit) {
                // UIViewContentModeScaleAspectFit
                CGRect frame = cell.imageView.frame;
                frame = [cell.imageView.superview convertRect:frame toView:self.view];
                snapView.frame = frame;
            } else {
                // UIViewContentModeScaleAspectFill
                snapView.frame = cell.imageView.yc_imageRect; // 使用照片的size
                CGPoint center = [cell.imageView.superview convertPoint:cell.imageView.center toView:self.view];
                snapView.center = center;
            }
            
            self.collectionView.hidden = YES;
            [self.view addSubview:snapView];
            self.snapView = snapView;
        }

        
        // 设置锚点
        CGPoint location = [pan locationInView:self.view];
        CGSize size = self.view.frame.size;
        float x = location.x / size.width;
        float y = location.y / size.height;
        CGRect frame = snapView.frame;
        snapView.layer.anchorPoint = CGPointMake(x, y);
        snapView.frame = frame;
        
        
        // 让父视图的 collection view 滚动到对应的 image
//        NSIndexPath *indexPath = [self.collectionView indexPathsForVisibleItems].firstObject;
//        PHAsset *asset = [self.fetchResult objectAtIndex:indexPath.item];
//        self.selectedAsset = asset;
        [self.delegate panDownAsset:self.selectedAsset];
        
        
    }else if (pan.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [pan translationInView:self.view];

        float alpha = 1 - fabs(translation.y)*2 / height;
        float scale = 1 - fabs(translation.y) / height;
        self.view.backgroundColor = [self.view.backgroundColor colorWithAlphaComponent:alpha];
//        self.navigationBar.alpha = alpha;
//        self.toolbar.alpha = alpha;
        
//        位移是相对的，所以如果视图被缩放了，位移会变大。所以位移要相对不会被缩放的视图，比如控制器的视图。
//        先缩放再平移，和先平移再缩放，效果完全不一样。
        self.snapView.transform = CGAffineTransformMakeTranslation(translation.x / 2, translation.y);
        self.snapView.transform = CGAffineTransformScale(self.snapView.transform, scale, scale);
//        NSLog(@"translation.y = %@",@(translation.y));
//        NSLog(@"alpha = %@", @(alpha));

        
    } else if (pan.state == UIGestureRecognizerStateEnded) {
        UIView *targetView = [self.delegate targetViewForAsset:self.selectedAsset];
        CGRect targetFrame = [targetView convertRect:targetView.frame toView:self.snapView.superview];
        
        // 0.21, 0.16
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.snapView.frame = targetFrame;
            self.view.backgroundColor = [UIColor clearColor];
        } completion:^(BOOL finished) {
            [self.delegate panDownAssetFinish:self.selectedAsset];
            [self dismissViewControllerAnimated:NO completion:nil];
            self.snapView.hidden = YES;
        }];
        
        
    } else if (pan.state == UIGestureRecognizerStateCancelled) {
        self.collectionView.transform = CGAffineTransformMakeTranslation(0, 0);
        self.collectionView.hidden = NO;
        [self.snapView removeFromSuperview];
        self.snapView = nil;
    }
}

- (void)handlePanGesture22:(UIPanGestureRecognizer *)pan {
    float height = self.view.frame.size.height;
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        // 显示状态栏
//        self.shouldHideStatusBar = NO;
//        [self setNeedsStatusBarAppearanceUpdate];
        

        self.snapView = [self.collectionView snapshotViewAfterScreenUpdates:NO];
        UIView *snapView = self.snapView;
        snapView.frame = self.collectionView.frame;
        [self.collectionView.superview addSubview:snapView];
        self.collectionView.hidden = YES;
        
//        设置锚点
//        CGPoint location = [pan locationInView:self.collectionView]; // 滑动到其他 cell 就不对了
        CGPoint location = [pan locationInView:self.view];
        CGSize size = self.collectionView.frame.size;
        float x = location.x / size.width;
        float y = location.y / size.height;
        
        CGRect frame = self.collectionView.frame;
        snapView.layer.anchorPoint = CGPointMake(x, y);
        snapView.frame = frame;
        
        
        // 让父视图的 collection view 滚动到对应的 image，
//        UICollectionViewCell *cell = [self.collectionView visibleCells].firstObject;
        NSIndexPath *indexPath = [self.collectionView indexPathsForVisibleItems].firstObject;
        PHAsset *asset = [self.fetchResult objectAtIndex:indexPath.item];
        self.selectedAsset = asset;
        [self.delegate panDownAsset:asset];
        
        
    }else if (pan.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [pan translationInView:self.view];

        float alpha = 1 - fabs(translation.y)*2 / height;
        float scale = 1 - fabs(translation.y) / height;
        self.view.backgroundColor = [self.view.backgroundColor colorWithAlphaComponent:alpha];
//        self.navigationBar.alpha = alpha;
//        self.toolbar.alpha = alpha;
        
//        位移是相对的，所以如果视图被缩放了，位移会变大。所以位移要相对不会被缩放的视图，比如控制器的视图。
//        先缩放再平移，和先平移再缩放，效果完全不一样。
        
        self.snapView.transform = CGAffineTransformMakeTranslation(translation.x / 2, translation.y);
//        self.collectionView.transform = CGAffineTransformMakeScale(alpha, alpha);
        
//        NSLog(@"translation.y = %@",@(translation.y));
//        NSLog(@"alpha = %@", @(alpha));
        
        self.snapView.transform = CGAffineTransformScale(self.snapView.transform, scale, scale);
//        self.collectionView.transform = CGAffineTransformTranslate(self.collectionView.transform, translation.x / 2, translation.y);
        
        
        
        
    } else if (pan.state == UIGestureRecognizerStateEnded) {
        
//        self.snapView.hidden = YES;

        UIView *targetView = [self.delegate targetViewForAsset:self.selectedAsset];
        CGRect targetFrame = [targetView convertRect:targetView.frame toView:self.snapView.superview];
        
        // 获取 imageView
//        UICollectionView *cv = (UICollectionView *)pan.view;
//        YCAssetPreviewCell *cell = (YCAssetPreviewCell *)cv.visibleCells.firstObject;
        
        // 获取 cell.imageView.image 相对于屏幕的位置
//        CGRect frame = [cell.imageView convertRect:cell.imageView.yc_imageRect toView:nil];
//        CGRect frame = [cell.imageView convertRect:cell.imageView.frame toView:nil];

        // 创建新的 imageView
//        UIImageView *view = [[UIImageView alloc]initWithImage:cell.imageView.image];
//        view.contentMode = UIViewContentModeScaleAspectFill;
//        [self.view addSubview:view];
//        view.frame = frame;
        
        // 0.21, 0.16
        [UIView animateWithDuration:2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.snapView.frame = targetFrame;
            self.view.backgroundColor = [UIColor clearColor];
        } completion:^(BOOL finished) {
//            if (self.completion) {
//                self.completion();
//            }
            [self.delegate panDownAssetFinish:self.selectedAsset];
            [self dismissViewControllerAnimated:NO completion:nil];
//            [self.navigationController popViewControllerAnimated:NO];
            self.snapView.hidden = YES;
        }];
        
        
    } else if (pan.state == UIGestureRecognizerStateCancelled) {
        self.collectionView.transform = CGAffineTransformMakeTranslation(0, 0);
        self.collectionView.hidden = NO;
        [self.snapView removeFromSuperview];
        self.snapView = nil;
    }
}



#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.panGesture) {
        UIPanGestureRecognizer *pan = self.panGesture;
        CGPoint v = [pan velocityInView:self.collectionView];
        if (v.y > 0 && fabs(v.x) < fabs(v.y)) {
//            NSLog(@"向下 pan");
            return YES;
        }
        return NO;
    }
    return YES;
}


@end
