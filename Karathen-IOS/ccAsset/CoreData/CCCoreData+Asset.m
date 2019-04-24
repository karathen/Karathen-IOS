//
//  CCCoreData+Asset.m
//  ccAsset
//
//  Created by SealWallet on 2018/11/20.
//  Copyright © 2018 raistone. All rights reserved.
//

#import "CCCoreData+Asset.h"
#import "CCCoreData+TradeRecord.h"

@implementation CCCoreData (Asset)

- (void)clearAssetDataCompletion:(saveCompletion)completion {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:CCAssetEntityName];
    if (@available(iOS 9.0, *)) {
        NSBatchDeleteRequest *deletRequest = [[NSBatchDeleteRequest alloc] initWithFetchRequest:request];
        [self.persistentStoreCoordinator executeRequest:deletRequest withContext:self.managedObjectContext error:nil];
    } else {
        NSArray *requestArray = [self.managedObjectContext executeFetchRequest:request error:nil];
        for (CCAsset *asset in requestArray) {
            [self.managedObjectContext deleteObject:asset];
        }
    }
    [self saveDataCompletion:completion];
}


#pragma mark -查询资产
- (NSArray <CCAsset *> *)requestAssetWithWalletAddress:(NSString *)walletAddress coinType:(CCCoinType)coinType accountID:(NSString *)accountID {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:CCAssetEntityName];
    //条件
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"walletAddress CONTAINS[cd] %@ AND coinType = %@ AND accountID CONTAINS[cd] %@ AND (isDelete = nil OR isDelete = NO)",walletAddress,@(coinType),accountID];
    request.predicate = pre;
    //
    NSSortDescriptor *idSort = [NSSortDescriptor sortDescriptorWithKey:@"asset_id" ascending:YES];
    request.sortDescriptors = @[idSort];
    NSArray *requestArray = [self.managedObjectContext executeFetchRequest:request error:nil];
    return requestArray;
}


#pragma mark - 查找
- (NSArray <CCAsset *> *)searchAssetsWithWallet:(CCWalletData *)walletData
                                        keyWord:(NSString *)keyWord
                              isHiddenNoBalance:(BOOL)isNoBalance
                                     filterType:(NSString *)filterType
                                  walletAddress:(NSString *)walletAddress {
    if (walletData.assets.count == 0) {
        return nil;
    }
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:CCAssetEntityName];
    //条件
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"walletAddress CONTAINS[cd] %@ AND coinType = %@ AND accountID CONTAINS[cd] %@ AND (isDelete = nil OR isDelete = NO)",walletAddress,@(walletData.type),walletData.wallet.accountID];
    request.predicate = pre;
    //
    NSSortDescriptor *idSort = [NSSortDescriptor sortDescriptorWithKey:@"asset_id" ascending:YES];
    request.sortDescriptors = @[idSort];
    NSArray *requestArray = [self.managedObjectContext executeFetchRequest:request error:nil];
    
    keyWord = [keyWord deleteSpace];
    if (keyWord.length) {
        pre = [NSPredicate predicateWithFormat:@"(tokenAddress CONTAINS[cd] %@) OR (tokenSynbol CONTAINS[cd] %@) OR (tokenName CONTAINS[cd] %@)",keyWord,keyWord,keyWord];
        requestArray = [requestArray filteredArrayUsingPredicate:pre];
    }
    
    if (isNoBalance) {
        switch (walletData.type) {
            case CCCoinTypeETH:
            {
                pre = [NSPredicate predicateWithFormat:@"balance != '0' AND balance != NULL OR tokenSynbol = 'ETH'"];
            }
                break;
            case CCCoinTypeNEO:
            {
                pre = [NSPredicate predicateWithFormat:@"balance != '0' AND balance != NULL OR (tokenSynbol = 'NEO' OR tokenSynbol = 'GAS')"];
            }
                break;
            case CCCoinTypeONT:
            {
                pre = [NSPredicate predicateWithFormat:@"balance != '0' AND balance != NULL OR (tokenSynbol = 'ONT' OR tokenSynbol = 'ONG')"];
            }
                break;
            default:
                break;
        }
        requestArray = [requestArray filteredArrayUsingPredicate:pre];
    }
    
    if (filterType) {
        pre = [NSPredicate predicateWithFormat:@"tokenType = %@ OR tokenType = NULL",filterType];
        requestArray = [requestArray filteredArrayUsingPredicate:pre];
    }
    
    return requestArray;
}


#pragma mark - 删除所有资产/未保存
- (void)deleteAllAssetWithAccountId:(NSString *)accountID {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:CCAssetEntityName];
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"accountID CONTAINS[cd] %@", accountID];
    request.predicate = pre;
    NSArray *requestArray = [self.managedObjectContext executeFetchRequest:request error:nil];
    for (CCAsset *asset in requestArray) {
        [self.managedObjectContext deleteObject:asset];
    }
}

