//
//  YCAssetListBaseCell.m
//  YCPictureManager
//
//  Created by 余超 on 2020/11/11.
//

#import "YCAssetListBaseCell.h"

@implementation YCAssetListBaseCell

//- (void)awakeFromNib {
//    [super awakeFromNib];
//}

//- (instancetype)initWithCoder:(NSCoder *)coder
//{
//    self = [super initWithCoder:coder];
//    if (self) {
//        [self config];
//    }
//    return self;
//}

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
    iv.contentMode = UIViewContentModeScaleAspectFill;
    iv.layer.masksToBounds = YES;
    self.imageView = iv;
    [self.contentView addSubview:iv];
    
    self.backgroundColor = [UIColor yellowColor];
    iv.backgroundColor = [UIColor blueColor];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.frame = self.bounds;
}

@end
