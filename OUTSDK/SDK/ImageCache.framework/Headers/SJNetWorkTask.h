//
//  SJNetWorkTask.h
//  ImageCache
//
//  Created by Hoolai on 16/9/6.
//  Copyright © 2016年 wsj_proj. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum: NSInteger{
    POST = 0,
    GET,
    PUT
}HTTP_TYPE;

typedef enum: NSInteger {
    JSON = 0,
    DIC
}DATA_TYPE;

typedef void(^HTTPCompletion)(BOOL result, NSDictionary* headers, NSData* data, NSError* error);

@interface SJNetWorkTask : NSObject<NSURLSessionDataDelegate>

- (instancetype)initWithHttpUrl:(NSString*)url httpType:(HTTP_TYPE)httpType dataType:(DATA_TYPE)dataType completedBlock:(HTTPCompletion)completedBlock;

- (instancetype)initWithHttpUrl:(NSString*)url httpType:(HTTP_TYPE)httpType dataType:(DATA_TYPE)dataType params:(NSDictionary*)params completedBlock:(HTTPCompletion)completedBlock;

- (instancetype)initWithHttpUrl:(NSString*)url httpType:(HTTP_TYPE)httpType dataType:(DATA_TYPE)dataType headers:(NSDictionary*)headers params:(NSDictionary*)params completedBlock:(HTTPCompletion)completedBlock;

- (void)startTask;

@end
