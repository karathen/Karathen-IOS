//
//  CCNotificationCenter.m
//  ccAsset
//
//  Created by SealWallet on 2018/8/2.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCNotificationCenter.h"

@implementation CCNotificationCenter


#pragma mark - 账户变动通知
+ (void)postAccountChange:(BOOL)add accountID:(NSString *)accountID {
    [[NSNotificationCenter defaultCenter] postNotificationName:CC_ACCOUNT_CHANGE_NOTIFICATION object:nil userInfo:@{@"add":@(add),@"accountID":accountID}];
}


+ (void)receiveAccountChangeObserver:(id)observer completion:(void(^)(BOOL add, NSString *accountID))completion {
    [[[NSNotificationCenter.defaultCenter rac_addObserverForName:CC_ACCOUNT_CHANGE_NOTIFICATION object:nil] takeUntil:[observer rac_willDeallocSignal]] subscribeNext:^(NSNotification * _Nullable x) {
        BOOL add = [x.userInfo[@"add"] boolValue];
        NSString *accountID = x.userInfo[@"accountID"];
        if (completion) {
            completion(add,accountID);
        }
    }];
}

#pragma mark -活跃账户发生变化的通知
+ (void)postActiveAccountChange {
    [[NSNotificationCenter defaultCenter] postNotificationName:CC_ACTIVE_ACCOUNT_CHANGE_NOTIFICATION object:nil userInfo:nil];
}

+ (void)receiveActiveAccountChangeObserver:(id)observer completion:(void(^)(void))completion {
    [[[NSNotificationCenter.defaultCenter rac_addObserverForName:CC_ACTIVE_ACCOUNT_CHANGE_NOTIFICATION object:nil] takeUntil:[observer rac_willDeallocSignal]] subscribeNext:^(NSNotification * _Nullable x) {
        if (completion) {
            completion();
        }
    }];
}


#pragma mark - 账户名字改变通知
+ (void)postAccountNameChange:(NSString *)accountID {
    [[NSNotificationCenter defaultCenter] postNotificationName:CC_ACCOUNT_NAME_CHANGE_NOTIFICATION object:nil userInfo:@{@"accountID":accountID}];

}

+ (void)receiveAccountNameChangeObserver:(id)observer completion:(void(^)(NSString *accountID))completion {
    [[[NSNotificationCenter.defaultCenter rac_addObserverForName:CC_ACCOUNT_NAME_CHANGE_NOTIFICATION object:nil] takeUntil:[observer rac_willDeallocSignal]] subscribeNext:^(NSNotification * _Nullable x) {
        NSString *accountID = x.userInfo[@"accountID"];
        if (completion) {
            completion(accountID);
        }
    }];
}

#pragma mark - 用户备份
+ (void)postAccountBackUp {
    [[NSNotificationCenter defaultCenter] postNotificationName:CC_ACCOUNT_BACKUP_NOTIFICATION object:nil userInfo:nil];
}

+ (void)receiveAccountBackUpObserver:(id)observer completion:(void(^)(void))completion {
    [[[NSNotificationCenter.defaultCenter rac_addObserverForName:CC_ACCOUNT_BACKUP_NOTIFICATION object:nil]  takeUntil:[observer rac_willDeallocSignal]] subscribeNext:^(NSNotification * _Nullable x) {
        if (completion) {
            completion();
        }
    }];
}


#pragma mark - 链默认地址切换
+ (void)postSelectWalletChange:(CCCoinType)coinType accountID:(NSString *)accountID {
    [[NSNotificationCenter defaultCenter] postNotificationName:CC_COIN_WALLETSELECT_CHANGE_NOTIFICATION object:nil userInfo:@{@"coinType":@(coinType),@"accountID":accountID}];
}

