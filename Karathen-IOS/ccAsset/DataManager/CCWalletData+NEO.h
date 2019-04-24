//
//  CCWalletData+NEO.h
//  ccAsset
//
//  Created by SealWallet on 2018/9/4.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCWalletData.h"

@class CCTradeRecordModel;
@interface CCWalletData (NEO)

/**
 查询余额结束
 
 @param completion 回调
 */
- (void)queryNEOBalancePriceCompletion:(void(^)(void))completion;

/**
 查询地址下有余额的资产

 @param completion 回调
 @param noContain 没查到的
 */
- (void)queryNEOAssetHoldingCompletion:(void(^)(void))completion
                             noContain:(void(^)(NSArray <CCAsset *> *assets))noContain;


/**
 查询单个价格

 @param asset asset
 @param completion 回调
 */
- (void)queryNEOBalancePriceAsset:(CCAsset *)asset completion:(void (^)(void))completion;


- (void)queryNEOAssets:(NSArray <CCAsset *> *)assets
       priceCompletion:(void(^)(void))priceCompletion
     balanceCompletion:(void(^)(NSArray<NSDictionary *> *balance, BOOL suc, CCWalletError error))balanceCompletion
         endCompletion:(void(^)(void))endCompletion;

/**
 转账
 
 @param asset 资产
 @param address 收款地址
 @param number 金额
 @param password 密码
 @param completion 回调
 */
- (void)transferNEOAsset:(CCAsset *)asset
               toAddress:(NSString *)address
                  number:(NSString *)number
                password:(NSString *)password
              completion:(void(^)(BOOL suc,CCWalletError error,CCTradeRecordModel *tradeRecord))completion;



/**
 地址区块浏览器网址
 
 @return 网址
 */
- (NSString *)addressNEOExplorer;

/**
 交易记录详情Url
 
 @param txId txid
 @return url
 */
- (NSString *)neoTradeDetailUrlWithTxId:(NSString *)txId;

@end
