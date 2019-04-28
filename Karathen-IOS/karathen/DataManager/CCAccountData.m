//
//  CCAccountData.m
//  Karathen
//
//  Created by Karathen on 2018/11/20.
//  Copyright © 2018 raistone. All rights reserved.
//

#import "CCAccountData.h"
#import "CCCoinData.h"
#import "CCCoreData+Coin.h"
#import "CCUploadDeviceRequest.h"
#import "CCCoreData+Account.h"

@interface CCAccountData ()

@property (nonatomic, strong) NSMutableDictionary <NSString *,CCCoinData *> *coinDic;

@end

@implementation CCAccountData

#pragma mark - 数据库创建账户
- (instancetype)initWithAccount:(CCAccount *)account {
    if (self = [super init]) {
        self.account = account;
    }
    return self;
}

- (CCCoinData *)activeCoin {
    if (!_activeCoin) {
        [self coins];
    }
    return _activeCoin;
}


#pragma mark - 创建账户
//硬件
+ (void)accountWithAccountID:(NSString *)accountId
                      sortID:(NSInteger)sortId
                  deviceName:(NSString *)deviceName
                  addressDic:(NSDictionary *)addressDic
                  importType:(CCImportType)importType
                 accountName:(NSString *)accountName
                passWordInfo:(NSString *)passWordInfo
                  completion:(void(^)(CCAccountData *accountData,CCWalletError error))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CCAccount *account = [[CCCoreData coreData] saveAccountWithAccountId:accountId sortID:sortId accountName:accountName walletType:CCWalletTypeHardware importType:importType coinType:CCCoinTypeNone passWordInfo:passWordInfo completion:nil];
        CCAccountData *accountData = [[CCAccountData alloc] initWithAccount:account];
        
        dispatch_group_t requestGroup = dispatch_group_create();
        
        __block BOOL success = YES;
        __block NSInteger count = 0;
        __block CCWalletError walletError;
        for (NSString *coinType in addressDic) {
            dispatch_group_enter(requestGroup);
            NSString *address = addressDic[coinType];
            CCCoinType type = [CCDataManager coinTypeWithKey:coinType];
            CCCoinData *coinData = [accountData coinDataWithCoinType:type];
            [coinData saveWalletWithAddress:address walletName:nil importType:importType slot:0 completion:^(BOOL suc, CCWalletError error) {
                if (!suc) {
                    success = suc;
                    walletError = error;
                }
                count += 1;
                dispatch_group_leave(requestGroup);
            }];
        }
        
        dispatch_group_notify(requestGroup, dispatch_get_main_queue(), ^{
            if (count == addressDic.allKeys.count && success) {
                if (completion) {
                    completion(accountData,walletError);
                }
            } else {
                [[CCCoreData coreData] deleteAccountWithAccountId:accountId completion:nil];
                if (completion) {
                    completion(nil,walletError);
                }
            }
        });
        
    });
}

//助记词
+ (void)accountWithAccountID:(NSString *)accountId
                      sortID:(NSInteger)sortId
                    mnemonic:(NSString *)mnemonic
                  walletType:(CCWalletType)walletType
                  importType:(CCImportType)importType
                    passWord:(NSString *)passWord
                passWordInfo:(NSString *)passWordInfo
                 accountName:(NSString *)accountName
                  completion:(void(^)(CCAccountData *accountData,CCWalletError error))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CCAccount *account = [[CCCoreData coreData] saveAccountWithAccountId:accountId sortID:sortId accountName:accountName walletType:walletType importType:importType coinType:CCCoinTypeNone passWordInfo:passWordInfo completion:nil];
        CCAccountData *accountData = [[CCAccountData alloc] initWithAccount:account];
        
        dispatch_group_t requestGroup = dispatch_group_create();
        
        __block BOOL success = YES;
        __block NSInteger count = 0;
        __block CCWalletError walletError;
        for (CCCoinData *coinData in accountData.coins) {
            dispatch_group_enter(requestGroup);
            [coinData createWalletWithMnemonic:mnemonic importType:importType completion:^(BOOL suc, CCWalletError error) {
                if (!suc) {
                    success = suc;
                    walletError = error;
                }
                count += 1;
                dispatch_group_leave(requestGroup);
            }];
        }
        
        dispatch_group_notify(requestGroup, dispatch_get_main_queue(), ^{
            if (count == accountData.coins.count && success) {
                if (completion) {
                    completion(accountData,walletError);
                }
            } else {
                [[CCCoreData coreData] deleteAccountWithAccountId:accountId completion:nil];
                if (completion) {
                    completion(nil,walletError);
                }
            }
        });
    });
}

