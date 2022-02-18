//
//  YCAssetPreviewCell.m
//  YCPictureManager
//
//  Created by 余超 on 2020/11/12.
//

#import "YCAssetPreviewCell.h"
#import "UIImageView+YCImageView.h"
#import "UIImage+Size.h"

@interface YCAssetPreviewCell ()<UIScrollViewDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, assign) CGAffineTransform scaleTransform;
@property (nonatomic, assign) CGAffineTransform rotateTransform;
@property (nonatomic, assign) CGFloat lastRotation;
@property (nonatomic, assign) float lastScale;


@end

// 修改 image view 的锚点对缩放的位置没有影响

@implementation YCAssetPreviewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.scaleTransform = CGAffineTransformIdentity;
        self.rotateTransform = CGAffineTransformIdentity;
        self.lastScale = 1;
        self.lastRotation = 0;

        self.clipsToBounds = YES;
        self.maxScale = 4;
        [self config];
    }
    return self;
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

- (void)dealloc {
    [_imageView removeObserver:self forKeyPath:@"image"];
}


#pragma mark -

- (void)config {
    // scroll view
    UIScrollView *sv = [UIScrollView new];
    sv.minimumZoomScale = 1;
    sv.maximumZoomScale = 6;
    sv.delegate = self;
    sv.pinchGestureRecognizer.enabled = NO;
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
    
    
    // 旋转手势
    UIRotationGestureRecognizer *rp = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotation:)];
//    [self.imageView addGestureRecognizer:rp];
    rp.delegate = self;
    self.imageView.userInteractionEnabled = YES;
    
    
    // 缩放手势
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handleScale:)];
    [self.imageView addGestureRecognizer:pinch];
    pinch.delegate = self;


    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 100, 160, 30)];
    label.backgroundColor = [UIColor yellowColor];
    [self.contentView addSubview:label];
    self.testL = label;
    label.textColor = [UIColor blackColor];
}



#pragma mark - UIScrollViewDelegate

//- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
//    return self.imageView;
//}

//
//- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view {
////    if (view == self.imageView) {
//////        NSLog(@"缩放1 %@", NSStringFromCGPoint(self.imageView.center));
//////        NSLog(@"缩放1 %@", self.imageView, NSStringFromCGSize(self.imageView.frame.size));
////
//////        CGPoint location = [scrollView.pinchGestureRecognizer locationInView:self.imageView];
//////        if (!CGPointEqualToPoint(CGPointZero, location)) {
////            [self modifyAnchorPointWithGesture:scrollView.pinchGestureRecognizer];
//////        }
////    }
//}
//
//- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale {
////    if (view == self.imageView) {
//////        NSLog(@"缩放2 %@", NSStringFromCGPoint(self.imageView.center));
////        // 恢复锚点
////        [self modifyAnchorPointWithGesture:nil];
////    }
//}
//
//- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
//    // 修复缩小的过程会偏上的 bug
////    CGFloat offsetX = MAX((scrollView.bounds.size.width - scrollView.contentInset.left - scrollView.contentInset.right - scrollView.contentSize.width) * 0.5, 0.0);
////    CGFloat offsetY = MAX((scrollView.bounds.size.height - scrollView.contentInset.top - scrollView.contentInset.bottom - scrollView.contentSize.height) * 0.5, 0.0);
////
////    self.imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
//
//    // 小图片的 x、y 有值，放大后会影响滚动区域
//    if (self.scrollView.zoomScale == self.scrollView.maximumZoomScale) {
//        self.scrollView.contentInset = UIEdgeInsetsMake(-self.imageView.y, -self.imageView.x, self.imageView.y, self.imageView.x);
//    } else {
//        self.scrollView.contentInset = UIEdgeInsetsZero;
//    }
//
//}

//-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    NSLog(@"hhh %@", scrollView);
//}


#pragma mark - 视觉差

// 视差，图片偏移
- (void)setXOffset:(float)x {
    // 系统自带的照片应用也是在放大照片的情况下，取消视差效果。
    // 如果在放大图片的时候也有视差效果，会在 ScanViewController 的 scrollViewDidScroll 方法里死循环
    if (self.scrollView.zoomScale != 1) {
        return;
    }
    
    // 图片缩放时，取消视差效果，防止死循环
    if (!CGAffineTransformIsIdentity(self.scaleTransform)) {
        return;
    }
    
    if (!CGAffineTransformIsIdentity(self.rotateTransform)) {
        return;
    }

//    CGRect newFrame = CGRectOffset(self.bounds, x, 0);
//    self.scrollView.frame = newFrame; // 会在 YCAssetPreviewVC 的 scrollViewDidScroll 方法里死循环
        
//    NSLog(@"%@, %f", NSStringFromSelector(_cmd), x);
    self.imageView.transform = CGAffineTransformMakeTranslation(x, 0);
}




