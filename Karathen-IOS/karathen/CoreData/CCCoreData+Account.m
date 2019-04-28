//
//  CCCoreData+Account.m
//  Karathen
//
//  Created by Karathen on 2018/11/20.
//  Copyright © 2018 raistone. All rights reserved.
//

#import "CCCoreData+Account.h"
#import "CCCoreData+Coin.h"
#import "CCCoreData+Wallet.h"
#import "CCCoreData+Asset.h"
#import "CCCoreData+TradeRecord.h"

@implementation CCCoreData (Account)

- (void)clearAccountDataCompletion:(saveCompletion)completion {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:CCAccountEntityName];
    
    if (@available(iOS 9.0, *)) {
        NSBatchDeleteRequest *deletRequest = [[NSBatchDeleteRequest alloc] initWithFetchRequest:request];
        [self.persistentStoreCoordinator executeRequest:deletRequest withContext:self.managedObjectContext error:nil];
    } else {
        NSArray *requestArray = [self.managedObjectContext executeFetchRequest:request error:nil];
        for (CCAccount *account in requestArray) {
            [self.managedObjectContext deleteObject:account];
        }
    }
    [self saveDataCompletion:completion];
}


#pragma mark - 所有用户
- (NSArray <CCAccount *> *)requestAllAccounts {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:CCAccountEntityName];
    NSSortDescriptor *idSort = [NSSortDescriptor sortDescriptorWithKey:@"sortID" ascending:YES];
    request.sortDescriptors = @[idSort];
    NSArray *requestArray = [self.managedObjectContext executeFetchRequest:request error:nil];
    return requestArray;
}

#pragma mark - 保存账户
- (CCAccount *)saveAccountWithAccountId:(NSString *)accountID
                                 sortID:(NSInteger)sortID
                            accountName:(NSString *)accountName
                             walletType:(CCWalletType)walletType
                             importType:(CCImportType)importType
                               coinType:(CCCoinType)coinType
                           passWordInfo:(NSString *)passWordInfo
                             completion:(saveCompletion)completion {
    CCAccount *account = [NSEntityDescription insertNewObjectForEntityForName:CCAccountEntityName inManagedObjectContext:self.managedObjectContext];
    account.accountID = accountID;
    account.sortID = sortID;
    account.walletType = walletType;
    account.importType = importType;
    account.coinType = coinType;
    account.accountName = accountName;
    account.passwordInfo = passWordInfo?:@"";
    [self saveDataCompletion:completion];
    return account;
}

#pragma mark - 删除账户
- (void)deleteAccountWithAccountId:(NSString *)accountID completion:(saveCompletion)completion {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:CCAccountEntityName];
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"accountID CONTAINS[cd] %@", accountID];
    request.predicate = pre;
    NSArray *requestArray = [self.managedObjectContext executeFetchRequest:request error:nil];
    for (CCAccount *account in requestArray) {
        [self.managedObjectContext deleteObject:account];
    }
    
    [self deleteCoinWithAccountId:accountID];
    [self deleteAllWalletWithAccountId:accountID];
    [self deleteAllAssetWithAccountId:accountID];
    [self deleteAllRecordWithAccountID:accountID];
    
    [self saveDataCompletion:completion];
}

@end
