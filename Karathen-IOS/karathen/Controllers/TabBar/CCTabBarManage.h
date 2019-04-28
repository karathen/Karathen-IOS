//
//  CCTabBarManage.h
//  Karathen
//
//  Created by Karathen on 2018/11/30.
//  Copyright © 2018 raistone. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CCTabBarManageType) {
    CCTabBarManageWallet,//钱包首页
    CCTabBarManageDApp,//DApp
    CCTabBarManageProfile,//个人中心
};


@interface CCTabBarManage : NSObject

- (NSArray *)currentVCs;
- (void)languageChange;

@end
