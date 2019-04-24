//
//  CCCoin+CoreDataProperties.h
//  ccAsset
//
//  Created by SealWallet on 2018/11/26.
//  Copyright © 2018 raistone. All rights reserved.
//
//

#import "CCCoin+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface CCCoin (CoreDataProperties)

+ (NSFetchRequest<CCCoin *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *accountID;
@property (nonatomic) int16_t coinType;
@property (nonatomic) BOOL isHidden;
@property (nonatomic) BOOL isSelected;
@property (nonatomic) int16_t sortID;

@end

NS_ASSUME_NONNULL_END
