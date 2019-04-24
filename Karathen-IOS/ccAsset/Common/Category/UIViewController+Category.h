//
//  UIViewController+Category.h
//  ccAsset
//
//  Created by SealWallet on 2018/7/24.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Category)

/**
 输入弹窗
 
 @param title title
 @param message message
 @param placeholder placeholder
 @param secureTextEntry 密码风格
 @param keyboardType 键盘风格
 @param destructive 确认按钮是否是destructive风格
 @param minLength 最小长度
 @param maxLength 最大长度
 @param completion 回调
 */
- (void)inputAlertWithTitle:(NSString *)title
                    message:(NSString *)message
                placeholder:(NSString *)placeholder
            secureTextEntry:(BOOL)secureTextEntry
               keyboardType:(UIKeyboardType)keyboardType
                destructive:(BOOL)destructive
                  minLength:(NSInteger)minLength
                  maxLength:(NSInteger)maxLength
                 completion:(void(^)(NSString *text))completion;


/**
 文字提示
 
 @param message 文字
 @param sureTitle 确认文字
 @param destructive 确认按钮是否是destructive风格
 @param sureAction 回调
 */
- (void)messageAlertMessage:(NSString *)message
                  sureTitle:(NSString *)sureTitle
                destructive:(BOOL)destructive
                 sureAction:(void(^)(void))sureAction;


/**
 文字提示
 
 @param title 文字
 @param message 文字
 @param cancelTitle 取消文字
 @param sureTitle 确认文字
 @param destructive 确认按钮是否是destructive风格
 @param alertAction 回调
 */
- (void)messageAlertTitle:(NSString *)title
                  message:(NSString *)message
                   cancel:(NSString *)cancelTitle
                sureTitle:(NSString *)sureTitle
              destructive:(BOOL)destructive
              alertAction:(void(^)(NSInteger index))alertAction;


/**
 弹出PIN输入提示框
 
 @param maxLength 最大长度 0 不限制
 @param onlyNum 是否只能是数字
 @param completion 回调
 */
- (void)showPassWordMaxLength:(NSInteger)maxLength
                      onlyNum:(BOOL)onlyNum
                   completion:(void(^)(NSString *text))completion;


@end
