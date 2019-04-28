//
//  CCAccount+CoreDataProperties.m
//  Karathen
//
//  Created by Karathen on 2018/11/26.
//  Copyright © 2018 raistone. All rights reserved.
//
//

#import "CCAccount+CoreDataProperties.h"

@implementation CCAccount (CoreDataProperties)

+ (NSFetchRequest<CCAccount *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"CCAccount"];
}

@dynamic accountID;
@dynamic accountName;
@dynamic walletType;
@dynamic importType;
@dynamic coinType;
@dynamic isBackup;
@dynamic isSelected;
@dynamic passwordInfo;
@dynamic sortID;

@end
