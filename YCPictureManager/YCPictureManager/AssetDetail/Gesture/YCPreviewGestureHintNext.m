//
//  YCPreviewGestureHintNext.m
//  YCPictureManager
//
//  Created by 余超 on 2020/11/26.
//

#import "YCPreviewGestureHintNext.h"

@implementation YCPreviewGestureHintNext

#pragma mark - Actions

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

- (void)handlePanUp:(UIPanGestureRecognizer *)pan {
    float height = self.view.frame.size.height;
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        NSLog(@"手势 handlePanUp");
        
        // 创建手势拖放的 view
        UIImageView *snapView = [UIImageView new];
        snapView.layer.masksToBounds = YES;
        {
            CGPoint location = [pan locationInView:pan.view];
            NSIndexPath *ip = [self.collectionView indexPathForItemAtPoint:location];
            YCAssetPreviewCell *cell = (YCAssetPreviewCell *)[self.collectionView cellForItemAtIndexPath:ip];
            
            CGRect frame = cell.imageView.frame;
            frame = [cell.imageView.superview convertRect:frame toView:self.view];
            snapView.frame = frame;
            snapView.image = cell.imageView.image;
            [self.view addSubview:snapView];
            self.snapView = snapView;


            self.selectedAsset = [self.fetchResult objectAtIndex:ip.item];
//            self.collectionView.hidden = YES;
            
            // 毛玻璃
            UIView *maskView = [[UIView alloc] initWithFrame:self.view.bounds];
            maskView.tag = 222;
            [self.view insertSubview:maskView belowSubview:snapView];
            UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
            UIVisualEffectView *effectview = [[UIVisualEffectView alloc] initWithEffect:blur];
            effectview.frame = maskView.bounds;
            [maskView addSubview:effectview];
            
            
            // 处理 collection view 滚动
            if (self.fetchResult.count > 1) {
                NSInteger index = ip.item;
                if (index == self.fetchResult.count - 1) {
                    index -= 1;
                } else {
                    index += 1;
                }
                NSIndexPath *nextIp = [NSIndexPath indexPathForItem:index inSection:0];
                self.collectionView.scrollEnabled = NO;
                [self.collectionView scrollToItemAtIndexPath:nextIp atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
            }
        }

        
        // 设置锚点
        CGPoint location = [pan locationInView:self.view];
        CGSize size = self.view.frame.size;
        float x = location.x / size.width;
        float y = location.y / size.height;
        CGRect frame = snapView.frame;
        snapView.layer.anchorPoint = CGPointMake(x, y);
        snapView.frame = frame;
        
    }else if (pan.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [pan translationInView:self.view];

        float alpha = 1 - fabs(translation.y)*2 / height;
        float scale = 1 - fabs(translation.y) / height;
        self.view.backgroundColor = [self.view.backgroundColor colorWithAlphaComponent:alpha];
        
        UIView *maskView = [self.view viewWithTag:222];
        maskView.alpha = alpha;
        
//        位移是相对的，所以如果视图被缩放了，位移会变大。所以位移要相对不会被缩放的视图，比如控制器的视图。
//        先缩放再平移，和先平移再缩放，效果完全不一样。
        self.snapView.transform = CGAffineTransformMakeTranslation(translation.x / 2, translation.y);
        self.snapView.transform = CGAffineTransformScale(self.snapView.transform, scale, scale);
        
    } else if (pan.state == UIGestureRecognizerStateEnded) {
        CGRect targetFrame = CGRectMake(self.view.frame.size.width - 50, 0, 0, 0);
        UIView *maskView = [self.view viewWithTag:222];

        // 0.21, 0.16
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.snapView.frame = targetFrame;
//            self.view.backgroundColor = [UIColor clearColor];
            maskView.alpha = 0;

        } completion:^(BOOL finished) {
            self.collectionView.hidden = NO;
            [self.snapView removeFromSuperview];
            self.snapView = nil;
            [maskView removeFromSuperview];
        }];
        
        self.collectionView.scrollEnabled = YES;
        
        
    } else if (pan.state == UIGestureRecognizerStateCancelled) {
        self.collectionView.hidden = NO;
        self.collectionView.scrollEnabled = YES;
        
        [self.snapView removeFromSuperview];
        self.snapView = nil;

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
