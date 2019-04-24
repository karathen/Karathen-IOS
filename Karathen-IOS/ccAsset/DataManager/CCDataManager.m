//
//  CCDataManager.m
//  ccAsset
//
//  Created by SealWallet on 2018/7/10.
//  Copyright © 2018年 SealWallet. All rights reserved.
//

#import "CCDataManager.h"
#import <SAMKeychain/SAMKeychain.h>
#import "CCCoreData+Wallet.h"
#import "CCCoreData+Asset.h"
#import "CCCoreData+TradeRecord.h"
#import "CCCryptoTool.h"
#import "CCETHMonitor.h"
#import "CCNEOMonitor.h"
#import "CCONTMonitor.h"
#import "CCAppInfo.h"

#import "CCWalletManager.h"
#import "CCCoreData+Account.h"
#import "CCCoreData+Coin.h"
#import "CCCoreData+Wallet.h"
#import "CCCoreData+Asset.h"
#import "CCCoreData+TradeRecord.h"

static CCDataManager *dataManager = nil;



@interface CCDataManager ()

@property (nonatomic, strong) NSMutableDictionary <NSString *,CCAccountData *> *accountDic;

//定时器，定时请求刷新数据
@property (nonatomic, strong) NSTimer *updateWalletTimer;
@property (nonatomic, assign) NSInteger timeCount;

@end


@implementation CCDataManager

+ (CCDataManager *)dataManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dataManager = [[CCDataManager alloc] init];
        
        [dataManager addUpdateWalletTimer];
    });
    return dataManager;
}

