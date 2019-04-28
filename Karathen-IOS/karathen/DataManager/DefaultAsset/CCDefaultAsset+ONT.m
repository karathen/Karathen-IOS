//
//  CCDefaultAsset+ONT.m
//  Karathen
//
//  Created by Karathen on 2018/9/19.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCDefaultAsset+ONT.h"

@implementation CCDefaultAsset (ONT)

+ (NSMutableDictionary *)ontSimpleAsset {
    NSMutableDictionary *simpleAssets = [NSMutableDictionary dictionary];
    //ONT
    NSDictionary *ontAsset = [CCDefaultAsset ontAsset];
    [CCDefaultAsset addAsset:ontAsset defaultAssets:simpleAssets];
    
    //ONG
    NSDictionary *ongAsset = [CCDefaultAsset ongAsset];
    [CCDefaultAsset addAsset:ongAsset defaultAssets:simpleAssets];
    
    return simpleAssets;
}

+ (NSDictionary *)ontAsset {
    return @{
             @"asset_id":@(1),
             @"isDefault":@(YES),
             @"notDelete":@(YES),
             @"tokenAddress":@"0000000000000000000000000000000000000001",
             @"tokenDecimal":@"0",
             @"tokenIcon":@"cc_asset_ont",
             @"tokenName":@"Ontology",
             @"tokenSynbol":@"ONT",
             @"tokenType":CCAseet_ONT_ONT,
             @"coinType":@(CCCoinTypeONT)
             };
}

+ (NSDictionary *)ongAsset {
    return @{
             @"asset_id":@(2),
             @"isDefault":@(YES),
             @"notDelete":@(YES),
             @"tokenAddress":@"0000000000000000000000000000000000000002",
             @"tokenDecimal":@"9",
             @"tokenIcon":@"cc_asset_ont",
             @"tokenName":@"Ontology Gas",
             @"tokenSynbol":@"ONG",
             @"tokenType":CCAseet_ONT_ONG,
             @"coinType":@(CCCoinTypeONT)
             };
}

@end
