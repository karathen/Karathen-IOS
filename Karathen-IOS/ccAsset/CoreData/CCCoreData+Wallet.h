//
//  CCCoreData+Wallet.h
//  ccAsset
//
//  Created by SealWallet on 2018/11/20.
//  Copyright © 2018 raistone. All rights reserved.
//

#import "CCCoreData.h"


@interface CCCoreData (Wallet)


/**
 清空数据

 @param completion 回调
 */
- (void)clearWalletDataCompletion:(saveCompletion)completion;

/**
 查询所有的钱包
 
 @return 钱包数组
 */
- (NSArray<CCWallet *> *)requestWalletsWithCoinType:(CCCoinType)coinType accountID:(NSString *)accountID;


/**
 查找默认地址
 
 @param coinType 链
 @return 默认
 */
- (CCWallet *)requestActiveWalletWithCoinType:(CCCoinType)coinType accountID:(NSString *)accountID;

/**
 删除所有钱包/未保存
 
 @param accountID accountID
 */
- (void)deleteAllWalletWithAccountId:(NSString *)accountID;


/**
 由地址查询钱包
 
 @param address 地址
 @return 钱包
 */
- (CCWallet *)requestWalletWithAddress:(NSString *)address coinType:(CCCoinType)coinType accountID:(NSString *)accountID;

/**
 存储钱包
 
 @param wallet 钱包
 @param walletId id
 @param completion 回调
 */
- (CCWallet *)saveWalletWithWallet:(NSDictionary *)wallet walletId:(NSInteger)walletId accountID:(NSString *)accountID completion:(saveCompletion)completion;


/**
 删除钱包
 
 @param address 地址
 @param coinType 链
 @param completion 回调
 */
- (void)deleteWalletWithAddress:(NSString *)address coinType:(CCCoinType)coinType accountID:(NSString *)accountID completion:(saveCompletion)completion;



@end

