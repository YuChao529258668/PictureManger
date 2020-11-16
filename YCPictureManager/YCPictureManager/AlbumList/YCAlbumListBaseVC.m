//
//  YCAlbumListBaseVC.m
//  YCPictureManager
//
//  Created by 余超 on 2020/11/16.
//

#import "YCAlbumListBaseVC.h"
#import "YCAssetsManager.h"
#import "YCAlbumListBaseCell.h"

@interface YCAlbumListBaseVC ()
<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) CGSize cellSize;
@property (nonatomic, assign) CGSize imageSize;

@property (nonatomic, strong) PHFetchResult<PHAssetCollection *> *fetchResult;

@end

@implementation YCAlbumListBaseVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    
    self.cellSize = CGSizeMake(160, 206);
    self.imageSize = CGSizeMake(160 * 2, 160 * 2);
    
    [self setupCollectionView];
    [self getAlbums];
}

#pragma mark - UICollectionView


- (void)setupCollectionView {
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.itemSize = self.cellSize;
    layout.minimumLineSpacing = 18;
    layout.minimumInteritemSpacing = 14;
    
    UICollectionView *cv = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    cv.dataSource = self;
    cv.delegate = self;
    cv.alwaysBounceVertical = YES;
    cv.contentInset = UIEdgeInsetsMake(14, 14, 14, 14);
    self.collectionView = cv;
    [self.view addSubview:cv];
    
    [cv registerClass:YCAlbumListBaseCell.class forCellWithReuseIdentifier:@"YCAlbumListBaseCell"];
    cv.backgroundColor = [UIColor whiteColor];
}
 

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.fetchResult.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    YCAlbumListBaseCell *cell = (YCAlbumListBaseCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"YCAlbumListBaseCell" forIndexPath:indexPath];
    
    PHAssetCollection *album = [self.fetchResult objectAtIndex:indexPath.item];
    PHAsset *asset = [YCAssetsManager fetchFirstAssetInCollection:album];
    
    cell.nameL.text = album.localizedTitle;
    cell.countL.text = [NSString stringWithFormat:@"%@",@(album.estimatedAssetCount)];

    [YCAssetsManager requestLowImage:asset size:self.imageSize handler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        cell.imageView.image = result;
    }];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    YCAssetListBaseCell *cell = (YCAssetListBaseCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
//    cell.imageView.hidden = YES;
//    self.selectCell = cell;
    
    PHAssetCollection *album = [self.fetchResult objectAtIndex:indexPath.item];
//    self.selectAsset = asset;
    
//    YCAssetPreviewVC *vc = [YCAssetPreviewVC new];
//    vc.index = indexPath.item;
//    vc.asset = asset;
//    vc.fetchResult = self.fetchResult;
//    vc.delegate = self;
    
//    [self.navigationController pushViewController:vc animated:YES];
    
//    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
//    nc.modalPresentationStyle = UIModalPresentationOverFullScreen;
//    [self presentViewController:nc animated:NO completion:nil];
}



#pragma mark -

- (void)getAlbums {
    self.fetchResult = [YCAssetsManager fetchAssetCollections];
    [self.collectionView reloadData];
}

@end