//私钥
+ (void)accountWithAccountID:(NSString *)accountId
                      sortID:(NSInteger)sortId
                  privateKey:(NSString *)privateKey
                  walletType:(CCWalletType)walletType
                    coinType:(CCCoinType)coinType
                    passWord:(NSString *)passWord
                passWordInfo:(NSString *)passWordInfo
                 accountName:(NSString *)accountName
                  completion:(void(^)(CCAccountData *accountData,CCWalletError error))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CCAccount *account = [[CCCoreData coreData] saveAccountWithAccountId:accountId sortID:sortId accountName:accountName walletType:walletType importType:CCImportTypePrivateKey coinType:coinType passWordInfo:passWordInfo completion:nil];
        CCAccountData *accountData = [[CCAccountData alloc] initWithAccount:account];
        
        CCCoinData *coinData = accountData.coins.firstObject;
        
        [coinData createWalletWithPrivateKey:privateKey completion:^(BOOL suc, CCWalletError error) {
            if (suc) {
                if (completion) {
                    completion(accountData,error);
                }
            } else {
                [[CCCoreData coreData] deleteAccountWithAccountId:accountId completion:nil];
                if (completion) {
                    completion(nil,error);
                }
            }
        }];
    });
}

//wif
+ (void)accountWithAccountID:(NSString *)accountId
                      sortID:(NSInteger)sortId
                         wif:(NSString *)wif
                  walletType:(CCWalletType)walletType
                    coinType:(CCCoinType)coinType
                    passWord:(NSString *)passWord
                passWordInfo:(NSString *)passWordInfo
                 accountName:(NSString *)accountName
                  completion:(void(^)(CCAccountData *accountData,CCWalletError error))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CCAccount *account = [[CCCoreData coreData] saveAccountWithAccountId:accountId sortID:sortId accountName:accountName walletType:walletType importType:CCImportTypeWIF coinType:coinType passWordInfo:passWordInfo completion:nil];
        CCAccountData *accountData = [[CCAccountData alloc] initWithAccount:account];
        
        CCCoinData *coinData = accountData.coins.firstObject;
        
        [coinData createWalletWithWIF:wif completion:^(BOOL suc, CCWalletError error) {
            if (suc) {
                if (completion) {
                    completion(accountData,error);
                }
            } else {
                [[CCCoreData coreData] deleteAccountWithAccountId:accountId completion:nil];
                if (completion) {
                    completion(nil,error);
                }
            }
        }];
    });
}

//keystore
+ (void)accountWithAccountID:(NSString *)accountId
                      sortID:(NSInteger)sortId
                    keystore:(NSString *)keystore
                  walletType:(CCWalletType)walletType
                    coinType:(CCCoinType)coinType
                    passWord:(NSString *)passWord
                passWordInfo:(NSString *)passWordInfo
                 accountName:(NSString *)accountName
                  completion:(void(^)(CCAccountData *accountData,NSString *privatekey,CCWalletError error))completion {
    CCAccount *account = [[CCCoreData coreData] saveAccountWithAccountId:accountId sortID:sortId accountName:accountName walletType:walletType importType:CCImportTypeKeystore coinType:coinType passWordInfo:passWordInfo completion:nil];
    CCAccountData *accountData = [[CCAccountData alloc] initWithAccount:account];
    
    CCCoinData *coinData = accountData.coins.firstObject;
    
    [coinData createWalletWithKeyStore:keystore passWord:passWord completion:^(BOOL suc, CCWalletError error, NSString *privatekey) {
        if (suc) {
            if (completion) {
                completion(accountData,privatekey,error);
            }
        } else {
            [[CCCoreData coreData] deleteAccountWithAccountId:accountId completion:nil];
            if (completion) {
                completion(nil,nil,error);
            }
        }
    }];
}

#pragma mark - 备份
- (void)backUp {
    if (self.account.isBackup) {
        return;
    }
    self.account.isBackup = YES;
    [[CCCoreData coreData] saveDataCompletion:nil];
    [CCNotificationCenter postAccountBackUp];
}

#pragma mark - 修改名称
- (void)changeName:(NSString *)name {
    if ([self.account.accountName compareWithString:name]) {
        return;
    }
    self.account.accountName = name;
    [[CCCoreData coreData] saveDataCompletion:nil];
    [CCNotificationCenter postAccountNameChange:self.account.accountID];
}

#pragma mark - 通过链类型获取CCCoinData
- (CCCoinData *)coinDataWithCoinType:(CCCoinType)coinType {
    CCCoinData *coin;
    if (!self.coinDic) {
        self.coinDic = [NSMutableDictionary dictionary];
        for (CCCoinData *coinData in self.coins) {
            CCCoinType type = coinData.coin.coinType;
            if (type == coinType) {
                coin = coinData;
            }
            NSString *key = [CCDataManager coinKeyWithType:type];
            [self.coinDic setValue:coinData forKey:key];
        }
    }
    if (!coin) {
        coin = [self.coinDic valueForKey:[CCDataManager coinKeyWithType:coinType]];
    }
    return coin;
}