+ (void)receiveSelectWalletChangeObserver:(id)observer
                               completion:(void(^)(CCCoinType coinType,NSString *accountID))completion {
    [[[NSNotificationCenter.defaultCenter rac_addObserverForName:CC_COIN_WALLETSELECT_CHANGE_NOTIFICATION object:nil] takeUntil:[observer rac_willDeallocSignal]] subscribeNext:^(NSNotification * _Nullable x) {
        CCCoinType coinType = [x.userInfo[@"coinType"] integerValue];
        NSString *accountID = x.userInfo[@"accountID"];
        if (completion) {
            completion(coinType,accountID);
        }
    }];
}

#pragma mark - 链管理
+ (void)postCoinManage {
    [[NSNotificationCenter defaultCenter] postNotificationName:CC_Coin_Manage_CHANGE_NOTIFICATION object:nil userInfo:nil];
}


+ (void)receiveCoinManageObserver:(id)observer completion:(void(^)(void))completion {
    [[[NSNotificationCenter.defaultCenter rac_addObserverForName:CC_Coin_Manage_CHANGE_NOTIFICATION object:nil] takeUntil:[observer rac_willDeallocSignal]] subscribeNext:^(NSNotification * _Nullable x) {
        if (completion) {
            completion();
        }
    }];
}

#pragma mark - 钱包筛选条件更改
+ (void)postWalletFilterChange:(NSString *)walletAddress {
    if (!walletAddress) {
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:CC_WALLET_FILTER_CHANGE_NOTIFICATION object:nil userInfo:@{@"walletAddress":walletAddress}];
}

+ (void)receiveWalletFilterChangeObserver:(id)observer
                               completion:(void(^)(NSString *walletAddress))completion {
    [[[NSNotificationCenter.defaultCenter rac_addObserverForName:CC_WALLET_FILTER_CHANGE_NOTIFICATION object:nil] takeUntil:[observer rac_willDeallocSignal]] subscribeNext:^(NSNotification * _Nullable x) {
        if (completion) {
            completion(x.userInfo[@"walletAddress"]);
        }
    }];
}


#pragma mark - 钱包隐藏余额更改
+ (void)postWalletHideNoBalanceChange:(NSString *)walletAddress {
    if (!walletAddress) {
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:CC_WALLET_HIDENOBALANCE_NOTIFICATION object:nil userInfo:@{@"walletAddress":walletAddress}];

}

+ (void)receiveWalletHideNoBalanceChangeObserver:(id)observer
                                      completion:(void(^)(NSString *walletAddress))completion {
    [[[NSNotificationCenter.defaultCenter rac_addObserverForName:CC_WALLET_HIDENOBALANCE_NOTIFICATION object:nil] takeUntil:[observer rac_willDeallocSignal]] subscribeNext:^(NSNotification * _Nullable x) {
        if (completion) {
            completion(x.userInfo[@"walletAddress"]);
        }
    }];
}

#pragma mark - 链上地址变动
+ (void)postWalletAddressChange:(CCCoinType)coinType {
    [[NSNotificationCenter defaultCenter] postNotificationName:CC_WALLET_ADDRESS_CHANGE_NOTIFICATION object:nil userInfo:@{@"coinType":@(coinType)}];
}

#pragma mark - 接收链上地址变动的通知
+ (void)receiveWalletAddressChangeObserver:(id)observer
                                completion:(void(^)(CCCoinType coinType))completion {
    [[[NSNotificationCenter.defaultCenter rac_addObserverForName:CC_WALLET_ADDRESS_CHANGE_NOTIFICATION object:nil] takeUntil:[observer rac_willDeallocSignal]] subscribeNext:^(NSNotification * _Nullable x) {
        CCCoinType coinType = [x.userInfo[@"coinType"] integerValue];
        if (completion) {
            completion(coinType);
        }
    }];
}


#pragma mark - 资产添加/删除
+ (void)postAssetChangeWithWalletAddress:(NSString *)address {
    if (!address) {
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:CC_ASSET_CHANGE_NOTIFICATION object:nil userInfo:@{@"address":address}];
}

