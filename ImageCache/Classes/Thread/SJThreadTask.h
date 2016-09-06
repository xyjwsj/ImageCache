//
//  SJThreadTask.h
//  ImageCache
//
//  Created by Hoolai on 16/9/3.
//  Copyright © 2016年 wsj_proj. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSInteger {
    SERIAL_TASK,
    CONCURRENT_TASK
}TaskType;

@class TaskCompletion;

@interface SJThreadTask : NSObject

@property (nonatomic, copy) void (^runBlock)();


/**
 *  初始化任务
 *
 *  @param runBlock   执行代码块
 *  @param completion 执行完成回调
 *
 *  @return 任务
 */
- (instancetype)initWithRunBlock:(void(^)())runBlock;

+ (instancetype)defaultRunBlock:(void(^)())runBlock;

@end
