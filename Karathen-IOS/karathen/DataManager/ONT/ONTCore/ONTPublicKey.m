//
//  ONTPublicKey.m
//  ONTWallet
//
//  Created by Yuzhiyou on 2018/7/13.
//  Copyright © 2018年 Yuzhiyou. All rights reserved.
//

#import "ONTPublicKey.h"
#import "Categories.h"
#import "NSMutableData+ONTScriptBuilder.h"

@interface ONTPublicKey(){
    NSData *pubkey;
}
@end
@implementation ONTPublicKey

- (instancetype)initWithData:(NSData*)pubKey
{
    self = [super init];
    if (self) {
        pubkey = pubKey;
    }
    return self;
}

-(NSData *)data{
    return pubkey;
}
- (ONTAddress*)toAddress {
    unsigned char CHECKSIG = ONT_OPCODE_CHECKSIG;
    
    NSMutableData *program = [NSMutableData new];
    [program pushData:pubkey];
    [program appendBytes:&CHECKSIG length:1];
    
    unsigned char COIN_VERSION = 0x17;
    
    NSString *hex = [[NSData dataWithBytes:&COIN_VERSION length:1].hexString stringByAppendingString:program.hash160.hexString];
    
    return [[ONTAddress alloc] initWithAddressString:[NSString base58checkWithData:hex.hexToData]];
}
@end
