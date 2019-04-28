//
//  CCTradeRecord+CoreDataProperties.m
//  Karathen
//
//  Created by Karathen on 2018/11/26.
//  Copyright © 2018 raistone. All rights reserved.
//
//

#import "CCTradeRecord+CoreDataProperties.h"

@implementation CCTradeRecord (CoreDataProperties)

+ (NSFetchRequest<CCTradeRecord *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"CCTradeRecord"];
}

@dynamic accountID;
@dynamic addressFrom;
@dynamic addressTo;
@dynamic blockHeight;
@dynamic blockTime;
@dynamic coinType;
@dynamic data;
@dynamic gas;
@dynamic gasPrice;
@dynamic remark;
@dynamic tokenAddress;
@dynamic txId;
@dynamic txReceiptStatus;
@dynamic value;
@dynamic walletAddress;

@end
