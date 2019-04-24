//
//  MBProgressHUD+CCHint.m
//  ccAsset
//
//  Created by SealWallet on 2018/7/16.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "MBProgressHUD+CCHint.h"

@implementation MBProgressHUD (CCHint)

+ (void)showMessage:(NSString *)message {
    [MBProgressHUD showMessage:message inView:[UIApplication sharedApplication].keyWindow];
}


+ (void)showMessage:(NSString *)message inView:(UIView *)view {
    [MBProgressHUD showMessage:message inView:view offsetY:0];
}


+ (void)showMessage:(NSString *)message offsetY:(CGFloat)offsetY {
    [MBProgressHUD showMessage:message inView:[UIApplication sharedApplication].keyWindow offsetY:offsetY];
}

+ (void)showMessage:(NSString *)message inView:(UIView *)view offsetY:(CGFloat)offsetY {
    if (view == nil) {
        view = [UIApplication sharedApplication].keyWindow;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.userInteractionEnabled = NO;
    hud.mode = MBProgressHUDModeText;
    hud.offset = CGPointMake(hud.offset.x, hud.offset.y + offsetY);
    hud.detailsLabel.text = message;
    hud.detailsLabel.textColor = [UIColor whiteColor];
    hud.detailsLabel.font = MediumFont(13);
    hud.bezelView.layer.cornerRadius = 8;
    hud.removeFromSuperViewOnHide = YES;
    hud.margin = 10;
    hud.bezelView.color = [UIColor colorWithWhite:0 alpha:.8];
    [hud hideAnimated:YES afterDelay:2];
}

@end
