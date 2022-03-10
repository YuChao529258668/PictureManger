//
//  YCPreviewGestureUpNext.m
//  YCPictureManager
//
//  Created by 余超 on 2022/2/18.
//

#import "YCPreviewGestureUpNext.h"

@implementation YCPreviewGestureUpNext

#pragma mark - Actions


- (void)handlePanUp:(UIPanGestureRecognizer *)pan {
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        NSLog(@"手势 handlePanUp");
        
        self.collectionView.scrollEnabled = NO;

        CGPoint location = [pan locationInView:pan.view];
        NSIndexPath *ip = [self.collectionView indexPathForItemAtPoint:location];
        
        YCAssetPreviewCell *cell = (YCAssetPreviewCell *)[self.collectionView cellForItemAtIndexPath:ip];
        cell.imageView.hidden = YES;
        
        UIView *snapView = [cell.imageView snapshotViewAfterScreenUpdates:NO];
        self.snapView = snapView;

        CGRect frame = cell.imageView.frame;
        frame = [cell.imageView.superview convertRect:frame toView:self.view];
        snapView.frame = frame;
                
        self.selectedAsset = [self.assetArray objectAtIndex:ip.item];
        self.selectIndexPath = ip;
        self.selectImageView = cell.imageView;

    } else if (pan.state == UIGestureRecognizerStateChanged) {
        [self panUpChange:pan];

    } else if (pan.state == UIGestureRecognizerStateEnded) {
        [self panUpEnd:pan];
        
    } else if (pan.state == UIGestureRecognizerStateCancelled) {
        [self cancelPanUp];
    }

}

- (void)cancelPanUp {

    [UIView animateWithDuration:0.2 animations:^{
        self.snapView.alpha = 1;
        self.snapView.transform = CGAffineTransformMakeTranslation(0, 0);

    } completion:^(BOOL finished) {
        [self.snapView removeFromSuperview];
        self.snapView = nil;

        self.selectImageView.hidden = NO;
        
        self.collectionView.scrollEnabled = YES;
        self.collectionView.hidden = NO;
    }];
    
    // todo
//        self.collectionView.transform = CGAffineTransformMakeTranslation(0, 0);
//        self.collectionView.hidden = NO;
//        [self.snapView removeFromSuperview];
//        self.snapView = nil;

}

