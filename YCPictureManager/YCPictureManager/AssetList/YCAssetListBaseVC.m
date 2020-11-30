//
//  YCAssetListBaseVC.m
//  YCPictureManager
//
//  Created by 余超 on 2020/11/11.
//

#import "YCAssetListBaseVC.h"
#import "YCAssetListBaseCell.h"
#import "YCAssetPreviewVC.h"
#import "YCUtil.h"
#import "YCLikeTestVC.h"


#define kCellSpacing 2

@interface YCAssetListBaseVC ()
<UICollectionViewDelegate, UICollectionViewDataSource, YCAssetPreviewVCDelegate>
//@property (nonatomic, strong) YCAssetListBaseCell *selectCell;
//@property (nonatomic, strong) PHAsset *selectAsset;
@property (nonatomic, assign) int fetchCount;

@end

@implementation YCAssetListBaseVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    [self setupCollectionView];
    [self getAssets];
}

- (void)getPower {
    if (self.fetchCount) {
        return;
    }
    
    [YCUtil powerPhotoWithVC:self callBack:^(BOOL succ) {
        if (succ) {
            [self getAssets];
        }
    }];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self getPower];
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        YCLikeTestVC *vc = [YCLikeTestVC new];
//        [self presentViewController:vc animated:YES completion:nil];
//    });
}


#pragma mark - UICollectionView

- (CGFloat)getItemWitdh {
    float swidth = self.view.frame.size.width;
    int count = swidth / 100;
//    float itemWidth = (int)((swidth - (count - 1) * kCellSpacing)/count /2) * 2; // 间距不固定
    int itemWidth = (swidth - (count - 1) * kCellSpacing)/count;
    self.imageSize = CGSizeMake(itemWidth, itemWidth);
    return itemWidth;
}

- (void)setupCollectionView {
    float width = [self getItemWitdh];
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.itemSize = CGSizeMake(width, width);
    layout.minimumLineSpacing = kCellSpacing;
    layout.minimumInteritemSpacing = kCellSpacing;
    
    UICollectionView *cv = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    cv.dataSource = self;
    cv.delegate = self;
    cv.alwaysBounceVertical = YES;
    cv.contentInset = UIEdgeInsetsMake(20, 0, 20, 0);
    self.collectionView = cv;
    [self.view addSubview:cv];
    
    [cv registerClass:YCAssetListBaseCell.class forCellWithReuseIdentifier:@"YCAssetListBaseCell"];
    cv.backgroundColor = [UIColor whiteColor];
}
 

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.fetchResult.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    YCAssetListBaseCell *cell = (YCAssetListBaseCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"YCAssetListBaseCell" forIndexPath:indexPath];
//    cell.contentView.backgroundColor = [UIColor greenColor];
        
    PHAsset *asset = [self.fetchResult objectAtIndex:indexPath.item];
    [YCAssetsManager requestLowImage:asset size:self.imageSize handler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        cell.imageView.image = result;
    }];
    
    cell.infoL.text = @"😂2.3M";
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    YCAssetListBaseCell *cell = (YCAssetListBaseCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
//    cell.imageView.hidden = YES;
//    self.selectCell = cell;
    
    PHAsset *asset = [self.fetchResult objectAtIndex:indexPath.item];
//    self.selectAsset = asset;
    
    YCAssetPreviewVC *vc = [YCAssetPreviewVC new];
    vc.index = indexPath.item;
    vc.asset = asset;
    vc.fetchResult = self.fetchResult;
    vc.delegate = self;
//    [self.navigationController pushViewController:vc animated:YES];
    
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    nc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:nc animated:NO completion:nil];
}


#pragma mark -

- (void)getAssets {
    if (![YCUtil isPhotoAuthorized]) {
        return;
    } else {
        self.fetchCount ++;
    }
    
    NSLog(@"getAssets");
    
    if (self.album) {
        self.fetchResult = [YCAssetsManager fetchAssetsInCollection:self.album];
    } else {
        self.fetchResult = [YCAssetsManager fetchLowAssets];
    }
    
    [self.collectionView reloadData];
}


#pragma mark - YCAssetPreviewVCDelegate

- (void)panDownAsset:(PHAsset *)asset {
    NSUInteger index = [self.fetchResult indexOfObject:asset];
    NSIndexPath *ip = [NSIndexPath indexPathForItem:index inSection:0];
    
    YCAssetListBaseCell *cell = (YCAssetListBaseCell *)[self.collectionView cellForItemAtIndexPath:ip];
    cell.imageView.hidden = YES;
    
    [self.collectionView scrollToItemAtIndexPath:ip atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
}

- (void)panDownAssetFinish:(PHAsset *)asset {
    NSUInteger index = [self.fetchResult indexOfObject:asset];
    NSIndexPath *ip = [NSIndexPath indexPathForItem:index inSection:0];
    YCAssetListBaseCell *cell = (YCAssetListBaseCell *)[self.collectionView cellForItemAtIndexPath:ip];
    cell.imageView.hidden = NO;
}

- (UIView *)targetViewForAsset:(PHAsset *)asset {
    NSUInteger index = [self.fetchResult indexOfObject:asset];
    NSIndexPath *ip = [NSIndexPath indexPathForItem:index inSection:0];
    YCAssetListBaseCell *cell = (YCAssetListBaseCell *)[self.collectionView cellForItemAtIndexPath:ip];
    return cell.imageView;
}


@end
