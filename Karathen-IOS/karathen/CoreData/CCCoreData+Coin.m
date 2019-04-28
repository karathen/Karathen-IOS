//
//  CCCoreData+Coin.m
//  Karathen
//
//  Created by Karathen on 2018/11/20.
//  Copyright © 2018 raistone. All rights reserved.
//

#import "CCCoreData+Coin.h"

@implementation CCCoreData (Coin)

- (void)clearCoinDataCompletion:(saveCompletion)completion {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:CCCoinEntityName];
    if (@available(iOS 9.0, *)) {
        NSBatchDeleteRequest *deletRequest = [[NSBatchDeleteRequest alloc] initWithFetchRequest:request];
        [self.persistentStoreCoordinator executeRequest:deletRequest withContext:self.managedObjectContext error:nil];
    } else {
        NSArray *requestArray = [self.managedObjectContext executeFetchRequest:request error:nil];
        for (CCCoin *coin in requestArray) {
            [self.managedObjectContext deleteObject:coin];
        }
    }    
    [self saveDataCompletion:completion];
}

#pragma mark - 查询账户下支持的链
- (NSArray <CCCoin *> *)requestCoinsWithAccountID:(NSString *)accountId {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:CCCoinEntityName];
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"accountID = %@",accountId];
    request.predicate = pre;
    NSSortDescriptor *idSort = [NSSortDescriptor sortDescriptorWithKey:@"sortID" ascending:YES];
    request.sortDescriptors = @[idSort];
    NSArray *requestArray = [self.managedObjectContext executeFetchRequest:request error:nil];
    return requestArray;
}


#pragma mark - 批量保存链
- (NSArray <CCCoin *> *)saveCoinsWithCoins:(NSArray *)coins accountID:(NSString *)accointId completion:(saveCompletion)completion {
    NSMutableArray *needAddCoins = [coins mutableCopy];
    //查询到现在所有的链
    NSArray *allCoins = [self requestCoinsWithAccountID:accointId];
    for (CCCoin *coin in allCoins) {
        if ([coins containsObject:@(coin.coinType)]) {
            [needAddCoins removeObject:@(coin.coinType)];
        }
    }
    
    NSInteger sortId = allCoins.count;
    //
    for (NSInteger i = 0; i < needAddCoins.count; i ++) {
        CCCoinType coinType = [needAddCoins[i] integerValue];
        CCCoin *coin = [NSEntityDescription insertNewObjectForEntityForName:CCCoinEntityName inManagedObjectContext:self.managedObjectContext];
        coin.accountID = accointId;
        coin.sortID = sortId + i;
        coin.isHidden = NO;
        coin.coinType = coinType;
    }
    [self saveDataCompletion:completion];
    
    return [self requestCoinsWithAccountID:accointId];
}

#pragma mark - 删除链/未保存
- (void)deleteCoinWithAccountId:(NSString *)accountID {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:CCCoinEntityName];
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"accountID CONTAINS[cd] %@", accountID];
    request.predicate = pre;
    NSArray *requestArray = [self.managedObjectContext executeFetchRequest:request error:nil];
    for (CCCoin *coin in requestArray) {
        [self.managedObjectContext deleteObject:coin];
    }
    
}


@end
