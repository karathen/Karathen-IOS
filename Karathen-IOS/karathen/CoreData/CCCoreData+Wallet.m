//
//  CCCoreData+Wallet.m
//  Karathen
//
//  Created by Karathen on 2018/11/20.
//  Copyright © 2018 raistone. All rights reserved.
//

#import "CCCoreData+Wallet.h"

@implementation CCCoreData (Wallet)

- (void)clearWalletDataCompletion:(saveCompletion)completion {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:CCWalletEntityName];
    if (@available(iOS 9.0, *)) {
        NSBatchDeleteRequest *deletRequest = [[NSBatchDeleteRequest alloc] initWithFetchRequest:request];
        [self.persistentStoreCoordinator executeRequest:deletRequest withContext:self.managedObjectContext error:nil];
    } else {
        NSArray *requestArray = [self.managedObjectContext executeFetchRequest:request error:nil];
        for (CCWallet *wallet in requestArray) {
            [self.managedObjectContext deleteObject:wallet];
        }
    }
    [self saveDataCompletion:completion];
}

#pragma mark - 查询所有的钱包
- (NSArray<CCWallet *> *)requestWalletsWithCoinType:(CCCoinType)coinType accountID:(NSString *)accountID {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:CCWalletEntityName];
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"coinType = %@ AND accountID CONTAINS[cd] %@",@(coinType),accountID];
    request.predicate = pre;
    NSSortDescriptor *idSort = [NSSortDescriptor sortDescriptorWithKey:@"slot" ascending:YES];
    request.sortDescriptors = @[idSort];
    NSArray *requestArray = [self.managedObjectContext executeFetchRequest:request error:nil];
    return requestArray;
}

#pragma mark - 查找默认地址
- (CCWallet *)requestActiveWalletWithCoinType:(CCCoinType)coinType accountID:(NSString *)accountID {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:CCWalletEntityName];
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"coinType = %@ AND isSelected = YES AND accountID CONTAINS[cd] %@",@(coinType),accountID];
    request.predicate = pre;
    NSArray *requestArray = [self.managedObjectContext executeFetchRequest:request error:nil];
    return requestArray.firstObject;
}

#pragma mark - 删除所有钱包/未保存
- (void)deleteAllWalletWithAccountId:(NSString *)accountID {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:CCWalletEntityName];
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"accountID CONTAINS[cd] %@", accountID];
    request.predicate = pre;
    NSArray *requestArray = [self.managedObjectContext executeFetchRequest:request error:nil];
    for (CCWallet *wallet in requestArray) {
        [self.managedObjectContext deleteObject:wallet];
    }
}


#pragma mark - 由地址查询钱包
- (CCWallet *)requestWalletWithAddress:(NSString *)address coinType:(CCCoinType)coinType accountID:(NSString *)accountID {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:CCWalletEntityName];
    //条件
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"address CONTAINS[cd] %@ AND coinType = %@ AND accountID CONTAINS[cd] %@", address,@(coinType),accountID];
    request.predicate = pre;
    NSArray *requestArray = [self.managedObjectContext executeFetchRequest:request error:nil];
    if (requestArray.count == 0) {
        return nil;
    } else {
        if (requestArray.count > 1) {
            for (NSInteger i = 1; i < requestArray.count; i++) {
                [self.managedObjectContext deleteObject:requestArray[i]];
            }
            [self saveDataCompletion:nil];
        }
        return requestArray.firstObject;
    }
}

#pragma mark - 存储钱包
- (CCWallet *)saveWalletWithWallet:(NSDictionary *)wallet walletId:(NSInteger)walletId accountID:(NSString *)accountID completion:(saveCompletion)completion {
    CCCoinType coinType = [wallet[@"coinType"] integerValue];
    CCWallet *requestWallet = [self requestWalletWithAddress:wallet[@"address"] coinType:coinType accountID:accountID];
    if (requestWallet) {
        return requestWallet;
    }
    //创建对象
    CCWallet *saveWallet = [NSEntityDescription insertNewObjectForEntityForName:CCWalletEntityName inManagedObjectContext:self.managedObjectContext];
    [self bindWallet:saveWallet walletDic:wallet walletId:walletId accountID:accountID];
    //保存
    [self saveDataCompletion:completion];
    return saveWallet;
}

#pragma mark - bindWallet
- (void)bindWallet:(CCWallet *)wallet walletDic:(NSDictionary *)walletDic walletId:(NSInteger)walletId accountID:(NSString *)accountID {
    wallet.address = walletDic[@"address"];
    wallet.balance = walletDic[@"balance"];
    wallet.isSelected = [walletDic[@"isSelected"] boolValue];
    wallet.slot = [walletDic[@"slot"] integerValue];
    wallet.coinType = [walletDic[@"coinType"] integerValue];
    wallet.iconId = [walletDic[@"iconId"] integerValue];
    wallet.accountID = accountID;
    wallet.walletName = walletDic[@"walletName"];
}

#pragma mark - 删除钱包
- (void)deleteWalletWithAddress:(NSString *)address coinType:(CCCoinType)coinType accountID:(NSString *)accountID completion:(saveCompletion)completion {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:CCWalletEntityName];
    //条件
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"address CONTAINS[cd] %@ AND coinType = %@ AND accountID CONTAINS[cd] %@", address,@(coinType),accountID];
    request.predicate = pre;
    NSArray *requestArray = [self.managedObjectContext executeFetchRequest:request error:nil];
    for (CCWallet *wallet in requestArray) {
        [self.managedObjectContext deleteObject:wallet];
    }
    //保存
    [self saveDataCompletion:completion];
}

@end
