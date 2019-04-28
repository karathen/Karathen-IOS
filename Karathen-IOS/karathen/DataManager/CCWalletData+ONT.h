//
//  CCWalletData+ONT.h
//  Karathen
//
//  Created by Karathen on 2018/9/19.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCWalletData.h"

@class CCTradeRecordModel;
@interface CCWalletData (ONT)

/**
 查询余额结束
 
 @param completion 回调
 */
- (void)queryONTBalancePriceCompletion:(void(^)(void))completion;



/**
 查询单个价格
 
 @param asset asset
 @param completion 回调
 */
- (void)queryONTBalancePriceAsset:(CCAsset *)asset completion:(void (^)(void))completion;

- (void)queryONTAssets:(NSArray <CCAsset *> *)assets
       priceCompletion:(void(^)(void))priceCompletion
     balanceCompletion:(void(^)(NSDictionary *balance, BOOL suc, CCWalletError error))balanceCompletion
         endCompletion:(void(^)(void))endCompletion;

/**
 转账
 
 @param asset 资产
 @param address 收款地址
 @param number 金额
 @param password 密码
 @param completion 回调
 */
- (void)transferONTAsset:(CCAsset *)asset
               toAddress:(NSString *)address
                  number:(NSString *)number
                password:(NSString *)password
              completion:(void(^)(BOOL suc,CCWalletError error,CCTradeRecordModel *tradeRecord))completion;



/**
 地址区块浏览器网址
 
 @return 网址
 */
- (NSString *)addressONTExplorer;

/**
 交易记录详情Url
 
 @param txId txid
 @return url
 */
- (NSString *)ontTradeDetailUrlWithTxId:(NSString *)txId;

@end
