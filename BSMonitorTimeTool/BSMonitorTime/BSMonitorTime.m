//
//  BSMonitorTime.m
//  获取任意线程的调用栈
//
//  Created by 宋澎 on 2019/3/28.
//  Copyright © 2019年 宋澎. All rights reserved.
//

#import "BSMonitorTime.h"
#import "BSBacktraceLogger.h"
#import "UIViewController+Common.h"

#define TimeTnterval 0.01       //监控的时间间隔，建议0.01秒最佳
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#ifdef DEBUG
#define BSLog(s, ... ) NSLog( @"[%@：in line: %d]-->%@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define BSLog(s, ... )
#endif

@interface BSMonitorTime ()

@property (nonatomic,strong) dispatch_source_t monitoringTimer;         //监控定时器
@property (nonatomic,strong) dispatch_source_t logTimer;                //日志定时器
@property (nonatomic,strong) NSMutableDictionary * callStackDict;       //调用栈Map
@property (nonatomic,strong) NSMutableArray * whiteList;                //控制器白名单，想要监控的白名单

@end

@implementation BSMonitorTime

+ (nonnull instancetype)sharedTimer{
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

// 启动监控
- (void)startMonitoringTimer{
    self.monitoringTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
    self.callStackDict = [NSMutableDictionary dictionary];
    dispatch_source_set_timer(self.monitoringTimer, dispatch_walltime(NULL, 0), TimeTnterval * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(self.monitoringTimer, ^{
        // key-代表方法调用地址 value-代表方法调用名称
        NSDictionary * mainThreadCallStack = [BSBacktraceLogger bs_backtraceMapOfMainThread];
        for (NSString * funcAddress in mainThreadCallStack.allKeys) {
            NSString * funcName = [mainThreadCallStack objectForKey:funcAddress];
            BSMonitorTimeModel * model = [self.callStackDict objectForKey:funcAddress];
            if (model == nil){
                model = [BSMonitorTimeModel new];
                model.functionName = funcName;
                model.consumeTime = TimeTnterval;
                model.functionAddress = funcAddress;
                [self.callStackDict setObject:model forKey:funcAddress];
            }else{
                model.consumeTime = model.consumeTime + TimeTnterval;
            }
        }
    });
    dispatch_resume(self.monitoringTimer);
}

// 关闭监控
- (void)closeMonitoringTimer{
    dispatch_source_cancel(self.monitoringTimer);
}

- (void)addLogButton{
    UIButton * logButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [logButton setTitle:@"显示方法耗时日志" forState:UIControlStateNormal];
    logButton.backgroundColor = [UIColor blackColor];
    logButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [logButton sizeToFit];
    CGFloat width = logButton.frame.size.width;
    logButton.frame = CGRectMake((kScreenWidth - width)/2, 44, width, 20);
    [logButton addTarget:self action:@selector(logAllCallStack) forControlEvents:UIControlEventTouchUpInside];
    UIWindow * keyWindow = [[UIApplication sharedApplication] keyWindow];
    [keyWindow addSubview:logButton];
    [keyWindow bringSubviewToFront:logButton];
}

/// 手动显示日志
- (void)manualShowLog{
    [self performSelector:@selector(addLogButton) withObject:nil afterDelay:0.1];
}

/// 自动显示日志
- (void)autoShowLog{
    self.logTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
    dispatch_source_set_timer(self.logTimer, dispatch_walltime(NULL, 0), 5 * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(self.logTimer, ^{
        [self logAllCallStack];
    });
    dispatch_resume(self.logTimer);
}

/// 取消自动显示日志
- (void)closeAutoShowLog{
    dispatch_source_cancel(self.logTimer);
}

/// 打印所有调用栈
- (void)logAllCallStack{
    NSMutableString * resultString = [NSMutableString stringWithFormat:@""];
    for (NSString * key in self.callStackDict.allKeys) {
        BSMonitorTimeModel * model = [self.callStackDict objectForKey:key];
        if (model.functionName && model.consumeTime > TimeTnterval){
            [resultString appendFormat:@"%@的耗时为：%0.2f \n\n\n",model.functionName,model.consumeTime];
        }
    }
//    BSLog(@"%@",[resultString copy]);
    UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:@"主线程中所有的方法耗时(误差0.01s)：" message:[resultString copy] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertVC addAction:confirmAction];
    [[UIViewController currentViewController] presentViewController:alertVC animated:true completion:nil];
}

@end

@implementation BSMonitorTimeModel

@end
