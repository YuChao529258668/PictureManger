//
//  YCLikeTestVC.m
//  YCPictureManager
//
//  Created by 余超 on 2020/11/23.
//

#import "YCLikeTestVC.h"
#import "YCAssetsManager.h"

@interface YCLikeTestVC ()
@property (nonatomic, strong) PHFetchResult<PHAsset *> *result;
@end

@implementation YCLikeTestVC

- (void)viewDidLoad {
    [super viewDidLoad];
    

}

- (void)test {
    
    if (self.result.count <= 1) {
        return;
    }
    
    NSInteger count = self.result.count;
    PHAsset *pre;
    PHAsset *next;
    NSMutableArray *allLikeArray = [NSMutableArray array];
    NSMutableArray *oneLikeArray = [NSMutableArray array];
    
    for (NSUInteger i = 0; i + 1 < count; i++) {
        
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

- (BOOL)isLikePre:(PHAsset *)pre withNext:(PHAsset *)next {
    
    return YES;
}


@end
