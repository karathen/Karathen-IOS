//
//  CCBlueTooth.h
//  ccAsset
//
//  Created by SealWallet on 2018/11/23.
//  Copyright © 2018 raistone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCBlueTooth : NSObject

@property (nonatomic, assign, readonly) BOOL blueToothOpen;

+ (CCBlueTooth *)blueTooth;

/**
 监控蓝牙状态
 */
- (void)startMonitor;

/**
 蓝牙状态改变

 @param observer 观察者
 @param stateChange 开启关闭
 */
+ (void)blueToothObserver:(id)observer stateChange:(void(^)(BOOL blueToothOpen))stateChange;


@end
