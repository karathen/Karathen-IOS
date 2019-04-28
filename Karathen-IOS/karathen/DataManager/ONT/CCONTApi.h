//
//  CCONTApi.h
//  Karathen
//
//  Created by Karathen on 2018/9/19.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ONTAccount;
@interface CCONTApi : NSObject

+ (instancetype)manager;


/**
 获取余额
 
 @param address 地址
 @param completion 回调
 */
- (void)getBalanceWithAddress:(NSString *)address
                   completion:(void(^)(NSDictionary *balance))completion;


/**
 转账
 
 @param account 用户
 @param asset 资产
 @param fromAddress 发
 @param toAddress 收
 @param number 数量
 @param completion 回调
 */
- (void)transferAccount:(ONTAccount *)account
                  asset:(CCAsset *)asset
            fromAddress:(NSString *)fromAddress
              toAddress:(NSString *)toAddress
                 number:(NSString *)number
             completion:(void(^)(BOOL suc,NSString *txId))completion ;


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
 获取交易状态
 
 @param txIds txId数组
 @param completion 回调
 */
- (void)getONTTransactionStatusWithTxIds:(NSArray *)txIds
                              completion:(void(^)(NSDictionary *statusDic))completion;

/**
 获取ONG
 
 @param address 地址
 @param completion 回调
 */
- (void)getONGWithAddress:(NSString *)address
               completion:(void(^)(BOOL suc,NSString *claimedONG,NSString *unClaimedONG))completion;

/**
 提取ONG
 
 @param walletData 钱包
 @param password 密码
 @param ammount 可提取
 @param completion 回调
 */
- (void)claimWalletData:(CCWalletData *)walletData
               password:(NSString *)password
                 amount:(NSString *)ammount
             completion:(void (^)(BOOL suc, CCWalletError error))completion;


/**
 获取交易信息

 @param txId txId
 @param completion 回调
 */
- (void)getONTTransactionWithTxid:(NSString *)txId
                       completion:(void(^)(NSDictionary *info))completion;

@end

@interface CCONTRequest : CCRequest


@end


@interface CCONTRpcRequest : CCRequest


@end


@interface CCONTExplorer : CCRequest


@end
