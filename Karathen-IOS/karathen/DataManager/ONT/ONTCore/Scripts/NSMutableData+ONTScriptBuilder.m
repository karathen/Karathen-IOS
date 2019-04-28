//
//  NSMutableData+ONTScriptBuilder.m
//  ONTWallet
//
//  Created by Yuzhiyou on 2018/7/24.
//  Copyright © 2018年 Yuzhiyou. All rights reserved.
//

#import "NSMutableData+ONTScriptBuilder.h"
#import "NSData+Extend.h"
#import "NSMutableData+Extend.h"

@implementation NSMutableData (ONTScriptBuilder)
-(void)addOpcode:(ONT_OPCODE)op{
    [self addByte:op];
}
-(void)addByte:(Byte)byte{
    [self appendBytes:&byte length:1];
}
-(void)addData:(NSData *)data{
    [self appendData:data];
}
-(void)pushBool:(BOOL)b{
    if (b == YES) {
        [self addOpcode:ONT_OPCODE_PUSH1];
    }else{
        [self addOpcode:ONT_OPCODE_PUSH0];
    }
}
-(void)pushNumber:(NSNumber *)number{
    if (number.longLongValue == -1) {
        [self addOpcode:ONT_OPCODE_PUSHM1];
    }else if (number.longLongValue == 0) {
        [self addOpcode:ONT_OPCODE_PUSH0];
    }else if (number.longLongValue > 0 && number.longLongValue <= 16) {
        [self addByte:(ONT_OPCODE_PUSH1-1+number.intValue)];
    }else{
        uint64_t value = CFSwapInt64HostToLittle(number.longLongValue);
        [self pushData:[NSData dataWithBytes:&value length:sizeof(value)]];
    }
}
-(void)pushData:(NSData *)data{
    if (data.length <= ONT_OPCODE_PUSHBYTES75) {
        [self appendUInt8:data.length];
    }else if (data.length < 0x100){
        [self addByte:ONT_OPCODE_PUSHDATA1];
        [self appendUInt8:data.length];
    }else if (data.length < 0x10000){
        [self addByte:ONT_OPCODE_PUSHDATA2];
        [self appendUInt16:data.length];
    }else if (data.length < 0x100000000L){
        [self addByte:ONT_OPCODE_PUSHDATA4];
        [self appendUInt32:(uint32_t)data.length];
    }
    [self addData:data];
}
-(void)pushPack{
    [self addByte:ONT_OPCODE_PACK];
}
@end
