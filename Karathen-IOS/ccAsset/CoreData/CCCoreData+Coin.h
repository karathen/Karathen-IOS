//
//  CCCoreData+Coin.h
//  ccAsset
//
//  Created by SealWallet on 2018/11/20.
//  Copyright © 2018 raistone. All rights reserved.
//

#import "CCCoreData.h"

@class CCCoin;
@interface CCCoreData (Coin)


/**
 清空数据

 @param completion 回调
 */
- (void)clearCoinDataCompletion:(saveCompletion)completion;

/**
 查询账户下支持的链

 @param accountId accountID
 @return 链数组
 */
- (NSArray <CCCoin *> *)requestCoinsWithAccountID:(NSString *)accountId;


/**
 批量保存链

 @param coins 添加链
 @param accointId accountID
 @param completion 回调
 @return 所有链
 */
- (NSArray <CCCoin *> *)saveCoinsWithCoins:(NSArray *)coins
                                 accountID:(NSString *)accointId
                                completion:(saveCompletion)completion;

/**
 删除链/未保存
 
 @param accountID 账户ID
 */
- (void)deleteCoinWithAccountId:(NSString *)accountID;

@end
