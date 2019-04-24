//
//  Macros.h
//  ccAsset
//
//  Created by SealWallet on 2018/7/9.
//  Copyright © 2018年 SealWallet. All rights reserved.
//

#ifndef Macros_h
#define Macros_h

#define LBXScan_Define_Native  //包含native库
#define LBXScan_Define_ZXing   //包含ZXing库
#define LBXScan_Define_ZBar   //包含ZBar库
#define LBXScan_Define_UI     //包含界面库

#import "AppDelegate.h"
#import "AppDelegate+RootViewController.h"
//宏定义
#import "CCThirdConfiguration.h"
#import "CCDimensionMacros.h"
#import "CCUtilsMacros.h"
#import "CCStockConstant.h"

//工具类
#import "CCMultiLanguage.h"
#import "MBProgressHUD+CCHint.h"
#import "CCRequest.h"
#import "UIViewController+Category.h"
#import "CCBlueTooth.h"
#import "CCAlertView.h"

//vc
#import "CCViewController.h"
#import "CCNavigationController.h"

//categroy
#import "UIView+CCFrame.h"
#import "UIView+TapBlock.h"
#import "NSString+Category.h"
#import "UINavigationController+Category.h"

//Lib
#import "ReactiveObjC.h"
#import "Masonry.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <MJExtension/MJExtension.h>
#import <MJRefresh/MJRefresh.h>
#import "CCRefreshNormalHeader.h"
#import "CCRefreshAutoNormalFooter.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <RealReachability/RealReachability.h>

//用户管理
#import "CCDataManager.h"
#import "CCWalletManager+ETH.h"
#import "CCWalletManager+NEO.h"
#import "CCWalletManager+ONT.h"
#import "CCCoinData.h"
#import "CCCurrencyUnit.h"
#import "CCDefaultAsset.h"
#import "CCHardwareWallet.h"
#import "CCETHApi.h"

//通知中心
#import "CCNotificationCenter.h"

#endif /* Macros_h */
