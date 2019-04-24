//
//  ONTTransaction.m
//  ONTWallet
//
//  Created by Yuzhiyou on 2018/7/23.
//  Copyright © 2018年 Yuzhiyou. All rights reserved.
//

#import "ONTTransaction.h"
#import "NSMutableData+Extend.h"
#import "NSData+Hash.h"
#import "NSData+Extend.h"

@implementation ONTTransaction
/**
 * @brief Initialization method
 */
- (instancetype)initWithType:(ONTTransactionType)type{
    self = [super init];
    if (self) {
        _type = type;
        _version = 0;
        _attributes = [NSMutableArray new];
        _signatures = [NSMutableArray new];
    }
    return self;
}
/**
 * @brief Obtaining complete byte stream data
 */
- (NSData *)toByte{
    NSMutableData *stream = [NSMutableData new];
    [stream appendUInt8:_version];
    [stream appendUInt8:_type];
    [stream appendUInt32:_nonce];
    [stream appendUInt64:_gasPrice];
    [stream appendUInt64:_gasLimit];
    [stream appendData:_payer.publicKeyHash160];
    [self toExclusiveByte:stream];
    // Attributes
    [stream ont_appendVarInt:_attributes.count];
    for (ONTAttribute *attribute in _attributes) {
        [attribute toByte:stream];
    }
    return stream;
}
/**
 * @brief Obtaining complete byte stream data
 */
- (NSData *)toRawByte{
    NSMutableData *stream = [NSMutableData new];
    [stream appendData:[self toByte]];
    // Signatures
    [stream ont_appendVarInt:_signatures.count];
    for (ONTSignature *signature in _signatures) {
        [signature toByte:stream];
    }
    return stream;
}
/**
 * @brief Obtaining Exclusive byte stream data
 */
- (void)toExclusiveByte:(NSMutableData *)stream{
}
- (NSData*)getSignHash {
    return [self toByte].SHA256_2;
}
@end
