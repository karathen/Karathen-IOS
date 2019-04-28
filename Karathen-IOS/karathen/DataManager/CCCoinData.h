//
//  CCCoinData.h
//  Karathen
//
//  Created by Karathen on 2018/8/27.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCWalletData.h"

@class CCCoin;
@interface CCCoinData : NSObject

@property (nonatomic, strong) CCCoin *coin;

@property (nonatomic, strong, readonly) NSMutableArray <CCWalletData *> *wallets;
@property (nonatomic, weak, readonly) CCWalletData *activeWallet;
@property (nonatomic, assign, readonly) CCImportType importType;


/**
 初始化链

 @param coin CCCoin
 @return CCCoinData
 */
- (instancetype)initWithCoin:(CCCoin *)coin;


/**
 助记词创建

 @param mnemonic 助记词
 @param importType 导入方式（助记词，生成助记词，硬件）
 @param completion 回调
 */
- (void)createWalletWithMnemonic:(NSString *)mnemonic
                      importType:(CCImportType)importType
                      completion:(void(^)(BOOL suc,CCWalletError error))completion;




/**
 私钥创建

 @param privateKey 私钥
 @param completion 回调
 */
- (void)createWalletWithPrivateKey:(NSString *)privateKey
                        completion:(void(^)(BOOL suc,CCWalletError error))completion;



/**
 wif创建

 @param wif wif
 @param completion 回调
 */
- (void)createWalletWithWIF:(NSString *)wif
                 completion:(void(^)(BOOL suc,CCWalletError error))completion;



/**
 keystore

 @param keystore keystore
 @param password 密码
 @param completion 回调
 */
- (void)createWalletWithKeyStore:(NSString *)keystore
                        passWord:(NSString *)password
                      completion:(void(^)(BOOL suc,CCWalletError error,NSString *privatekey))completion;

/**
 HD钱包增加地址

 @param walletName 地址名
 @param passWord 密码
 @param importType 导入方式
 @param completion 回调
 */
- (void)createHDAddressWithWalletName:(NSString *)walletName
                             passWord:(NSString *)passWord
                           importType:(CCImportType)importType
                           completion:(void(^)(BOOL suc,CCWalletError error))completion;


/**
 保存地址

 @param address 地址
 @param walletName 名称
 @param importType 导入方式
 @param slot slot
 @param completion 回调
 */
- (void)saveWalletWithAddress:(NSString *)address
                   walletName:(NSString *)walletName
                   importType:(CCImportType)importType
                         slot:(int)slot
                   completion:(void(^)(BOOL suc,CCWalletError error))completion;
/**
 修改当前默认钱包

 @param walletData 默认钱包
 */
- (void)changeActiveWallet:(CCWalletData *)walletData;


/**
 默认新创建的名字

 @return 默认
 */
- (NSString *)createWalletName;


/**
 地址得到钱包

 @param address 地址
 @return 钱包
 */
- (CCWalletData *)walletDataWithAddress:(NSString *)address;



@end
