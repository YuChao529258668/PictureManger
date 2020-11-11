//
//  NSObject+PerformBlockAfterDelay.h
//  139PushMail
//
//  Created by LeadtoneDev on 14-4-10.
//  Copyright (c) 2014年 立通无限. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SB(block,args...)  block?block(args):nil

@interface NSObject (PerformBlockAfterDelay)
- (void)performBlock:(void (^)(void))block
          afterDelay:(NSTimeInterval)delay;
-(void)doAsyncBlock:(void (^)(void))block;
-(void)doAsyGlobalBlock:(void (^)(void))block;
-(void)doAsyncBlock:(void (^)(void))block delay:(float)delay;
-(void)doUIBlock:(void (^)(void))block;
-(void)doUIBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay;

/// 如果当前是主线程，直接执行，否则在主线程同步执行
- (void)doSyncUIBlock:(void (^)(void))block;

@end
