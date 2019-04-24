//
//  CCDimensionMacros.h
//  ccAsset
//
//  Created by SealWallet on 2018/7/9.
//  Copyright © 2018年 SealWallet. All rights reserved.
//

//定义尺寸
#ifndef CCDimensionMacros_h
#define CCDimensionMacros_h

//屏幕 rect
#define SCREEN_WIDTH    ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT   ([UIScreen mainScreen].bounds.size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

//是否是iphone
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
//是否是iPad
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

//比例适配
#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)
#define IS_IPHONE_X (IS_IPHONE && SCREEN_MAX_LENGTH == 812.0)

//相对于iPhone6适配
#define FitScale(R) (R)*(SCREEN_WIDTH/375.0)

//状态栏高度
#define STATUS_BAR_HEIGHT (IS_IPHONE_X?44.f:20.f)
//NavBar高度
#define NAVIGATION_BAR_HEIGHT (44.0)
//状态栏 ＋ 导航栏 高度
#define STATUS_AND_NAVIGATION_HEIGHT (STATUS_BAR_HEIGHT + NAVIGATION_BAR_HEIGHT)
//UITabBar高度
#define TAB_BAR_HEIGHT (IS_IPHONE_X?83.f:49.f)


#endif /* CCDimensionMacros_h */
