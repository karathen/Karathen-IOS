//
//  CCCoreData+Asset.h
//  Karathen
//
//  Created by Karathen on 2018/11/20.
//  Copyright © 2018 raistone. All rights reserved.
//

#import "CCCoreData.h"

@interface CCCoreData (Asset)


/**
 清空数据

 @param completion 回调
 */
- (void)clearAssetDataCompletion:(saveCompletion)completion;

/**
 查询资产
 
 @param walletAddress 钱包地址
 @param coinType 链
 @return 资产
 */
- (NSArray <CCAsset *> *)requestAssetWithWalletAddress:(NSString *)walletAddress coinType:(CCCoinType)coinType accountID:(NSString *)accountID;


/**
 删除所有资产/未保存
 
 @param accountID accountID
 */
- (void)deleteAllAssetWithAccountId:(NSString *)accountID;


/**
 保存
 
 @param asset asset
 @param walletAddress 钱包地址
 @param coinType coinType
 @param completion 回调
 @return asset
 */
- (CCAsset *)saveAssetWithAsset:(NSDictionary *)asset
                  walletAddress:(NSString *)walletAddress
                       coinType:(CCCoinType)coinType
                      accountID:(NSString *)accountID
                     completion:(saveCompletion)completion;


/**
 批量保存
 
 @param assets assets key：tokenAddress value：NSDictionary
 @param walletAddress 钱包地址
 @param coinType coinType
 @param completion 回调
 @return 数组
 */
- (NSArray <CCAsset *> *)saveAssetWithAssets:(NSDictionary *)assets
                               walletAddress:(NSString *)walletAddress
                                    coinType:(CCCoinType)coinType
                                   accountID:(NSString *)accountID
                                  completion:(saveCompletion)completion;


/**
 筛选
 
 @param walletData 钱包
 @param keyWord 关键字
 @param isNoBalance 是否隐藏无余额
 @param filterType 筛选条件
 @param walletAddress 钱包地址
 @return 结果
 */
- (NSArray <CCAsset *> *)searchAssetsWithWallet:(CCWalletData *)walletData
                                        keyWord:(NSString *)keyWord
                              isHiddenNoBalance:(BOOL)isNoBalance
                                     filterType:(NSString *)filterType
                                  walletAddress:(NSString *)walletAddress;

@end
