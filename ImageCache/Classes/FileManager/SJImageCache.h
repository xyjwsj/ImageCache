//
//  SJImageCache.h
//  ImageCache
//
//  Created by Hoolai on 16/9/5.
//  Copyright © 2016年 wsj_proj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SJImageCache : NSObject
@property (nonatomic, retain) NSMutableDictionary *memCache;//内存缓存图片引用
@property (assign, nonatomic) NSInteger maxCacheAge;
@property (nonatomic, retain) NSString *diskCachePath;//物理缓存路径
@property (nonatomic, assign) NSTimeInterval cacheMaxCacheAge;
@property (assign, nonatomic) BOOL shouldDisableiCloud;

+(instancetype)sharedImageCacheComponent:(NSString*)component;

/*
 *创建指定图片key的路径
 */

/**
 *  创建指定图片key的路径
 *
 *  @param key 路径或唯一标示
 *
 *  @return 路径
 */
- (NSString *)cachePathForKey:(NSString *)key;

/**
 *  保存图片
 *
 *  @param image <#image description#>
 *  @param key   <#key description#>
 */
- (void)storeImage:(UIImage *)image forKey:(NSString *)key;

//

/**
 *  保存图片，并选择是否保存到物理存储上
 *
 *  @param image  图片Image
 *  @param key    路径或其他唯一标示
 *  @param toDisk 是否存储硬盘
 */
- (void)storeImage:(UIImage *)image forKey:(NSString *)key toDisk:(BOOL)toDisk;

/**
 *  保存图片，可以选择把NSData数据保存到物理存储上
 *
 *  @param image  图片Image
 *  @param data   图片data
 *  @param key    路径或其他唯一标示
 *  @param toDisk 是否存储硬盘
 */
- (void)storeImage:(UIImage *)image imageData:(NSData *)data forKey:(NSString *)key toDisk:(BOOL)toDisk;

/**
 *  <#Description#>
 *
 *  @param key      <#key description#>
 *  @param delegate <#delegate description#>
 */
- (void)queryCacheForKey:(NSString *)key delegate:(void(^)(BOOL find, NSString* key, UIImage* image))delegate;

//清除key索引的图片
- (void)removeImageForKey:(NSString *)key;
//清除内存图片
- (void)clearMemory;
//清除物理缓存
- (void)clearDisk;
//清除过期物理缓存
- (void)cleanDisk;

@end
