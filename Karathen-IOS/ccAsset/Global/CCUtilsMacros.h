//
//  CCUtilsMacros.h
//  ccAsset
//
//  Created by SealWallet on 2018/7/9.
//  Copyright © 2018年 SealWallet. All rights reserved.
//

//定义工具类
#ifndef CCUtilsMacros_h
#define CCUtilsMacros_h

#define IS_iOS11 ([UIDevice currentDevice].systemVersion.floatValue >= 11)

//颜色
#define RGB(c) [UIColor colorWithRed:((c>>16)&0xFF)/256.0  green:((c>>8)&0xFF)/256.0   blue:((c)&0xFF)/256.0   alpha:1.0]
#define RGB_ALPHA(c, a) [UIColor colorWithRed:((c>>16)&0xFF)/256.0  green:((c>>8)&0xFF)/256.0   blue:((c)&0xFF)/256.0   alpha:a]

#define RGB_COLOR(_red, _green, _blue) [UIColor colorWithRed:(_red)/255.0f green:(_green)/255.0f blue:(_blue)/255.0f alpha:1]
#define RGB_COLOR_ALPHA(_red, _green, _blue, a) [UIColor colorWithRed:(_red)/255.0f green:(_green)/255.0f blue:(_blue)/255.0f alpha:a]

//按钮可点击背景色
#define CC_BTN_ENABLE_COLOR RGB(0x5778F6)
//按钮不可点击背景色
#define CC_BTN_DISABLE_COLOR RGB(0xeff1f3)
//按钮蓝色文字颜色
#define CC_BTN_TITLE_COLOR RGB(0x5575FD)
//灰色背景
#define CC_GRAY_BACKCOLOR RGB(0xF6F7F9)
///灰色文字
#define CC_GRAY_TEXTCOLOR RGB(0xB7B6BB)
//灰色线
#define CC_GRAY_LINECOLOR RGB_COLOR(205,205,205)
///黑色
#define CC_BLACK_COLOR RGB(0x333333)

//强/弱引用
#define CCWeakSelf(type)  __weak typeof(type) weak##type = type;
#define CCStrongSelf(type)  __strong typeof(type) type = weak##type;

#define WEAK_SELF __weak typeof(self) weakSelf = self;

//角度计算
#define DEGREES_TO_RADIANS(degrees) ((degrees)*M_PI)/180

//字体
#define BoldFont(s) [UIFont boldSystemFontOfSize:s]
#define MediumFont(s) [UIFont systemFontOfSize:s]

//版本号


//DEBUG 模式下打印
#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DLog(...)
#endif

//需要弹出的提示
#ifdef DEBUG
#   define ULog(fmt, ...)  { UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%s\n [Line %d] ", __PRETTY_FUNCTION__, __LINE__] message:[NSString stringWithFormat:fmt, ##__VA_ARGS__]  delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil]; [alert show]; }
#else
#   define ULog(...)
#endif


#endif /* CCUtilsMacros_h */
