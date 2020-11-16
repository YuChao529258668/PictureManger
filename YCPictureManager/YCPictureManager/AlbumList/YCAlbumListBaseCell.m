//
//  YCAlbumListBaseCell.m
//  YCPictureManager
//
//  Created by 余超 on 2020/11/16.
//

#import "YCAlbumListBaseCell.h"

@implementation YCAlbumListBaseCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self config];
    }
    return self;
}

- (void)config {
    // imageView
    UIImageView *iv = [UIImageView new];
    iv.contentMode = UIViewContentModeScaleAspectFill;
    iv.layer.cornerRadius = 6;
    iv.layer.masksToBounds = YES;
    self.imageView = iv;
    [self.contentView addSubview:iv];
    
    
    // labels
    UILabel *nameL = [UILabel new];
    nameL.font = [UIFont systemFontOfSize:16];
    nameL.textColor = [UIColor blackColor];
    self.nameL = nameL;
    [self.contentView addSubview:nameL];
    
    UILabel *countL = [UILabel new];
    countL.font = [UIFont systemFontOfSize:15];
    countL.textColor = [UIColor grayColor];
    self.countL = countL;
    [self.contentView addSubview:countL];
    
//    self.backgroundColor = [UIColor yellowColor];
//    iv.backgroundColor = [UIColor blueColor];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // h: 160 + 10 + 14 + 8 +12 = 204
    CGSize size = self.bounds.size;
    self.imageView.frame = CGRectMake(0, 0, size.width, size.width);
    self.nameL.frame = CGRectMake(0, CGRectGetMaxY(self.imageView.frame)+10, size.width, 14);
    self.countL.frame = CGRectMake(0, CGRectGetMaxY(self.nameL.frame)+8, size.width, 12);
}

@end
