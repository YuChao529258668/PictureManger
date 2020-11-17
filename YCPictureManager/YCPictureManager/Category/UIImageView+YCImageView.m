//
//  UIImageView+YCImageView.m
//  图片浏览
//
//  Created by 余超 on 2017/7/25.
//  Copyright © 2017年 yc. All rights reserved.
//

#import "UIImageView+YCImageView.h"

@implementation UIImageView (YCImageView)

- (CGRect)yc_imageRect {
    if (self.frame.size.height == 0 || self.frame.size.width == 0) {
        return CGRectZero;
    }

    if (self.contentMode == UIViewContentModeScaleAspectFill
        || self.contentMode == UIViewContentModeScaleToFill) {
        return self.bounds;
    }
    
    UIImage *image = self.image;
    
    if (!image) {
//        return CGRectZero;
        return self.bounds;
    }
    
    float hfactor = image.size.width / self.frame.size.width;
    float vfactor = image.size.height / self.frame.size.height;
    
    float factor = fmax(hfactor, vfactor);
    
    // Divide the size by the greater of the vertical or horizontal shrinkage factor
    float newWidth = image.size.width / factor;
    float newHeight = image.size.height / factor;
    
    // Then figure out if you need to offset it to center vertically or horizontally
    float leftOffset = (self.frame.size.width - newWidth) / 2;
    float topOffset = (self.frame.size.height - newHeight) / 2;
    
    return CGRectMake(leftOffset, topOffset, newWidth, newHeight);
}

- (CGRect)yc_imageRect2 {
    if (self == nil) {
        return CGRectZero;
    }
    
    CGSize imageSize = self.image.size;
    CGSize screenSize = self.frame.size;
    
    float width = 0;
    float height = 0;
    float x = 0;
    float y = 0;
    float factor = imageSize.width / imageSize.height;
    
    if (imageSize.height > imageSize.width) {
        height = screenSize.height;
        width = height * factor;
    } else {
        width = screenSize.width;
        height = width / factor;
    }
    
    x = (screenSize.width - width) / 2;
    y = (screenSize.height - height) / 2;
    
    return CGRectMake(x, y, width, height);
}



@end