- (void)clearData {
    NSString *currentClearVersion = [[NSUserDefaults standardUserDefaults] objectForKey:CC_CURRENT_CLEARDATA_VERSION];
    if (currentClearVersion == nil) {
        //清空NSUserDefaults
        NSString *appDomaion = [[NSBundle mainBundle] bundleIdentifier];
        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomaion];
        
        //清空钥匙串
        NSArray *accounts = [SAMKeychain accountsForService:CCWalletDataServiceName];
        for (NSDictionary *account in accounts) {
            NSString *accountID = account[@"acct"];
            if (accountID) {
                [SAMKeychain deletePasswordForService:CCWalletDataServiceName account:accountID];
            }
        }
        //清空数据库
        [[CCCoreData coreData] clearAccountDataCompletion:nil];
        [[CCCoreData coreData] clearCoinDataCompletion:nil];
        [[CCCoreData coreData] clearWalletDataCompletion:nil];
        [[CCCoreData coreData] clearAssetDataCompletion:nil];
        [[CCCoreData coreData] clearTradeRecordDataCompletion:nil];

        //设置版本号
        [[NSUserDefaults standardUserDefaults] setObject:[CCAppInfo appVersion] forKey:CC_CURRENT_CLEARDATA_VERSION];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark - 通过ID获取账户
- (CCAccountData *)accountWithAccountID:(NSString *)accountID {
    CCAccountData *account;
    if (!self.accountDic) {
        self.accountDic = [NSMutableDictionary dictionary];
        for (CCAccountData *accountData in self.accounts) {
            NSString *key = accountData.account.accountID;
            if ([accountID compareWithString:key]) {
                account = accountData;
            }
            [self.accountDic setValue:accountData forKey:key];
        }
    }
    if (!account) {
        account = [self.accountDic valueForKey:accountID];
    }
    return account;
}

#pragma mark - 添加用户
- (void)addAccount:(CCAccountData *)account withWalletInfo:(NSString *)walletInfo passWord:(NSString *)passWord {
    NSString *accountID = account.account.accountID;

    [self changeActiveAccount:account];
    [self.accounts addObject:account];
    [self.accountDic setValue:account forKey:accountID];
    [self saveWalletInfo:walletInfo accountID:accountID passWord:passWord];
    
    [CCNotificationCenter postAccountChange:YES accountID:accountID];
}

- (void)addAccount:(CCAccountData *)account withWalletInfo:(NSString *)walletInfo {
    NSString *accountID = account.account.accountID;
    
    [self changeActiveAccount:account];
    [self.accounts addObject:account];
    [self.accountDic setValue:account forKey:accountID];
    [self saveWalletInfo:walletInfo accountID:accountID];
    
    [CCNotificationCenter postAccountChange:YES accountID:accountID];
}

#pragma mark - 删除账号
- (void)deleteAccount:(CCAccountData *)account
             passWord:(NSString *)passWord
           completion:(void(^)(BOOL suc, CCWalletError error))completion {
    NSString *accountID = account.account.accountID;
    if (account.account.walletType == CCWalletTypeHardware) {
        [self deleteAccount:account completion:completion];
    } else {
        @weakify(self)
        [self walletInfoWithAccountID:accountID password:passWord completion:^(NSString *walletInfo) {
            @strongify(self)
            if (walletInfo) {
                [self deleteAccount:account completion:completion];
            } else {
                if (completion) {
                    completion(NO, CCWalletErrorPWD);
                }
            }
        }];
    }
}


#pragma mark - 硬件钱包删除删除
- (void)deleteAccount:(CCAccountData *)account
           completion:(void(^)(BOOL suc, CCWalletError error))completion {
    NSString *accountID = account.account.accountID;

    //删除钥匙串
    [SAMKeychain deletePasswordForService:CCWalletDataServiceName account:accountID];
    
    [self.accountDic removeObjectForKey:accountID];
    [self.accounts removeObject:account];
    //删除账户
    [[CCCoreData coreData] deleteAccountWithAccountId:accountID completion:nil];
    
    if (self.accounts.count > 0) {
        [self changeActiveAccount:self.accounts.firstObject];
    }
    
    if (completion) {
        completion(YES, CCWalletDeleteAccountSuc);
    }
    
    [CCNotificationCenter postAccountChange:NO accountID:accountID];
}

#pragma mark - 修改当前默认账户
- (void)changeActiveAccount:(CCAccountData *)accountData {
    if (!accountData) {
        return;
    }
    if (self.activeAccount == accountData) {
        return;
    }
    if (self.activeAccount) {
        self.activeAccount.account.isSelected = NO;
    }
    accountData.account.isSelected = YES;
    [[CCCoreData coreData] saveDataCompletion:nil];
    
    self.activeAccount = accountData;
    
    [CCNotificationCenter postActiveAccountChange];
}

- (NSInteger)nextCurrentID {
    if (self.accounts.count == 0) {
        return 1;
    } else {
        CCAccountData *account = self.accounts.lastObject;
        return account.account.sortID + 1;
    }
}

- (NSString *)createWalletName {
    NSInteger sortId = [self nextCurrentID];
    return [NSString stringWithFormat:@"Wallet-%@",@(sortId)];
}

#pragma mark - 创建钱包方式
- (void)accountWithMnemonic:(NSString *)mnemonic
                 walletType:(CCWalletType)walletType
                 importType:(CCImportType)importType
                   passWord:(NSString *)passWord
               passWordInfo:(NSString *)passWordInfo
                accountName:(NSString *)accountName
             verifyMnemonic:(BOOL)verifyMnemonic
                 completion:(void(^)(BOOL suc, CCWalletError error))completion {
    NSString *accountID = [[NSString stringWithFormat:@"%@%@",mnemonic,@(importType)] md5ForLower32Bate];
    if ([self accountWithAccountID:accountID]) {
        if (completion) {
            completion(NO,CCWalletErrorAddressRepeat);
        }
        return;
    }
    
    mnemonic = [mnemonic deleteSpace];
    if (![Account isValidMnemonicPhrase:mnemonic]) {
        if (completion) {
            completion(NO,CCWalletErrorMnemonicsValidPhrase);
        }
        return;
    }
    
    NSInteger sortId = [self nextCurrentID];
    if (!accountName) {
        accountName = [NSString stringWithFormat:@"Wallet-%@",@(sortId)];
    }
    @weakify(self)
    [CCAccountData accountWithAccountID:accountID sortID:sortId mnemonic:mnemonic walletType:walletType importType:importType passWord:passWord passWordInfo:passWordInfo accountName:accountName completion:^(CCAccountData *accountData, CCWalletError error) {
        if (verifyMnemonic) {
            [accountData backUp];
        }
        @strongify(self)
        if (accountData) {
            [self addAccount:accountData withWalletInfo:mnemonic passWord:passWord];
            if (completion) {
                completion(YES,CCWalletImportMnemonicsSuc);
            }
        } else {
            if (completion) {
                completion(NO,error);
            }
        }
    }];
}
/**
 助记词
 */
- (void)accountWithMnemonic:(NSString *)mnemonic
                 walletType:(CCWalletType)walletType
                 importType:(CCImportType)importType
                   passWord:(NSString *)passWord
               passWordInfo:(NSString *)passWordInfo
                accountName:(NSString *)accountName
                 completion:(void(^)(BOOL suc, CCWalletError error))completion {
    [self accountWithMnemonic:mnemonic walletType:walletType importType:importType passWord:passWord passWordInfo:passWordInfo accountName:accountName verifyMnemonic:NO completion:completion];
}


/**
 私钥
 */
- (void)accountWithPrivatekey:(NSString *)privatekey
                   walletType:(CCWalletType)walletType
                     coinType:(CCCoinType)coinType
                     passWord:(NSString *)passWord
                 passWordInfo:(NSString *)passWordInfo
                  accountName:(NSString *)accountName
                   completion:(void(^)(BOOL suc, CCWalletError error))completion {
    NSString *accountID = [[NSString stringWithFormat:@"%@%@%@",privatekey,@(coinType),@(CCImportTypePrivateKey)] md5ForLower32Bate];
    if ([self accountWithAccountID:accountID]) {
        if (completion) {
            completion(NO,CCWalletErrorAddressRepeat);
        }
        return;
    }
    NSInteger sortId = [self nextCurrentID];
    if (!accountName) {
        accountName = [NSString stringWithFormat:@"Wallet-%@",@(sortId)];
    }
    
    @weakify(self)
    [CCAccountData accountWithAccountID:accountID sortID:sortId privateKey:privatekey walletType:walletType coinType:coinType passWord:passWord passWordInfo:passWordInfo accountName:accountName completion:^(CCAccountData *accountData, CCWalletError error) {
        @strongify(self)
        if (accountData) {
            [self addAccount:accountData withWalletInfo:privatekey passWord:passWord];
            if (completion) {
                completion(YES,CCWalletImportPrivateKeySuc);
            }
        } else {
            if (completion) {
                completion(NO,error);
            }
        }
    }];
}

/**
 wif
 */
- (void)accountWithWIF:(NSString *)wif
            walletType:(CCWalletType)walletType
              coinType:(CCCoinType)coinType
              passWord:(NSString *)passWord
          passWordInfo:(NSString *)passWordInfo
           accountName:(NSString *)accountName
            completion:(void(^)(BOOL suc, CCWalletError error))completion {
    NSString *accountID = [[NSString stringWithFormat:@"%@%@%@",wif,@(coinType),@(CCImportTypeWIF)] md5ForLower32Bate];
    if ([self accountWithAccountID:accountID]) {
        if (completion) {
            completion(NO,CCWalletErrorAddressRepeat);
        }
        return;
    }
    NSInteger sortId = [self nextCurrentID];
    if (!accountName) {
        accountName = [NSString stringWithFormat:@"Wallet-%@",@(sortId)];
    }
    @weakify(self)
    [CCAccountData accountWithAccountID:accountID sortID:sortId wif:wif walletType:walletType coinType:coinType passWord:passWord passWordInfo:passWordInfo accountName:accountName completion:^(CCAccountData *accountData, CCWalletError error) {
        @strongify(self)
        if (accountData) {
            [self addAccount:accountData withWalletInfo:wif passWord:passWord];
            if (completion) {
                completion(YES,CCWalletImportWIFSuc);
            }
        } else {
            if (completion) {
                completion(NO,error);
            }
        }
    }];
}

/**
 keystore
 */
- (void)accountWithKeystore:(NSString *)keystore
                 walletType:(CCWalletType)walletType
                   coinType:(CCCoinType)coinType
                   passWord:(NSString *)passWord
               passWordInfo:(NSString *)passWordInfo
                accountName:(NSString *)accountName
                 completion:(void(^)(BOOL suc, CCWalletError error))completion {
    NSString *accountID = [[NSString stringWithFormat:@"%@%@%@",keystore,@(coinType),@(CCImportTypeKeystore)] md5ForLower32Bate];
    if ([self accountWithAccountID:accountID]) {
        if (completion) {
            completion(NO,CCWalletErrorAddressRepeat);
        }
        return;
    }
    NSInteger sortId = [self nextCurrentID];
    if (!accountName) {
        accountName = [NSString stringWithFormat:@"Wallet-%@",@(sortId)];
    }
    @weakify(self)
    [CCAccountData accountWithAccountID:accountID sortID:sortId keystore:keystore walletType:walletType coinType:coinType passWord:passWord passWordInfo:passWordInfo accountName:accountName completion:^(CCAccountData *accountData, NSString *privatekey, CCWalletError error) {
        @strongify(self)
        if (accountData) {
            [self addAccount:accountData withWalletInfo:privatekey passWord:passWord];
            if (completion) {
                completion(YES,CCWalletImportWIFSuc);
            }
        } else {
            if (completion) {
                completion(NO,error);
            }
        }
    }];
}

//硬件导入
- (void)accountWithDeviceName:(NSString *)deviceName
                   addressDic:(NSDictionary *)addressDic
                   importType:(CCImportType)importType
                  accountName:(NSString *)accountName
                 passWordInfo:(NSString *)passWordInfo
                   completion:(void(^)(BOOL suc, CCWalletError error))completion {
    NSString *accountID = [[deviceName lowercaseString] md5ForLower32Bate];
    if ([self accountWithAccountID:accountID]) {
        if (completion) {
            completion(NO,CCWalletErrorAddressRepeat);
        }
        return;
    }

    NSInteger sortId = [self nextCurrentID];
    if (!accountName) {
        accountName = [NSString stringWithFormat:@"Wallet-%@",@(sortId)];
    }
    
    @weakify(self)
    [CCAccountData accountWithAccountID:accountID sortID:sortId deviceName:deviceName addressDic:addressDic importType:importType accountName:accountName passWordInfo:passWordInfo completion:^(CCAccountData *accountData, CCWalletError error) {
        @strongify(self)
        if (accountData) {
            [self addAccount:accountData withWalletInfo:deviceName];
            if (completion) {
                completion(YES,CCWalletImportMnemonicsSuc);
            }
        } else {
            if (completion) {
                completion(NO,CCWalletErrorMnemonicsValidPhrase);
            }
        }
    }];
}

- (NSString *)accountIDWithDeviceName:(NSString *)deviceName {
    NSString *accountID = [[deviceName lowercaseString] md5ForLower32Bate];
    return accountID;
}

#pragma mark - 存储账户的信息
- (void)saveWalletInfo:(NSString *)walletInfo
             accountID:(NSString *)accountID
              passWord:(NSString *)password {
    walletInfo = [CCCryptoTool encrypt:walletInfo password:password saltString:accountID];
    [SAMKeychain setPassword:walletInfo forService:CCWalletDataServiceName account:accountID];
}

- (void)saveWalletInfo:(NSString *)walletInfo
             accountID:(NSString *)accountID {
    [SAMKeychain setPassword:walletInfo forService:CCWalletDataServiceName account:accountID];
}

- (void)deleteWalletInfoAccountID:(NSString *)accountID
                         passWord:(NSString *)password {
    NSString *walletInfo = [SAMKeychain passwordForService:CCWalletDataServiceName account:accountID];
    if (walletInfo) {
        walletInfo = [CCCryptoTool decrypt:walletInfo password:password saltString:accountID];
        if (walletInfo) {
            [SAMKeychain deletePasswordForService:CCWalletDataServiceName account:accountID];
        }
    }
}


#pragma mark - 重置密码
- (void)resetPassWord:(NSString *)password
          oldPassWord:(NSString *)oldPassWord
            accountID:(NSString *)accountID
           completion:(void(^)(BOOL suc, CCWalletError error))completion {
    @weakify(self)
    [self walletInfoWithAccountID:accountID password:oldPassWord completion:^(NSString *walletInfo) {
        @strongify(self)
        if (walletInfo) {
            [self saveWalletInfo:walletInfo accountID:accountID passWord:password];
            if (completion) {
                completion(YES,CCWalletChangePasswordSuc);
            }
        } else {
            if (completion) {
                completion(NO,CCWalletErrorPWD);
            }
        }
    }];
}

#pragma mark - 获取用户的存储信息
- (void)walletInfoWithAccountID:(NSString *)accountID
                             password:(NSString *)password
                           completion:(void(^)(NSString *walletInfo))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *walletInfo = [SAMKeychain passwordForService:CCWalletDataServiceName account:accountID];
        if (walletInfo) {
            walletInfo = [CCCryptoTool decrypt:walletInfo password:password saltString:accountID];
        }
        if (completion) {
            completion(walletInfo);
        }
    });
}

