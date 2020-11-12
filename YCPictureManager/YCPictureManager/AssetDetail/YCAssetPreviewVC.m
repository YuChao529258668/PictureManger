//
//  YCAssetPreviewVC.m
//  YCPictureManager
//
//  Created by 余超 on 2020/11/12.
//

#import "YCAssetPreviewVC.h"
#import "YCAssetPreviewCell.h"

@interface YCAssetPreviewVC ()
<UICollectionViewDelegate, UICollectionViewDataSource>

@end

@implementation YCAssetPreviewVC

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupCollectionView];

}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.collectionView.frame = self.view.bounds;
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
//    layout.minimumLineSpacing = kCellSpacing;
//    layout.minimumInteritemSpacing = kCellSpacing;
    
    UICollectionView *cv = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    cv.dataSource = self;
    cv.delegate = self;
    cv.alwaysBounceVertical = YES;
    cv.contentInset = UIEdgeInsetsMake(20, 0, 20, 0);
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
    cell.contentView.backgroundColor = [UIColor greenColor];
    
//    cell.imageView.image = nil;
    
    PHAsset *asset = [self.fetchResult objectAtIndex:indexPath.item];
    [self.imageManager requestImageForAsset:asset targetSize:self.imageSize contentMode:PHImageContentModeDefault options:self.imageOption resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        cell.imageView.image = result;
//        NSLog(@"获取照片结束");
    }];
    return cell;
}

@end
