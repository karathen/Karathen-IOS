//
//  ONTAttribute.m
//  ONTWallet
//
//  Created by Yuzhiyou on 2018/7/24.
//  Copyright © 2018年 Yuzhiyou. All rights reserved.
//

#import "ONTAttribute.h"
#import "NSMutableData+Extend.h"
#import "NSData+Extend.h"

@implementation ONTAttribute

/**
 * @brief Obtaining complete byte stream data
 */
- (void)toByte:(NSMutableData *)stream{
    [stream appendUInt8:_usage];
    [stream ont_appendVarData:_data];
}

@end
