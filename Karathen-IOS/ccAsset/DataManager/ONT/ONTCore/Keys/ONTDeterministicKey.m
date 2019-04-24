//
//  ONTDeterministicKey.m
//
//  Created by XiaoQing Pan on 2018/5/9.
//  Copyright © 2018 yuzhiyou All rights reserved.
//

#import "ONTDeterministicKey.h"
#import "SHAHash.h"
#include "memzero.h"
#import "secp256k1.h"
#import "secp256k1_zkp.h"
#import "Categories.h"
#import "ONTECKey.h"
#import "uECC.h"
#import "bip39.h"

@implementation ONTDeterministicKey

- (instancetype)initWithSeed:(NSData*)seed {
    // generate private key
    NSData *masterPriKey = [ONTDeterministicKey createMasterPrivateKey:seed forKey:[@"Nist256p1 seed" dataUsingEncoding:NSUTF8StringEncoding]];
    
    // generate hd_key object
    self = [self initWithPri:[masterPriKey subdataWithRange:NSMakeRange(0, 32)] Pub:nil Code:[masterPriKey subdataWithRange:NSMakeRange(32, 32)]];
    return self;
}

- (instancetype)initWithPri:(NSData *)pri Pub:(NSData *)pub Code:(NSData *)code
{
    self = [super initWithPri:pri Pub:pub Code:code];
    if (self) {
        // generate public key
        if (pub == nil) {
            // prepare data
            uint8_t priv[32];
            memcpy(priv, pri.bytes, 32);
            
            uint8_t uncompressed_pub[65];
            uint8_t public[33];
            uECC_compute_public_key(priv, uncompressed_pub);
            uECC_compress(uncompressed_pub, public);
            
            publicKey = [NSData dataWithBytes:public length:sizeof(public)];
            // clear
            memzero(priv, sizeof(priv));
            memzero(uncompressed_pub, sizeof(uncompressed_pub));
            memzero(public, sizeof(public));
        }
    }
    return self;
}
+ (NSData *)createMasterPrivateKey:(NSData*)seed forKey:(NSData *)key{
    // selection algorithm
    NSData *masterPrivateKey = [SHAHash Hmac512:key Data:seed];
    return masterPrivateKey;
}
- (DeterministicKey*)privChild:(ChildNumber*)childNumber {
    // selection algorithm(Secp256r1)
    MBigNumber *N = [[MBigNumber alloc] initWithDataBE:@"FFFFFFFF00000000FFFFFFFFFFFFFFFFBCE6FAADA7179E84F3B9CAC2FC632551".hexToData];
    
    // [1] get chain code
    NSMutableData *data = [NSMutableData new];
    if (childNumber.Hardened) {
        uint8_t temp = 0;
        [data appendBytes:&temp length:1];
        [data appendData:privateKey];
    } else {
        [data appendData:publicKey];
    }
    [data appendData:childNumber.getPath];
    NSData *i = [SHAHash Hmac512:chainCode Data:data];
    
    // [2] generate child key
    MBigNumber *ki;
    while (true) {
        NSData *il = [i subdataWithRange:NSMakeRange(0, 32)];
        MBigNumber *ilInt = [[MBigNumber alloc] initWithDataBE:il];
        MBigNumber *pri = [[MBigNumber alloc] initWithDataBE:privateKey];
        ki = [[pri add:ilInt] mod:N];
        if (ki.isZero || ![ilInt isLess:N]) {
            uint8_t temp = 1;
            [data replaceBytesInRange:NSMakeRange(0, 1) withBytes:&temp length:1];
            [data replaceBytesInRange:NSMakeRange(1, 32) withBytes:[i subdataWithRange:NSMakeRange(32, 32)].bytes length:32];
            i = [SHAHash Hmac512:chainCode Data:data];
        }else{
            break;
        }
        
    }
    
    // [3] generate ONTDeterministicKey object
    DeterministicKey *rawKey = [[ONTDeterministicKey alloc] initWithPri:ki.toDataBE Pub:nil Code:[i subdataWithRange:NSMakeRange(32, 32)]];
    return rawKey;
}

- (DeterministicKey*)pubChild:(ChildNumber *)childNumber {
    return nil;
}


- (id)toECKey {
    return [[ONTECKey alloc] initWithKey:privateKey Pub:publicKey];
}

@end
