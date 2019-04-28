//
//  CCWalletManager+NEO.m
//  Karathen
//
//  Created by Karathen on 2018/8/22.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCWalletManager+NEO.h"
#import "CCNEOAccount.h"
#import "NSData+Extend.h"

@implementation CCWalletManager (NEO)

#pragma mark -  助记词创建多地址
+ (NSString *)createNEOAddressWithMnemonics:(NSString *)mnemonics
                                       slot:(int)slot {

    CCNEOAccount *account = [[CCNEOAccount alloc] initWithMnemonic:mnemonics slot:slot];
    return account.address.address;
}

#pragma mark - 私钥创建地址
+ (NSString *)createNEOAddressWithPrivateKey:(NSString *)privateKey {
    if ([privateKey hasPrefix:@"0x"]) {
        privateKey = [privateKey substringFromIndex:2];
    }
    if (privateKey.length != 64) {
        return nil;
    }
    CCNEOAccount *account = [[CCNEOAccount alloc] initWithPrivateKey:privateKey];
    return account.address.address;
}

#pragma mark - wif创建地址
+ (NSString *)createNEOAddressWithWIF:(NSString *)wif {
    if ([wif hasPrefix:@"0x"]) {
        wif = [wif substringFromIndex:2];
    }
    if (wif.length != 52) {
        return nil;
    }
    CCNEOAccount *account = [[CCNEOAccount alloc] initWithWIF:wif];
    return account.address.address;
}

#pragma mark - 通过助记词导出私钥
+ (NSString *)exportNEOPrivateKeyWithMnemonics:(NSString *)mnemonics
                                          slot:(int)slot {
    
    CCNEOAccount *account = [[CCNEOAccount alloc] initWithMnemonic:mnemonics slot:slot];
    return account.privateKey.data.hexString;
}

#pragma mark - 通过助记词导出wif
+ (NSString *)exportNEOWIFWithMnemonics:(NSString *)mnemonics
                                          slot:(int)slot {
    CCNEOAccount *account = [[CCNEOAccount alloc] initWithMnemonic:mnemonics slot:slot];
    return account.privateKey.toWif;
}


#pragma mark - 私钥导出WIF
+ (NSString *)exportNEOWIFWithPrivateKey:(NSString *)privateKey {
    CCNEOAccount *account = [[CCNEOAccount alloc] initWithPrivateKey:privateKey];
    return account.privateKey.toWif;
}


#pragma mark - wif导出私钥
+ (NSString *)exportNEOPrivateKeyWithWIF:(NSString *)wif {
    CCNEOAccount *account = [[CCNEOAccount alloc] initWithWIF:wif];
    return account.privateKey.data.hexString;
}

@end
