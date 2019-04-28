//
//  CCWalletData+ETH.h
//  Karathen
//
//  Created by Karathen on 2018/9/4.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCWalletData.h"

@class CCTradeRecordModel;
@interface CCWalletData (ETH)


/**
 查询余额结束

 @param completion 回调
 */
- (void)queryETHBalancePriceCompletion:(void(^)(void))completion;

/**
 查询单个价格
 
 @param asset asset
 @param completion 回调
 */
- (void)queryETHBalancePriceAsset:(CCAsset *)asset completion:(void (^)(void))completion;


/**
 查询价格

 @param assets 多个资产
 @param priceCompletion 价格
 @param balanceCompletion 余额
 @param endCompletion 结束
 */
- (void)queryETHAssets:(NSArray <CCAsset *> *)assets
       priceCompletion:(void(^)(void))priceCompletion
     balanceCompletion:(void(^)(NSDictionary *balances, BOOL suc, CCWalletError error))balanceCompletion
         endCompletion:(void(^)(void))endCompletion;

/**
 查询地址下有余额的资产

 @param completion 结束回调
 */
- (void)queryETHAssetHoldingCompletion:(void(^)(void))completion
                             noContain:(void(^)(NSArray <CCAsset *> *assets))noContain;


/**
 转账

 @param asset 资产
 @param address 收款地址
 @param number 金额
 @param password 密码
 @param completion 回调
 */
- (void)transferETHAsset:(CCAsset *)asset
               toAddress:(NSString *)address
                  number:(NSString *)number
                password:(NSString *)password
                gasPrice:(NSString *)gasPrice
                gasLimit:(NSString *)gasLimit
              completion:(void(^)(BOOL suc,CCWalletError error,CCTradeRecordModel *tradeRecord))completion;

///硬件转账
- (void)transferHardwareETHAsset:(CCAsset *)asset
                       toAddress:(NSString *)address
                          number:(NSString *)number
                        password:(NSString *)password
                        gasPrice:(NSString *)gasPrice
                        gasLimit:(NSString *)gasLimit
                         process:(void(^)(NSString *message))process
                      completion:(void(^)(BOOL suc,CCWalletError error,CCTradeRecordModel *tradeRecord))completion;

/**
 地址区块浏览器网址

 @return 网址
 */
- (NSString *)addressETHExplorer;


/**
 交易记录详情Url
 
 @param txId txid
 @return url
 */
- (NSString *)ethTradeDetailUrlWithTxId:(NSString *)txId;

@end
