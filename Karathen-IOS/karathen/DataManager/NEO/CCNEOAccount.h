//
//  CCNEOAccount.h
//  Karathen
//
//  Created by Karathen on 2018/9/7.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ONTPublicKey.h"
#import "ONTPrivateKey.h"
#import "ONTAddress.h"

@interface CCNEOAccount : NSObject

@property (nonatomic, readonly) ONTPrivateKey *privateKey;
@property (nonatomic, readonly) ONTPublicKey *publicKey;
@property (nonatomic, readonly) ONTAddress *address;


/**
 助记词创建

 @param mnemonic 助记词
 @param slot slot
 @return CCNEOAccount
 */
- (instancetype)initWithMnemonic:(NSString *)mnemonic slot:(int)slot;


/**
 私钥创建

 @param privateKey 私钥
 @return CCNEOAccount
 */
- (instancetype)initWithPrivateKey:(NSString *)privateKey;


/**
 WIF创建
 
 @param wif wif
 @return CCNEOAccount
 */
- (instancetype)initWithWIF:(NSString *)wif;


@end
