//
//  CCBlueTooth.h
//  karathen
//
//  Created by MengLiMing on 2018/11/23.
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



@end
