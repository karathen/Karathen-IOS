//
//  CCWalletManager+NEO.h
//  Karathen
//
//  Created by Karathen on 2018/8/22.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCWalletManager.h"

@interface CCWalletManager (NEO)


/**
 助记词创建多地址
 
 @param mnemonics 助记词
 @param slot slot
 @return 地址
 */
+ (NSString *)createNEOAddressWithMnemonics:(NSString *)mnemonics
                                       slot:(int)slot;

/**
 私钥创建地址
 
 @param privateKey 私钥
 @return 地址
 */
+ (NSString *)createNEOAddressWithPrivateKey:(NSString *)privateKey;

/**
 wif创建地址
 
 @param wif wif
 @return 地址
 */
+ (NSString *)createNEOAddressWithWIF:(NSString *)wif;

/**
 通过助记词导出私钥
 
 @param mnemonics 助记词
 @param slot slot
 @return 私钥
 */
+ (NSString *)exportNEOPrivateKeyWithMnemonics:(NSString *)mnemonics
                                          slot:(int)slot;

/**
 通过助记词导出wif
 
 @param mnemonics 助记词
 @param slot slot
 @return wif
 */
+ (NSString *)exportNEOWIFWithMnemonics:(NSString *)mnemonics
                                   slot:(int)slot;


/**
 私钥导出WIF

 @param privateKey 私钥
 @return wif
 */
+ (NSString *)exportNEOWIFWithPrivateKey:(NSString *)privateKey;


/**
 wif导出私钥

 @param wif wif
 @return 私钥
 */
+ (NSString *)exportNEOPrivateKeyWithWIF:(NSString *)wif;

@end
