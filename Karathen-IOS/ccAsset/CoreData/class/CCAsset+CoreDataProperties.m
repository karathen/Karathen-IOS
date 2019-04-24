//
//  CCAsset+CoreDataProperties.m
//  ccAsset
//
//  Created by SealWallet on 2018/11/26.
//  Copyright © 2018 raistone. All rights reserved.
//
//

#import "CCAsset+CoreDataProperties.h"

@implementation CCAsset (CoreDataProperties)

+ (NSFetchRequest<CCAsset *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"CCAsset"];
}

@dynamic accountID;
@dynamic asset_id;
@dynamic balance;
@dynamic coinType;
@dynamic isDefault;
@dynamic isDelete;
@dynamic notDelete;
@dynamic price;
@dynamic priceUSD;
@dynamic tokenAddress;
@dynamic tokenDecimal;
@dynamic tokenIcon;
@dynamic tokenName;
@dynamic tokenSynbol;
@dynamic tokenType;
@dynamic walletAddress;

@end
