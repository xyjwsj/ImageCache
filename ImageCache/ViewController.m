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
#import "SJNetWorkManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(100, 150, 50, 40);
    btn.backgroundColor = [UIColor grayColor];
    [btn setTitle:@"测试" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(upload) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    UIButton* btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn1.frame = CGRectMake(100, 200, 50, 40);
    btn1.backgroundColor = [UIColor grayColor];
    [btn1 setTitle:@"http" forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(testHttp) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:btn1];
    
}

- (void)testHttp {
    
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:@(123) forKey:@"gameId"];
    [dic setObject:@(123) forKey:@"hoolaiPassportId"];
    [dic setObject:@"string" forKey:@"reason"];
    [dic setObject:@(YES) forKey:@"resolved"];
    
    NSArray* array = [[NSArray alloc] initWithObjects:@"string", nil];
    
    [dic setObject:array forKey:@"pictureUrls"];
    
    [[SJNetWorkManager netWorkManager] httpPostURL:@"http://192.168.150.117:9000/api/open/test" dataType:JSON params:dic completion:^(BOOL result, NSDictionary *headers, NSData *data, NSError *error) {
        NSError* error1 = nil;
        id res = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error1];
        NSLog(@"tst");
    }];
}

- (void)upload {
    NSMutableArray* images = [NSMutableArray array];
    [images addObject:[UIImage imageNamed:@"963_03"]];
    [[SJNetImageManager netImageManager] uploadWithURL:@"http://www.hoolaiimg.com/h/fileUpload/upload" images:images completed:^(BOOL result, NSData *uploadData) {
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
