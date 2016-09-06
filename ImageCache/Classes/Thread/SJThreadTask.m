//
//  SJThreadTask.m
//  ImageCache
//
//  Created by Hoolai on 16/9/3.
//  Copyright © 2016年 wsj_proj. All rights reserved.
//

#import "SJThreadTask.h"

@interface SJThreadTask()

@property (nonatomic, retain) NSString* taskId;
@property (nonatomic, retain) NSString* taskName;

@end

@implementation SJThreadTask

- (instancetype)initWithRunBlock:(void(^)())runBlock {
    if (self = [super init]) {
        _runBlock = runBlock;
    }
    return self;
}

+ (instancetype)defaultRunBlock:(void (^)())runBlock {
    return [[SJThreadTask alloc] initWithRunBlock:runBlock];
}

@end