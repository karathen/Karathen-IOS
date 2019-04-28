//
//  CCCoin+CoreDataProperties.m
//  Karathen
//
//  Created by Karathen on 2018/11/26.
//  Copyright © 2018 raistone. All rights reserved.
//
//

#import "CCCoin+CoreDataProperties.h"

@implementation CCCoin (CoreDataProperties)

+ (NSFetchRequest<CCCoin *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"CCCoin"];
}

@dynamic accountID;
@dynamic coinType;
@dynamic isHidden;
@dynamic isSelected;
@dynamic sortID;

@end
