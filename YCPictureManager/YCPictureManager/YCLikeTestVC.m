//
//  YCLikeTestVC.m
//  YCPictureManager
//
//  Created by 余超 on 2020/11/23.
//

#import "YCLikeTestVC.h"
#import "YCAssetsManager.h"
#import "YCImageCompare.h"

@interface YCLikeTestVC ()
@property (nonatomic, strong) PHFetchResult<PHAsset *> *result;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, strong) NSMutableArray<NSMutableArray *> *allLikeArray;
@end

@implementation YCLikeTestVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.7 alpha:0.7];
    self.size = CGSizeMake(125, 125);
    
    self.result = [YCAssetsManager fetchLowAssetsWithCount:1000];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self test];
    });

}

- (void)test {
    
    if (self.result.count <= 1) {
        return;
    }
    
    NSInteger count = self.result.count;
    PHAsset *pre;
    PHAsset *next;
    NSMutableArray *allLikeArray = [NSMutableArray array];
    NSMutableArray *oneLikeArray = nil;
    
    for (NSUInteger i = 0; i + 1 < count; i++) {
        @autoreleasepool {
            NSLog(@"i = %@", @(i));
            pre = [self.result objectAtIndex:i];
            next = [self.result objectAtIndex:i+1];
            
            if ([self isLikePre:pre withNext:next]) {
                if (!oneLikeArray) {
                    oneLikeArray = [NSMutableArray array];
                    [allLikeArray addObject:oneLikeArray];
                }
                if (![oneLikeArray.lastObject isEqual:pre]) {
                    [oneLikeArray addObject:pre];
                }
                [oneLikeArray addObject:next];
            } else {
                oneLikeArray = nil;
            }
        }
    }
    
    self.allLikeArray = allLikeArray;
//    NSLog(@"%@", self.allLikeArray);
    NSLog(@"相同照片组数：%@", @(self.allLikeArray.count));
}

- (BOOL)isLikePre:(PHAsset *)pre withNext:(PHAsset *)next {
    if (!pre || !next) {
        return NO;
    }
    
    __block BOOL error;
    __block UIImage *preImage;
    __block UIImage *nextImage;
    
    [YCAssetsManager requestLowImage:pre size:self.size handler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        error = result? NO: YES;
        preImage = result;
    }];
    
    if (error) {
        return NO;
    }
    
    [YCAssetsManager requestLowImage:next size:self.size handler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        error = result? NO: YES;
        nextImage = result;
    }];
    
    if (error) {
        return NO;
    }

    BOOL like = [YCImageCompare isImage:preImage likeImage:nextImage];
    return like;
}


@end
