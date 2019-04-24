//
//  MBProgressHUD+CCHint.h
//  ccAsset
//
//  Created by SealWallet on 2018/7/16.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>

@interface MBProgressHUD (CCHint)

/**
 弹出文本提示

 @param message 显示的文本
 */
+ (void)showMessage:(NSString *)message;


/**
 弹出文本提示

 @param message 显示的文本
 @param offsetY 偏移
 */
+ (void)showMessage:(NSString *)message offsetY:(CGFloat)offsetY;

/**
 弹出文本提示

 @param message 显示的文本
 @param view 展示信息的试图
 */
+ (void)showMessage:(NSString *)message inView:(UIView *)view;

/**
 弹出文本提示

 @param message 显示的文本
 @param view 展示信息的试图
 @param offsetY 偏移
 */
+ (void)showMessage:(NSString *)message inView:(UIView *)view offsetY:(CGFloat)offsetY;

@end
