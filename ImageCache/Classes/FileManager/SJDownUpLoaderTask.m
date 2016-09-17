//
//  SJDownLoaderTask.m
//  ImageCache
//
//  Created by Hoolai on 16/9/5.
//  Copyright © 2016年 wsj_proj. All rights reserved.
//

#import "SJDownUpLoaderTask.h"
#import "SJImageCache.h"

static NSString* component = @"access";

typedef enum: NSInteger {
    DOWNLOAD_TASK = 0,
    SIGNLE_UPLOAD_TASK,
    MUTI_UPLOAD_TASK
}RequestType;

@implementation SJDownUpLoaderTask {
    NSURLSessionDownloadTask* _downLoadTask;
    NSURLSessionUploadTask* _upLoadTask;
    NSURLSessionDataTask* _dataTask;
    NSURLSession* _session;
    NSString* _urlStr;
    SJImageDownloaderCompletedBlock _downLoadcompletedBlock;
    SJImageUploaderCompletedBlock _upLoadcompletedBlock;
    SJImageLoadProgressBlock _loadProgressBlock;
    RequestType _type;
}

- (instancetype)initDownloadURL:(NSString *)url completedBlock:(SJImageDownloaderCompletedBlock)completedBlock {
    return [self initDownloadURL:url progressBlock:nil completedBlock:completedBlock];
}

- (instancetype)initDownloadURL:(NSString *)url progressBlock:(SJImageLoadProgressBlock)progressBlock completedBlock:(SJImageDownloaderCompletedBlock)completedBlock {
    if (self = [super init]) {
        _urlStr = url;
        _type = DOWNLOAD_TASK;
        _downLoadcompletedBlock = completedBlock;
        NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        NSURL *downloadURL = [NSURL URLWithString:url];
        _downLoadTask = [_session downloadTaskWithURL:downloadURL];
        _loadProgressBlock = progressBlock;
    }
    return  self;
}

- (instancetype)initUploadURL:(NSString *)url image:(NSData*)image completedBlock:(SJImageUploaderCompletedBlock)completedBlock {
    if (self = [super init]) {
        _type = SIGNLE_UPLOAD_TASK;
        // 1. 创建URL
        NSURL *urlRequest = [NSURL URLWithString:url];
        // 2. 创建请求
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:urlRequest];
        // 设置请求的为POST
        request.HTTPMethod = @"POST";
        
        // 3.构建要上传的数据
        
        // 设置request的body
        request.HTTPBody = image;
        
        // 设置请求 Content-Length
        [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)image.length] forHTTPHeaderField:@"Content-Length"];
        // 设置请求 Content-Type
        [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",@"Xia"] forHTTPHeaderField:@"Content-Type"];
//        [request setValue:[NSString stringWithFormat:@"application/json; boundary=%@",@"Xia"] forHTTPHeaderField:@"Content-Type"];
        _upLoadcompletedBlock = completedBlock;
        
        // 4. 创建会话
        _session = [NSURLSession sharedSession];
        _upLoadTask = [_session uploadTaskWithRequest:request fromData:image completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSError* error1 = nil;
            id res = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error1];
            if (!error) {
                // 上传成功
                if (_upLoadcompletedBlock) {
                    _upLoadcompletedBlock(YES, nil);
                }
            }else {
                // 上传失败, 打印error信息
                NSLog(@"error --- %@", error.localizedDescription);
                if (_upLoadcompletedBlock) {
                    _upLoadcompletedBlock(NO, nil);
                }
            }  
        }];
    }
    return  self;
}

- (instancetype)initUploadURL:(NSString *)url images:(NSArray *)images completedBlock:(SJImageUploaderCompletedBlock)completedBlock {
    if (self = [super init]) {
        _type = MUTI_UPLOAD_TASK;
        NSString* KBoundary = @"AaB03x";
        // 1. 创建URL
        NSURL *urlRequest = [NSURL URLWithString:url];
        // 2. 创建请求
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:urlRequest];
        // 设置请求的为POST
        request.HTTPMethod = @"POST";
        
        //    multipart/form-data; boundary=---------------------------2079310075963042894277672019
        
        //设置请求头信息
        NSString * type=[NSString stringWithFormat:@"multipart/form-data; boundary=%@",KBoundary];
//        NSString * type=[NSString stringWithFormat:@"application/json; boundary=%@",KBoundary];
        [request setValue:type forHTTPHeaderField:@"Content-Type"];
        
        NSDictionary * parmaterDict=[NSMutableDictionary dictionary];
        
        
        request.HTTPBody =[self getHttpBodWithKeyData:[self getFileData:images key:@"Filedata"] andParmaters:parmaterDict];
        
        _upLoadcompletedBlock = completedBlock;
        
        // 4. 创建会话
        _session = [NSURLSession sharedSession];
        _dataTask = [_session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (!error) {
                completedBlock(YES, data);
            } else {
                completedBlock(NO, data);
            }
        }];
    }

    return self;
}

