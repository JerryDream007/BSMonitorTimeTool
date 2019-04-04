//
//  ViewController.m
//  BSMonitorTimeTool
//
//  Created by 宋澎 on 2019/4/4.
//  Copyright © 2019年 宋澎. All rights reserved.
//

#import "ViewController.h"
#import "BSMonitorTime.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self testAAAAAAAAAAA];
}

- (void)testAAAAAAAAAAA{
    [self testBBBBBBBBBB];
}

- (void)testBBBBBBBBBB{
    while (true) {
        sleep(3);
        break;
    }
}

- (void)viewDidAppear:(BOOL)animated{
    //打印日志
    [[BSMonitorTime sharedTimer] logAllCallStack];
}

@end
