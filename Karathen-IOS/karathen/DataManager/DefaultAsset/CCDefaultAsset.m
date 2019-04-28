//
//  CCDefaultAsset.m
//  Karathen
//
//  Created by Karathen on 2018/8/29.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCDefaultAsset.h"
#import "CCDefaultAsset+ETH.h"
#import "CCDefaultAsset+NEO.h"
#import "CCDefaultAsset+ONT.h"

@implementation CCDefaultAsset

+ (NSDictionary *)simpleAssetWithCoinType:(CCCoinType)coinType {
    switch (coinType) {
        case CCCoinTypeETH:
        {
            return [self ethSimpleAsset];
        }
            break;
        case CCCoinTypeNEO:
        {
            return [self neoSimpleAsset];
        }
            break;
        case CCCoinTypeONT:
        {
            return [self ontSimpleAsset];
        }
            break;
        default:
            break;
    }
    return nil;
}

+ (void)addAsset:(NSDictionary *)asset defaultAssets:(NSMutableDictionary *)defaultAssets {
    if (asset) {
        NSString *tokenAddress = asset[@"tokenAddress"];
        [defaultAssets setValue:asset forKey:[tokenAddress lowercaseString]];
    }
}


@end
