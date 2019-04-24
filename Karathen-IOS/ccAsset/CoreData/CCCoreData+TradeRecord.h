//
//  CCCoreData+TradeRecord.h
//  ccAsset
//
//  Created by SealWallet on 2018/11/20.
//  Copyright © 2018 raistone. All rights reserved.
//

#import "CCCoreData.h"
#import "CCTradeRecord+CoreDataClass.h"

@class CCTradeRecordModel;
@interface CCCoreData (TradeRecord)


/**
 清空数据

 @param completion 回调
 */
- (void)clearTradeRecordDataCompletion:(saveCompletion)completion;

/**
 查询记录
 
 @param walletAddress 钱包地址
 @param tokenAddress 资产地址
 @param coinType coinType
 @return 记录
 */
- (NSArray *)requsetTradeRecordsWithWalletAddress:(NSString *)walletAddress tokenAddress:(NSString *)tokenAddress coinType:(CCCoinType)coinType accountID:(NSString *)accountID;

/**
 查询需要请求块高的交易记录
 
 @param coinType 链
 @return 记录
 */
- (NSArray *)requestNeedRequestBlockRecords:(CCCoinType)coinType;

/**
 查询需要刷新状态的交易记录
 
 @param coinType 链
 @return 记录
 */
- (NSArray *)requestNeedRequestStatusRecords:(CCCoinType)coinType;

/**
 更新交易记录，上线
 
 @param txId txid
 @param timestamp 时间戳
 @param blockHeight 块高
 @param coinType coinType
 @param completion 回调
 */
- (void)updateTradeWithTxid:(NSString *)txId
                             timestamp:(NSTimeInterval)timestamp
                           blockHeight:(NSString *)blockHeight
                              coinType:(CCCoinType)coinType
                            completion:(saveCompletion)completion;

/**
 删除所有记录/未保存
 
 @param accountID accountID
 */
- (void)deleteAllRecordWithAccountID:(NSString *)accountID;

/**
 保存记录
 
 @param tradeRecordModel CCTradeRecordModel
 @param walletAddress 钱包地址
 @param tokenAddress 资产地址
 @param completion 回调
 */
- (CCTradeRecord *)saveTradeRecord:(CCTradeRecordModel *)tradeRecordModel
                     walletAddress:(NSString *)walletAddress
                      tokenAddress:(NSString *)tokenAddress
                         accountID:(NSString *)accountID
                        completion:(saveCompletion)completion;



/**
 删除信息
 
 @param txId txid
 @param walletAddress 钱包地址
 @param tokenAddress 资产地址
 @param coinType coinType
 @param completion 结束
 */
- (void)deleteTradeRecordWithTxId:(NSString *)txId
                    walletAddress:(NSString *)walletAddress
                     tokenAddress:(NSString *)tokenAddress
                         coinType:(CCCoinType)coinType
                        accountID:(NSString *)accountID
                       completion:(saveCompletion)completion;


/**
 批量删除信息
 
 @param txIds txid数组
 @param walletAddress 钱包地址
 @param tokenAddress 资产地址
 @param coinType coinType
 @param completion 结束
 */
- (void)deleteTradeRecordWithTxIds:(NSArray *)txIds
                     walletAddress:(NSString *)walletAddress
                      tokenAddress:(NSString *)tokenAddress
                          coinType:(CCCoinType)coinType
                         accountID:(NSString *)accountID
                        completion:(saveCompletion)completion;


/**
 删除记录
 
 @param walletAddress 钱包
 @param tokenAddress 资产
 @param completion 回调
 */
- (void)deleteTradeRecordWalletAddress:(NSString *)walletAddress
                          tokenAddress:(NSString *)tokenAddress
                              coinType:(CCCoinType)coinType
                             accountID:(NSString *)accountID
                            completion:(saveCompletion)completion;


/**
 删除记录
 
 @param walletAddress 钱包
 @param completion 回调
 */
- (void)deleteTradeRecordWalletAddress:(NSString *)walletAddress
                              coinType:(CCCoinType)coinType
                             accountID:(NSString *)accountID
                            completion:(saveCompletion)completion;

@end
