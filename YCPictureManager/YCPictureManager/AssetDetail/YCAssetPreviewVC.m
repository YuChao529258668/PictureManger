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

#define kGestureKind 1

@interface YCAssetPreviewVC ()
<UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate>
@property (nonatomic, assign) CGSize imageSize;
@property (nonatomic, assign) BOOL isFitstTime;
@property (nonatomic, assign) BOOL isPanDown; // 标记上滑还是下滑
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UIImageView *snapView;
@property (nonatomic, strong) YCPreviewGesture *gesture;
@end

@implementation YCAssetPreviewVC

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
    cv.backgroundColor = [UIColor whiteColor];
    
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
    if (kGestureKind == 0) {
        self.gesture = [YCPreviewGestureScaleNext new];
    } else if (kGestureKind == 1) {
        self.gesture = [YCPreviewGestureHintNext new];
    }
    self.gesture.vc = self;
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


@end
