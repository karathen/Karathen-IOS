//
//  ONTSignature.m
//  ONTWallet
//
//  Created by Yuzhiyou on 2018/7/26.
//  Copyright © 2018年 Yuzhiyou. All rights reserved.
//

#import "ONTSignature.h"
#import "NSMutableData+Extend.h"
#import "NSMutableData+ONTScriptBuilder.h"
#import "NSData+Extend.h"
#import "uECC.h"

#define MULTI_SIG_MAX_PUBKEY_SIZE 16

@implementation ONTSignature
/**
 * @brief Initialization method
 */
- (instancetype)init{
    self = [super init];
    if (self) {
        _publicKeys = [NSMutableArray new];
        _signatureDatas = [NSMutableArray new];
    }
    return self;
}
-(instancetype)initWithPublicKey:(NSData *)publicKey signature:(NSData *)signature{
    self = [self init];
    if (self) {
        [_publicKeys addObject:publicKey];
        [_signatureDatas addObject:signature];
        _M = _publicKeys.count;
    }
    return self;
}
/**
 * @brief Obtaining complete byte stream data
 */
- (void)toByte:(NSMutableData *)stream{
    [stream ont_appendVarData:[self programFromSignatures:_signatureDatas]];
    
    if (!_publicKeys || _publicKeys.count == 0) {
        return;
    }
    if (_publicKeys.count == 1) {
        [stream ont_appendVarData:[self programFromPubKey:_publicKeys[0]]];
    }else {
        [stream ont_appendVarData:[self programFromMultiPubKey:_publicKeys m:_M]];
    }
}
#pragma mark - Utils
-(NSData *)programFromSignatures:(NSMutableArray<NSData *> *)signatures{
    // sort
    [signatures sortUsingComparator:^NSComparisonResult(NSData *  _Nonnull obj1, NSData *  _Nonnull obj2) {
        return [obj1.hexString compare:obj2.hexString];
    }];
    // push
    NSMutableData *data = [NSMutableData new];
    for (NSData *signature in signatures) {
        [data pushData:signature];
    }
    return data;
}
-(NSData *)programFromPubKey:(NSData *)publicKey{
    NSMutableData *data = [NSMutableData new];
    [data pushData:publicKey];
    [data addOpcode:ONT_OPCODE_CHECKSIG];
    return data;
}
-(NSData *)programFromMultiPubKey:(NSMutableArray<NSData *> *)publicKeys m:(NSUInteger)m{
    NSMutableData *data = [NSMutableData new];
    NSInteger n = publicKeys.count;
    if (m <= 0 || m > n || n > MULTI_SIG_MAX_PUBKEY_SIZE) {
        return data;
    }
    [data pushNumber:@(m)];
    // Sort public keys
    [publicKeys sortUsingComparator:^NSComparisonResult(NSData *  _Nonnull obj1, NSData *  _Nonnull obj2) {
        return [obj1.hexString compare:obj2.hexString];
    }];
    for (NSData *pubKey in publicKeys) {
        [data pushData:pubKey];
    }
    [data pushNumber:@(publicKeys.count)];
    [data addOpcode:ONT_OPCODE_CHECKMULTISIG];
    return data;
}
@end
