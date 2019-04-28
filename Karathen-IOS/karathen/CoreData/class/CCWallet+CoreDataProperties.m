//
//  CCWallet+CoreDataProperties.m
//  Karathen
//
//  Created by Karathen on 2018/11/26.
//  Copyright © 2018 raistone. All rights reserved.
//
//

#import "CCWallet+CoreDataProperties.h"

@implementation CCWallet (CoreDataProperties)

+ (NSFetchRequest<CCWallet *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"CCWallet"];
}

@dynamic accountID;
@dynamic address;
@dynamic balance;
@dynamic filterType;
@dynamic iconId;
@dynamic isHideNoBalance;
@dynamic isSelected;
@dynamic slot;
@dynamic coinType;
@dynamic walletName;

@end
