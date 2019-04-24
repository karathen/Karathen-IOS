//
//  CCRandomHelp.m
//  ccAsset
//
//  Created by SealWallet on 2018/9/21.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCRandomHelp.h"

#define ARC4RANDOM_MAX 0x100000000//arc4random()返回的最大值是 0x100000000


@implementation CCRandomHelp

//生成随机整数
+ (NSInteger)randomIntegerBetween:(NSInteger)min and:(NSInteger)max {
    NSInteger range = max - min;
    if (range == 0) {
        return min;
    }
    return arc4random()%range + min;
}
//生成随机小数
+ (CGFloat)randomFloatBetween:(CGFloat)min and:(CGFloat)max {
    CGFloat range = max - min;
    if (range == 0) {
        return min;
    }
    return floorf(((double)arc4random() / ARC4RANDOM_MAX) * range) + min;
}


@end
