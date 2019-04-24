//
//  Hasher.h
//  ectest
//
//  Created by XiaoQing Pan on 2018/5/8.
//  Copyright © 2018 XiaoQing Pan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IAGAesGcm.h"

@interface SHAHash : NSObject

+ (NSData*)Hmac512:(NSData*)key Data:(NSData*)data;
+ (NSData*)SHA1:(NSData*)data;
+ (NSData*)RIPEMD160:(NSData*)data;
+ (NSData*)Keccak256:(NSData*)data;
+ (NSData*)Sha2512:(NSData*)data;
+ (NSData*)Sha2256:(NSData*)data;
#pragma mark - AES PKCS7Padding
+ (NSData*)aesDecrypt:(NSData*)data key:(NSData *)key iv:(NSData *)iv;
+ (NSData*)aesEncrypt:(NSData*)data key:(NSData *)key iv:(NSData *)iv;
#pragma mark - AES 128 GCM
+ (NSData *)aesGcm128Decrypt:(NSData*)data key:(NSData *)key iv:(NSData *)iv aad:(NSData *)aad tag:(NSData *)tag;
+ (IAGCipheredData *)aesGcm128Encrypt:(NSData*)data key:(NSData *)key iv:(NSData *)iv aad:(NSData *)aad;

@end
