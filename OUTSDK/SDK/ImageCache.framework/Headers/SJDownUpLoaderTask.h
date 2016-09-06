//
//  SJDownLoaderTask.h
//  ImageCache
//
//  Created by Hoolai on 16/9/5.
//  Copyright © 2016年 wsj_proj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^SJImageDownloaderCompletedBlock)(UIImage *image);
typedef void(^SJImageUploaderCompletedBlock)(BOOL result, NSData* data);

@interface SJDownUpLoaderTask : NSObject<NSURLSessionDownloadDelegate, NSURLSessionDataDelegate>

- (instancetype)initDownloadURL:(NSString*)url completedBlock:(SJImageDownloaderCompletedBlock)completedBlock;

- (instancetype)initUploadURL:(NSString*)url image:(NSData*)image completedBlock:(SJImageUploaderCompletedBlock)completedBlock;

- (instancetype)initUploadURL:(NSString*)url images:(NSArray*)images completedBlock:(SJImageUploaderCompletedBlock)completedBlock;

- (void)startTask;

@end
