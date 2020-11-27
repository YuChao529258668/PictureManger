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
@property (nonatomic, strong) UITapGestureRecognizer *doubleTap;
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
        [self config];
    }
    return self;
}

- (void)config {
    // scroll view
    UIScrollView *sv = [UIScrollView new];
    sv.minimumZoomScale = 1;
    sv.maximumZoomScale = 2.4;
    sv.delegate = self;
    self.scrollView = sv;
    [self.contentView addSubview:sv];
//    sv.backgroundColor = [UIColor lightGrayColor];
    sv.backgroundColor = [UIColor clearColor];
    if (@available(iOS 11.0, *)) {
        sv.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    // image view
    UIImageView *iv = [[UIImageView alloc] initWithFrame:self.bounds];
    NSLog(@"%p, 大小: %@ config", self.imageView, NSStringFromCGSize(self.imageView.frame.size));
    iv.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView = iv;
    [self.scrollView addSubview:iv];
    // kvo. 设置 image 后重新布局
    [iv addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:nil];
    
    // 双击手势
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap)];
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
        CGSize size = self.scrollView.frame.size;
        self.imageView.center = CGPointMake(size.width/2, size.height/2);
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.scrollView.frame = self.bounds;

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


#pragma mark -

- (void)handleDoubleTap {
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
            
    if (self.scrollView.zoomScale != self.scrollView.maximumZoomScale) {
        [self.scrollView setZoomScale:self.scrollView.maximumZoomScale animated:YES];
    } else {
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
    }
}

// 修改锚点，用于缩放
- (void)modifyAnchorPointWithGesture:(UIGestureRecognizer *)gesture {
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


@end
