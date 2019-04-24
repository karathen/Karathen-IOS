//
//  CCAccount+CoreDataProperties.h
//  ccAsset
//
//  Created by SealWallet on 2018/11/26.
//  Copyright © 2018 raistone. All rights reserved.
//
//

#import "CCAccount+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface CCAccount (CoreDataProperties)

+ (NSFetchRequest<CCAccount *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *accountID;
@property (nullable, nonatomic, copy) NSString *accountName;
@property (nonatomic) int16_t walletType;
@property (nonatomic) int16_t importType;
@property (nonatomic) int16_t coinType;
@property (nonatomic) BOOL isBackup;
@property (nonatomic) BOOL isSelected;
@property (nullable, nonatomic, copy) NSString *passwordInfo;
@property (nonatomic) int16_t sortID;

@end

NS_ASSUME_NONNULL_END
