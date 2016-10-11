//
//  SJNetWorkManager.h
//  ImageCache
//
//  Created by Hoolai on 16/9/6.
//  Copyright © 2016年 wsj_proj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SJNetWorkTask.h"

@interface SJNetWorkManager : NSObject

+ (instancetype)netWorkManager;

+ (instancetype)defaultJSONNetWorkManager;

#pragma all args

- (void)httpGetURL:(NSString*)url dataType:(DATA_TYPE)dataType completion:(HTTPCompletion)completion;

- (void)httpGetURL:(NSString*)url dataType:(DATA_TYPE)dataType params:(NSDictionary*)params completion:(HTTPCompletion)completion;

- (void)httpGetURL:(NSString*)url dataType:(DATA_TYPE)dataType params:(NSDictionary*)params headers:(NSDictionary*)headers completion:(HTTPCompletion)completion;

- (void)httpPostURL:(NSString*)url dataType:(DATA_TYPE)dataType params:(NSDictionary*)params completion:(HTTPCompletion)completion;

- (void)httpPostURL:(NSString*)url dataType:(DATA_TYPE)dataType params:(NSDictionary*)params headers:(NSDictionary*)headers completion:(HTTPCompletion)completion;

#pragma default dataType

- (void)httpGetURL:(NSString*)url completion:(HTTPCompletion)completion;

- (void)httpGetURL:(NSString*)url params:(NSDictionary*)params completion:(HTTPCompletion)completion;

- (void)httpGetURL:(NSString*)url params:(NSDictionary*)params headers:(NSDictionary*)headers completion:(HTTPCompletion)completion;

- (void)httpPutURL:(NSString*)url completion:(HTTPCompletion)completion;

- (void)httpPutURL:(NSString*)url params:(NSDictionary*)params completion:(HTTPCompletion)completion;

- (void)httpPutURL:(NSString*)url params:(NSDictionary*)params headers:(NSDictionary*)headers completion:(HTTPCompletion)completion;

- (void)httpPostURL:(NSString*)url params:(NSDictionary*)params completion:(HTTPCompletion)completion;

- (void)httpPostURL:(NSString*)url params:(NSDictionary*)params headers:(NSDictionary*)headers completion:(HTTPCompletion)completion;

@end
