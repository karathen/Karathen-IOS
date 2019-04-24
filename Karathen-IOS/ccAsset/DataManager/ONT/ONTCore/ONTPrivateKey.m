//
//  ONTPrivateKey.m
//  ONTWallet
//
//  Created by Yuzhiyou on 2018/7/13.
//  Copyright © 2018年 Yuzhiyou. All rights reserved.
//

#import "ONTPrivateKey.h"
#import "Categories.h"

@interface ONTPrivateKey (){
    NSData *privkey;
}
@end
@implementation ONTPrivateKey
/**
 * @brief Initialization method
 */
- (instancetype) initWithData:(NSData *)privKey{
    self = [super init];
    if (self) {
        privkey = privKey;
    }
    return self;
}
/**
 * @brief Initialization method
 */
- (instancetype) initWithPrivateKeyHex:(NSString *)privKeyHex {
    self = [super init];
    if (self) {
        privkey = privKeyHex.hexToData;
    }
    return self;
}
/**
 * @brief Initialization method
 */
- (instancetype) initWithWif:(NSString *)wif{
    self = [super init];
    if (self) {
        NSData *privKeyData =  [wif base58checkToData];
        // Check Length
        if (!privKeyData || privKeyData.length != 34) {
            return nil;
        }
        // Check Version & compressed
        unsigned char version;
        [privKeyData getBytes:&version length:1];
        
        unsigned char compressed;
        [privKeyData getBytes:&compressed range:NSMakeRange(33, 1)];
        
        if (version != 0x80 ||  compressed != 0x01) {
            return nil;
        }
        privkey = [privKeyData subdataWithRange:NSMakeRange(1, 32)];
    }
    return self;
}
/**
 * @return EOS Private to Wif
 */
- (NSString *)toWif{
    NSMutableData *privateData = [NSMutableData new];
    unsigned char byte = 0x80;
    
    [privateData appendBytes:&byte length:1];
    [privateData appendData:privkey];
    
    unsigned char compressed = 0x01;
    [privateData appendBytes:&compressed length:1];
    
    return [NSString base58checkWithData:privateData];
}
/**
 * @return EOS Private Data
 */
-(NSData *)data{
    return privkey;
}

@end
