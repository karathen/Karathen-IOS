//
//  CCCoreData+TradeRecord.m
//  Karathen
//
//  Created by Karathen on 2018/11/20.
//  Copyright © 2018 raistone. All rights reserved.
//

#import "CCCoreData+TradeRecord.h"
#import "CCTradeRecordModel.h"

@implementation CCCoreData (TradeRecord)

- (void)clearTradeRecordDataCompletion:(saveCompletion)completion {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:CCTradeRecordEntityName];
    if (@available(iOS 9.0, *)) {
        NSBatchDeleteRequest *deletRequest = [[NSBatchDeleteRequest alloc] initWithFetchRequest:request];
        [self.persistentStoreCoordinator executeRequest:deletRequest withContext:self.managedObjectContext error:nil];
    } else {
        NSArray *requestArray = [self.managedObjectContext executeFetchRequest:request error:nil];
        for (CCTradeRecord *record in requestArray) {
            [self.managedObjectContext deleteObject:record];
        }
    }
    [self saveDataCompletion:completion];
}

#pragma mark - 查询记录
- (NSArray *)requsetTradeRecordsWithWalletAddress:(NSString *)walletAddress tokenAddress:(NSString *)tokenAddress coinType:(CCCoinType)coinType accountID:(NSString *)accountID {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:CCTradeRecordEntityName];
    //条件
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"walletAddress CONTAINS[cd] %@ AND tokenAddress CONTAINS[cd] %@ AND coinType = %@ AND accountID CONTAINS[cd] %@", walletAddress,tokenAddress,@(coinType),accountID];
    request.predicate = pre;
    NSSortDescriptor *timeSort = [NSSortDescriptor sortDescriptorWithKey:@"blockTime" ascending:NO];
    request.sortDescriptors = @[timeSort];
    
    NSArray *requestArray = [self.managedObjectContext executeFetchRequest:request error:nil];
    return requestArray;
}


#pragma mark - 查询需要请求块高的交易记录
- (NSArray *)requestNeedRequestBlockRecords:(CCCoinType)coinType {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:CCTradeRecordEntityName];
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"coinType = %@ AND blockHeight = NULL AND txReceiptStatus = 0",@(coinType)];
    request.predicate = pre;
    NSArray *requestArray = [self.managedObjectContext executeFetchRequest:request error:nil];
    return requestArray;
}

#pragma mark - 查询需要刷新状态的交易记录
- (NSArray *)requestNeedRequestStatusRecords:(CCCoinType)coinType {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:CCTradeRecordEntityName];
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"coinType = %@ AND blockHeight != NULL AND txReceiptStatus = 0",@(coinType)];
    request.predicate = pre;
    NSArray *requestArray = [self.managedObjectContext executeFetchRequest:request error:nil];
    return requestArray;
}


#pragma mark - 更新记录
- (void)updateTradeWithTxid:(NSString *)txId
                  timestamp:(NSTimeInterval)timestamp
                blockHeight:(NSString *)blockHeight
                   coinType:(CCCoinType)coinType
                 completion:(saveCompletion)completion {
    if (!txId) {
        return;
    }
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:CCTradeRecordEntityName];
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"txId CONTAINS[cd] %@ AND coinType = %@ AND accountID CONTAINS[cd] %@",txId,@(coinType)];
    request.predicate = pre;
    NSArray *requestArray = [self.managedObjectContext executeFetchRequest:request error:nil];
    
    CCTradeRecord *tradeRecord;
    for (NSInteger i = 0; i < requestArray.count; i ++) {
        CCTradeRecord *item = requestArray[i];
        tradeRecord = item;
        tradeRecord.blockTime = timestamp;
        tradeRecord.blockHeight = [NSString stringWithFormat:@"%@",blockHeight];
    }
    
    [CCNotificationCenter postAssetTradeUpdateWithWalletAddress:tradeRecord.walletAddress tokenAddress:tradeRecord.tokenAddress];

    [self saveDataCompletion:completion];
}

#pragma mark - 删除所有记录
- (void)deleteAllRecordWithAccountID:(NSString *)accountID {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:CCTradeRecordEntityName];
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"accountID CONTAINS[cd] %@",accountID];
    request.predicate = pre;
    NSArray *requestArray = [self.managedObjectContext executeFetchRequest:request error:nil];
    for (CCTradeRecord *record in requestArray) {
        [self.managedObjectContext deleteObject:record];
    }
}

#pragma mark - 保存记录
- (CCTradeRecord *)saveTradeRecord:(CCTradeRecordModel *)tradeRecordModel
                     walletAddress:(NSString *)walletAddress
                      tokenAddress:(NSString *)tokenAddress
                         accountID:(NSString *)accountID
                        completion:(saveCompletion)completion {
    if (!tradeRecordModel) {
        return nil;
    }
    //请求
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:CCTradeRecordEntityName];
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"walletAddress CONTAINS[cd] %@ AND tokenAddress CONTAINS[cd] %@ AND txId CONTAINS[cd] %@ AND coinType = %@ AND accountID CONTAINS[cd] %@", walletAddress,tokenAddress,tradeRecordModel.txId,@(tradeRecordModel.coinType),accountID];
    request.predicate = pre;
    NSArray *requestArray = [self.managedObjectContext executeFetchRequest:request error:nil];
    for (NSInteger i = 0; i < requestArray.count; i ++) {
        CCTradeRecord *tradeRecord = requestArray[i];
        if (i == 0) {
            [self changeTradeRecord:tradeRecord withModel:tradeRecordModel walletAddress:walletAddress tokenAddress:tokenAddress accountID:accountID];
        } else {
            //重复的删除
            [self.managedObjectContext deleteObject:tradeRecord];
        }
    }
    if (requestArray.count) {
        return nil;
    }
    
    CCTradeRecord *tradeRecord = [NSEntityDescription insertNewObjectForEntityForName:CCTradeRecordEntityName inManagedObjectContext:self.managedObjectContext];
    [self changeTradeRecord:tradeRecord withModel:tradeRecordModel walletAddress:walletAddress tokenAddress:tokenAddress accountID:accountID];
    [self saveDataCompletion:completion];
    
    //添加
    [CCNotificationCenter postAssetTradeUpdateWithWalletAddress:walletAddress tokenAddress:tokenAddress];
    
    return tradeRecord;
}

