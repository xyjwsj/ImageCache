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

NSString* const imageKeyBlock = @"imageKeyBlock";

@implementation UIImageView (SJNetImage)

-(void)setImageUrl:(NSString *)url placeholderImage:(UIImage*)placeholderImage completion:(LoadCompletion)completion {
    objc_setAssociatedObject(self, &imageKeyBlock, completion, OBJC_ASSOCIATION_COPY);
    [[SJNetImageManager netImageManager] imageWithURL:url placeholderImage:placeholderImage imageView:self];
}

- (void)blockImage:(UIImage *)image {
    [self setImage:image];
    if (objc_getAssociatedObject(self, &imageKeyBlock)) {
        LoadCompletion blockCompletion = (LoadCompletion)objc_getAssociatedObject(self, &imageKeyBlock);
        if (image) {
            blockCompletion(YES, image);
        } else {
            blockCompletion(NO, nil);
        }
    }
    
}

@end
