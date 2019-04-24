//
//  ONTECKey.m
//  Forrest
//
//  Created by XiaoQing Pan on 2018/3/20.
//  Copyright © 2018 Yuzhiyou. All rights reserved.
//

#import "ONTECKey.h"
#import "NSData+Extend.h"
#include "secp256k1_zkp.h"
#include "memzero.h"
#import "uECC.h"
#import <neoutils/neoutils.h>

@implementation ONTECKey

- (instancetype)initWithKey:(NSData*)priKey Pub:(NSData*)pubKey {
    self = [self init];
    if (self) {
        privateKey = priKey;
        // public key to supplement the missing
        if (pubKey == nil && privateKey != nil) {
            // prepare data
            uint8_t priv[32];
            memcpy(priv, privateKey.bytes, 32);
            
            uint8_t uncompressed_pub[64];
            uint8_t pub[33];
            uECC_compute_public_key(priv, uncompressed_pub);
            uECC_compress(uncompressed_pub, pub);
            
            publicKey = [NSData dataWithBytes:pub length:sizeof(pub)];
            // clear
            memzero(priv, sizeof(priv));
            memzero(uncompressed_pub, sizeof(uncompressed_pub));
            memzero(pub, sizeof(pub));
            
        } else {
            publicKey = pubKey;
        }
    }
    return self;
}

- (ECKeySignature*)sign:(NSData*)mess {
    NSError *error;
    NSData *sig = NeoutilsSign(mess, privateKey.hexString, &error);
    if (error) {
        return nil;
    }
    ECKeySignature *signature = [[ECKeySignature alloc] initWithData:sig V:255];
    return signature;
}

- (Boolean)verify:(NSData*)mess :(ECKeySignature*)sig {
    return NO;
}

@end