#pragma mark - 手势

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
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

#pragma mark - 缩放

- (void)handleScale:(UIPinchGestureRecognizer *)pinch {
//    return;
    NSLog(@"location pinch = %@", NSStringFromCGPoint([pinch locationInView:self.imageView]));
    
    
//    static float lastScale = 1;
    
//    float scale = lastScale;
//    float scale = lastScale + (pinch.scale - 1);

//        if (pinch.scale >= 1) {
//            scale = lastScale + (pinch.scale - 1);
//        } else {
////            scale = lastScale - pinch.scale;
//            scale = lastScale * pinch.scale;
//        }
    
    float scale = self.lastScale * pinch.scale;

    NSLog(@"scale = %f", scale);

    if (pinch.state == UIGestureRecognizerStateBegan) {
        
        
    } else if (pinch.state == UIGestureRecognizerStateChanged) {
        

//        self.iv.transform = CGAffineTransformMakeScale(scale, scale);
        self.scaleTransform = CGAffineTransformMakeScale(scale, scale);
        self.imageView.transform = CGAffineTransformConcat(self.rotateTransform, self.scaleTransform);

        
    } else {
        self.lastScale = scale;
        self.scrollView.contentSize = self.imageView.frame.size;
//        [self resetCenter];
        [self resetContentOffset];
    }
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)tap {
    float scale;
    
    if (self.scrollView.zoomScale != self.scrollView.minimumZoomScale) {
        scale = self.scrollView.minimumZoomScale;
//        self.scrollView.contentInset = UIEdgeInsetsZero;
    } else {
        scale = self.scrollView.maximumZoomScale;
        // 双击放大后，显示不全的 bug
//        self.scrollView.contentInset = UIEdgeInsetsMake(-self.imageView.y, 0, self.imageView.y, 0);
    }
    
    CGPoint location = [self.doubleTap locationInView:self.imageView];
    float dx = fabs(location.x) / self.imageView.width;
    float dy = fabs(location.y) / self.imageView.height;

    CGRect zoomRect;
    zoomRect.size.height = self.scrollView.frame.size.height / scale;
    zoomRect.size.width  = self.scrollView.frame.size.width  / scale;
    zoomRect.origin.x    = location.x - (zoomRect.size.width  * dx);
    zoomRect.origin.y    = location.y - (zoomRect.size.height * dy);

    // 需要实现 viewForZoomingInScrollView
    [self.scrollView zoomToRect:zoomRect animated:YES];

}



#pragma mark - 旋转

- (void)handleRotation:(UIRotationGestureRecognizer *)rp {
    NSLog(@"location rotation = %@", NSStringFromCGPoint([rp locationInView:self.imageView]));

    CGFloat rotation = rp.rotation + self.lastRotation;
//    NSLog(@"%f", rp.rotation);
//    NSLog(@"r = %f, count = %d", rp.rotation, (int)(rotation/M_PI_2));

    if (rp.state == UIGestureRecognizerStateChanged) {
//        self.iv.transform = CGAffineTransformMakeRotation(rotation);
        
        self.rotateTransform = CGAffineTransformMakeRotation(rotation);
        self.imageView.transform = CGAffineTransformConcat(self.rotateTransform, self.scaleTransform);

    } else if (rp.state == UIGestureRecognizerStateEnded) {
//        float temp = rotation % M_PI_4;
//        int count = (int)(rotation/M_PI_4);
//        int co = (int)(rp.rotation/M_PI_4);
//        int count2 = (int)(rp.rotation/M_PI_2) + (int)((int)(rp.rotation) % (int)(M_PI_2))/M_PI_4;
//        int cou = (int)(rp.rotation/M_PI_2 + fmod(rp.rotation, M_PI_2)/M_PI_4);
        int c = (int)(rp.rotation/M_PI_2) + (int)(fmod(rp.rotation, M_PI_2)/M_PI_4);
        int count = c;

        float rota = count * M_PI_2 + self.lastRotation;
        self.lastRotation = rota;
        [UIView animateWithDuration:0.5 animations:^{
//            self.iv.transform = CGAffineTransformMakeRotation(rota);
            self.rotateTransform = CGAffineTransformMakeRotation(rota);
            self.imageView.transform = CGAffineTransformConcat(self.rotateTransform, self.scaleTransform);
            self.scrollView.contentSize = self.imageView.frame.size;
        }];

    }

}

#pragma mark -

