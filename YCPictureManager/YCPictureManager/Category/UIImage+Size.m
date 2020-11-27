//
//  UIImage+Size.m
//  YCPictureManager
//
//  Created by 余超 on 2020/11/27.
//

#import "UIImage+Size.h"

@implementation UIImage (Size)

- (CGRect)yc_rectForScreen {
    return [self yc_rectForFrame:[UIScreen mainScreen].bounds];
}

- (CGRect)yc_rectForFrame:(CGRect)frame {
    if (frame.size.height == 0 || frame.size.width == 0) {
        return CGRectZero;
    }
    
    UIImage *image = self;
        
    float hfactor = image.size.width / frame.size.width;
    float vfactor = image.size.height / frame.size.height;
    
    float factor = fmax(hfactor, vfactor);
    
    // Divide the size by the greater of the vertical or horizontal shrinkage factor
    float newWidth = image.size.width / factor;
    float newHeight = image.size.height / factor;
    
    // Then figure out if you need to offset it to center vertically or horizontally
    float leftOffset = (frame.size.width - newWidth) / 2;
    float topOffset = (frame.size.height - newHeight) / 2;
    
    return CGRectMake(leftOffset, topOffset, newWidth, newHeight);
}

@end
