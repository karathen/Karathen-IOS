//
//  CCWallet+CoreDataProperties.h
//  Karathen
//
//  Created by Karathen on 2018/11/26.
//  Copyright © 2018 raistone. All rights reserved.
//
//

#import "CCWallet+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface CCWallet (CoreDataProperties)

+ (NSFetchRequest<CCWallet *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *accountID;
@property (nullable, nonatomic, copy) NSString *address;
@property (nullable, nonatomic, copy) NSString *balance;
@property (nullable, nonatomic, copy) NSString *filterType;
@property (nonatomic) int16_t iconId;
@property (nonatomic) BOOL isHideNoBalance;
@property (nonatomic) BOOL isSelected;
@property (nonatomic) int16_t slot;
@property (nonatomic) int16_t coinType;
@property (nullable, nonatomic, copy) NSString *walletName;

@end

NS_ASSUME_NONNULL_END
