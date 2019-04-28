//
//  Hasher.m
//  ectest
//
//  Created by XiaoQing Pan on 2018/5/8.
//  Copyright © 2018 XiaoQing Pan. All rights reserved.
//

#import "SHAHash.h"
#import "hmac.h"
#import "options.h"
#import "ripemd160.h"
#import "sha3.h"
#import "sha2.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation SHAHash

+ (NSData*)Hmac512:(NSData*)key Data:(NSData*)data {
    static CONFIDENTIAL uint8_t I[32 + 32];
    static CONFIDENTIAL HMAC_SHA512_CTX ctx;
    hmac_sha512_Init(&ctx, key.bytes, key.length);
    hmac_sha512_Update(&ctx, data.bytes, data.length);
    hmac_sha512_Final(&ctx, I);
    return [[NSData alloc] initWithBytes:I length:64];
}

+ (NSData*)HmacSha1:(NSData *)key Data:(NSData *)data {
    const char *cKey  = key.bytes;
    const char *cData = data.bytes;
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    return HMAC;
}

+ (NSData*)HmacSha512:(NSData *)key Data:(NSData *)data {
    const char *cKey  = key.bytes;
    const char *cData = data.bytes;
    unsigned char cHMAC[CC_SHA512_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA512, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    return HMAC;
}

+ (NSData*)SHA1:(NSData*)data {
    NSMutableData *d = [NSMutableData dataWithLength:CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(data.bytes, (CC_LONG) data.length, d.mutableBytes);
    return d;
}

+ (NSData*)RIPEMD160:(NSData*)data {
    NSMutableData *d = [NSMutableData dataWithLength:20];
    ripemd160(data.bytes, data.length, d.mutableBytes);
    return d;
}

+ (NSData*)Keccak256:(NSData*)data {
    NSMutableData *d = [NSMutableData dataWithLength:(256 / 8)];
    
    SHA3_CTX context;
    keccak_256_Init(&context);
    keccak_Update(&context, data.bytes, (size_t)data.length);
    keccak_Final(&context, d.mutableBytes);
    
    return d;
}

+ (NSData*)Sha2512:(NSData*)data {
    NSMutableData *d = [NSMutableData dataWithLength:64];
    sha512_Raw(data.bytes, data.length, d.mutableBytes);
    return d;
}

+ (NSData *)Sha2256:(NSData*)data {
    NSMutableData *d = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(data.bytes, data.length, d.mutableBytes);
    return d;
}
+ (NSData *)aesDecrypt:(NSData*)data key:(NSData *)key iv:(NSData *)iv{
    if (key.length != 16 && key.length != 24 && key.length != 32) {
        return nil;
    }
    if (iv.length != 16) {
        return nil;
    }
    // setup output buffer
    size_t bufferSize = [data length] + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    // do encrypt
    size_t encryptedSize = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,
                                          [key bytes],     // Key
                                          [key length],    // kCCKeySizeAES
                                          [iv bytes],       // IV
                                          [data bytes],
                                          [data length],
                                          buffer,
                                          bufferSize,
                                          &encryptedSize);
    if (cryptStatus == kCCSuccess) {
        NSData *result = [NSData dataWithBytes:buffer length:encryptedSize];
        free(buffer);
        return result;
    }
    else {
        free(buffer);
        return nil;
    }
}
+ (NSData *)aesEncrypt:(NSData*)data key:(NSData *)key iv:(NSData *)iv{
    if (key.length != 16 && key.length != 24 && key.length != 32) {
        return nil;
    }
    if (iv.length != 16) {
        return nil;
    }
    // setup output buffer
    size_t bufferSize = [data length] + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    // do encrypt
    size_t encryptedSize = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,
                                          [key bytes],     // Key
                                          [key length],    // kCCKeySizeAES
                                          [iv bytes],       // IV
                                          [data bytes],
                                          [data length],
                                          buffer,
                                          bufferSize,
                                          &encryptedSize);
    if (cryptStatus == kCCSuccess) {
        NSData *result = [NSData dataWithBytes:buffer length:encryptedSize];
        free(buffer);
        
        return result;
    }
    else {
        free(buffer);
        return nil;
    }
}

#pragma mark - AES GCM
#pragma mark - AES 128 GCM
+ (NSData *)aesGcm128Decrypt:(NSData*)data key:(NSData *)key iv:(NSData *)iv aad:(NSData *)aad tag:(NSData *)tag{
    NSError *error;
    IAGCipheredData *cipheredData = [[IAGCipheredData alloc] initWithCipheredData:data authenticationTag:tag];
    NSData *decryptData = [IAGAesGcm plainDataByAuthenticatedDecryptingCipheredData:cipheredData
                                                    withAdditionalAuthenticatedData:aad
                                                               initializationVector:iv
                                                                                key:key
                                                                              error:&error];
    if (error) {
        return nil;
    }
    return decryptData;
}
+ (IAGCipheredData *)aesGcm128Encrypt:(NSData*)data key:(NSData *)key iv:(NSData *)iv aad:(NSData *)aad{
    NSError *error;
    IAGCipheredData *cipheredData = [IAGAesGcm cipheredDataByAuthenticatedEncryptingPlainData:data
                                                              withAdditionalAuthenticatedData:aad authenticationTagLength:IAGAuthenticationTagLength128 initializationVector:iv key:key error:&error];
    if (error) {
        return nil;
    }
    return cipheredData;
}
@end