- (NSDictionary*)getFileData:(NSArray*)datas key:(NSString*)key {
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    NSString* fileKey = @"";
    for (int i = 0; i < datas.count; i ++) {
        if (i == 0) {
            fileKey = key;
        } else {
            fileKey = [NSString stringWithFormat:@"%@%d", key, i];
        }
        [dic setObject:UIImagePNGRepresentation(datas[i]) forKey:fileKey];
    }
    return dic;
}

/**
 *  Description
 *
 *  @param keyName   服务器需要识别的 获取文件的名称userfile[]
 *  @param filesDict 文件上传的字典 。key = 文件的名字，value =文件的路径
 *  @param parmaters 文本字典 key =参数名 ,value = 参数值
 */
-(NSData *)getHttpBodWithKeyData:(NSDictionary *)datas andParmaters:(NSDictionary *)parmaters
{
    NSString* KBoundary = @"AaB03x";
    //循环头部信息
    //    -----------------------------2079310075963042894277672019
    //    Content-Disposition: form-data; name="userfile[]"; filename="test.rtf"
    //    Content-Type: application/octet-stream 通用类型
    
    NSMutableData * data=[NSMutableData data];
    
    [datas enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        
        NSString * fileName=key;
        NSData* fileData = obj;
        
        
        NSMutableString * headerString=[NSMutableString stringWithFormat:@"\r\n--%@\r\n",KBoundary];
        NSString * type=[NSString stringWithFormat:@"Content-Disposition: form-data;name=%@; filename=%@\r\n",fileName, fileName];
        
        [headerString appendString:type];
        
        //使用通用类型的方法 application/octet-stream
        [headerString appendFormat:@"Content-Type: application/json\r\n\r\n"];
        
        
        [data appendData:[headerString dataUsingEncoding:NSUTF8StringEncoding]];
        
        
        //创建文件内容
        
        [data appendData:fileData];
        
    }];
    
    
    //获取文本信息
    [parmaters enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        
        //文件格式
        
        //        -----------------------------2079310075963042894277672019
        //        Content-Disposition: form-data; name="username"
        //
        //        文本内容
        NSString * parmaterKey=key;
        NSString * parmaterValue=obj;
        
        
        NSMutableString * textStr=[NSMutableString stringWithFormat:@"\r\n--%@\r\n",KBoundary];
        
        [textStr appendFormat:@"Content-Disposition: form-data;name=%@\r\n\r\n",parmaterKey];
        
        [data appendData:[textStr dataUsingEncoding:NSUTF8StringEncoding]];
        
        
        //文本内容
        NSData * msgData=[parmaterValue dataUsingEncoding:NSUTF8StringEncoding];
        
        [data appendData:msgData];
        
        
        
    }];
    
    //加入尾部
    NSMutableString * footerString=[NSMutableString stringWithFormat:@"\r\n--%@--",KBoundary];
    
    [data appendData:[footerString dataUsingEncoding:NSUTF8StringEncoding]];
    
    return data;
    
    
}


- (void)startTask {
    if (_type == DOWNLOAD_TASK) {
        [_downLoadTask resume];
    }
    if (_type == SIGNLE_UPLOAD_TASK) {
        [_upLoadTask resume];
    }
    if (_type == MUTI_UPLOAD_TASK) {
        [_dataTask resume];
    }
}

#pragma mark - NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    // 将临时文件剪切或者复制Caches文件夹
    NSFileManager *mgr = [NSFileManager defaultManager];
    
    NSString* path = [[SJImageCache sharedImageCacheComponent:component] cachePathForKey:_urlStr];
    // AtPath : 剪切前的文件路径
    // ToPath : 剪切后的文件路径
    [mgr moveItemAtPath:location.path toPath:path error:nil];
    if (_downLoadcompletedBlock) {
        _downLoadcompletedBlock([UIImage imageWithContentsOfFile:path]);
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
//    NSLog(@"获得下载进度--%@", [NSThread currentThread]);
    if (_loadProgressBlock) {
        NSString* currentStr = [NSString stringWithFormat:@"%lld", totalBytesWritten];
        NSString* totalStr = [NSString stringWithFormat:@"%lld", totalBytesExpectedToWrite];
        _loadProgressBlock(totalBytesWritten, totalBytesExpectedToWrite, [currentStr longLongValue]*1.0/[totalStr longLongValue]);
    }

}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes
{
    
}

@end
