//
//  SJNetWorkTask.m
//  ImageCache
//
//  Created by Hoolai on 16/9/6.
//  Copyright © 2016年 wsj_proj. All rights reserved.
//

#import "SJNetWorkTask.h"

@implementation SJNetWorkTask {
    NSURLSession *_session;
    NSURLSessionDataTask *_task;
    NSMutableData* _data;
    HTTPCompletion _completdBlock;
}

- (instancetype)initWithHttpUrl:(NSString *)url httpType:(HTTP_TYPE)httpType dataType:(DATA_TYPE)dataType completedBlock:(HTTPCompletion)completedBlock {
    return [self initWithHttpUrl:url httpType:httpType dataType:dataType headers:nil params:nil completedBlock:completedBlock];
}

- (instancetype)initWithHttpUrl:(NSString *)url httpType:(HTTP_TYPE)httpType dataType:(DATA_TYPE)dataType params:(NSDictionary *)params completedBlock:(HTTPCompletion)completedBlock {
    return [self initWithHttpUrl:url httpType:httpType dataType:dataType headers:nil params:params completedBlock:completedBlock];
}

- (instancetype)initWithHttpUrl:(NSString *)url httpType:(HTTP_TYPE)httpType dataType:(DATA_TYPE)dataType headers:(NSDictionary *)headers params:(NSDictionary *)params completedBlock:(HTTPCompletion)completedBlock {
    //1 构造URL网络地址
    _completdBlock = completedBlock;
    NSURL *requestUrl = [NSURL URLWithString:url];
    
    //2 构造网络请求对象  NSURLRequest
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:requestUrl];
    //设置请求方式 GET
    if (httpType == GET) {
        request.HTTPMethod = @"GET";
    } else {
        request.HTTPMethod = @"POST";
    }
    
    if (headers) {
        request.allHTTPHeaderFields = headers;
    }
    
    if (params) {
        NSData* postData = [self setHttpBody:params dataType:dataType];
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        if (dataType == JSON) {
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        }
        if (dataType == DIC) {
            [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        }
        [request setHTTPBody:postData];
    }
    
    
    //设置请求的超时时间
    request.timeoutInterval = 60;
    
    _session = [NSURLSession sharedSession];
    
    _task = [_session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"网络请求完成");
        
        //获取响应头
        //将响应对象 转化为NSHTTPURLResponse对象
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        //获取网络连接的状态码
        //  200 成功  404 网页未找到
        NSLog(@"状态码:%li", httpResponse.statusCode);
        if (httpResponse.statusCode == 200) {
            NSLog(@"请求成功");
            completedBlock(YES, httpResponse.allHeaderFields, data, nil);
        } else {
            completedBlock(NO, nil, nil, error);
        }
        
    }];
    return self;
}

- (NSData*)setHttpBody:(NSDictionary*)params dataType:(DATA_TYPE)dataType{
    if (dataType == JSON) {
        return [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
    }

    NSMutableData* data = [NSMutableData data];
    NSArray* allKeys = [params allKeys];
    NSString* textStr = @"";
    for (int i = 0; i < params.count; i++) {
        if (i == 0) {
            textStr = [NSString stringWithFormat:@"%@=%@", allKeys[i], [params objectForKey:allKeys[i]]];
        } else {
            textStr = [NSString stringWithFormat:@"&%@=%@", allKeys[i], [params objectForKey:allKeys[i]]];
        }
        [data appendData:[textStr dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    return data;
}

- (void)startTask {
    [_task resume];
}

-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    //通过状态码来判断石是否成功
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if (httpResponse.statusCode == 200) {
        NSLog(@"请求成功");
        
        NSLog(@"%@", httpResponse.allHeaderFields);
        
        //初始化接受数据的NSData变量
        _data = [[NSMutableData alloc] init];
        
        //执行Block回调 来继续接收响应体数据
        //执行completionHandler 用于使网络连接继续接受数据
        /*
         NSURLSessionResponseCancel 取消接受
         NSURLSessionResponseAllow  继续接受
         NSURLSessionResponseBecomeDownload 将当前任务 转化为一个下载任务
         NSURLSessionResponseBecomeStream   将当前任务 转化为流任务
         */
//        completionHandler(NSURLSessionResponseAllow);
        
    } else {
        NSLog(@"请求失败");
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    //    NSLog(@"收到了一个数据包");
    
    //拼接完整数据
    [_data appendData:data];
    NSLog(@"接受到了%li字节的数据", data.length);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    NSLog(@"数据接收完成");
    
    if (error) {
        NSLog(@"数据接收出错!");
        //清空出错的数据
        _data = nil;
    } else {
        //数据传输成功无误，JSON解析数据
        //        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:_data options:NSJSONReadingMutableLeaves error:nil];
        //        NSLog(@"%@", dic);
    }
}

@end
