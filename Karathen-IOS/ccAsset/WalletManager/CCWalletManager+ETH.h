//
//  CCWalletManager+ETH.h
//  ccAsset
//
//  Created by SealWallet on 2018/8/22.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCWalletManager.h"

@interface CCWalletManager (ETH)

/**
 助记词创建多地址


 @param mnemonics 助记词
 @param slot slot
 @return 地址
 */
+ (NSString *)createETHAddressWithMnemonics:(NSString *)mnemonics
                                       slot:(int)slot;

/**
 私钥创建地址

 @param privateKey 私钥
 @return 地址
 */
+ (NSString *)createETHAddressWithPrivateKey:(NSString *)privateKey;


/**
 keystore创建地址导出私钥

 @param keystore keystore
 @param password 密码
 @param completion 回调
 */
+ (void)createETHAddressWithKeystore:(NSString *)keystore
                            password:(NSString *)password
                          completion:(void(^)(BOOL suc,CCWalletError error,NSString *privatekey,NSString *address))completion;

/**
 通过助记词导出私钥

 @param mnemonics 助记词
 @param slot slot
 @return 私钥
 */
+ (NSString *)exportETHPrivateKeyWithMnemonics:(NSString *)mnemonics
                                          slot:(int)slot;



/**
 助记词导出keystore

 @param mnemonics 助记词
 @param slot slot
 @param password 密码
 @param completion 回调
 */
+ (void)exportETHKeystoreWithMnemonics:(NSString *)mnemonics
                                  slot:(int)slot
                              password:(NSString *)password
                            completion:(void(^)(BOOL suc,CCWalletError error,NSString *keystore))completion;


/**
 私钥导出keystore

 @param privateKey 私钥
 @param password 密码
 @param completion 回调
 */
+ (void)exportETHKeystoreWithPrivatekey:(NSString *)privateKey
                               password:(NSString *)password
                             completion:(void(^)(BOOL suc,CCWalletError error,NSString *keystore))completion;
@end