- (NSString *)walletInfoWithAccountID:(NSString *)accountID {
    NSString *walletInfo = [SAMKeychain passwordForService:CCWalletDataServiceName account:accountID];
    return walletInfo;
}

#pragma mark - 是否有账户
- (BOOL)hadAccount {
    return self.accounts.count;
}


#pragma mark - get
- (NSMutableArray<CCAccountData *> *)accounts {
    if (!_accounts) {
        _accounts = [NSMutableArray array];
        NSArray *accounts = [[CCCoreData coreData] requestAllAccounts];
        
        CCAccountData *activeAccount;

        for (CCAccount *account in accounts) {
            CCAccountData *accountData = [[CCAccountData alloc] initWithAccount:account];
            NSString *walletInfo = [self walletInfoWithAccountID:account.accountID];
            if (!walletInfo) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [self deleteAccount:accountData completion:nil];
                });
                continue;
            }
            [_accounts addObject:accountData];
            if (account.isSelected) {
                activeAccount = accountData;
            }
        }
        
        if (!activeAccount && _accounts.count) {
            activeAccount = _accounts.firstObject;
        }
        
        self.activeAccount = activeAccount;
    }
    return _accounts;
}


#pragma mark - 钱包刷新定时器
- (void)addUpdateWalletTimer {
    if (_updateWalletTimer) {
        return;
    }
    _updateWalletTimer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(updateWalletAction) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_updateWalletTimer forMode:NSRunLoopCommonModes];
}

