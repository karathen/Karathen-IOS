//
//  CCCurrencyUnit.h
//  ccAsset
//
//  Created by SealWallet on 2018/8/29.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import <Foundation/Foundation.h>

/** 可选择的语言 */
static NSString *const CCCurrencyUnitCNY = @"CNY";     // 人民币
static NSString *const CCCurrencyUnitUSD = @"USD";     // 美元

@interface CCCurrencyUnit : NSObject

/**
 当前选择的货币种类
 
 @return 货币种类
 */
+ (NSString *)currentCurrencyUnit;


/**
 切换币种
 
 @param unit 币种
 */
+ (void)changeCurrencyUnit:(NSString *)unit;

/**
 当前可以切换的币种
 
 @return 数组
 */
+ (NSArray *)allCurrencyUnit;

@end
