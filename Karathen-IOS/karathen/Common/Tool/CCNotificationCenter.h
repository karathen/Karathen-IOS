//
//  CCNotificationCenter.h
//  Karathen
//
//  Created by Karathen on 2018/8/2.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import <Foundation/Foundation.h>


//统一管理通知的类
@interface CCNotificationCenter : NSObject


///------------账户变动通知

/**
 发送账户变动通知

 @param add YES添加NO删除
 */
+ (void)postAccountChange:(BOOL)add accountID:(NSString *)accountID;

/**
 接收账户变动通知

 @param observer observer
 @param completion 回调
 */
+ (void)receiveAccountChangeObserver:(id)observer completion:(void(^)(BOOL add, NSString *accountID))completion;


///------------活跃账户发生变化的通知

/**
 发送活跃账户发生变化的通知

 */
+ (void)postActiveAccountChange;

/**
 接收活跃账户发生变化的通知

 @param observer observer
 @param completion 回调
 */
+ (void)receiveActiveAccountChangeObserver:(id)observer completion:(void(^)(void))completion;

///------------账户名字改变通知

/**
 发送账户名字改变通知
 
 */
+ (void)postAccountNameChange:(NSString *)accountID;

/**
 接收账户名字改变通知
 
 @param observer observer
 @param completion 回调
 */
+ (void)receiveAccountNameChangeObserver:(id)observer completion:(void(^)(NSString *accountID))completion;

///------------用户备份

/**
 发送用户备份的通知
 
 */
+ (void)postAccountBackUp;

/**
 接收用户备份的通知
 
 @param observer observer
 @param completion 回调
 */
+ (void)receiveAccountBackUpObserver:(id)observer completion:(void(^)(void))completion;


///------------ 链默认地址切换
/**
 发送链默认地址切换通知

 @param coinType 链
 */
+ (void)postSelectWalletChange:(CCCoinType)coinType accountID:(NSString *)accountID;

/**
 接收链默认地址切换通知

 @param observer observer
 @param completion 回调
 */
+ (void)receiveSelectWalletChangeObserver:(id)observer
                               completion:(void(^)(CCCoinType coinType,NSString *accountID))completion;

///------------ 链管理
/**
 发送链管理
 */
+ (void)postCoinManage;

/**
 接收链管理通知
 
 @param observer observer
 @param completion 回调
 */
+ (void)receiveCoinManageObserver:(id)observer completion:(void(^)(void))completion;


///------------ 钱包筛选条件更改
/**
 发送钱包筛选条件更改通知
 
 @param walletAddress 地址
 */
+ (void)postWalletFilterChange:(NSString *)walletAddress;

/**
 接收钱包筛选条件更改通知
 
 @param observer observer
 @param completion 回调
 */
+ (void)receiveWalletFilterChangeObserver:(id)observer
                               completion:(void(^)(NSString *walletAddress))completion;


///------------ 钱包隐藏余额更改
/**
 发送钱包隐藏余额更改通知
 
 @param walletAddress 地址
 */
+ (void)postWalletHideNoBalanceChange:(NSString *)walletAddress;

/**
 接收钱包隐藏余额更改通知
 
 @param observer observer
 @param completion 回调
 */
+ (void)receiveWalletHideNoBalanceChangeObserver:(id)observer
                                      completion:(void(^)(NSString *walletAddress))completion;


///------------ 链上地址变动
/**
 发送链上地址变动的通知
 */
+ (void)postWalletAddressChange:(CCCoinType)coinType;

/**
 接收链上地址变动的通知
 
 @param observer observer
 @param completion 回调
 */
+ (void)receiveWalletAddressChangeObserver:(id)observer
                                completion:(void(^)(CCCoinType coinType))completion;

///------------ 资产添加/删除
/**
 发送资产变动通知
 
 @param address 资产所属钱包地址
 */
+ (void)postAssetChangeWithWalletAddress:(NSString *)address;

/**
 接收资产变动通知
 
 @param observer observer
 @param completion 回调
 */
+ (void)receiveAssetChangeObserver:(id)observer
                        completion:(void(^)(NSString *address))completion;

///------------ 新增交易
/**
 发送新增交易通知
 
 @param walletAddress 钱包地址
 @param tokenAddress 资产地址
 */
+ (void)postAssetTradeUpdateWithWalletAddress:(NSString *)walletAddress
                              tokenAddress:(NSString *)tokenAddress;

/**
 接收新增交易通知
 
 @param observer observer
 @param completion 回调
 */
+ (void)receiveAssetTradeUpdateObserver:(id)observer
                             completion:(void(^)(NSString *walletAddress,NSString *tokenAddress))completion;


///------------ 钱包余额变化
/**
 发送钱包余额变化通知
 
 @param walletAddress 钱包地址
 */
+ (void)postWalletBalanceChangeWithWalletAddress:(NSString *)walletAddress;

/**
 接收钱包余额变化通知
 
 @param observer observer
 @param completion 回调
 */
+ (void)receiveWalletBalanceChangeObserver:(id)observer
                                completion:(void(^)(NSString *walletAddress))completion;

///------------ 钱包名字变化
/**
 发送钱包名变化通知
 
 @param walletAddress 钱包地址
 */
+ (void)postWalletNameChangeWithWalletAddress:(NSString *)walletAddress;

/**
 接收钱包名变化通知
 
 @param observer observer
 @param completion 回调
 */
+ (void)receiveWalletNameChangeObserver:(id)observer
                             completion:(void(^)(NSString *walletAddress))completion;

///------------ 货币单位切换
/**
 发送切换货币单位通知
 
 @param currentUnit 货币单位
 */
+ (void)postCurrencyUnitChangeWithUnit:(NSString *)currentUnit;

/**
 接收切换货币单位通知
 
 @param observer observer
 @param completion 回调
 */
+ (void)receiveCurrencyUnitChangeObserver:(id)observer
                               completion:(void(^)(NSString *currentUnit))completion;

///------------ 块高刷新
/**
 发送块高刷新通知
 
 @param coinType 链
 */
+ (void)postBlockHeightRefrshWithCoinType:(CCCoinType)coinType;

/**
 接收块高刷新通知
 
 @param observer observer
 @param completion 回调
 */
+ (void)receiveBlockHeightRefrshObserver:(id)observer
                              completion:(void(^)(CCCoinType coinType))completion;


///------------ 蓝牙状态改变
/**
 发送蓝牙状态改变通知
 
 */
+ (void)postBlueToothStateChange:(BOOL)state;

/**
 接收蓝牙状态改变通知
 
 @param observer observer
 @param completion 回调
 */
+ (void)receiveBlueToothstateChangeObserver:(id)observer completion:(void(^)(BOOL state))completion ;

///------------ 应用状态通知
/**
 接收前台活跃的通知
 
 @param observer observer
 @param completion 回调
 */
+ (void)receiveAppStateActiveObserver:(id)observer completion:(void(^)(void))completion;

/**
 接收进入后台的通知

 @param observer observer
 @param completion 回调
 */
+ (void)receiveEnterBackgroundObserver:(id)observer completion:(void(^)(void))completion;

///------------ 界面旋转切换
/**
 接收界面旋转的通知
 
 @param observer observer
 @param completion 回调
 */
+ (void)receiveStatusBarOrientationDidChangeObserver:(id)observer completion:(void(^)(void))completion;

///------------ 网络连接变化
/**
 接收网络变化通知

 @param observer observer
 @param completion 回调
 */
+ (void)receiveRealReachabilityChangedObserver:(id)observer completion:(void(^)(ReachabilityStatus status))completion;


@end
