//
//  ONTAccount.m
//  ONTWallet
//
//  Created by Yuzhiyou on 2018/7/13.
//  Copyright © 2018年 Yuzhiyou. All rights reserved.
//

#import "ONTAccount.h"
#import "crypto_scrypt.h"
#import "NSData+Extend.h"
#import "NSData+Hash.h"
#import "NSString+Base58.h"
#import "MnemonicCode.h"

#import "ONTDeterministicKey.h"
#import "ONTECKey.h"
#import "IAGAesGcm.h"
#import "ONTStruct.h"
#import "ONTTransaction.h"
#import "ONTNativeBuildParams.h"
#import "ONTInvokeCode.h"

@interface ONTAccount()

@property(nonatomic, readonly) NSString *password;

@end

@implementation ONTAccount

- (instancetype)initWithMnemonic:(NSString *)mnemonic slot:(int)slot {
    self = [super init];
    if (self) {
        // 助记词
        MnemonicCode *mnemonicCode  = [MnemonicCode shareInstance];
        if (![mnemonicCode check:mnemonic]) {
            return nil;
        }
        NSData *seed = [mnemonicCode toSeed:[mnemonic componentsSeparatedByString:@" "] withPassphrase:@""];
        ONTDeterministicKey *rootKey = [[ONTDeterministicKey alloc] initWithSeed:seed];
        
        NSMutableArray *path = [NSMutableArray new];
        [path addObject:[[ChildNumber alloc] initWithPath:44 Hardened:YES]];
        [path addObject:[[ChildNumber alloc] initWithPath:1024 Hardened:YES]];
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

- (NSString *)makeTransferToAddress:(NSString *)toAddress
                       tokenAddress:(NSString *)tokenAddress
                             amount:(NSString *)amount
                            decimal:(NSString *)decimal
                           gasPrice:(long)gasPrice
                           gasLimit:(long)gasLimit {
    ONTECKey *ecKey = [[ONTECKey alloc] initWithPriKey:self.privateKey.data];
    ONTPublicKey *publicKey = [[ONTPublicKey alloc] initWithData:ecKey.publicKeyAsData];
    
    ONTAddress *from = publicKey.toAddress;
    ONTAddress *to = [[ONTAddress alloc] initWithAddressString:toAddress];
    
    ONTAddress *contractAddress = [[ONTAddress alloc] initWithData:tokenAddress.hexToData];

    
    ONTStruct *ontStruct = [[ONTStruct alloc] init];
    [ontStruct add:from];
    [ontStruct add:to];
    
    NSDecimalNumber *amountValue = [NSDecimalNumber decimalNumberWithString:amount];
    double decimalDouble = pow(10.0, decimal.integerValue);
    [ontStruct add:[[ONTLong alloc] initWithLong:(long)(amountValue.doubleValue*decimalDouble)]];

    ONTStructs *structs = [[ONTStructs alloc] init];
    [structs add:ontStruct];
    
    NSMutableArray *array = [NSMutableArray new];
    [array addObject:structs];
    
    NSData *args = [ONTNativeBuildParams createCodeParamsScript:array];
    ONTTransaction *transaction = [ONTInvokeCode invokeCodeTransaction:contractAddress initMethod:@"transfer" args:args payer:from gasLimit:gasLimit gasPrice:gasPrice];
    
    // 签名
    ECKeySignature *sign = [ecKey sign:transaction.getSignHash];
    [transaction.signatures addObject:[[ONTSignature alloc] initWithPublicKey:ecKey.publicKeyAsData signature:sign.toDataNoV]];
    
    NSString *txHex = transaction.toRawByte.hexString;
    return txHex;
}



- (NSString *)makeClaimOngTxWithAddress:(NSString *)address
                                 amount:(NSString *)amount
                               gasPrice:(long)gasPrice
                               gasLimit:(long)gasLimit {
    ONTECKey *ecKey = [[ONTECKey alloc] initWithPriKey:self.privateKey.data];
    ONTPublicKey *publicKey = [[ONTPublicKey alloc] initWithData:ecKey.publicKeyAsData];
    
    ONTAddress *from = publicKey.toAddress;
    ONTAddress *to = [[ONTAddress alloc] initWithAddressString:address];
    
    ONTAddress *ontContractAddress = [[ONTAddress alloc] initWithData:ONT_CONTRACT.hexToData];
    ONTAddress *ongContractAddress = [[ONTAddress alloc] initWithData:ONG_CONTRACT.hexToData];
    
    ONTStruct *ontStruct = [[ONTStruct alloc] init];
    [ontStruct add:from];
    [ontStruct add:ontContractAddress];
    [ontStruct add:to];
    NSDecimalNumber *amountValue = [NSDecimalNumber decimalNumberWithString:amount];
    [ontStruct add:[[ONTLong alloc] initWithLong:(long)(amountValue.doubleValue*1000000000)]];
    
    NSMutableArray *array = [NSMutableArray new];
    [array addObject:ontStruct];
    
    NSData *args = [ONTNativeBuildParams createCodeParamsScript:array];
    ONTTransaction *transaction = [ONTInvokeCode invokeCodeTransaction:ongContractAddress initMethod:@"transferFrom" args:args payer:from gasLimit:gasLimit gasPrice:gasPrice];
    
    // 签名
    ECKeySignature *sign = [ecKey sign:transaction.getSignHash];
    [transaction.signatures addObject:[[ONTSignature alloc] initWithPublicKey:ecKey.publicKeyAsData signature:sign.toDataNoV]];
    
    NSString *txHex = transaction.toRawByte.hexString;
    return txHex;
}


@end