- (void)changeTradeRecord:(CCTradeRecord *)tradeRecord
                withModel:(CCTradeRecordModel *)model
            walletAddress:(NSString *)walletAddress
             tokenAddress:(NSString *)tokenAddress
                accountID:(NSString *)accountID {
    tradeRecord.addressFrom = model.addressFrom;
    tradeRecord.addressTo = model.addressTo;
    tradeRecord.blockHeight = model.blockHeight;
    tradeRecord.blockTime = model.blockTime;
    tradeRecord.gas = model.gas;
    tradeRecord.gasPrice = model.gasPrice;
    tradeRecord.tokenAddress = tokenAddress;
    tradeRecord.txId = model.txId;
    tradeRecord.value = model.value;
    tradeRecord.data = model.data;
    tradeRecord.remark = model.remark;
    tradeRecord.walletAddress = walletAddress;
    tradeRecord.coinType = model.coinType;
    tradeRecord.accountID = accountID;
}

#pragma mark - 删除记录
- (void)deleteTradeRecordWithTxId:(NSString *)txId
                    walletAddress:(NSString *)walletAddress
                     tokenAddress:(NSString *)tokenAddress
                         coinType:(CCCoinType)coinType
                        accountID:(NSString *)accountID
                       completion:(saveCompletion)completion {
    if (!txId) {
        return;
    }
    //请求
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:CCTradeRecordEntityName];
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"walletAddress = %@ AND tokenAddress = %@ AND txId = %@ AND coinType = %@ AND accountID CONTAINS[cd] %@", walletAddress,tokenAddress,txId,@(coinType),accountID];
    request.predicate = pre;
    NSArray *requestArray = [self.managedObjectContext executeFetchRequest:request error:nil];
    for (CCTradeRecord *tradeRecord in requestArray) {
        [self.managedObjectContext deleteObject:tradeRecord];
    }
    [self saveDataCompletion:completion];
}

#pragma mark - 批量删除
- (void)deleteTradeRecordWithTxIds:(NSArray *)txIds
                     walletAddress:(NSString *)walletAddress
                      tokenAddress:(NSString *)tokenAddress
                          coinType:(CCCoinType)coinType
                         accountID:(NSString *)accountID
                        completion:(saveCompletion)completion {
    if (txIds.count == 0) {
        return;
    }
    //请求
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:CCTradeRecordEntityName];
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"walletAddress CONTAINS[cd] %@ AND tokenAddress CONTAINS[cd] %@ AND coinType = %@ AND accountID CONTAINS[cd] %@",walletAddress,tokenAddress,@(coinType),accountID];
    request.predicate = pre;
    NSArray *requestArray = [self.managedObjectContext executeFetchRequest:request error:nil];
    for (CCTradeRecord *tradeRecord in requestArray) {
        if ([txIds containsObject:tradeRecord.txId]) {
            [self.managedObjectContext deleteObject:tradeRecord];
        }
    }
    [self saveDataCompletion:completion];
}

- (void)deleteTradeRecordWalletAddress:(NSString *)walletAddress
                          tokenAddress:(NSString *)tokenAddress
                              coinType:(CCCoinType)coinType
                             accountID:(NSString *)accountID
                            completion:(saveCompletion)completion {
    //请求
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:CCTradeRecordEntityName];
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"walletAddress CONTAINS[cd] %@ AND tokenAddress CONTAINS[cd] %@ AND coinType = %@ AND accountID CONTAINS[cd] %@", walletAddress,tokenAddress,@(coinType),accountID];
    request.predicate = pre;
    NSArray *requestArray = [self.managedObjectContext executeFetchRequest:request error:nil];
    for (CCTradeRecord *tradeRecord in requestArray) {
        [self.managedObjectContext deleteObject:tradeRecord];
    }
    [self saveDataCompletion:completion];
}

- (void)deleteTradeRecordWalletAddress:(NSString *)walletAddress
                              coinType:(CCCoinType)coinType
                             accountID:(NSString *)accountID
                            completion:(saveCompletion)completion {
    //请求
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:CCTradeRecordEntityName];
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"walletAddress CONTAINS[cd] %@ AND coinType = %@ AND accountID CONTAINS[cd] %@", walletAddress,@(coinType),accountID];
    request.predicate = pre;
    NSArray *requestArray = [self.managedObjectContext executeFetchRequest:request error:nil];
    for (CCTradeRecord *tradeRecord in requestArray) {
        [self.managedObjectContext deleteObject:tradeRecord];
    }
    [self saveDataCompletion:completion];
}


@end
