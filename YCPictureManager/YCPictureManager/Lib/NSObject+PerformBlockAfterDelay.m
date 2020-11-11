//
//  NSObject+PerformBlockAfterDelay.m
//  139PushMail
//
//  Created by LeadtoneDev on 14-4-10.
//  Copyright (c) 2014年 立通无限. All rights reserved.
//

#import "NSObject+PerformBlockAfterDelay.h"

@implementation NSObject (PerformBlockAfterDelay)
- (void)performBlock:(void (^)(void))block
          afterDelay:(NSTimeInterval)delay
{
    if ([NSThread isMainThread]) {
        
    block = [block copy];
    [self performSelector:@selector(fireBlockAfterDelay:)
               withObject:block
               afterDelay:delay];
        
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
            if (block) {
                block();
            }
        });
    }
}

- (void)fireBlockAfterDelay:(void (^)(void))block {
    block();
}
-(void)doAsyncBlock:(void (^)(void))block{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        block();
    });
}
-(void)doAsyGlobalBlock:(void (^)(void))block{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),block);
}
-(void)doAsyncBlock:(void (^)(void))block delay:(float)delay{
    
    if ([NSThread isMainThread]) {
        
    block = [block copy];
    [self performSelector:@selector(doAsyncBlock:)
               withObject:block
               afterDelay:delay];

    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
            if (block) {
                block();
            }
        });
    }

}
-(void)doUIBlock:(void (^)(void))block{
    if ([NSThread currentThread].isMainThread) {
        if (block) {
            block();
        }
    } else {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (block) {
        block();
        }
    });
    }
}
-(void)doUIBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay{
//    block = [block copy];
//    [self performSelector:@selector(doUIBlock:)
//               withObject:block
//               afterDelay:delay];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (block) {
            block();
        }
    });
}

- (void)doSyncUIBlock:(void (^)(void))block {
    if ([NSThread currentThread].isMainThread) {
        if (block) {
            block();
        }
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

@end
