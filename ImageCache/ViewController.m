//
//  ViewController.m
//  ImageCache
//
//  Created by Hoolai on 16/9/3.
//  Copyright © 2016年 wsj_proj. All rights reserved.
//

#import "ViewController.h"
#import "SJThreadTask.h"
#import "SJGCDThreadPoolManager.h"
#import "SJNetImageManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 50, 40);
    btn.backgroundColor = [UIColor grayColor];
    [btn setTitle:@"测试" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(upload) forControlEvents:UIControlEventTouchUpInside];
    btn.center = self.view.center;
    [self.view addSubview:btn];
    
}

- (void)upload {
    NSMutableArray* images = [NSMutableArray array];
    [images addObject:[UIImage imageNamed:@"963_03"]];
    [[SJNetImageManager netImageManager] uploadWithURL:@"http://www.hoolaiimg.com/h/fileUpload/upload" images:images completed:^(BOOL result, NSArray *uploadData) {
        NSLog(@"tst");
        
    }];
}

- (void)test {
    NSMutableArray* tasks = [NSMutableArray array];
    for (int i = 1; i <= 10; i++) {
        SJThreadTask* task = [self createTask:[NSString stringWithFormat:@"%d", i]];
//        [[SJGCDThreadPoolManager threadPool] executeTask:task];
        [tasks addObject:task];
    }
    
//    [[SJGCDThreadPoolManager threadPool] executeTasks:tasks completion:^(BOOL result) {
//        NSLog(@"execute task completion");
//    }];
}

- (SJThreadTask*)createTask:(NSString*)idStr {
    SJThreadTask* task = [[SJThreadTask alloc] initWithRunBlock:^() {
        NSLog(@"execute id: %@", idStr);
    }];
    return task;
}

@end
