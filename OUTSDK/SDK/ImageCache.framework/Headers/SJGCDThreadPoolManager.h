//
//  SJGCDThreadPoolManager.h
//  ImageCache
//
//  Created by Hoolai on 16/9/3.
//  Copyright © 2016年 wsj_proj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SJThreadTask.h"

@interface SJGCDThreadPoolManager : NSObject

+ (instancetype)threadPool;

/**
 *  未加入调度组，执行一个任务
 *
 *  @param task 执行任务
 */
- (void)executeTask:(SJThreadTask*)task;

/**
 *  未加入调度组，执行多个任务
 *
 *  @param tasks 多个任务
 */
- (void)executeTasks:(NSArray<SJThreadTask*>*)tasks;


/**
 *  执行多个任务
 *
 *  @param tasks      多个任务
 *  @param completion 完成回调
 */
- (void)executeTasks:(NSArray<SJThreadTask *> *)tasks completion:(void(^)(BOOL result))completion;

@end