#pragma mark - 需要显示的链
- (NSArray *)noHiddenCoins {
    NSMutableArray *coins = [NSMutableArray array];
    for (CCCoinData *coinData in self.coins) {
        if (!coinData.coin.isHidden) {
            [coins addObject:coinData];
        }
    }
    if (coins.count == 0) {
        coins = [self.coins mutableCopy];
    }
    return coins;
}

#pragma mark - 编辑修改链
- (void)changeCoins {
    [self.coins sortUsingComparator:^NSComparisonResult(CCCoinData *obj1, CCCoinData *obj2) {
        return obj1.coin.sortID > obj2.coin.sortID;
    }];
    self.showCoins = [self noHiddenCoins];
    [self changeActiveCoin:self.showCoins.firstObject];
}

#pragma mark - 修改当前默认链
- (void)changeActiveCoin:(CCCoinData *)coinData {
    if (!coinData) {
        return;
    }
    if (self.activeCoin == coinData) {
        return;
    }
    self.activeCoin.coin.isSelected = NO;
    coinData.coin.isSelected = YES;
    [[CCCoreData coreData] saveDataCompletion:nil];

    self.activeCoin = coinData;
}


#pragma mark - 添加一条链
- (void)createCoinWithCoinData:(CCCoinData *)coinData
                      passWord:(NSString *)password
                    completion:(void (^)(BOOL, CCWalletError))completion {
    [coinData createHDAddressWithWalletName:nil passWord:password importType:self.account.importType completion:completion];
}

#pragma mark - 上传地址
- (void)upLoadDevice {
    NSMutableDictionary *addressDic = [NSMutableDictionary dictionary];
    
    for (CCCoinData *coinData in self.coins) {
        NSMutableArray *addressArray = [NSMutableArray array];
        for (CCWalletData *walletData in coinData.wallets) {
            [addressArray addObject:walletData.address];
        }
        [addressDic setValue:addressArray forKey:[CCDataManager coinKeyWithType:coinData.coin.coinType]];
    }
    
    CCUploadDeviceRequest *request = [[CCUploadDeviceRequest alloc] init];
    request.addressDic = addressDic;
    [request uploadRequet:nil];
}


#pragma mark - 当前账户所选择的链
- (NSArray *)coinType {
    switch (self.account.importType) {
        case CCImportTypeSeed:
        case CCImportTypeMnemonic:
        case CCImportTypeHardware:
        {
            if (self.account.walletType == CCWalletTypePhone) {
                ///手机钱包支持的链
                return @[
                         @(CCCoinTypeETH),
                         @(CCCoinTypeNEO),
                         @(CCCoinTypeONT)
                         ];
            } else if (self.account.walletType == CCWalletTypeHardware) {
                ///硬件钱包支持的链
                return [CCHardwareWallet hardwareCoins];
            }
        }
            break;
        case CCImportTypeKeystore:
        case CCImportTypePrivateKey:
        case CCImportTypeWIF:
        {
            ///导入时选择的链
            return @[@(self.account.coinType)];
        }
            break;
        default:
            break;
    }
    return nil;
}

#pragma mark - 钱包图标
- (NSString *)accountIcon {
    NSString *icon;
    switch (self.account.walletType) {
        case CCWalletTypePhone:
        {
            icon = @"cc_account_phone";
        }
            break;
        case CCWalletTypeHardware:
        {
            icon = @"cc_account_hardware";
        }
            break;
        default:
            break;
    }
    return icon;
}


#pragma mark - get
- (NSMutableArray<CCCoinData *> *)coins {
    if (!_coins) {
        _coins = [NSMutableArray array];
        NSArray *coins = [[CCCoreData coreData] requestCoinsWithAccountID:self.account.accountID];
        NSArray *customCoins = [self coinType];
        //如果没有，配置当前账户的默认链
        if (coins.count != customCoins.count) {
            //批量添加链
            coins = [[CCCoreData coreData] saveCoinsWithCoins:customCoins accountID:self.account.accountID completion:nil];
        }
        
        //当前选中的链
        CCCoinData *activeCoin;
        for (CCCoin *coin in coins) {
            CCCoinData *coinData = [[CCCoinData alloc] initWithCoin:coin];
            if (coin.isSelected) {
                activeCoin = coinData;
            }
            [_coins addObject:coinData];
        }
        //当前选中的链
        if (!activeCoin && _coins.count) {
            activeCoin = _coins.firstObject;
        }
        self.activeCoin = activeCoin;
    }
    return _coins;
}


#pragma mark - 当前可以显示的链
- (NSArray<CCCoinData *> *)showCoins {
    if (!_showCoins) {
        _showCoins = [self noHiddenCoins];
    }
    return _showCoins;
}


@end
