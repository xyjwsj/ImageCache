//
//  UIImageView+SJNetImage.h
//  ImageCache
//
//  Created by Hoolai on 16/9/5.
//  Copyright © 2016年 wsj_proj. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^LoadCompletion)(BOOL result, UIImage* image);

@interface UIImageView (SJNetImage)

-(void)setImageUrl:(NSString*)url placeholderImage:(UIImage*)placeholderImage completion:(LoadCompletion)completion;

- (void)blockImage:(UIImage*)image;

@end