- (void)removeUpdateWalletTimer {
    if (!_updateWalletTimer) {
        return;
    }
    [_updateWalletTimer invalidate];
    _updateWalletTimer = nil;
}

- (void)updateWalletAction {
    self.timeCount = self.timeCount%100;
    
    //请求块高
    if (self.timeCount % 15 == 0) {
        @weakify(self)
        [CCETHApi getETHBlockNumCompletion:^(NSInteger blockHeight) {
            @strongify(self)
            [self saveBlockTypeWithType:CCCoinTypeETH blockHeight:blockHeight];
        }];
    }
    //请求gasPrice
    if (self.timeCount % 55 == 0) {
        @weakify(self)
        [CCETHApi getETHGasPriceCompletion:^(NSString *gasPrice) {
            @strongify(self)
            [self saveGasPriceWithType:CCCoinTypeETH gasPrice:gasPrice];
        }];
    }
    //刷新记录
    [[CCETHMonitor monitor] updateWithTimerCount:self.timeCount];
    [[CCNEOMonitor monitor] updateWithTimerCount:self.timeCount];
    [[CCONTMonitor monitor] updateWithTimerCount:self.timeCount];

    self.timeCount += 1;
}

#pragma mark - 块高
- (NSInteger)blockHeightWithType:(CCCoinType)coinType {
    NSString *blockKey = [self blockHeightKeyWithCoinType:coinType];
    return [[NSUserDefaults standardUserDefaults] integerForKey:blockKey];
}

