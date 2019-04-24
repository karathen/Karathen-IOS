//
//  CCCryptoTool.m
//  ccAsset
//
//  Created by SealWallet on 2018/8/29.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCCryptoTool.h"
#import "NSData+Hash.h"
#import "NSData+Extend.h"
#import "crypto_scrypt.h"

@implementation CCCryptoTool

// 加密
+(NSString *)encrypt:(NSString *)decryptCode password:(NSString *)password saltString:(NSString *)saltString {
    int N = 4096;
    int r = 8;
    int p = 8;
    int dkLen = 64;
    char stop = 0;
    
    NSData *passwordData = [[password precomposedStringWithCompatibilityMapping] dataUsingEncoding:NSUTF8StringEncoding];
    
    NSData *saltHashTmp = [saltString dataUsingEncoding:NSUTF8StringEncoding].SHA256_2;
    NSData *salt = [saltHashTmp subdataWithRange:NSMakeRange(0, 4)];
    
    NSMutableData *derivedkey = [NSMutableData dataWithLength:dkLen];
    int status = crypto_scrypt(passwordData.bytes, (int)passwordData.length, salt.bytes, salt.length, N, r, p, derivedkey.mutableBytes,derivedkey.length, &stop);
    // Bad scrypt parameters
    if (status == -1) {
        DLog(@"Bad scrypt parameters");
    }
    NSData *derivedhalf2 = [derivedkey subdataWithRange:NSMakeRange(32, 32)];
    NSData *iv = [derivedkey subdataWithRange:NSMakeRange(0, 16)];
    
    NSData *decryptData = [decryptCode dataUsingEncoding:NSUTF8StringEncoding];
    decryptData = [decryptData aesEncrypt:derivedhalf2 iv:iv];
    
    NSString *encryptedData = [[NSString alloc] initWithData:decryptData.base64 encoding:NSUTF8StringEncoding];
    return encryptedData;
}

// 解密
+(NSString *)decrypt:(NSString *)encryptedCode password:(NSString *)password saltString:(NSString *)saltString {
    int N = 4096;
    int r = 8;
    int p = 8;
    int dkLen = 64;
    char stop = 0;
    
    NSData *passwordData = [[password precomposedStringWithCompatibilityMapping] dataUsingEncoding:NSUTF8StringEncoding];
    
    NSData *saltHashTmp = [saltString dataUsingEncoding:NSUTF8StringEncoding].SHA256_2;
    NSData *salt = [saltHashTmp subdataWithRange:NSMakeRange(0, 4)];
    
    NSMutableData *derivedkey = [NSMutableData dataWithLength:dkLen];
    int status = crypto_scrypt(passwordData.bytes, (int)passwordData.length, salt.bytes, salt.length, N, r, p, derivedkey.mutableBytes,derivedkey.length, &stop);
    // Bad scrypt parameters
    if (status == -1) {
        return nil;
    }
    NSData *derivedhalf2 = [derivedkey subdataWithRange:NSMakeRange(32, 32)];
    NSData *iv = [derivedkey subdataWithRange:NSMakeRange(0, 16)];
    
    NSData *encryptedData = [NSData decodeBase64:encryptedCode];
    NSData *decryptedData = [encryptedData aesDecrypt:derivedhalf2 iv:iv];
    
    NSString *decryptedCode = [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
    if (!decryptedCode) {
        return nil;
    }
    return decryptedCode;
}


@end
