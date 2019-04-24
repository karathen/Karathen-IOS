//
//  CCNEOAccount.m
//  ccAsset
//
//  Created by SealWallet on 2018/9/7.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCNEOAccount.h"
#import "MnemonicCode.h"
#import "ONTDeterministicKey.h"
#import "ONTECKey.h"
#import "NSData+Extend.h"

@implementation CCNEOAccount


- (instancetype)initWithMnemonic:(NSString *)mnemonic slot:(int)slot {
    if (self = [super init]) {
        // 助记词
        MnemonicCode *mnemonicCode  = [MnemonicCode shareInstance];
        if (![mnemonicCode check:mnemonic]) {
            return nil;
        }
        NSData *seed = [mnemonicCode toSeed:[mnemonic componentsSeparatedByString:@" "] withPassphrase:@""];
        ONTDeterministicKey *rootKey = [[ONTDeterministicKey alloc] initWithSeed:seed];
        
        NSMutableArray *path = [NSMutableArray new];
        [path addObject:[[ChildNumber alloc] initWithPath:44 Hardened:YES]];
        [path addObject:[[ChildNumber alloc] initWithPath:888 Hardened:YES]];
        [path addObject:[[ChildNumber alloc] initWithPath:0 Hardened:YES]];
        [path addObject:[[ChildNumber alloc] initWithPath:0 Hardened:NO]];
        [path addObject:[[ChildNumber alloc] initWithPath:slot Hardened:NO]];
        
        ONTECKey *ecKey = [[rootKey Derive:path] toECKey];
        if (!ecKey.privateKeyAsData || !ecKey.publicKeyAsData) {
            return nil;
        }
        _privateKey = [[ONTPrivateKey alloc] initWithData:ecKey.privateKeyAsData];
        _publicKey = [[ONTPublicKey alloc] initWithData:ecKey.publicKeyAsData];
    }
    return self;
}

- (instancetype)initWithPrivateKey:(NSString *)privateKey {
    if (self = [super init]) {
        ONTPrivateKey *private = [[ONTPrivateKey alloc] initWithPrivateKeyHex:privateKey];
        ONTECKey *ecKey = [[ONTECKey alloc] initWithPriKey:private.data];
        if (!ecKey.privateKeyAsData || !ecKey.publicKeyAsData) {
            return nil;
        }
        _privateKey = [[ONTPrivateKey alloc] initWithData:ecKey.privateKeyAsData];
        _publicKey = [[ONTPublicKey alloc] initWithData:ecKey.publicKeyAsData];
    }
    return self;
}

- (instancetype)initWithWIF:(NSString *)wif {
    if (self = [super init]) {
        ONTPrivateKey *private = [[ONTPrivateKey alloc] initWithWif:wif];
        ONTECKey *ecKey = [[ONTECKey alloc] initWithPriKey:private.data];
        if (!ecKey.privateKeyAsData || !ecKey.publicKeyAsData) {
            return nil;
        }
        _privateKey = [[ONTPrivateKey alloc] initWithData:ecKey.privateKeyAsData];
        _publicKey = [[ONTPublicKey alloc] initWithData:ecKey.publicKeyAsData];
    }
    return self;
}

- (ONTAddress *)address {
    return _publicKey.toAddress;
}

@end
