//
//  SJNetWorkManager.m
//  ImageCache
//
//  Created by Hoolai on 16/9/6.
//  Copyright © 2016年 wsj_proj. All rights reserved.
//

#import "SJNetWorkManager.h"
#import "SJGCDThreadPoolManager.h"
#import "SJThreadTask.h"

@implementation SJNetWorkManager {
    DATA_TYPE _dataType;
}

+ (instancetype)netWorkManager {
    static dispatch_once_t once;
    static SJNetWorkManager* instance;
    dispatch_once(&once, ^{
        instance = [[SJNetWorkManager alloc] init];
    });
    return instance;
}

+ (instancetype)defaultJSONNetWorkManager {
    static dispatch_once_t once;
    static SJNetWorkManager* instance;
    dispatch_once(&once, ^{
        instance = [[SJNetWorkManager alloc] initWithDataType:JSON];
    });
    return instance;
}

- (instancetype)initWithDataType:(DATA_TYPE)dataType {
    if (self = [super init]) {
        _dataType = JSON;
    }
    return self;
}

#pragma default http get

- (void)httpGetURL:(NSString *)url completion:(HTTPCompletion)completion {
    [self httpGetURL:url dataType:_dataType params:nil headers:nil completion:completion];
}

- (void)httpGetURL:(NSString *)url params:(NSDictionary *)params completion:(HTTPCompletion)completion {
    [self httpGetURL:url dataType:_dataType params:params headers:nil completion:completion];
}

- (void)httpGetURL:(NSString *)url params:(NSDictionary *)params headers:(NSDictionary *)headers completion:(HTTPCompletion)completion {
    [self httpRequestURL:url httpType:GET dataType:_dataType params:params headers:headers completion:completion];
}

#pragma default http put

- (void)httpPutURL:(NSString *)url completion:(HTTPCompletion)completion {
    [self httpPutURL:url dataType:_dataType params:nil headers:nil completion:completion];
}

- (void)httpPutURL:(NSString *)url params:(NSDictionary *)params completion:(HTTPCompletion)completion {
    [self httpPutURL:url dataType:_dataType params:params headers:nil completion:completion];
}

- (void)httpPutURL:(NSString *)url params:(NSDictionary *)params headers:(NSDictionary *)headers completion:(HTTPCompletion)completion {
    [self httpRequestURL:url httpType:GET dataType:_dataType params:params headers:headers completion:completion];
}

#pragma default post http

- (void)httpPostURL:(NSString *)url params:(NSDictionary *)params completion:(HTTPCompletion)completion {
    [self httpPostURL:url dataType:_dataType params:params headers:nil completion:completion];
}

- (void)httpPostURL:(NSString *)url params:(NSDictionary *)params headers:(NSDictionary *)headers completion:(HTTPCompletion)completion {
    [self httpRequestURL:url httpType:POST dataType:_dataType params:params headers:headers completion:completion];
}

//###############################################
#pragma get http

- (void)httpGetURL:(NSString *)url dataType:(DATA_TYPE)dataType completion:(HTTPCompletion)completion {
    [self httpGetURL:url dataType:dataType params:nil headers:nil completion:completion];
}

- (void)httpGetURL:(NSString *)url dataType:(DATA_TYPE)dataType params:(NSDictionary *)params completion:(HTTPCompletion)completion {
    [self httpGetURL:url dataType:dataType params:params headers:nil completion:completion];
}

- (void)httpGetURL:(NSString *)url dataType:(DATA_TYPE)dataType params:(NSDictionary *)params headers:(NSDictionary *)headers completion:(HTTPCompletion)completion {
    [self httpRequestURL:url httpType:GET dataType:dataType params:params headers:headers completion:completion];
}

//////
#pragma put http

- (void)httpPutURL:(NSString *)url dataType:(DATA_TYPE)dataType completion:(HTTPCompletion)completion {
    [self httpPutURL:url dataType:dataType params:nil headers:nil completion:completion];
}

- (void)httpPutURL:(NSString *)url dataType:(DATA_TYPE)dataType params:(NSDictionary *)params completion:(HTTPCompletion)completion {
    [self httpPutURL:url dataType:dataType params:params headers:nil completion:completion];
}

- (void)httpPutURL:(NSString *)url dataType:(DATA_TYPE)dataType params:(NSDictionary *)params headers:(NSDictionary *)headers completion:(HTTPCompletion)completion {
    [self httpRequestURL:url httpType:PUT dataType:dataType params:params headers:headers completion:completion];
}

#pragma post http

- (void)httpPostURL:(NSString *)url dataType:(DATA_TYPE)dataType params:(NSDictionary *)params completion:(HTTPCompletion)completion {
    [self httpPostURL:url dataType:dataType params:params headers:nil completion:completion];
}

- (void)httpPostURL:(NSString *)url dataType:(DATA_TYPE)dataType params:(NSDictionary *)params headers:(NSDictionary *)headers completion:(HTTPCompletion)completion {
    [self httpRequestURL:url httpType:POST dataType:dataType params:params headers:headers completion:completion];
}

#pragma private http method

- (void)httpRequestURL:(NSString *)url httpType:(HTTP_TYPE)httpType dataType:(DATA_TYPE)dataType params:(NSDictionary *)params   headers:(NSDictionary *)headers completion:(HTTPCompletion)completion {
    __block SJNetWorkTask* netTask = [[SJNetWorkTask alloc] initWithHttpUrl:url httpType:httpType dataType:dataType headers:headers params:params completedBlock:^(BOOL result, NSDictionary *headers, NSData *data, NSError *error) {
        if (completion) {
            completion(result, headers, data, error);
        }
    }];
    [[SJGCDThreadPoolManager threadPool] executeTask:[SJThreadTask defaultRunBlock:^{
        [netTask startTask];
    }]];
}

@end
