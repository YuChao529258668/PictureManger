//
//  YCAssetListBaseVC.m
//  YCPictureManager
//
//  Created by 余超 on 2020/11/11.
//

#import "YCAssetListBaseVC.h"

#define kCellSpacing 2

@interface YCAssetListBaseVC ()
<UICollectionViewDelegate, UICollectionViewDataSource>

@end

@implementation YCAssetListBaseVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    [self setupCollectionView];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [YCUtil powerPhotoWithVC:self callBack:^(BOOL succ) {
        if (succ) {
            [self readyForAssets];
            [self getAssets];
        }
    }];
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
//    return 20;
    return self.fetchResult.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    YCAssetListBaseCell *cell = (YCAssetListBaseCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"YCAssetListBaseCell" forIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor greenColor];
    
//    cell.imageView.image = nil;
    
    PHAsset *asset = [self.fetchResult objectAtIndex:indexPath.item];
    [self.imageManager requestImageForAsset:asset targetSize:self.imageSize contentMode:PHImageContentModeDefault options:self.imageOption resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        cell.imageView.image = result;
//        NSLog(@"获取照片结束");
    }];
    return cell;
}



#pragma mark -

- (void)readyForAssets {
    PHFetchOptions *options = [PHFetchOptions new];
    options.fetchLimit = 100;
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    self.assetsOption = options;
    
    PHCachingImageManager *manager = [PHCachingImageManager new];
    self.imageManager = manager;
    
    PHImageRequestOptions *imgOptions = [PHImageRequestOptions new];
    imgOptions.networkAccessAllowed = NO;
//    imgOptions.resizeMode = PHImageRequestOptionsResizeModeFast;
//    imgOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
    imgOptions.resizeMode = PHImageRequestOptionsResizeModeNone;
//    imgOptions.synchronous = NO;
//    imgOptions.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
    imgOptions.synchronous = YES;
    imgOptions.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
//    imgOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;

    self.imageOption = imgOptions;
}

- (void)getAssets {
    PHAssetMediaType type = PHAssetMediaTypeImage;
    PHFetchResult *result = [PHAsset fetchAssetsWithMediaType:type options:self.assetsOption];
    self.fetchResult = result;
    
    [self.collectionView reloadData];
}

@end
