//
//  CCAccountData.h
//  ccAsset
//
//  Created by SealWallet on 2018/11/20.
//  Copyright © 2018 raistone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCAccount+CoreDataClass.h"
#import "CCCoin+CoreDataClass.h"

@class CCCoinData;
@interface CCAccountData : NSObject

@property (nonatomic, strong) CCAccount *account;
@property (nonatomic, strong) NSMutableArray <CCCoinData *> *coins;
@property (nonatomic, weak) CCCoinData *activeCoin;
@property (nonatomic, strong) NSArray <CCCoinData *> *showCoins;


/**
 创建CCAccountData
 
 @param account CCAccount
 @return CCAccountData
 */
- (instancetype)initWithAccount:(CCAccount *)account;


/**
 通过链类型获取CCCoinData

 @param coinType 链类型
 @return CCCoinData
 */
- (CCCoinData *)coinDataWithCoinType:(CCCoinType)coinType;


/**
 钱包图标

 @return 钱包图标
 */
- (NSString *)accountIcon;

/**
 修改当前默认链

 @param coinData CCCoinData
 */
- (void)changeActiveCoin:(CCCoinData *)coinData;


/**
 修改名称

 @param name 名称
 */
- (void)changeName:(NSString *)name;

/**
 备份
 */
- (void)backUp;

/**
 编辑修改链
 */
- (void)changeCoins;

/**
 上传钱包地址
 */
- (void)upLoadDevice;


/**
 硬件创建钱包

 @param accountId 账户ID
 @param sortId 排序
 @param deviceName 设备名
 @param addressDic 地址字典
 @param importType 导入方式
 @param accountName 账户名
 @param completion 回调
 */
+ (void)accountWithAccountID:(NSString *)accountId
                      sortID:(NSInteger)sortId
                  deviceName:(NSString *)deviceName
                  addressDic:(NSDictionary *)addressDic
                  importType:(CCImportType)importType
                 accountName:(NSString *)accountName
                passWordInfo:(NSString *)passWordInfo
                  completion:(void(^)(CCAccountData *accountData,CCWalletError error))completion;

/**
 创建助记词钱包

 @param accountId 账户ID
 @param sortId 排序ID
 @param mnemonic 助记词
 @param walletType 钱包方式
 @param importType 导入方式
 @param passWord 密码
 @param passWordInfo 密码提示
 @param accountName 账户名
 @param completion 回调
 */
+ (void)accountWithAccountID:(NSString *)accountId
                      sortID:(NSInteger)sortId
                    mnemonic:(NSString *)mnemonic
                  walletType:(CCWalletType)walletType
                  importType:(CCImportType)importType
                    passWord:(NSString *)passWord
                passWordInfo:(NSString *)passWordInfo
                 accountName:(NSString *)accountName
                  completion:(void(^)(CCAccountData *accountData,CCWalletError error))completion;

/**
 私钥创建

 @param accountId 账户ID
 @param sortId 排序ID
 @param privateKey 私钥
 @param walletType 钱包方式
 @param coinType 链
 @param passWord 密码
 @param passWordInfo 密码提示
 @param accountName 账户名
 @param completion 回调
 */
+ (void)accountWithAccountID:(NSString *)accountId
                      sortID:(NSInteger)sortId
                  privateKey:(NSString *)privateKey
                  walletType:(CCWalletType)walletType
                    coinType:(CCCoinType)coinType
                    passWord:(NSString *)passWord
                passWordInfo:(NSString *)passWordInfo
                 accountName:(NSString *)accountName
                  completion:(void(^)(CCAccountData *accountData,CCWalletError error))completion;

/**
 wif创建
 
 @param accountId 账户ID
 @param sortId 排序ID
 @param wif wif
 @param walletType 钱包方式
 @param coinType 链
 @param passWord 密码
 @param passWordInfo 密码提示
 @param accountName 账户名
 @param completion 回调
 */
+ (void)accountWithAccountID:(NSString *)accountId
                      sortID:(NSInteger)sortId
                         wif:(NSString *)wif
                  walletType:(CCWalletType)walletType
                    coinType:(CCCoinType)coinType
                    passWord:(NSString *)passWord
                passWordInfo:(NSString *)passWordInfo
                 accountName:(NSString *)accountName
                  completion:(void(^)(CCAccountData *accountData,CCWalletError error))completion;


/**
 keystore创建
 
 @param accountId 账户ID
 @param sortId 排序ID
 @param keystore keystore
 @param walletType 钱包方式
 @param coinType 链
 @param passWord 密码
 @param passWordInfo 密码提示
 @param accountName 账户名
 @param completion 回调
 */
+ (void)accountWithAccountID:(NSString *)accountId
                      sortID:(NSInteger)sortId
                    keystore:(NSString *)keystore
                  walletType:(CCWalletType)walletType
                    coinType:(CCCoinType)coinType
                    passWord:(NSString *)passWord
                passWordInfo:(NSString *)passWordInfo
                 accountName:(NSString *)accountName
                  completion:(void(^)(CCAccountData *accountData,NSString *privatekey,CCWalletError error))completion;


/**
 创建添加链

 @param coinData 链
 @param password 密码
 @param completion 回调
 */
- (void)createCoinWithCoinData:(CCCoinData *)coinData
                      passWord:(NSString *)password
                    completion:(void (^)(BOOL suc, CCWalletError error))completion;

@end
