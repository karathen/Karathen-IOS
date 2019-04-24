//
//  CCWalletManager+ONT.m
//  ccAsset
//
//  Created by SealWallet on 2018/9/19.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCWalletManager+ONT.h"
#import "ONTAccount.h"
#import "NSData+Extend.h"

@implementation CCWalletManager (ONT)

#pragma mark -  助记词创建多地址
+ (NSString *)createONTAddressWithMnemonics:(NSString *)mnemonics
                                       slot:(int)slot {
    ONTAccount *account = [[ONTAccount alloc] initWithMnemonic:mnemonics slot:slot];
    return account.address.address;
}

#pragma mark - 私钥创建地址
+ (NSString *)createONTAddressWithPrivateKey:(NSString *)privateKey {
    if ([privateKey hasPrefix:@"0x"]) {
        privateKey = [privateKey substringFromIndex:2];
    }
    if (privateKey.length != 64) {
        return nil;
    }
    ONTAccount *account = [[ONTAccount alloc] initWithPrivateKey:privateKey];
    return account.address.address;
}

#pragma mark - wif创建地址
+ (NSString *)createONTAddressWithWIF:(NSString *)wif {
    if ([wif hasPrefix:@"0x"]) {
        wif = [wif substringFromIndex:2];
    }
    if (wif.length != 52) {
        return nil;
    }
    ONTAccount *account = [[ONTAccount alloc] initWithWIF:wif];
    return account.address.address;
}

#pragma mark - 通过助记词导出私钥
+ (NSString *)exportONTPrivateKeyWithMnemonics:(NSString *)mnemonics
                                          slot:(int)slot {
    ONTAccount *account = [[ONTAccount alloc] initWithMnemonic:mnemonics slot:slot];
    return account.privateKey.data.hexString;
}

#pragma mark - 通过助记词导出wif
+ (NSString *)exportONTWIFWithMnemonics:(NSString *)mnemonics
                                   slot:(int)slot {
    ONTAccount *account = [[ONTAccount alloc] initWithMnemonic:mnemonics slot:slot];
    return account.privateKey.toWif;
}


#pragma mark - 私钥导出WIF
+ (NSString *)exportONTWIFWithPrivateKey:(NSString *)privateKey {
    ONTAccount *account = [[ONTAccount alloc] initWithPrivateKey:privateKey];
    return account.privateKey.toWif;
}

#pragma mark - wif导出私钥
+ (NSString *)exportONTPrivateKeyWithWIF:(NSString *)wif {
    ONTAccount *account = [[ONTAccount alloc] initWithWIF:wif];
    return account.privateKey.data.hexString;
}

@end
