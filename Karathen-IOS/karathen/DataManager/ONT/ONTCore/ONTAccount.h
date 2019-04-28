//
//  ONTAccount.h
//  ONTWallet
//
//  Created by Yuzhiyou on 2018/7/13.
//  Copyright © 2018年 Yuzhiyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ONTPublicKey.h"
#import "ONTPrivateKey.h"
#import "ONTAddress.h"


typedef NS_ENUM(NSUInteger, ONTTokenType) {
    ONTTokenTypeONT,
    ONTTokenTypeONG,
};

#define ONT_CONTRACT @"0000000000000000000000000000000000000001"
#define ONG_CONTRACT @"0000000000000000000000000000000000000002"

/**
 数字资产
 */
@interface ONTAccount : NSObject

@property (nonatomic, readonly) ONTPrivateKey *privateKey;
@property (nonatomic, readonly) ONTPublicKey *publicKey;
@property (nonatomic, readonly) ONTAddress *address;

/**
 助记词创建
 
 @param mnemonic 助记词
 @param slot slot
 @return ONTAccount
 */
- (instancetype)initWithMnemonic:(NSString *)mnemonic slot:(int)slot;

/**
 私钥创建
 
 @param privateKey 私钥
 @return ONTAccount
 */
- (instancetype)initWithPrivateKey:(NSString *)privateKey;

/**
 WIF创建
 
 @param wif wif
 @return ONTAccount
 */
- (instancetype)initWithWIF:(NSString *)wif;


/**
 构造 ONT、ONG 交易

 @param toAddress 收款地址
 @param tokenAddress 合约地址
 @param amount 转账金额
 @param decimal 小数位
 @param gasPrice 默认 500
 @param gasLimit 默认 20000
 @return TxHex
 */
- (NSString *)makeTransferToAddress:(NSString *)toAddress
                       tokenAddress:(NSString *)tokenAddress
                             amount:(NSString *)amount
                            decimal:(NSString *)decimal
                           gasPrice:(long)gasPrice
                           gasLimit:(long)gasLimit;

/**
 构造提取 ONG 交易

 @param address 提取地址
 @param amount 提取金额
 @param gasPrice 默认 500
 @param gasLimit 默认 20000
 @return TxHex
 */
- (NSString *)makeClaimOngTxWithAddress:(NSString *)address amount:(NSString *)amount gasPrice:(long)gasPrice gasLimit:(long)gasLimit;

@end
