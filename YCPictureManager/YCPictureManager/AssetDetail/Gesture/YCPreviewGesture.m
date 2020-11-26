//
//  YCPreviewGesture.m
//  YCPictureManager
//
//  Created by 余超 on 2020/11/26.
//

#import "YCPreviewGesture.h"


@interface YCPreviewGesture ()

@end


@implementation YCPreviewGesture

//+ (instancetype)gestureWithVC:(YCAssetPreviewVC *)vc {
//    typeof(self) gesture = [self alloc] init
//}

- (void)setVc:(YCAssetPreviewVC *)vc {
    _vc = vc;
    
    self.collectionView = vc.collectionView;
    self.view = vc.view;
    self.delegate = vc.delegate;
    self.fetchResult = vc.fetchResult;
    self.index = vc.index;
    self.asset = vc.asset;
    
    [self setupGesture];
}

#pragma mark - 手势

- (void)setupGesture {
    UIPanGestureRecognizer *pan = [UIPanGestureRecognizer new];
    [pan addTarget:self action:@selector(handlePanGesture:)];
    pan.delegate = self;
    [self.collectionView addGestureRecognizer:pan];
    self.panGesture = pan;
}



@end
