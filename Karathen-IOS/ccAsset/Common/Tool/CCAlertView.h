//
//  CCAlertView.h
//  ccAsset
//
//  Created by SealWallet on 2018/7/16.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CCAlertViewType) {
    CCAlertViewTypeTextAlert,//文字提示框
    CCAlertViewTypeLoading,//加载框提示
};

@class CCAlertView;
@protocol CCAlertViewDelegate <NSObject>

@optional
- (void)alertViewDidHidden:(CCAlertView *)alertView;

@end

@interface CCAlertView : UIView

@property (nonatomic, copy) void(^sureAction)(void);
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *sureTitle;
@property (nonatomic, assign) CCAlertViewType type;
@property (nonatomic, weak) id<CCAlertViewDelegate> delegate;

+ (CCAlertView *)alertViewMessage:(NSString *)message sureTitle:(NSString *)sureTitle withType:(CCAlertViewType)type;

- (void)showView;
- (void)showViewInView:(UIView *)view;
- (void)hiddenView;


+ (void)showAlertWithMessage:(NSString *)message;

+ (CCAlertView *)showLoadingMessage:(NSString *)message inView:(UIView *)view;
+ (CCAlertView *)showLoadingMessage:(NSString *)message;
+ (void)hidenAlertLoadingForView:(UIView *)view;
+ (void)hidenAlertLoading;

@end
