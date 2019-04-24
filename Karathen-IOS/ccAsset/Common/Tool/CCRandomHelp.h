//
//  CCRandomHelp.h
//  ccAsset
//
//  Created by SealWallet on 2018/9/21.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCRandomHelp : NSObject

///生成随机整数
+ (NSInteger)randomIntegerBetween:(NSInteger)min and:(NSInteger)max;
///生成随机小数
+ (CGFloat)randomFloatBetween:(CGFloat)min and:(CGFloat)max;

@end
