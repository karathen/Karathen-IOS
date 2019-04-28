//
//  ONTNativeBuildParams.m
//  ONTWallet
//
//  Created by Yuzhiyou on 2018/7/25.
//  Copyright © 2018年 Yuzhiyou. All rights reserved.
//

#import "ONTNativeBuildParams.h"
#import "NSMutableData+ONTScriptBuilder.h"

@implementation ONTNativeBuildParams
+(NSData *)createCodeParamsScriptWithObject:(NSObject *)val{
    NSMutableData *data = [NSMutableData new];
    if ([val isKindOfClass:NSData.class]) {
        [data pushData:(NSData *)val];
    }else if ([val isKindOfClass:ONTBool.class]){
        [data pushBool:((ONTBool *)val).value];
    }else if ([val isKindOfClass:ONTInteger.class]){
        [data pushNumber:@(((ONTInteger *)val).value)];
    }else if ([val isKindOfClass:ONTLong.class]){
        [data pushNumber:@(((ONTLong *)val).value)];
    }else if ([val isKindOfClass:ONTAddress.class]){
        [data pushData:((ONTAddress *)val).publicKeyHash160];
    }else if ([val isKindOfClass:NSString.class]){
        [data pushData:[((NSString *)val) dataUsingEncoding:NSUTF8StringEncoding]];
    }else if ([val isKindOfClass:ONTStruct.class]){
        ONTStruct *stuct = (ONTStruct *)val;
        for (NSObject *o in stuct.array) {
            [data addData:[ONTNativeBuildParams createCodeParamsScriptWithObject:o]];
            
            [data addOpcode:ONT_OPCODE_DUPFROMALTSTACK];
            [data addOpcode:ONT_OPCODE_SWAP];
            [data addOpcode:ONT_OPCODE_APPEND];
        }
    }
    return data;
}
+(NSData *)createCodeParamsScript:(NSArray<NSObject *> *)array{
    NSMutableData *data = [NSMutableData new];
    for (NSObject *val in array) {
        if ([val isKindOfClass:NSData.class]) {
            [data pushData:(NSData *)val];
        }else if ([val isKindOfClass:ONTBool.class]){
            [data pushBool:((ONTBool *)val).value];
        }else if ([val isKindOfClass:ONTInteger.class]){
            [data pushNumber:@(((ONTInteger *)val).value)];
        }else if ([val isKindOfClass:ONTLong.class]){
            [data pushNumber:@(((ONTLong *)val).value)];
        }else if ([val isKindOfClass:ONTAddress.class]){
            [data pushData:((ONTAddress *)val).publicKeyHash160];
        }else if ([val isKindOfClass:NSString.class]){
            [data pushData:[((NSString *)val) dataUsingEncoding:NSUTF8StringEncoding]];
        }else if ([val isKindOfClass:ONTStruct.class]){
            [data pushNumber:@(0)];
            [data addOpcode:ONT_OPCODE_NEWSTRUCT];
            [data addOpcode:ONT_OPCODE_TOALTSTACK];
            
            ONTStruct *s = (ONTStruct *)val;
            for (NSObject *o in s.array) {
                [data addData:[ONTNativeBuildParams createCodeParamsScriptWithObject:o]];
                
                [data addOpcode:ONT_OPCODE_DUPFROMALTSTACK];
                [data addOpcode:ONT_OPCODE_SWAP];
                [data addOpcode:ONT_OPCODE_APPEND];
            }
            [data addOpcode:ONT_OPCODE_FROMALTSTACK];
        }else if ([val isKindOfClass:ONTStructs.class]){
            [data pushNumber:@(0)];
            [data addOpcode:ONT_OPCODE_NEWSTRUCT];
            [data addOpcode:ONT_OPCODE_TOALTSTACK];
            
            ONTStructs *ss = (ONTStructs *)val;
            for (ONTStruct *s in ss.structs) {
                [data addData:[ONTNativeBuildParams createCodeParamsScriptWithObject:s]];
            }
            
            [data addOpcode:ONT_OPCODE_FROMALTSTACK];
            [data pushNumber:@(ss.structs.count)];
            [data pushPack];
        }else if ([val isKindOfClass:NSArray.class] || [val isKindOfClass:NSMutableArray.class]){
            NSArray<NSObject *> *a = (NSArray<NSObject *> *)val;
            [ONTNativeBuildParams createCodeParamsScript:a];
            [data pushNumber:@(a.count)];
            [data pushPack];
        }
        
    }
    
    return data;
}
@end
