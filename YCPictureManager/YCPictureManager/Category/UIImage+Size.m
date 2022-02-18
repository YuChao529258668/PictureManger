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

//- (CGRect)yc_rectForFrame:(CGRect)frame {
//    if (frame.size.height == 0 || frame.size.width == 0) {
//        return CGRectZero;
//    }
//
//    UIImage *image = self;
//
//    float hfactor = image.size.width / frame.size.width;
//    float vfactor = image.size.height / frame.size.height;
//
//    float factor = fmax(hfactor, vfactor);
//
//    // Divide the size by the greater of the vertical or horizontal shrinkage factor
//    float newWidth = image.size.width / factor;
//    float newHeight = image.size.height / factor;
//
//    // Then figure out if you need to offset it to center vertically or horizontally
//    float leftOffset = (frame.size.width - newWidth) / 2;
//    float topOffset = (frame.size.height - newHeight) / 2;
//
//    return CGRectMake(leftOffset, topOffset, newWidth, newHeight);
//}

- (CGRect)yc_rectForFrame:(CGRect)frame {
    CGSize input = self.size;
    CGSize output = [self yc_sizeOfInput:input max:frame.size];
    
    if (output.height == 0 || output.width == 0) {
        return CGRectZero;
    }
    
    // Then figure out if you need to offset it to center vertically or horizontally
    float leftOffset = (frame.size.width - output.width) / 2;
    float topOffset = (frame.size.height - output.height) / 2;
    
    return CGRectMake(leftOffset, topOffset, output.width, output.height);
}

- (CGSize)yc_sizeOfInput:(CGSize)input max:(CGSize)max {
    if (input.width == 0 || input.height == 0
        || max.width == 0 || max.height == 0)
    {
        return input;
    }
    
    float hfactor = input.width / max.width;
    float vfactor = input.height / max.height;
    
    float factor = fmax(hfactor, vfactor);
    
    // Divide the size by the greater of the vertical or horizontal shrinkage factor
    float newWidth = input.width / factor;
    float newHeight = input.height / factor;
    
    return CGSizeMake(newWidth, newHeight);
}


@end
