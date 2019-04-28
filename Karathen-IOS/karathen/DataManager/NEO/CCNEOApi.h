//
//  CCNEOApi.h
//  Karathen
//
//  Created by Karathen on 2018/9/3.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CCNEOAccount;
@interface CCNEOApi : NSObject

+ (instancetype)manager;


/**
 获取余额
 
 @param address 地址
 @param tokens token地址
 @param completion 回调
 */
- (void)getBalanceWithAddress:(NSString *)address
                       tokens:(NSArray *)tokens
                   completion:(void(^)(NSArray <NSDictionary *> *balance))completion;


/**
 获取地址下有余额的资产
 
 @param address 地址
 @param completion 回调
 */
- (void)getAssetHoldingWithAddress:(NSString *)address
                        completion:(void(^)(BOOL suc, NSArray <CCTokenInfoModel *> *assets))completion;

/**
 转账

 @param account 用户
 @param fromAddress 发
 @param toAddress 收
 @param number 数量
 @param tokenAddress token
 @param completion 回调
 */
- (void)transferAccount:(CCNEOAccount *)account
            fromAddress:(NSString *)fromAddress
              toAddress:(NSString *)toAddress
                 number:(NSString *)number
           tokenAddress:(NSString *)tokenAddress
             completion:(void(^)(BOOL suc,NSString *txId))completion;


/**
 获取交易记录

 @param address 地址
 @param tokenAddress 资产地址
 @param page 页数
 @param completion 回调
 */
- (void)getTransationWithAddress:(NSString *)address
                    tokenAddress:(NSString *)tokenAddress
                            page:(NSInteger)page
                      completion:(void(^)(BOOL suc,NSArray *records))completion;


/**
 获取Gas

 @param address 地址
 @param completion 回调
 */
- (void)getGasWithAddress:(NSString *)address
               completion:(void(^)(BOOL suc,NSString *allGas,NSString *claimedGas,NSString *unClaimedGas))completion;



/**
 提取GAS

 @param walletData 钱包
 @param password 密码
 @param completion 回调
 */
- (void)claimGasWalletData:(CCWalletData *)walletData
                  password:(NSString *)password
                completion:(void (^)(BOOL suc, CCWalletError error))completion;


/**
 获取交易信息
 
 @param txId txId
 @param completion 回调
 */
- (void)getNEOTransactionWithTxid:(NSString *)txId
                       completion:(void(^)(NSDictionary *info))completion;

/**
 获取交易状态
 
 @param txIds txId数组
 @param completion 回调
 */
- (void)getNEOTransactionStatusWithTxIds:(NSArray *)txIds
                              completion:(void(^)(NSDictionary *statusDic))completion;

@end


@interface CCNEORequest : CCRequest


@end


@interface CCNEOScanRequest : CCRequest


@end
