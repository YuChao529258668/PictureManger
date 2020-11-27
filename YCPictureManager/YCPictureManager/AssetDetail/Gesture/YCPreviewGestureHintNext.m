//
//  YCPreviewGestureHintNext.m
//  YCPictureManager
//
//  Created by 余超 on 2020/11/26.
//

#import "YCPreviewGestureHintNext.h"

@interface YCPreviewGestureHintNext ()
@property (nonatomic, strong) UIView *hintView;

@end


@implementation YCPreviewGestureHintNext

- (void)setupHintView {
    if (self.hintView) {
        return;
    }
    
    UIView *view = [UIView new];
//    view.backgroundColor = [UIColor whiteColor];
    self.hintView = view;
    [self.view addSubview:view];
    [YCUtil addBlurTo:view style:UIBlurEffectStyleDark];// UIBlurEffectStyleDark UIBlurEffectStyleRegular

    UILabel *lable = [UILabel new];
    lable.textColor = [UIColor darkTextColor];
    lable.font = [UIFont systemFontOfSize:15];
    lable.text = @"上滑选中图片";
    lable.textAlignment = NSTextAlignmentCenter;
    [view addSubview:lable];
    
    CGRect frame = self.view.bounds;
    view.frame = frame;
    frame.origin.y = 80;
    frame.size.height = 30;
    lable.frame = frame;
    
    
}

#pragma mark - Actions


- (void)handlePanUp:(UIPanGestureRecognizer *)pan {
    float height = self.view.frame.size.height;
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        NSLog(@"手势 handlePanUp");
        
        self.collectionView.scrollEnabled = NO;

        [self setupHintView];
        self.hintView.hidden = NO;

        CGPoint location = [pan locationInView:pan.view];
        NSIndexPath *ip = [self.collectionView indexPathForItemAtPoint:location];
        
        YCAssetPreviewCell *cell = (YCAssetPreviewCell *)[self.collectionView cellForItemAtIndexPath:ip];
        cell.imageView.hidden = YES;
        
        UIView *snapView = [cell.imageView snapshotViewAfterScreenUpdates:NO];
        self.snapView = snapView;
        [self.hintView addSubview:snapView];

        CGRect frame = cell.imageView.frame;
        frame = [cell.imageView.superview convertRect:frame toView:self.view];
        snapView.frame = frame;
                
        self.selectedAsset = [self.assetArray objectAtIndex:ip.item];
        self.selectIndexPath = ip;
        self.selectImageView = cell.imageView;

    } else if (pan.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [pan translationInView:self.view];
        float alpha = 1 - fabs(translation.y)*2 / height;
        
        self.snapView.alpha = alpha;
        self.snapView.transform = CGAffineTransformMakeTranslation(0, translation.y);
        
    } else if (pan.state == UIGestureRecognizerStateEnded) {
        CGRect targetFrame = self.snapView.frame;
        targetFrame.origin.y = - self.view.frame.size.height;

        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.snapView.frame = targetFrame;
            self.snapView.alpha = 0;
            self.hintView.alpha = 0;
//            self.view.backgroundColor = [UIColor clearColor];

        } completion:^(BOOL finished) {
            self.collectionView.hidden = NO;
            [self.snapView removeFromSuperview];
            self.snapView = nil;
            self.hintView.hidden = YES;
            self.hintView.alpha = 1;
            self.selectImageView.hidden = NO;
        }];
        
        self.collectionView.scrollEnabled = YES;
        
        // 处理 collection view 滚动
//        if (self.fetchResult.count > 1) {
//            NSInteger index = self.selectIndexPath.item;
//            if (index == self.fetchResult.count - 1) {
//                index -= 1;
//            } else {
//                index += 1;
//            }
//            NSIndexPath *nextIp = [NSIndexPath indexPathForItem:index inSection:0];
//            [self.collectionView scrollToItemAtIndexPath:nextIp atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
//        }
        
        [self.selectArray addObject:self.selectedAsset];
        [self.assetArray removeObject:self.selectedAsset];
        [self.collectionView deleteItemsAtIndexPaths:@[self.selectIndexPath]];

        
    } else if (pan.state == UIGestureRecognizerStateCancelled) {
        self.collectionView.hidden = NO;
        self.collectionView.scrollEnabled = YES;
        
        [self.snapView removeFromSuperview];
        self.snapView = nil;

        self.hintView.hidden = YES;
        self.selectImageView.hidden = NO;
        self.hintView.alpha = 1;
        self.snapView.alpha = 1;
        
        self.collectionView.scrollEnabled = YES;

        // todo
//        self.collectionView.transform = CGAffineTransformMakeTranslation(0, 0);
//        self.collectionView.hidden = NO;
//        [self.snapView removeFromSuperview];
//        self.snapView = nil;
    }

}

- (void)handlePanDown:(UIPanGestureRecognizer *)pan {
    
    float height = self.view.frame.size.height;
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        NSLog(@"手势 handlePanDown");

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
            
            self.selectedAsset = [self.assetArray objectAtIndex:ip.item];
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
        
        
    } else if (pan.state == UIGestureRecognizerStateChanged) {
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
            [self.vc dismissViewControllerAnimated:NO completion:nil];
            self.snapView.hidden = YES;
        }];
        
        
    } else if (pan.state == UIGestureRecognizerStateCancelled) {
        // todo
        self.collectionView.transform = CGAffineTransformMakeTranslation(0, 0);
        self.collectionView.hidden = NO;
        [self.snapView removeFromSuperview];
        self.snapView = nil;
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)pan {
    CGPoint v = [self.panGesture velocityInView:self.collectionView];
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        self.isPanDown = v.y > 0;
    }
    
    if (self.isPanDown) {
        [self handlePanDown:pan];
    } else {
        [self handlePanUp:pan];
    }
}


#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer != self.panGesture) {
        return NO;
    }
    
    CGPoint v = [self.panGesture velocityInView:self.collectionView];
    
    // 左右滑
    if (fabs(v.x) > fabs(v.y)) {
        return NO;
    }

    //    NSLog(@"手势 v.y = %lf, fabs(v.x) = %lf", v.y, fabs(v.x));

    // 是否放大的平移
    CGPoint location = [self.panGesture locationInView:self.collectionView];
    NSIndexPath *ip = [self.collectionView indexPathForItemAtPoint:location];
    YCAssetPreviewCell *cell = (YCAssetPreviewCell *)[self.collectionView cellForItemAtIndexPath:ip];
//
//    NSLog(@"手势 iv.frame = %@", NSStringFromCGRect(cell.imageView.frame));
//    NSLog(@"手势 contentSize = %@", NSStringFromCGSize(cell.scrollView.contentSize));
//    NSLog(@"手势 contentOffset = %@", NSStringFromCGPoint(cell.scrollView.contentOffset));
//    NSLog(@"----------------------------------");
    
    if (v.y > 0) {
        // 下滑
        if (cell.scrollView.contentOffset.y > 0) {
            return NO;
        } else {
            return YES;
        }

    } else {
        // 上滑
        UIScrollView *sv = cell.scrollView;
        if (sv.contentSize.height > sv.frame.size.height + sv.contentOffset.y) {
            return NO;
        } else {
            return YES;
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    // 上滑、下滑，平移、缩放，旋转、长按
    if ([otherGestureRecognizer isKindOfClass:UIPanGestureRecognizer.class] && [otherGestureRecognizer.view isKindOfClass:UIScrollView.class]) {
        return YES;
    }
    return NO;
}

@end
