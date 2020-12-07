//
//  YCAssetPreviewCell.m
//  YCPictureManager
//
//  Created by 余超 on 2020/11/12.
//

#import "YCAssetPreviewCell.h"
#import "UIImageView+YCImageView.h"
#import "UIImage+Size.h"

@interface YCAssetPreviewCell ()<UIScrollViewDelegate>
@end

@implementation YCAssetPreviewCell

- (void)dealloc
{
    [_imageView removeObserver:self forKeyPath:@"image"];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        [self config];
    }
    return self;
}

- (void)config {
    // scroll view
    UIScrollView *sv = [UIScrollView new];
    sv.minimumZoomScale = 1;
    sv.maximumZoomScale = 6;
    sv.delegate = self;
    self.scrollView = sv;
    [self.contentView addSubview:sv];
//    sv.backgroundColor = [UIColor lightGrayColor];
    sv.backgroundColor = [UIColor clearColor];
    if (@available(iOS 11.0, *)) {
        sv.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    // image view
//    UIImageView *iv = [[UIImageView alloc] initWithFrame:self.bounds];
    UIImageView *iv = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    iv.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView = iv;
    [self.scrollView addSubview:iv];
    NSLog(@"%p, 大小: %@ config", self.imageView, NSStringFromCGSize(self.imageView.frame.size));
    // kvo. 设置 image 后重新布局
    [iv addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:nil];
    
    // 双击手势
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    self.doubleTap = doubleTap;
//    self.imageView.userInteractionEnabled = YES;
//    [self.imageView addGestureRecognizer:doubleTap];
    [self.scrollView addGestureRecognizer:doubleTap];

    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 100, 50, 30)];
    [self.contentView addSubview:label];
    self.testL = label;
    label.textColor = [UIColor blackColor];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"image"]) {
        NSLog(@"%p, 大小: %@ ，observeValueForKeyPath", self.imageView, NSStringFromCGSize(self.imageView.frame.size));
//        self.imageView.frame = self.imageView.yc_imageRect;
        self.imageView.frame = self.imageView.image.yc_rectForScreen;
        NSLog(@"%p, 大小: %@ ，observeValueForKeyPath222", self.imageView, NSStringFromCGSize(self.imageView.frame.size));
        CGSize size = self.frame.size;
        self.imageView.center = CGPointMake(size.width/2, size.height/2);
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.scrollView.frame = self.bounds;

    /*
    NSLog(@"%p, 大小: %@ layoutSubviews", self.imageView, NSStringFromCGSize(self.imageView.frame.size));
    
    if (self.scrollView.zoomScale == 1) {
        if (self.imageView.image) {
//            self.imageView.frame = self.imageView.yc_imageRect;
            self.imageView.frame = self.imageView.image.yc_rectForScreen;
            NSLog(@"%p, 大小: %@ layoutSubviews222", self.imageView, NSStringFromCGSize(self.imageView.frame.size));

        } else {
            self.imageView.frame = self.frame;
            NSLog(@"%p, 大小: %@ layoutSubviews333", self.imageView, NSStringFromCGSize(self.imageView.frame.size));

        }
//        self.imageView.frame = self.imageView.yc_imageRect;
        CGSize size = self.scrollView.frame.size;
        self.imageView.center = CGPointMake(size.width/2, size.height/2);

    } else {
        if (!self.scrollView.isZooming) {
            CGSize size = self.bounds.size;
            self.imageView.center = CGPointMake(size.width/2, size.height/2);
        }
    }
    */
}

#pragma mark - UIScrollViewDelegate

- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
//    return self.scaleView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view {
    if (view == self.imageView) {
//        NSLog(@"缩放1 %@", NSStringFromCGPoint(self.imageView.center));
//        NSLog(@"缩放1 %@", self.imageView, NSStringFromCGSize(self.imageView.frame.size));
        
//        CGPoint location = [scrollView.pinchGestureRecognizer locationInView:self.imageView];
//        if (!CGPointEqualToPoint(CGPointZero, location)) {
            [self modifyAnchorPointWithGesture:scrollView.pinchGestureRecognizer];
//        }
    }
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale {
    if (view == self.imageView) {
//        NSLog(@"缩放2 %@", NSStringFromCGPoint(self.imageView.center));
        // 恢复锚点
        [self modifyAnchorPointWithGesture:nil];
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    // 修复缩小的过程会偏上的 bug
    CGFloat offsetX = MAX((scrollView.bounds.size.width - scrollView.contentInset.left - scrollView.contentInset.right - scrollView.contentSize.width) * 0.5, 0.0);
    CGFloat offsetY = MAX((scrollView.bounds.size.height - scrollView.contentInset.top - scrollView.contentInset.bottom - scrollView.contentSize.height) * 0.5, 0.0);

    self.imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
}

#pragma mark -

- (void)handleDoubleTap:(UITapGestureRecognizer *)tap {
//    [self modifyAnchorPointWithGesture:self.doubleTap];
    
//    float scale = (self.scrollView.zoomScale != self.scrollView.maximumZoomScale)? self.scrollView.maximumZoomScale: self.scrollView.minimumZoomScale;
//
//    [UIView animateWithDuration:0.2 animations:^{
//        self.imageView.transform = CGAffineTransformMakeScale(scale, scale);
//    } completion:^(BOOL finished) {
//        [self modifyAnchorPointWithGesture:nil];
//
//        self.imageView.transform = CGAffineTransformMakeScale(0, 0);
//        [self.scrollView setZoomScale:scale animated:NO];
////        self.scrollView.contentSize = self.imageView.yc_imageRect.size;
//    }];
            
    if (self.scrollView.zoomScale != self.scrollView.minimumZoomScale) {
        [self imageScale:self.scrollView.minimumZoomScale withCenter:[tap locationInView:self.imageView]];
    }else
    {
        [self imageScale:self.scrollView.maximumZoomScale withCenter:[tap locationInView:self.imageView]];
    }

//    NSLog(@"handleDoubleTap111 %@", self.imageView);
//    NSLog(@"handleDoubleTap111 %@", self.scrollView);
//    if (self.scrollView.zoomScale != self.scrollView.maximumZoomScale) {
//        [self.scrollView setZoomScale:self.scrollView.maximumZoomScale animated:YES];
//    } else {
//        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
//    }
//    NSLog(@"handleDoubleTap222 %@", self.scrollView);
}

- (void)imageScale:(CGFloat)scale withCenter:(CGPoint)loction
{
    CGRect zoomRect = [self zoomRectForScale:scale withCenter:loction];
//    float x = self.imageView.width/2;
//    float y = 0;
//    float width = self.imageView.width/2;
//    float height = self.imageView.height/2;
//    zoomRect = CGRectMake(x, y, width, height);
    [self.scrollView zoomToRect:zoomRect animated:YES];
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center{
    CGRect zoomRect;
    zoomRect.size.height = self.scrollView.frame.size.height / scale;
    zoomRect.size.width  = self.scrollView.frame.size.width  / scale;
    zoomRect.origin.x    = center.x - (zoomRect.size.width  * 0.5);
    zoomRect.origin.y    = center.y - (zoomRect.size.height * 0.5);
    return zoomRect;
}


// 修改锚点，用于缩放
- (void)modifyAnchorPointWithGesture:(UIGestureRecognizer *)gesture {
    return;
    NSLog(@"%p, 大小: %@  modifyAnchorPointWithGesture", self.imageView, NSStringFromCGSize(self.imageView.frame.size));

    // 修改
    if (gesture) {
        CGSize size = self.imageView.frame.size;
        CGPoint location = [gesture locationInView:self.imageView];
        float x = location.x/size.width;
        float y = location.y/size.height;
        CGRect frame = self.imageView.frame;
        self.imageView.layer.anchorPoint = CGPointMake(x, y);
//        self.imageView.layer.anchorPoint = CGPointMake(0.3, 0.3);
        self.imageView.frame = frame;
        NSLog(@"%p, 大小: %@  modifyAnchorPointWithGesture2222", self.imageView, NSStringFromCGSize(self.imageView.frame.size));

    } else {
        // 恢复锚点
        CGRect frame = self.imageView.frame;
        self.imageView.layer.anchorPoint = CGPointMake(0.5, 0.5);
        self.imageView.frame = frame;
        NSLog(@"%p, 大小: %@ modifyAnchorPointWithGesture33333", self.imageView, NSStringFromCGSize(self.imageView.frame.size));

    }
    NSLog(@"锚点 %@", NSStringFromCGPoint(self.imageView.layer.anchorPoint));
}



#pragma mark -

- (void)didEndDisplaying {
    NSLog(@"%p, 大小: %@ didEndDisplaying", self.imageView, NSStringFromCGSize(self.imageView.frame.size));

    UIScrollView *sv = self.scrollView;
    [sv setZoomScale:sv.minimumZoomScale animated:NO];
    sv.contentSize = CGSizeZero;
    sv.contentOffset = CGPointZero;
    self.imageView.layer.anchorPoint = CGPointMake(0.5, 0.5);
    self.imageView.frame = self.scrollView.bounds;
    NSLog(@"%p, 大小: %@ didEndDisplaying2222", self.imageView, NSStringFromCGSize(self.imageView.frame.size));

}

// 视差，图片偏移
- (void)setXOffset:(float)x {
    
    // 系统自带的照片应用也是在放大照片的情况下，取消视差效果。
    // 如果在放大图片的时候也有视差效果，会在 ScanViewController 的 scrollViewDidScroll 方法里死循环
    if (self.scrollView.zoomScale != 1) {
        return;
    }
    
    CGRect newFrame = CGRectOffset(self.bounds, x, 0);
//    self.imageView.frame = newFrame;
    self.scrollView.frame = newFrame;
}


@end
