//
//  UIImageView+SJNetImage.m
//  ImageCache
//
//  Created by Hoolai on 16/9/5.
//  Copyright © 2016年 wsj_proj. All rights reserved.
//

#import "UIImageView+SJNetImage.h"
#import "SJNetImageManager.h"

@implementation UIImageView (SJNetImage)

-(void)setImageUrl:(NSString *)url placeholderImage:(NSString *)placeholderImage {
    [[SJNetImageManager netImageManager] imageWithURL:url placeholderImage:placeholderImage imageView:self];
}

@end