+ (void)receiveAssetChangeObserver:(id)observer
                        completion:(void(^)(NSString *address))completion {
    [[[NSNotificationCenter.defaultCenter rac_addObserverForName:CC_ASSET_CHANGE_NOTIFICATION object:nil] takeUntil:[observer rac_willDeallocSignal]] subscribeNext:^(NSNotification * _Nullable x) {
        NSString *address = x.userInfo[@"address"];
        if (completion) {
            completion(address);
        }
    }];
}

#pragma mark -  新增交易
+ (void)postAssetTradeUpdateWithWalletAddress:(NSString *)walletAddress
                              tokenAddress:(NSString *)tokenAddress {
    if (!walletAddress || !tokenAddress) {
        return;
    }
    NSMutableDictionary *userinfo = [NSMutableDictionary dictionary];
    [userinfo setObject:walletAddress forKey:@"walletAddress"];
    [userinfo setObject:tokenAddress forKey:@"tokenAddress"];
    [[NSNotificationCenter defaultCenter] postNotificationName:CC_ASSET_TRADE_Update_NOTIFICATION object:nil userInfo:userinfo];
}

+ (void)receiveAssetTradeUpdateObserver:(id)observer
                             completion:(void(^)(NSString *walletAddress,NSString *tokenAddress))completion {
    [[[NSNotificationCenter.defaultCenter rac_addObserverForName:CC_ASSET_TRADE_Update_NOTIFICATION object:nil] takeUntil:[observer rac_willDeallocSignal]] subscribeNext:^(NSNotification * _Nullable x) {
        if (completion) {
            NSString *walletAddress = x.userInfo[@"walletAddress"];
            NSString *tokenAddress = x.userInfo[@"tokenAddress"];
            completion(walletAddress,tokenAddress);
        }
    }];
}

#pragma mark - 钱包余额变化
+ (void)postWalletBalanceChangeWithWalletAddress:(NSString *)walletAddress {
    if (!walletAddress) {
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:CC_WALLET_BALANCE_CHANGE_NOTIFICATION object:nil userInfo:@{@"walletAddress":walletAddress}];
}

+ (void)receiveWalletBalanceChangeObserver:(id)observer
                                completion:(void(^)(NSString *walletAddress))completion {
    [[[NSNotificationCenter.defaultCenter rac_addObserverForName:CC_WALLET_BALANCE_CHANGE_NOTIFICATION object:nil] takeUntil:[observer rac_willDeallocSignal]] subscribeNext:^(NSNotification * _Nullable x) {
        if (completion) {
            NSString *walletAddress = x.userInfo[@"walletAddress"];
            completion(walletAddress);
        }
    }];
}

#pragma mark - 钱包名变化
+ (void)postWalletNameChangeWithWalletAddress:(NSString *)walletAddress {
    if (!walletAddress) {
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:CC_WALLET_NAME_CHANGE_NOTIFICATION object:nil userInfo:@{@"walletAddress":walletAddress}];
}

+ (void)receiveWalletNameChangeObserver:(id)observer
                             completion:(void(^)(NSString *walletAddress))completion {
    [[[NSNotificationCenter.defaultCenter rac_addObserverForName:CC_WALLET_NAME_CHANGE_NOTIFICATION object:nil] takeUntil:[observer rac_willDeallocSignal]] subscribeNext:^(NSNotification * _Nullable x) {
        if (completion) {
            NSString *walletAddress = x.userInfo[@"walletAddress"];
            completion(walletAddress);
        }
    }];
}

#pragma mark - 货币单位切换
+ (void)postCurrencyUnitChangeWithUnit:(NSString *)currentUnit {
    if (!currentUnit) {
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:CC_CURRENCYUNIT_CHANGE_NOTIFICATION object:nil userInfo:@{@"currentUnit":currentUnit}];
}

