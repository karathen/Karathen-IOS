//
//  ONTNativeBuildParams.h
//  ONTWallet
//
//  Created by Yuzhiyou on 2018/7/25.
//  Copyright © 2018年 Yuzhiyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ONTBool.h"
#import "ONTInteger.h"
#import "ONTLong.h"
#import "ONTAddress.h"
#import "ONTStruct.h"

@interface ONTNativeBuildParams : NSObject
+(NSData *)createCodeParamsScriptWithObject:(NSObject *)val;
+(NSData *)createCodeParamsScript:(NSArray<NSObject *> *)array;
@end
