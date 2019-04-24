//
//  CCDefaultAsset+ETH.m
//  ccAsset
//
//  Created by SealWallet on 2018/8/29.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCDefaultAsset+ETH.h"

@implementation CCDefaultAsset (ETH)

+ (NSMutableDictionary *)ethSimpleAsset {
    NSMutableDictionary *simpleAssets = [NSMutableDictionary dictionary];
    //ETH
    NSDictionary *ethAsset = [CCDefaultAsset ethAsset];
    [CCDefaultAsset addAsset:ethAsset defaultAssets:simpleAssets];
    
    return simpleAssets;
}


+ (NSDictionary *)ethAsset {
    return @{
             @"asset_id":@(1),
             @"isDefault":@(YES),
             @"notDelete":@(YES),
             @"tokenAddress":@"0x0000000000000000000000000000000000000000",
             @"tokenDecimal":@"18",
             @"tokenIcon":@"cc_asset_eth",
             @"tokenName":@"Ethereum",
             @"tokenSynbol":@"ETH",
             @"coinType":@(CCCoinTypeETH)
             };
}

@end
