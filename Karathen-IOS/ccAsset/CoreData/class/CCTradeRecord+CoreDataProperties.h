//
//  CCTradeRecord+CoreDataProperties.h
//  ccAsset
//
//  Created by SealWallet on 2018/11/26.
//  Copyright © 2018 raistone. All rights reserved.
//
//

#import "CCTradeRecord+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface CCTradeRecord (CoreDataProperties)

+ (NSFetchRequest<CCTradeRecord *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *accountID;
@property (nullable, nonatomic, copy) NSString *addressFrom;
@property (nullable, nonatomic, copy) NSString *addressTo;
@property (nullable, nonatomic, copy) NSString *blockHeight;
@property (nonatomic) double blockTime;
@property (nonatomic) int16_t coinType;
@property (nullable, nonatomic, copy) NSString *data;
@property (nullable, nonatomic, copy) NSString *gas;
@property (nullable, nonatomic, copy) NSString *gasPrice;
@property (nullable, nonatomic, copy) NSString *remark;
@property (nullable, nonatomic, copy) NSString *tokenAddress;
@property (nullable, nonatomic, copy) NSString *txId;
@property (nonatomic) int16_t txReceiptStatus;
@property (nullable, nonatomic, copy) NSString *value;
@property (nullable, nonatomic, copy) NSString *walletAddress;

@end

NS_ASSUME_NONNULL_END