#pragma mark - 保存资产
- (CCAsset *)saveAssetWithAsset:(NSDictionary *)asset
                  walletAddress:(NSString *)walletAddress
                       coinType:(CCCoinType)coinType
                      accountID:(NSString *)accountID
                     completion:(saveCompletion)completion {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:CCAssetEntityName];
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"walletAddress CONTAINS[cd] %@ AND tokenAddress CONTAINS[cd] %@ AND coinType = %@ AND accountID CONTAINS[cd] %@",walletAddress,asset[@"tokenAddress"],@(coinType),accountID];
    request.predicate = pre;
    
    NSArray *requestArray = [self.managedObjectContext executeFetchRequest:request error:nil];
    //如果有说明添加过
    if (requestArray.count) {
        CCAsset *asset = requestArray.firstObject;
        if (asset.isDelete == YES) {
            asset.isDelete = NO;
        }
        [self saveDataCompletion:completion];
        return asset;
    }
    
    CCAsset *saveAsset = [NSEntityDescription insertNewObjectForEntityForName:CCAssetEntityName inManagedObjectContext:self.managedObjectContext];
    saveAsset.walletAddress = walletAddress;
    [self bindAsset:saveAsset accountID:accountID withDic:asset];
    
    [self saveDataCompletion:completion];
    return saveAsset;
}

#pragma mark - 批量保存资产
- (NSArray <CCAsset *> *)saveAssetWithAssets:(NSDictionary *)assets
                               walletAddress:(NSString *)walletAddress
                                    coinType:(CCCoinType)coinType
                                   accountID:(NSString *)accountID
                                  completion:(saveCompletion)completion  {
    NSMutableDictionary *assetsMut = [assets mutableCopy];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:CCAssetEntityName];
    //条件
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"walletAddress CONTAINS[cd] %@ AND coinType = %@ AND accountID CONTAINS[cd] %@",walletAddress,@(coinType),accountID];
    request.predicate = pre;
    NSSortDescriptor *idSort = [NSSortDescriptor sortDescriptorWithKey:@"asset_id" ascending:YES];
    request.sortDescriptors = @[idSort];
    NSArray *requestArray = [self.managedObjectContext executeFetchRequest:request error:nil];
    for (CCAsset *asset in requestArray) {
        NSString *tokenAddress = [asset.tokenAddress lowercaseString];
        NSDictionary *changeAsset = assets[tokenAddress];
        if (changeAsset) {
            asset.walletAddress = walletAddress;
            [self bindAsset:asset accountID:accountID withDic:changeAsset];
            [assetsMut removeObjectForKey:tokenAddress];
        }
    }
    
    if (assetsMut.allKeys.count) {
        //之后存储新的
        for (NSDictionary *assetDic in assetsMut.allValues) {
            CCAsset *saveAsset = [NSEntityDescription insertNewObjectForEntityForName:CCAssetEntityName inManagedObjectContext:self.managedObjectContext];
            saveAsset.walletAddress = walletAddress;
            [self bindAsset:saveAsset accountID:accountID withDic:assetDic];
        }
    }
    [self saveDataCompletion:completion];
    
    return [self requestAssetWithWalletAddress:walletAddress coinType:coinType accountID:accountID];
}

- (void)bindAsset:(CCAsset *)asset accountID:(NSString *)accountId withDic:(NSDictionary *)assetDic {
    asset.asset_id = asset.asset_id==0?[assetDic[@"asset_id"] integerValue]:asset.asset_id;
    asset.balance = assetDic[@"balance"]?:(asset.balance?:@"0");
    if ([assetDic.allKeys containsObject:@"isDefault"]) {
        asset.isDefault = [assetDic[@"isDefault"] integerValue];
    }
    asset.price = assetDic[@"price"]?:(asset.price?:@"0");
    asset.priceUSD = assetDic[@"priceUSD"]?:(asset.priceUSD?:@"0");
    asset.tokenAddress = assetDic[@"tokenAddress"];
    asset.tokenDecimal = assetDic[@"tokenDecimal"];
    asset.tokenIcon = assetDic[@"tokenIcon"];
    asset.tokenName = assetDic[@"tokenName"];
    asset.tokenSynbol = assetDic[@"tokenSynbol"];
    asset.tokenType = assetDic[@"tokenType"];
    if ([assetDic.allKeys containsObject:@"notDelete"]) {
        asset.notDelete = [assetDic[@"notDelete"] boolValue];
    }
    asset.coinType = [assetDic[@"coinType"] integerValue];
    asset.accountID = accountId;
}

@end