- (void)prepareForReuse {
    [super prepareForReuse];
    
    NSLog(@"%p, 大小: %@ prepareForReuse", self.imageView, NSStringFromCGSize(self.imageView.frame.size));

    self.lastRotation = 0;
    self.lastScale = 1;
    self.scaleTransform = CGAffineTransformIdentity;
    self.rotateTransform = CGAffineTransformIdentity;
    self.imageView.transform = CGAffineTransformIdentity;
//    self.scaleTransform = CGAffineTransformMakeScale(1, 1);
//    self.rotateTransform = CGAffineTransformMakeRotation(0);
//    self.imageView.transform = CGAffineTransformConcat(self.rotateTransform, self.scaleTransform);

    
    UIScrollView *sv = self.scrollView;
    [sv setZoomScale:sv.minimumZoomScale animated:NO];
    sv.contentSize = CGSizeZero;
    sv.contentOffset = CGPointZero;
    self.imageView.layer.anchorPoint = CGPointMake(0.5, 0.5);
    self.imageView.frame = self.scrollView.bounds;
    NSLog(@"%p, 大小: %@ prepareForReuse22", self.imageView, NSStringFromCGSize(self.imageView.frame.size));
}

- (void)didEndDisplaying {
    NSLog(@"%p, 大小: %@ didEndDisplaying", self.imageView, NSStringFromCGSize(self.imageView.frame.size));

    self.lastRotation = 0;
    self.lastScale = 1;
    self.scaleTransform = CGAffineTransformIdentity;
    self.rotateTransform = CGAffineTransformIdentity;
    self.imageView.transform = CGAffineTransformIdentity;

    
    UIScrollView *sv = self.scrollView;
    [sv setZoomScale:sv.minimumZoomScale animated:NO];
    sv.contentSize = CGSizeZero;
    sv.contentOffset = CGPointZero;
    self.imageView.layer.anchorPoint = CGPointMake(0.5, 0.5);
    self.imageView.frame = self.scrollView.bounds;
    NSLog(@"%p, 大小: %@ didEndDisplaying2222", self.imageView, NSStringFromCGSize(self.imageView.frame.size));

}

- (void)resetContentOffset {
    UIView *scrollView = self.scrollView;
    UIView *view = self.imageView;

    CGRect f1 = self.imageView.frame;
    CGRect f2 = [self.imageView.superview convertRect:self.imageView.frame toView:self];
    CGRect f3 = self.imageView.bounds;
    CGRect f4 = self.frame;
    CGRect f5 = self.scrollView.frame;
    CGRect f6 = [self.imageView.superview convertRect:self.imageView.frame toView:self.scrollView];

    [self resetCenter];
    
//    self.scrollView.contentOffset = f1.origin;
    
    CGFloat x = - f1.origin.x;
    CGFloat y = - f1.origin.y;
    self.scrollView.contentOffset = CGPointMake(x, y);
    
    int i = 0;
//    CGPoint location
}


- (void)resetCenter {
    UIView *scrollView = self.scrollView;
    UIView *view = self.imageView;
    CGFloat width = fmax(view.width, scrollView.width);
    CGFloat height = fmax(view.height, scrollView.height);
    view.center = CGPointMake(width/2, height/2);
    [self log];

}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"image"]) {
        NSLog(@"%p, 大小: %@ ，observeValueForKeyPath", self.imageView, NSStringFromCGSize(self.imageView.frame.size));
//        self.imageView.frame = self.imageView.yc_imageRect;
        self.imageView.frame = self.imageView.image.yc_rectForScreen;
        NSLog(@"%p, 大小: %@ ，observeValueForKeyPath222", self.imageView, NSStringFromCGSize(self.imageView.frame.size));
        NSLog(@"%p, 大小: %@ ，observeValueForKeyPath333", self.imageView, NSStringFromCGSize(self.imageView.image.size));
        CGSize size = self.frame.size;
        self.imageView.center = CGPointMake(size.width/2, size.height/2);
        
        // 设置最大缩放
        UIImage *image = self.imageView.image;
        if (image.size.width + image.size.height) {
            float maxScale = (float)fmax(fmax(size.width/image.size.width, size.height/image.size.height), self.maxScale);
            self.scrollView.maximumZoomScale = maxScale;
        } else {
            self.scrollView.maximumZoomScale = self.maxScale;
        }
        
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)log {
    NSLog(@"------------------");
    NSLog(@"contentOffset = %@", NSStringFromCGPoint(self.scrollView.contentOffset));
    NSLog(@"contentSize = %@", NSStringFromCGSize(self.scrollView.contentSize));
    
    NSLog(@"center = %@", NSStringFromCGPoint(self.imageView.center));
    NSLog(@"Origin = %@", NSStringFromCGPoint(self.imageView.viewOrigin));
    NSLog(@"size = %@", NSStringFromCGSize(self.imageView.viewSize));
    
//    CGRect frame = [self.scrollView convertRect:self.scrollView.bounds toView:self.imageView];
//    NSLog(@"visiable = %@", NSStringFromCGRect(frame));
    NSLog(@"\n");
}


@end