+ (void)receiveCurrencyUnitChangeObserver:(id)observer
                               completion:(void(^)(NSString *currentUnit))completion {
    [[[NSNotificationCenter.defaultCenter rac_addObserverForName:CC_CURRENCYUNIT_CHANGE_NOTIFICATION object:nil] takeUntil:[observer rac_willDeallocSignal]] subscribeNext:^(NSNotification * _Nullable x) {
        if (completion) {
            NSString *currentUnit = x.userInfo[@"currentUnit"];
            completion(currentUnit);
        }
    }];
}

#pragma mark - 块高刷新
+ (void)postBlockHeightRefrshWithCoinType:(CCCoinType)coinType {
    [[NSNotificationCenter defaultCenter] postNotificationName:CC_BLOCKHEIGHT_REFRESH_NOTIFICATION object:nil userInfo:@{@"coinType":@(coinType)}];
}

+ (void)receiveBlockHeightRefrshObserver:(id)observer
                              completion:(void(^)(CCCoinType coinType))completion {
    [[[NSNotificationCenter.defaultCenter rac_addObserverForName:CC_BLOCKHEIGHT_REFRESH_NOTIFICATION object:nil] takeUntil:[observer rac_willDeallocSignal]] subscribeNext:^(NSNotification * _Nullable x) {
        if (completion) {
            CCCoinType coinType = [x.userInfo[@"coinType"] integerValue];
            completion(coinType);
        }
    }];
}


#pragma mark - 蓝牙状态改变
+ (void)postBlueToothStateChange:(BOOL)state {
    [[NSNotificationCenter defaultCenter] postNotificationName:CC_BLUETOOTH_STATE_CHANGE_NOTIFICATION object:nil userInfo:@{@"state":@(state)}];
}

+ (void)receiveBlueToothstateChangeObserver:(id)observer completion:(void(^)(BOOL state))completion {
    [[[NSNotificationCenter.defaultCenter rac_addObserverForName:CC_BLUETOOTH_STATE_CHANGE_NOTIFICATION object:nil] takeUntil:[observer rac_willDeallocSignal]] subscribeNext:^(NSNotification * _Nullable x) {
        if (completion) {
            BOOL state = [x.userInfo[@"state"] boolValue];
            completion(state);
        }
    }];
}

#pragma mark - 应用状态
+ (void)receiveAppStateActiveObserver:(id)observer completion:(void(^)(void))completion {
    [[[NSNotificationCenter.defaultCenter rac_addObserverForName:UIApplicationDidBecomeActiveNotification object:nil] takeUntil:[observer rac_willDeallocSignal]] subscribeNext:^(NSNotification * _Nullable x) {
        if (completion) {
            completion();
        }
    }];
}

+ (void)receiveEnterBackgroundObserver:(id)observer completion:(void(^)(void))completion {
    [[[NSNotificationCenter.defaultCenter rac_addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil] takeUntil:[observer rac_willDeallocSignal]] subscribeNext:^(NSNotification * _Nullable x) {
        if (completion) {
            completion();
        }
    }];
}

#pragma mark - 界面旋转切换
+ (void)receiveStatusBarOrientationDidChangeObserver:(id)observer completion:(void(^)(void))completion {
    [[[NSNotificationCenter.defaultCenter rac_addObserverForName:UIApplicationDidChangeStatusBarOrientationNotification object:nil] takeUntil:[observer rac_willDeallocSignal]] subscribeNext:^(NSNotification * _Nullable x) {
        if (completion) {
            completion();
        }
    }];
}

#pragma mark - 网络连接变化
+ (void)receiveRealReachabilityChangedObserver:(id)observer completion:(void(^)(ReachabilityStatus status))completion {
    [[[NSNotificationCenter.defaultCenter rac_addObserverForName:kRealReachabilityChangedNotification object:nil] takeUntil:[observer rac_willDeallocSignal]] subscribeNext:^(NSNotification * _Nullable x) {
        RealReachability *reachability = (RealReachability *)x.object;
        ReachabilityStatus status = [reachability currentReachabilityStatus];
        if (completion) {
            completion(status);
        }
    }];
}

@end
