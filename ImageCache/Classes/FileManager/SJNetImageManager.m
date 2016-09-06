//
//  SJNetImageManager.m
//  ImageCache
//
//  Created by Hoolai on 16/9/5.
//  Copyright © 2016年 wsj_proj. All rights reserved.
//

#import "SJNetImageManager.h"
#import "SJGCDThreadPoolManager.h"
#import "SJThreadTask.h"
#import "SJDownUpLoaderTask.h"

static NSString* namespaceStr = @"com.hoolai.access";

@implementation SJNetImageManager {
    NSMutableDictionary* dic;
    NSMutableDictionary* dicStatus;
    NSMutableDictionary* dicData;
}

+ (instancetype)netImageManager {
    static dispatch_once_t once;
    static SJNetImageManager* instance;
    dispatch_once(&once, ^{
        instance = [[SJNetImageManager alloc] init];
    });

    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        dic = [NSMutableDictionary dictionary];
        dicStatus = [NSMutableDictionary dictionary];
        dicData = [NSMutableDictionary dictionary];
    }
    return  self;
}

- (void)imageWithURL:(NSString *)url placeholderImage:(NSString *)placeholderImage imageView:(UIImageView *)imageView {
    [imageView setImage:[UIImage imageNamed:placeholderImage]];
    [self showThreadTaskWithImageView:imageView url:url];
}

- (UIImageView *)imageWithURL:(NSString *)url placeholderImage:(NSString *)placeholderImage {
    UIImageView* imageView = [[UIImageView alloc] init];
    [imageView setImage:[UIImage imageNamed:placeholderImage]];
    [self showThreadTaskWithImageView:imageView url:url];
    return imageView;
}

- (SJThreadTask*)showThreadTaskWithImageView:(UIImageView*)imageView url:(NSString*)url{
    __block UIImageView* weakImageView = imageView;
    __block SJDownUpLoaderTask* downloadTask = [[SJDownUpLoaderTask alloc] initDownloadURL:url completedBlock:^(UIImage *image) {
        [weakImageView setImage:image];
    }];
    SJThreadTask* task = [SJThreadTask defaultRunBlock:^{
        [downloadTask startTask];
    }];
    [[SJGCDThreadPoolManager threadPoolWithNamespace:namespaceStr] executeTask:task];
    return task;
}

- (void)uploadWithURL:(NSString *)url images:(NSArray<UIImage *> *)images completed:(GroupUploadCompleted)completed {
    
//    @synchronized (self) {
//        NSString *timeString = [NSString stringWithFormat:@"%f%f", [self time], [self time]];
//        [dic setObject:completed forKey:timeString];
//        [dicStatus setObject:@(images.count) forKey:timeString];
//        NSMutableArray* tasks = [NSMutableArray array];
//        for (UIImage* image in images) {
//            [tasks addObject:[self threadTaskWithUrl:url image:image idStr:timeString]];
//        }
//        [[SJGCDThreadPoolManager threadPoolWithNamespace:namespaceStr] executeTasks:tasks completion:^(BOOL result) {
//            
//        }];
//    }
    
    __block SJDownUpLoaderTask* uploadTask = [[SJDownUpLoaderTask alloc] initUploadURL:url images:images completedBlock:^(BOOL result, NSData *data) {
        if (completed) {
            completed(result, nil);
        }
    }];
    SJThreadTask* task = [SJThreadTask defaultRunBlock:^{
        [uploadTask startTask];
    }];
    [[SJGCDThreadPoolManager threadPoolWithNamespace:namespaceStr] executeTask:task];
    
}

- (NSTimeInterval)time {
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970]*1000;
    return a;
}

- (SJThreadTask*)threadTaskWithUrl:(NSString*)url image:(UIImage*)image idStr:(NSString*)str{
    
    __block SJDownUpLoaderTask* uploadTask = [[SJDownUpLoaderTask alloc] initUploadURL:url image:UIImagePNGRepresentation(image) completedBlock:^(BOOL result, NSData* data) {
        [self notifyUploadCompleted:str result:result uploadResult:data];
    }];
    SJThreadTask* task = [SJThreadTask defaultRunBlock:^{
        [uploadTask startTask];
    }];
    return task;
}

- (void)notifyUploadCompleted:(NSString*)idStr result:(BOOL)result uploadResult:(NSData*)uploadResult{
    @synchronized (self) {
        NSInteger status = [[dicStatus objectForKey:idStr] integerValue];
        if (status < 0) {
            return;
        }
        if (result) {
            [dicStatus setObject:@([[dic objectForKey:idStr] integerValue] - 1) forKey:idStr];
            NSMutableArray* array = [dicData objectForKey:idStr];
            if (array == nil) {
                array = [NSMutableArray array];
            }
            [array addObject:uploadResult];
            [dicData setObject:array forKey:idStr];
            
            if ([[dicStatus objectForKey:idStr] integerValue] == 0) {
                GroupUploadCompleted completed = [dic objectForKey:idStr];
                completed(YES, [[dicData objectForKey:idStr] copy]);
                [dic removeObjectForKey:idStr];
                [dicStatus removeObjectForKey:idStr];
                [dicData removeObjectForKey:idStr];
            }
        } else {
            [dicStatus setObject:@(-1) forKey:idStr];
            GroupUploadCompleted completed = [dic objectForKey:idStr];
            completed(NO, nil);
            [dic removeObjectForKey:idStr];
            [dicStatus removeObjectForKey:idStr];
            [dicData removeObjectForKey:idStr];
        }
    }
}


@end