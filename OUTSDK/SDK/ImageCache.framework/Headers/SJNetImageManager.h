//
//  SJNetImageManager.h
//  ImageCache
//
//  Created by Hoolai on 16/9/5.
//  Copyright © 2016年 wsj_proj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^GroupUploadCompleted)(BOOL result, NSData* data);

@interface SJNetImageManager : NSObject

+ (instancetype)netImageManager;

- (void)imageWithURL:(NSString*)url placeholderImage:(NSString*)placeholderImage imageView:(UIImageView*)imageView;

- (UIImageView*)imageWithURL:(NSString*)url placeholderImage:(NSString*)placeholderImage;

- (void)uploadWithURL:(NSString*)url images:(NSArray<UIImage*>*)images completed:(GroupUploadCompleted)completed;

@end
