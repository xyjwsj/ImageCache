//
//  SJNetImageManager.h
//  ImageCache
//
//  Created by Hoolai on 16/9/5.
//  Copyright © 2016年 wsj_proj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SJImageCache.h"

typedef void(^GroupUploadCompleted)(BOOL result, NSData* data);
typedef void(^NetImageProgressBlock)(int64_t current, int64_t total, float progress);

@interface SJNetImageManager : NSObject

+ (instancetype)netImageManager;

- (void)imageWithURL:(NSString*)url placeholderImage:(UIImage*)placeholderImage imageView:(UIImageView*)imageView;

- (void)imageWithURL:(NSString*)url placeholderImage:(UIImage*)placeholderImage imageView:(UIImageView*)imageView progressBlock:(NetImageProgressBlock)progressBlock;

- (UIImageView*)imageWithURL:(NSString*)url placeholderImage:(NSString*)placeholderImage;

- (void)uploadWithURL:(NSString*)url images:(NSArray<UIImage*>*)images completed:(GroupUploadCompleted)completed;

@end
