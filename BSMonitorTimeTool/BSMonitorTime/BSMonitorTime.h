//
//  BSMonitorTime.h
//  获取任意线程的调用栈
//
//  Created by 宋澎 on 2019/3/28.
//  Copyright © 2019年 宋澎. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BSMonitorTime : NSObject

// 监控器单例
+ (nonnull instancetype)sharedTimer;

// 启动监控
- (void)startMonitoringTimer;
// 关闭监控
- (void)closeMonitoringTimer;

// 打印方法耗时
- (void)logAllCallStack;
// 手动显示日志
- (void)manualShowLog;

@end

@interface BSMonitorTimeModel : NSObject

@property (nonatomic,copy) NSString * functionName;         //方法名称
@property (nonatomic,assign) CGFloat consumeTime;           //消耗时间
@property (nonatomic,copy) NSString * functionAddress;      //方法地址

@end


NS_ASSUME_NONNULL_END
