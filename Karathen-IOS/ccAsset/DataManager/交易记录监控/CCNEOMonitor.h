//
//  CCNEOMonitor.h
//  ccAsset
//
//  Created by SealWallet on 2018/10/29.
//  Copyright © 2018 raistone. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CCTradeRecord;

@interface CCNEOMonitor : NSObject

+ (instancetype)monitor;

/**
 定时刷新
 
 @param count 计数
 */
- (void)updateWithTimerCount:(NSInteger)count;


/**
 添加记录
 
 @param record 记录
 */
- (void)addRecord:(CCTradeRecord *)record;

@end