- (void)cancelPanDown {
    [UIView animateWithDuration:0.2 animations:^{
        self.view.backgroundColor = self.view.backgroundColor;
        self.vc.navigationController.navigationBar.alpha = 1;
        self.vc.bottomBar.alpha = 1;
        
//        位移是相对的，所以如果视图被缩放了，位移会变大。所以位移要相对不会被缩放的视图，比如控制器的视图。
//        先缩放再平移，和先平移再缩放，效果完全不一样。
        self.snapView.transform = CGAffineTransformMakeTranslation(0, 0);
        self.snapView.transform = CGAffineTransformScale(self.snapView.transform, 1, 1);

    } completion:^(BOOL finished) {
        // todo
        self.collectionView.transform = CGAffineTransformMakeTranslation(0, 0);
        self.collectionView.hidden = NO;
        
        [self.snapView removeFromSuperview];
        self.snapView = nil;
        self.vc.bottomBar.alpha = 1;
        self.vc.navigationController.navigationBar.alpha = 1;
    }];
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
            // yctodo 注意 ip 为空的情况
            
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
            [self.view insertSubview:snapView belowSubview:self.vc.bottomBar];
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
        self.vc.navigationController.navigationBar.alpha = alpha;
        self.vc.bottomBar.alpha = alpha;
        
//        位移是相对的，所以如果视图被缩放了，位移会变大。所以位移要相对不会被缩放的视图，比如控制器的视图。
//        先缩放再平移，和先平移再缩放，效果完全不一样。
        self.snapView.transform = CGAffineTransformMakeTranslation(translation.x / 2, translation.y);
        self.snapView.transform = CGAffineTransformScale(self.snapView.transform, scale, scale);
//        NSLog(@"translation.y = %@",@(translation.y));
//        NSLog(@"alpha = %@", @(alpha));

        
    } else if (pan.state == UIGestureRecognizerStateEnded) {
        CGPoint tran = [self.panGesture translationInView:self.vc.view];
        if (fabs(tran.y) < kGestureTriggerTranslationY) {
            [self cancelPanDown];
            return;
        }

        UIView *targetView = [self.delegate targetViewForAsset:self.selectedAsset];
        CGRect targetFrame = [targetView convertRect:targetView.frame toView:self.snapView.superview];
        
        // 0.21, 0.16
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.snapView.frame = targetFrame;
            self.view.backgroundColor = [UIColor clearColor];
            self.vc.navigationController.navigationBar.alpha = 0;
            self.vc.bottomBar.alpha = 0;
        } completion:^(BOOL finished) {
            [self.delegate panDownAssetFinish:self.selectedAsset];
            [self.vc dismissViewControllerAnimated:NO completion:nil];
            self.snapView.hidden = YES;
        }];
        
        
    } else if (pan.state == UIGestureRecognizerStateCancelled) {
        [self cancelPanDown];
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
        // 缩放后，小数位数不同样多，所以取整
        int offsetY = (int)cell.scrollView.contentOffset.y;
        int insetTop = (int)cell.scrollView.contentInset.top;
        if (offsetY + insetTop > 0) {
            return NO;
        } else {
            return YES;
        }

    } else {
        // 上滑
        UIScrollView *sv = cell.scrollView;
        // 缩放后，小数位数不同样多，所以取整
        int h1 = (int)(sv.contentSize.height + sv.contentInset.bottom);
        int h2 = (int)(sv.frame.size.height + sv.contentOffset.y);
        if (h1 > h2) {
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

#pragma mark -

- (BOOL)shouldSelect {
    CGPoint tran = [self.panGesture translationInView:self.vc.view];
    
    if (tran.y > 0) {
        return NO;
    }
    
    if (fabs(tran.y) < kGestureTriggerTranslationY) {
        return NO;
    }

    NSLog(@"YES");
    return YES;
}

- (void)panUpChange:(UIPanGestureRecognizer *)pan {
//    [self panUpChange_move_scale:pan];
    
//    [self panUpChange_move:pan];

    [self panUpChange_move_card:pan];
}

- (void)panUpChange_move:(UIPanGestureRecognizer *)pan {
    CGPoint translation = [pan translationInView:self.view];
    NSLog(@"translation.y = %lf", translation.y);
    
    self.snapView.transform = CGAffineTransformMakeTranslation(0, translation.y);
    
//    [self onSelect];
}

- (void)panUpChange_move_card:(UIPanGestureRecognizer *)pan {
    CGPoint translation = [pan translationInView:self.view];
    NSLog(@"translation.y = %lf", translation.y);
        
//    self.snapView.transform = CGAffineTransformMakeTranslation(0, translation.y);
    
    float t = translation.y / kGestureTriggerTranslationY;
    NSLog(@"bbb t = %lf", t);
    float scale = 1;
    if (t < 0 && fabsf(t)>=0.5) {
        scale = 1.5 - fabsf(t);
        NSLog(@"bbb scale1 = %lf", scale);
//        scale = fmaxf(scale, 1);
        if (scale > 1) {
            scale = 1;
        }
        scale = fmaxf(scale, 0.75);
        NSLog(@"bbb scale2 = %lf", scale);
    }

//            CGAffineTransform t1 = CGAffineTransformMakeTranslation(translation.x, translation.y);
//    CGAffineTransform t1 = CGAffineTransformMakeTranslation(translation.x/scale, translation.y/scale);
    CGAffineTransform t1 = CGAffineTransformMakeTranslation(0, translation.y/scale);
//            CGAffineTransform t2 = CGAffineTransformScale(self.snapView.transform, scale, scale);
    CGAffineTransform t2 = CGAffineTransformMakeScale(scale, scale);
//        CGAffineTransform t2 = CGAffineTransformMakeScale(1, scale);
    self.snapView.transform = CGAffineTransformConcat(t1, t2);
        
}



#pragma mark -

- (void)panUpEnd:(UIPanGestureRecognizer *)pan {
//    CGPoint tran = [self.panGesture translationInView:self.vc.view];
//    if (fabs(tran.y) < kGestureTriggerTranslationY) {
//        [self cancelPanUp];
//        return;
//    }
    
    if (![self shouldSelect]) {
        [self cancelPanUp];
        return;
    }
    
    CGRect targetFrame = self.snapView.frame;
    targetFrame.origin.y = - self.view.frame.size.height;

    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.snapView.frame = targetFrame;
        self.snapView.alpha = 0;
//            self.view.backgroundColor = [UIColor clearColor];

    } completion:^(BOOL finished) {
        self.collectionView.hidden = NO;
        [self.snapView removeFromSuperview];
        self.snapView = nil;
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
    [self.vc updateSelectCount:self.selectArray.count];
    
    [self.assetArray removeObject:self.selectedAsset];
    [self.collectionView deleteItemsAtIndexPaths:@[self.selectIndexPath]];

}

@end