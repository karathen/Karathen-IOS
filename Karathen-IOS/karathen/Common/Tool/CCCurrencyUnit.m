//
//  CCCurrencyUnit.m
//  Karathen
//
//  Created by Karathen on 2018/8/29.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCCurrencyUnit.h"

@implementation CCCurrencyUnit

#pragma mark - 当前选择的货币种类
+ (NSString *)currentCurrencyUnit {
    NSString *current = [[NSUserDefaults standardUserDefaults] objectForKey:CC_CURRENT_CURRENCYUNIT];
    if (current) {
        return current;
    }
    //没有的话取当前语言
    if ([[CCMultiLanguage manager].currentLanguage isEqualToString:CCLanguageOfChinese]) {
        current = CCCurrencyUnitCNY;
    } else {
        current = CCCurrencyUnitUSD;
    }
    [CCCurrencyUnit changeCurrencyUnit:current];
    return current;
}


#pragma mark - 切换币种
+ (void)changeCurrencyUnit:(NSString *)unit {
    NSString *current = [[NSUserDefaults standardUserDefaults] objectForKey:CC_CURRENT_CURRENCYUNIT];
    if ([current isEqualToString:unit]) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:unit forKey:CC_CURRENT_CURRENCYUNIT];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [CCNotificationCenter postCurrencyUnitChangeWithUnit:unit];
}

#pragma mark - 当前可以切换的币种
+ (NSArray *)allCurrencyUnit {
    return @[
             CCCurrencyUnitCNY,
             CCCurrencyUnitUSD
             ];
}


@end
