//
//  CCContentHintView.h
//  ccAsset
//
//  Created by SealWallet on 2018/7/16.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CCContentHintView;
@protocol CCContentHintViewDelegate <NSObject>

@optional
- (void)hintViewCancel:(CCContentHintView *)hintView;
- (void)hintViewConfirm:(CCContentHintView *)hintView;

@end


@interface CCContentHintView : UIView


+ (CCContentHintView *)hintViewWithTitle:(NSString *)title content:(NSString *)content;

- (void)changeTitle:(NSString *)title content:(NSString *)content;

@property (nonatomic, weak) id<CCContentHintViewDelegate> delegate;

/**
 展示
 */
- (void)showView;

/**
 展示

 @param view 父试图
 */
- (void)showViewInView:(UIView *)view;

/**
 消失
 */
- (void)hiddenView;

@end
