//
//  CCScanQRViewController.h
//  Karathen
//
//  Created by Karathen on 2018/8/1.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCBlueViewController.h"
#import "CCQRCodeRule.h"

@class CCScanQRViewController;
@protocol CCScanQRViewControllerDelegate <NSObject>

@optional
//转账扫描跳转
- (void)scanVC:(CCScanQRViewController *)scanVC tradeToAddress:(NSString *)toAddress asset:(CCAsset *)asset;
- (void)scanVC:(CCScanQRViewController *)scanVC result:(NSString *)result;

@end

@interface CCScanQRViewController : CCBlueViewController

@property (nonatomic, assign) CCQRCodeRuleType ruleType;
@property (nonatomic, weak) CCWalletData *walletData;
@property (nonatomic, weak) CCAsset *asset;
@property (nonatomic, weak) id<CCScanQRViewControllerDelegate> delegate;

@end
