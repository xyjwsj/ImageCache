//
//  SJImageCache.m
//  ImageCache
//
//  Created by Hoolai on 16/9/5.
//  Copyright © 2016年 wsj_proj. All rights reserved.
//

#import "SJImageCache.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import "SJGCDThreadPoolManager.h"
#import "SJThreadTask.h"

@implementation SJImageCache {
    NSFileManager *_fileManager;
    NSString* _namespace;
}

#pragma mark NSObject

- (id)initWithComponent:(NSString*)component {
    if ((self = [super init])) {
        _namespace = component;
        // Init the memory cache
        _memCache = [[NSMutableDictionary alloc] init];
        
        // Init the disk cache
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        _diskCachePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:component];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:_diskCachePath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:_diskCachePath
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:NULL];
        }
        
        // Init the operation queue
        
#if TARGET_OS_IPHONE
        // Subscribe to app events
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(clearMemory)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(cleanDisk)
                                                     name:UIApplicationWillTerminateNotification
                                                   object:nil];
        
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_4_0
        UIDevice *device = [UIDevice currentDevice];
        if ([device respondsToSelector:@selector(isMultitaskingSupported)] && device.multitaskingSupported) {
            // When in background, clean memory in order to have less chance to be killed
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(clearMemory)
                                                         name:UIApplicationDidEnterBackgroundNotification
                                                       object:nil];
        }
#endif
#endif
    }
    
    [[SJGCDThreadPoolManager threadPool] executeTask:[[SJThreadTask alloc] initWithRunBlock:^{
        _fileManager = [NSFileManager new];
    }]];
    
    
    return self;
}

- (void)dealloc
{
    _memCache = nil;
    _diskCachePath = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark SDImageCache (class methods)

+ (SJImageCache *)sharedImageCacheComponent:(NSString*)component {
    static dispatch_once_t once;
    static SJImageCache* instance;
    dispatch_once(&once, ^{
        instance = [[SJImageCache alloc] initWithComponent:component];
    });
    return instance;
}

#pragma mark SDImageCache (private)

/*
 *创建指定图片key的路径
 */
- (NSString *)cachePathForKey:(NSString *)key
{
    const char *cStr = [key UTF8String];
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5( cStr, strlen(cStr), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
    
    return [_diskCachePath stringByAppendingPathComponent:filename];
}


- (void)storeDataToDisk:(NSData *)imageData forKey:(NSString*)key {
    if (!imageData) {
        return;
    }
    
    if (![_fileManager fileExistsAtPath:_diskCachePath]) {
        [_fileManager createDirectoryAtPath:_diskCachePath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    
    // get cache Path for image key
    NSString *cachePathForKey = [self cachePathForKey:key];
    // transform to NSUrl
    NSURL *fileURL = [NSURL fileURLWithPath:cachePathForKey];
    
    [_fileManager createFileAtPath:cachePathForKey contents:imageData attributes:nil];
    
    // disable iCloud backup
    if (self.shouldDisableiCloud) {
        [fileURL setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:nil];
    }
    
}


#pragma mark ImageCache

/*
 *缓存图片
 *
 **/
- (void)storeImage:(UIImage *)image imageData:(NSData *)data forKey:(NSString *)key toDisk:(BOOL)toDisk
{
    if (!image || !key)
    {
        return;
    }
    
    //缓存图片到内存上
    [_memCache setObject:image forKey:key];
    
    //如果需要缓存到物理存储上，并data不为空，则把data缓存到物理存储上
    if (toDisk) {
        if (!data) return;
        //后台线程缓存图片到物理存储上
        __block typeof(self) weakSelf = self;
        [[SJGCDThreadPoolManager threadPool] executeTask:[SJThreadTask defaultRunBlock:^{
            [weakSelf storeDataToDisk:data forKey:key];
        }]];
    }
}

/*
 *保存图片到内存上，不保存到物理存储上
 */
- (void)storeImage:(UIImage *)image forKey:(NSString *)key {
    [self storeImage:image imageData:nil forKey:key toDisk:YES];
}
/*
 *保存图片到内存上，不保存到物理存储上
 */
- (void)storeImage:(UIImage *)image forKey:(NSString *)key toDisk:(BOOL)toDisk {
    [self storeImage:image imageData:nil forKey:key toDisk:toDisk];
}

/*
 *通过key返回指定图片
 */
- (UIImage *)imageFromKey:(NSString *)key
{
    return [self imageFromKey:key fromDisk:YES];
}

/*
 *返回一张图像
 *key：图像的key
 *fromDisk：如果内存中没有图片，是否在物理存储上查找
 *return 返回查找到的图片，如果没有则返回nil
 */
- (UIImage *)imageFromKey:(NSString *)key fromDisk:(BOOL)fromDisk
{
    if (key == nil) {
        return nil;
    }
    
    UIImage *image = [_memCache objectForKey:key];
    
    if (!image && fromDisk) //如果内存没有图片，并且可以在物理存储上查找，则返回物理存储上的图片
    {
        image = [[UIImage alloc] initWithContentsOfFile:[self cachePathForKey:key]];
        if (image)
        {
            [_memCache setObject:image forKey:key];
        }
    }
    
    return image;
}

- (void)queryCacheForKey:(NSString *)key delegate:(id <SJImageCacheDelegate>)delegate {
    if (!delegate) {
        return;
    }
    
    if (!key) {
        if ([delegate respondsToSelector:@selector(didNotFoundImageForKey:)]) {
            [delegate didNotFoundImageForKey:key];
        }
        return;
    }
    
    // First check the in-memory cache...
    UIImage *image = [_memCache objectForKey:key];
    if (image)
    {
        // ...notify delegate immediately, no need to go async
        if ([delegate respondsToSelector:@selector(didImageCache:)]) {
            [delegate didImageCache:image];
        }
        return;
    }
    
    [self queryDiskCacheWithKey:key delegate:delegate];
}

/*
 *查找物理缓存上的图片
 */
- (void)queryDiskCacheWithKey:(NSString *)key delegate:(id <SJImageCacheDelegate>)delegate {
    
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:[self cachePathForKey:key]];
    if (image) {
        if ([delegate respondsToSelector:@selector(didImageCache:)]) {
            [delegate didImageCache:image];
        }
    } else {
        if ([delegate respondsToSelector:@selector(didNotFoundImageForKey:)]) {
            [delegate didNotFoundImageForKey:key];
        }
    }
}

/*
 *从内存和物理存储上移除指定图片
 */
- (void)removeImageForKey:(NSString *)key
{
    if (key == nil)
    {
        return;
    }
    
    [_memCache removeObjectForKey:key];
    [[NSFileManager defaultManager] removeItemAtPath:[self cachePathForKey:key] error:nil];
}
/*
 *清除内存缓存区的图片
 */
- (void)clearMemory
{
    [_memCache removeAllObjects];
}

/*
 *清除物理存储上的图片
 */
- (void)clearDisk
{
    [[NSFileManager defaultManager] removeItemAtPath:_diskCachePath error:nil];
    [[NSFileManager defaultManager] createDirectoryAtPath:_diskCachePath
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:NULL];
}
/*
 *清除过期缓存的图片
 */
- (void)cleanDisk
{
    NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:-_maxCacheAge];
    NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:_diskCachePath];
    for (NSString *fileName in fileEnumerator)
    {
        NSString *filePath = [_diskCachePath stringByAppendingPathComponent:fileName];
        NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        if ([[[attrs fileModificationDate] laterDate:expirationDate] isEqualToDate:expirationDate])
        {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
    }
}

@end
