//
//  SJGCDThreadPoolManager.m
//  ImageCache
//
//  Created by Hoolai on 16/9/3.
//  Copyright © 2016年 wsj_proj. All rights reserved.
//

#import "SJGCDThreadPoolManager.h"

#define DISPATCH_GROUP_NUM 5

@interface SJGCDThreadPoolManager()

@end

@implementation SJGCDThreadPoolManager {
    dispatch_queue_t concurrentQueue; //并行队列
    dispatch_group_t groups[DISPATCH_GROUP_NUM];
    int groupStatus[DISPATCH_GROUP_NUM];
    
    NSLock* _lock;
    
}

+ (instancetype)threadPoolWithNamespace:(NSString*)ns{
    static dispatch_once_t once;
    static SJGCDThreadPoolManager* instance;
    dispatch_once(&once, ^{
        instance = [[SJGCDThreadPoolManager alloc] initWithNamespace:ns];
    });
    return instance;
}

- (instancetype)initWithNamespace:(NSString*)ns {
    if (self = [super init]) {
        concurrentQueue = dispatch_queue_create([ns UTF8String], DISPATCH_QUEUE_CONCURRENT);
        for (int i = 0; i < sizeof(groups) / sizeof(groups[0]); i++) {
            groups[i] = dispatch_group_create();
            groupStatus[i] = 0;
        }
        
        _lock = [[NSLock alloc] init];
    }

    return self;
}

- (dispatch_group_t)getGroup {
    dispatch_group_t canUseGroup;
    [_lock lock];
    for (int i = 0; i < sizeof(groups) / sizeof(groups[0]); i++) {
        if (groupStatus[i] == 0) {
            canUseGroup = groups[i];
            groupStatus[i] = 1; //group 忙
            break;
        }
    }
    [_lock unlock];
    return canUseGroup;
}

- (void)deallocGroup:(dispatch_group_t)group {
    [_lock lock];
    
    for (int i = 0; i < sizeof(groups) / sizeof(groups[0]); i++) {
        if (groups[i] == group) {
            groupStatus[i] = 0; //释放group
            break;
        }
    }
    
    [_lock unlock];
}

#pragma open api

- (void)executeTask:(SJThreadTask *)task {
    dispatch_block_t taskBlock = ^{
        if (!task.runBlock) {
            NSLog(@"no setting task execute code");
            return;
        }
        task.runBlock(task);
    };
    dispatch_async(concurrentQueue, taskBlock);
}

-(void)executeTasks:(NSArray<SJThreadTask *> *)tasks {
    for (SJThreadTask* task in tasks) {
        [self executeTask:task];
    }
}


- (void)executeTasks:(NSArray<SJThreadTask *> *)tasks completion:(void (^)(BOOL))completion {
    dispatch_group_t useGroup = [self getGroup];
    for (SJThreadTask* task in tasks) {
        dispatch_group_async(useGroup, concurrentQueue, ^{
            if (!task.runBlock) {
                NSLog(@"no setting task execute code");
                return;
            }
            task.runBlock(task);
        });
    }
    dispatch_group_notify(useGroup, concurrentQueue, ^{
        [self deallocGroup:useGroup];
        if (completion) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                completion(YES);
            });
        }
    });
}

#pragma open api end


@end
