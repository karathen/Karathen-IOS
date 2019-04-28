//
//  CCETHApi.h
//  Karathen
//
//  Created by Karathen on 2018/9/10.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CCHardwareWallet;
@interface CCETHApi : NSObject


+ (instancetype)manager;
/**
 eth网络请求
 */
@property (nonatomic, strong) EtherscanProvider *ethProvider;

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
 查询721资产下的tokenid
 
 @param ownerAddress 地址
 @param tokenAddress 合约地址
 @param page 页数
 @param completion 回调
 */
- (void)getTokensOfOwner:(NSString *)ownerAddress
            tokenAddress:(NSString *)tokenAddress
                    page:(NSInteger)page
              completion:(void(^)(BOOL suc, NSArray *tokens))completion;

/**
 获取地址下拥有的资产

 @param address 地址
 @param completion 回调
 */
- (void)getAssetHoldingWithAddress:(NSString *)address
                        completion:(void(^)(BOOL suc, NSArray <CCTokenInfoModel *> *assets))completion;

/**
 转账
 
 @param account Account
 @param asset CCAsset
 @param fromAddress fromAddress
 @param toAddress toAddress
 @param money money
 @param gasPrice gasPrice
 @param gasLimit gasLimit
 @param needEstimateGas needEstimateGas
 @param remark remark
 @param completion completion
 */
+ (void)transferETHAccount:(Account *)account
                     asset:(CCAsset *)asset
               fromAddress:(NSString *)fromAddress
                 toAddress:(NSString *)toAddress
                     money:(NSString *)money
                  gasPrice:(NSString *)gasPrice
                  gasLimit:(NSString *)gasLimit
           needEstimateGas:(BOOL)needEstimateGas
                    remark:(NSString *)remark
                completion:(void(^)(NSString *hashStr,NSString *gasPrice,NSString *gasLimit,NSString *data,BOOL suc,CCWalletError error))completion;

//硬件转账
+ (void)transferETHardwareWallet:(CCHardwareWallet *)hardware
                            slot:(int)slot
                        verifyFp:(BOOL)verifyFp
                        password:(NSString *)password
                           asset:(CCAsset *)asset
                     fromAddress:(NSString *)fromAddress
                       toAddress:(NSString *)toAddress
                           money:(NSString *)money
                        gasPrice:(NSString *)gasPrice
                        gasLimit:(NSString *)gasLimit
                 needEstimateGas:(BOOL)needEstimateGas
                          remark:(NSString *)remark
                         process:(void(^)(NSString *message))process
                      completion:(void(^)(NSString *hashStr,NSString *gasPrice,NSString *gasLimit,NSString *data,BOOL suc,CCWalletError error))completion;

/**
 dapp签名广播交易

 @param walletData CCWalletData
 @param passWord PIN
 @param toAddress toAddress
 @param gasPrice gasPrice
 @param gasLimit gasLimit
 @param value value
 @param transdata data
 @param completion 回调
 */
+ (void)transferWalletData:(CCWalletData *)walletData
                  passWord:(NSString *)passWord
                 toAddress:(NSString *)toAddress
                  gasPrice:(NSString *)gasPrice
                  gasLimit:(NSString *)gasLimit
                     value:(NSString *)value
                 transdata:(NSData *)transdata
                completion:(void(^)(NSString *hashStr,NSString *gasPrice,NSString *gasLimit,NSString *data,BOOL suc,CCWalletError error))completion;


/**
 查询交易
 
 @param txId txId
 @param completion 回调
 */
+ (void)getETHTransactionWithTxid:(NSString *)txId
                       completion:(void(^)(TransactionInfoPromise *info))completion;

+ (void)getETHTransactionReceiptWithTxid:(NSString *)txId
                              completion:(void(^)(TransactionInfoPromise *info))completion;

/**
 查询余额
 
 @param arrayToken 查询的代币所有token
 @param address eth地址
 @param completion 回调
 */
+(void)getETHBalanceWithTokens:(NSArray<NSString *> *)arrayToken
                   withAddress:(NSString *)address
                    completion:(void(^)(NSDictionary *balances,BOOL suc,CCWalletError error))completion;

/**
 获取GasPrice
 
 @param completion 回调
 */
+ (void)getETHGasPriceCompletion:(void(^)(NSString *gasPrice))completion;



/**
 查询块高

 @param completion 回调
 */
+ (void)getETHBlockNumCompletion:(void (^)(NSInteger))completion;


/**
 网络
 
 @return 网络类型
 */
+ (ChainId)chainId;

/**
 apikey
 
 @return apikey
 */
+ (NSString *)apiKey;


@end


@interface CCETHRequest : CCRequest


@end

@interface CCETHScanRequest : CCRequest

@end

