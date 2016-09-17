//
//  UIImageView+SJNetImage.m
//  ImageCache
//
//  Created by Hoolai on 16/9/5.
//  Copyright © 2016年 wsj_proj. All rights reserved.
//

#import "UIImageView+SJNetImage.h"
#import "SJNetImageManager.h"
#import <objc/runtime.h>

NSString* const imageCompletionKeyBlock = @"imageCompletionKeyBlock";
NSString* const imageProgressKeyBlock = @"imageProgressKeyBlock";

@implementation UIImageView (SJNetImage)

-(void)setImageUrl:(NSString *)url placeholderImage:(UIImage*)placeholderImage completion:(LoadCompletion)completion {
    objc_setAssociatedObject(self, &imageCompletionKeyBlock, completion, OBJC_ASSOCIATION_COPY);
    [[SJNetImageManager netImageManager] imageWithURL:url placeholderImage:placeholderImage imageView:self];
}

- (void)setImageUrl:(NSString *)url placeholderImage:(UIImage *)placeholderImage progressBlock:(void (^)(int64_t, int64_t, float))progressBlock completion:(LoadCompletion)completion {
    objc_setAssociatedObject(self, &imageCompletionKeyBlock, completion, OBJC_ASSOCIATION_COPY);
    [[SJNetImageManager netImageManager] imageWithURL:url placeholderImage:placeholderImage imageView:self progressBlock:progressBlock];
}

- (void)blockImage:(UIImage *)image {
    [self setImage:image];
    if (objc_getAssociatedObject(self, &imageCompletionKeyBlock)) {
        LoadCompletion blockCompletion = (LoadCompletion)objc_getAssociatedObject(self, &imageCompletionKeyBlock);
        if (image) {
            blockCompletion(YES, image);
        } else {
            blockCompletion(NO, nil);
        }
    }
    
}

@end
