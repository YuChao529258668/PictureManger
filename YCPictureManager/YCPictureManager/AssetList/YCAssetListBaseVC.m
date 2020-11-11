//
//  YCAssetListBaseVC.m
//  YCPictureManager
//
//  Created by 余超 on 2020/11/11.
//

#import "YCAssetListBaseVC.h"
#import "YCAssetListBaseCell.h"
#import "YCUtil.h"

#define kCellSpacing 2

@interface YCAssetListBaseVC ()
<UICollectionViewDelegate, UICollectionViewDataSource>

@end

@implementation YCAssetListBaseVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    [self setupCollectionView];
    
    [YCUtil powerPhotoWithVC:self callBack:^(BOOL succ) {
        if (succ) {
            
        }
    }];
}


#pragma mark - UICollectionView

- (CGFloat)getItemWitdh {
    float swidth = self.view.frame.size.width;
    int count = swidth / 100;
//    float itemWidth = (int)((swidth - (count - 1) * kCellSpacing)/count /2) * 2; // 间距不固定
    int itemWidth = (swidth - (count - 1) * kCellSpacing)/count;
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
    self.collectionView = cv;
    [self.view addSubview:cv];
    
    [cv registerClass:YCAssetListBaseCell.class forCellWithReuseIdentifier:@"YCAssetListBaseCell"];
    cv.backgroundColor = [UIColor whiteColor];
}
 

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 20;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    YCAssetListBaseCell *cell = (YCAssetListBaseCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"YCAssetListBaseCell" forIndexPath:indexPath];
//    cell.contentView.backgroundColor = [UIColor greenColor];
    return cell;
}

@end
