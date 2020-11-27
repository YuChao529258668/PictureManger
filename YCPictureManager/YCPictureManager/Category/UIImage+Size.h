//
//  UIImage+Size.h
//  YCPictureManager
//
//  Created by 余超 on 2020/11/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Size)

- (CGRect)yc_rectForScreen;

- (CGRect)yc_rectForFrame:(CGRect)frame;

@end

NS_ASSUME_NONNULL_END
