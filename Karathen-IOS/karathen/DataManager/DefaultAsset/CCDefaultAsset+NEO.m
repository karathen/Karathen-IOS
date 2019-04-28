//
//  CCDefaultAsset+NEO.m
//  Karathen
//
//  Created by Karathen on 2018/8/29.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCDefaultAsset+NEO.h"

@implementation CCDefaultAsset (NEO)

+ (NSMutableDictionary *)neoSimpleAsset  {
    NSMutableDictionary *simpleAssets = [NSMutableDictionary dictionary];
    //NEO
    NSDictionary *neoAsset = [CCDefaultAsset neoAsset];
    [CCDefaultAsset addAsset:neoAsset defaultAssets:simpleAssets];
    
    //GAS
    NSDictionary *gasAsset = [CCDefaultAsset gasAsset];
    [CCDefaultAsset addAsset:gasAsset defaultAssets:simpleAssets];
    
    return simpleAssets;
}

+ (NSDictionary *)neoAsset {
    return @{
             @"asset_id":@(1),
             @"isDefault":@(YES),
             @"notDelete":@(YES),
             @"tokenAddress":@"0xc56f33fc6ecfcd0c225c4ab356fee59390af8560be0e930faebe74a6daff7c9b",
             @"tokenDecimal":@"0",
             @"tokenIcon":@"cc_asset_neo",
             @"tokenName":@"NEO",
             @"tokenSynbol":@"NEO",
             @"tokenType":CCAseet_NEO_NEO,
             @"coinType":@(CCCoinTypeNEO)
             };
}

+ (NSDictionary *)gasAsset {
    return @{
             @"asset_id":@(2),
             @"isDefault":@(YES),
             @"notDelete":@(YES),
             @"tokenAddress":@"0x602c79718b16e442de58778e148d0b1084e3b2dffd5de6b7b16cee7969282de7",
             @"tokenDecimal":@"8",
             @"tokenIcon":@"cc_asset_neo",
             @"tokenName":@"GAS",
             @"tokenSynbol":@"GAS",
             @"tokenType":CCAseet_NEO_GAS,
             @"coinType":@(CCCoinTypeNEO)
             };
}

@end
