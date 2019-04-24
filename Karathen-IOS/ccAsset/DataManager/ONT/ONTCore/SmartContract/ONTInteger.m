//
//  ONTInteger.m
//  ONTWallet
//
//  Created by Yuzhiyou on 2018/7/25.
//  Copyright © 2018年 Yuzhiyou. All rights reserved.
//

#import "ONTInteger.h"

@implementation ONTInteger
/**
 * @brief Initialization method
 */
- (instancetype)initWithInteger:(NSInteger)i{
    self = [super init];
    if (self) {
        _value = i;
    }
    return self;
}
@end
