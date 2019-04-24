//
//  CCAsset+CoreDataProperties.h
//  ccAsset
//
//  Created by SealWallet on 2018/11/26.
//  Copyright © 2018 raistone. All rights reserved.
//
//

#import "CCAsset+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface CCAsset (CoreDataProperties)

+ (NSFetchRequest<CCAsset *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *accountID;
@property (nonatomic) int16_t asset_id;
@property (nullable, nonatomic, copy) NSString *balance;
@property (nonatomic) int16_t coinType;
@property (nonatomic) BOOL isDefault;
@property (nonatomic) BOOL isDelete;
@property (nonatomic) BOOL notDelete;
@property (nullable, nonatomic, copy) NSString *price;
@property (nullable, nonatomic, copy) NSString *priceUSD;
@property (nullable, nonatomic, copy) NSString *tokenAddress;
@property (nullable, nonatomic, copy) NSString *tokenDecimal;
@property (nullable, nonatomic, copy) NSString *tokenIcon;
@property (nullable, nonatomic, copy) NSString *tokenName;
@property (nullable, nonatomic, copy) NSString *tokenSynbol;
@property (nullable, nonatomic, copy) NSString *tokenType;
@property (nullable, nonatomic, copy) NSString *walletAddress;

@end

NS_ASSUME_NONNULL_END
