//
//  CCDataManager.h
//  Karathen
//
//  Created by Karathen on 2018/7/10.
//  Copyright © 2018年 Karathen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCWalletManager.h"
#import "CCAccountData.h"

@class CCCoinData;
@interface CCDataManager : NSObject

@property (nonatomic, strong) NSMutableArray <CCAccountData *> *accounts;
@property (nonatomic, weak) CCAccountData *activeAccount;

/**
 用户信息管理

 @return 用户信息管理
 */
+ (CCDataManager *)dataManager;



/**
 修改当前默认账户
 
 @param accountData CCAccountData
 */
- (void)changeActiveAccount:(CCAccountData *)accountData;


/**
 硬件创建账户

 @param deviceName 设备名
 @param addressDic 地址字典
 @param importType 导入方式
 @param accountName 账户名
 @param completion 回调
 */
- (void)accountWithDeviceName:(NSString *)deviceName
                   addressDic:(NSDictionary *)addressDic
                   importType:(CCImportType)importType
                  accountName:(NSString *)accountName
                 passWordInfo:(NSString *)passWordInfo
                   completion:(void(^)(BOOL suc, CCWalletError error))completion;
/**
助记词创建账户

 @param mnemonic 助记词
 @param walletType 账户钱包类型
 @param importType 导入方式
 @param passWord 密码
 @param passWordInfo 密码提示
 @param accountName 账户名
 @param completion 回调
 */
- (void)accountWithMnemonic:(NSString *)mnemonic
                 walletType:(CCWalletType)walletType
                 importType:(CCImportType)importType
                   passWord:(NSString *)passWord
               passWordInfo:(NSString *)passWordInfo
                accountName:(NSString *)accountName
             verifyMnemonic:(BOOL)verifyMnemonic
                 completion:(void(^)(BOOL suc, CCWalletError error))completion;
- (void)accountWithMnemonic:(NSString *)mnemonic
                 walletType:(CCWalletType)walletType
                 importType:(CCImportType)importType
                   passWord:(NSString *)passWord
               passWordInfo:(NSString *)passWordInfo
                accountName:(NSString *)accountName
                 completion:(void(^)(BOOL suc, CCWalletError error))completion;


/**
 私钥创建账户

 @param privatekey 私钥
 @param walletType 账户钱包类型
 @param coinType 链
 @param passWord 密码
 @param passWordInfo 密码提示
 @param accountName 账户名
 @param completion 回调
 */
- (void)accountWithPrivatekey:(NSString *)privatekey
                   walletType:(CCWalletType)walletType
                     coinType:(CCCoinType)coinType
                     passWord:(NSString *)passWord
                 passWordInfo:(NSString *)passWordInfo
                  accountName:(NSString *)accountName
                   completion:(void(^)(BOOL suc, CCWalletError error))completion;


/**
 wif创建账户

 @param wif wif
 @param walletType 账户钱包类型
 @param coinType 链
 @param passWord 密码
 @param passWordInfo 密码提示
 @param accountName 账户名
 @param completion 回调
 */
- (void)accountWithWIF:(NSString *)wif
            walletType:(CCWalletType)walletType
              coinType:(CCCoinType)coinType
              passWord:(NSString *)passWord
          passWordInfo:(NSString *)passWordInfo
           accountName:(NSString *)accountName
            completion:(void(^)(BOOL suc, CCWalletError error))completion;

/**
 keystore创建账户
 
 @param keystore keystore
 @param walletType 账户钱包类型
 @param coinType 链
 @param passWord 密码
 @param passWordInfo 密码提示
 @param accountName 账户名
 @param completion 回调
 */
- (void)accountWithKeystore:(NSString *)keystore
                 walletType:(CCWalletType)walletType
                   coinType:(CCCoinType)coinType
                   passWord:(NSString *)passWord
               passWordInfo:(NSString *)passWordInfo
                accountName:(NSString *)accountName
                 completion:(void(^)(BOOL suc, CCWalletError error))completion;


/**
 添加用户

 @param account account
 @param walletInfo 钱包信息
 @param passWord 密码
 */
- (void)addAccount:(CCAccountData *)account
    withWalletInfo:(NSString *)walletInfo
          passWord:(NSString *)passWord;


/**
 删除用户

 @param account 用户
 @param passWord 密码
 @param completion 回调
 */
- (void)deleteAccount:(CCAccountData *)account
             passWord:(NSString *)passWord
           completion:(void(^)(BOOL suc, CCWalletError error))completion;


/**
 删除账户（硬件钱包删除）

 @param account 账户
 @param completion 回调
 */
- (void)deleteAccount:(CCAccountData *)account
           completion:(void(^)(BOOL suc, CCWalletError error))completion;

/**
用户ID查找用户

 @param accountID 用户ID
 @return 用户
 */
- (CCAccountData *)accountWithAccountID:(NSString *)accountID;


/**
 是否创建有钱包

 @return 是否创建有钱包
 */
- (BOOL)hadAccount;



/**
 获取
 
 @param coinType 链
 @return 块高
 */
- (NSInteger)blockHeightWithType:(CCCoinType)coinType;

/**
 存储块高
 
 @param coinType 块高
 */
- (void)saveBlockTypeWithType:(CCCoinType)coinType blockHeight:(NSInteger)blockHeight;

/**
 获取gasprice
 
 @param coinType 链
 @return gasprice
 */
- (NSString *)gasPriceWithType:(CCCoinType)coinType;



/**
 存储钱包信息

 @param walletInfo 钱包信息
 @param accountID 用户ID
 @param password 密码
 */
- (void)saveWalletInfo:(NSString *)walletInfo accountID:(NSString *)accountID passWord:(NSString *)password;


/**
 重置密码

 @param password 新密码
 @param oldPassWord 老密码
 @param accountID 账户ID
 @param completion 回调
 */
- (void)resetPassWord:(NSString *)password
          oldPassWord:(NSString *)oldPassWord
            accountID:(NSString *)accountID
           completion:(void(^)(BOOL suc, CCWalletError error))completion;


/**
 获取用户存储的信息

 @param accountID 账户ID
 @param password 密码
 @param completion 回调
 */
- (void)walletInfoWithAccountID:(NSString *)accountID
                       password:(NSString *)password
                     completion:(void(^)(NSString *walletInfo))completion;

- (NSString *)walletInfoWithAccountID:(NSString *)accountID;


/**
 硬件名得到ID

 @param deviceName 硬件名
 @return ID
 */
- (NSString *)accountIDWithDeviceName:(NSString *)deviceName;

/**
 默认名

 @return 默认名
 */
- (NSString *)createWalletName;

/**
 清空数据
 */
- (void)clearData;


/**
 链名称
 
 @param type 链
 @return 名称
 */
+ (NSString *)coinNameWithType:(CCCoinType)type;


/**
 链图标
 
 @param type 链
 @return 图标
 */
+ (NSString *)coinIconWithType:(CCCoinType)type;

/**
 钱包链的key
 
 @param type 链
 @return key
 */
+ (NSString *)coinKeyWithType:(CCCoinType)type;

/**
 钱包链的Type
 
 @param key key
 @return CCCoinType
 */
+ (CCCoinType)coinTypeWithKey:(NSString *)key;

@end
