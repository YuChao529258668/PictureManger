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
//    iv.contentMode = UIViewContentModeScaleAspectFit;// yctest
    iv.layer.masksToBounds = YES;
    self.imageView = iv;
    [self.contentView addSubview:iv];
    
//    self.backgroundColor = [UIColor yellowColor];
//    iv.backgroundColor = [UIColor blueColor];
    
    
//    UIBlurEffectStyleExtraLight,
//    UIBlurEffectStyleLight,
//    UIBlurEffectStyleDark,

    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *effectview = [[UIVisualEffectView alloc] initWithEffect:blur];
    [self.contentView addSubview:effectview];
    self.blurView = effectview;
    effectview.alpha = 0.6;

    UILabel *infoL = [UILabel new];
    self.infoL = infoL;
    [self.contentView addSubview:infoL];
    infoL.textColor = [UIColor whiteColor];
    infoL.font = [UIFont systemFontOfSize:13];
    infoL.textAlignment = NSTextAlignmentRight;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.frame = self.bounds;
    self.blurView.frame = CGRectMake(0, self.bounds.size.height-26, self.bounds.size.width, 26);
    self.infoL.frame = CGRectMake(4, self.bounds.size.height-26, self.bounds.size.width-8, 26);
}

@end
