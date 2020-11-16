//
//  YCAssetPreviewCell.m
//  YCPictureManager
//
//  Created by 余超 on 2020/11/12.
//

#import "YCAssetPreviewCell.h"

@implementation YCAssetPreviewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self config];
    }
    return self;
}

- (void)config {
    UIImageView *iv = [UIImageView new];
    iv.contentMode = UIViewContentModeScaleAspectFit;
//    iv.layer.masksToBounds = YES;
    self.imageView = iv;
    [self.contentView addSubview:iv];
    
//    self.backgroundColor = [UIColor yellowColor];
//    iv.backgroundColor = [UIColor blueColor];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.frame = self.bounds;
}

@end
