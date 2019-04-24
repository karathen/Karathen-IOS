//
//  CCCoreData.h
//  ccAsset
//
//  Created by SealWallet on 2018/11/20.
//  Copyright © 2018 raistone. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const CCAccountEntityName = @"CCAccount";
static NSString *const CCCoinEntityName = @"CCCoin";
static NSString *const CCWalletEntityName = @"CCWallet";
static NSString *const CCAssetEntityName = @"CCAsset";
static NSString *const CCTradeRecordEntityName = @"CCTradeRecord";

typedef void(^saveCompletion)(BOOL suc, NSError *error);

@interface CCCoreData : NSObject

+ (CCCoreData *)coreData;

///coreData 数据查询使用
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

//保存
- (void)saveDataCompletion:(saveCompletion)completion;

@end

