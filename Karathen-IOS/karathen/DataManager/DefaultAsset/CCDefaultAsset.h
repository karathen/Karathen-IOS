//
//  CCDefaultAsset.h
//  Karathen
//
//  Created by Karathen on 2018/8/29.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import <Foundation/Foundation.h>

//ETH
#define CCAseet_ETH_ERC20 @"ERC-20"
#define CCAseet_ETH_ERC721 @"ERC-721"
//NEO
#define CCAseet_NEO_NEO @"NEO"
#define CCAseet_NEO_GAS @"GAS"
#define CCAseet_NEO_Token @"Token"
#define CCAseet_NEO_Share @"Share"
#define CCAseet_NEO_Nep_5 @"NEP-5"
//ONT
#define CCAseet_ONT_ONT @"ONT"
#define CCAseet_ONT_ONG @"ONG"


@interface CCDefaultAsset : NSObject

+ (NSDictionary *)simpleAssetWithCoinType:(CCCoinType)coinType;

+ (void)addAsset:(NSDictionary *)asset defaultAssets:(NSMutableDictionary *)defaultAssets;

@end
