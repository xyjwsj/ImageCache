//
//  UIImageView+SJNetImage.h
//  ImageCache
//
//  Created by Hoolai on 16/9/5.
//  Copyright © 2016年 wsj_proj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^LoadCompletion)(BOOL result, UIImage* image);
typedef void(^LoadProgress)(int64_t current, int64_t total, float progress);

@interface UIImageView (SJNetImage)

-(void)setImageUrl:(NSString*)url placeholderImage:(UIImage*)placeholderImage completion:(LoadCompletion)completion;

-(void)setImageUrl:(NSString*)url placeholderImage:(UIImage*)placeholderImage progressBlock:(LoadProgress)progressBlock completion:(LoadCompletion)completion;

- (void)blockImage:(UIImage*)image;

@end