- (void)saveBlockTypeWithType:(CCCoinType)coinType blockHeight:(NSInteger)blockHeight {
    NSInteger oldHeight = [self blockHeightWithType:coinType];
    if (blockHeight <= oldHeight) {
        return;
    }
    [CCNotificationCenter postBlockHeightRefrshWithCoinType:coinType];
    [[NSUserDefaults standardUserDefaults] setInteger:blockHeight forKey:[self blockHeightKeyWithCoinType:coinType]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)blockHeightKeyWithCoinType:(CCCoinType)coinType {
    return [NSString stringWithFormat:@"%@_BlockHeight",[CCDataManager coinKeyWithType:coinType]];
}

#pragma mark - gasPrice
- (NSString *)gasPriceWithType:(CCCoinType)coinType {
    NSString *blockKey = [self gasPriceKeyWithCoinType:coinType];
    NSString *gasPrice = [[NSUserDefaults standardUserDefaults] stringForKey:blockKey];
    if (coinType == CCCoinTypeETH) {
        gasPrice = gasPrice?:@"9900000000";
    }
    return gasPrice;
}

- (void)saveGasPriceWithType:(CCCoinType)coinType gasPrice:(NSString *)gasPrice {
    if (coinType == CCCoinTypeETH) {
        gasPrice = gasPrice?:@"9900000000";
    }
    [[NSUserDefaults standardUserDefaults] setObject:gasPrice forKey:[self gasPriceKeyWithCoinType:coinType]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)gasPriceKeyWithCoinType:(CCCoinType)coinType {
    return [NSString stringWithFormat:@"%@_GasPrice",[CCDataManager coinKeyWithType:coinType]];
}

#pragma mark - 链名称
+ (NSString *)coinNameWithType:(CCCoinType)type {
    switch (type) {
        case CCCoinTypeETH:
            return @"Ethereum";
            break;
        case CCCoinTypeNEO:
            return @"NEO";
            break;
        case CCCoinTypeONT:
            return @"Ontology";
            break;
        default:
            break;
    }
    return nil;
}

#pragma mark - coinType转key
+ (NSString *)coinKeyWithType:(CCCoinType)type {
    switch (type) {
        case CCCoinTypeETH:
            return @"ETH";
            break;
        case CCCoinTypeNEO:
            return @"NEO";
            break;
        case CCCoinTypeONT:
            return @"ONT";
            break;
        default:
            break;
    }
    return nil;
}

+ (CCCoinType)coinTypeWithKey:(NSString *)key {
    if ([key isEqualToString:@"ETH"]) {
        return CCCoinTypeETH;
    } else if ([key isEqualToString:@"NEO"]) {
        return CCCoinTypeNEO;
    } else if ([key isEqualToString:@"ONT"]) {
        return CCCoinTypeONT;
    }
    return CCCoinTypeNone;
}

#pragma mark - 链图标
+ (NSString *)coinIconWithType:(CCCoinType)type {
    switch (type) {
        case CCCoinTypeETH:
            return @"cc_asset_eth";
            break;
        case CCCoinTypeNEO:
            return @"cc_asset_neo";
            break;
        case CCCoinTypeONT:
            return @"cc_asset_ont";
            break;
        default:
            break;
    }
    return nil;
}

@end
