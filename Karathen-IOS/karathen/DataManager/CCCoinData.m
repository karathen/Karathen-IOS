//
//  CCCoinData.m
//  Karathen
//
//  Created by Karathen on 2018/8/27.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCCoinData.h"
#import "CCCoreData+Wallet.h"
#import "CCRandomHelp.h"
#import "CCCoreData+Asset.h"
#import "CCCoreData+TradeRecord.h"


@interface CCCoinData ()

///当前链下的所有钱包
@property (nonatomic, strong) NSMutableArray <CCWalletData *> *wallets;
//当前选中的钱包
@property (nonatomic, weak) CCWalletData *activeWallet;

@end

@implementation CCCoinData

- (instancetype)initWithCoin:(CCCoin *)coin {
    if (self = [super init]) {
        self.coin = coin;
    }
    return self;
}

- (CCAccountData *)accountData {
    return [[CCDataManager dataManager] accountWithAccountID:self.coin.accountID];
}

- (CCImportType)importType {
    return self.accountData.account.importType;
}

- (CCWalletData *)activeWallet {
    if (!_activeWallet) {
        [self wallets];
    }
    return _activeWallet;
}

#pragma mark - 初次创建账户
//助记词
- (void)createWalletWithMnemonic:(NSString *)mnemonic
                      importType:(CCImportType)importType
                      completion:(void(^)(BOOL suc,CCWalletError error))completion {
    mnemonic = [mnemonic deleteSpace];
    NSString *address = [self createWalletByCoinTypeWithMnemonic:mnemonic slot:0];
    NSString *walletName = [NSString stringWithFormat:@"%@-1",[CCDataManager coinKeyWithType:self.coin.coinType]];
    [self saveWalletWithAddress:address walletName:walletName importType:importType slot:0 completion:completion];
}

//私钥
- (void)createWalletWithPrivateKey:(NSString *)privateKey
                        completion:(void(^)(BOOL suc,CCWalletError error))completion {
    privateKey = [privateKey deleteSpace];
    NSString *address = [self createWalletByCoinTypeWithPrivateKey:privateKey];
    NSString *walletName = [NSString stringWithFormat:@"%@-1",[CCDataManager coinKeyWithType:self.coin.coinType]];
    [self saveWalletWithAddress:address walletName:walletName importType:CCImportTypePrivateKey slot:0 completion:completion];
}

//wif
- (void)createWalletWithWIF:(NSString *)wif
                 completion:(void(^)(BOOL suc,CCWalletError error))completion {
    wif = [wif deleteSpace];
    NSString *address = [self createWalletByCoinTypeWithWIF:wif];
    NSString *walletName = [NSString stringWithFormat:@"%@-1",[CCDataManager coinKeyWithType:self.coin.coinType]];
    [self saveWalletWithAddress:address walletName:walletName importType:CCImportTypeWIF slot:0 completion:completion];
}

//keystore
- (void)createWalletWithKeyStore:(NSString *)keystore
                        passWord:(NSString *)password
                      completion:(void(^)(BOOL suc,CCWalletError error,NSString *privatekey))completion {
    @weakify(self)
    [CCWalletManager createETHAddressWithKeystore:keystore password:password completion:^(BOOL suc, CCWalletError error, NSString *privatekey, NSString *address) {
        @strongify(self)
        if (suc) {
            NSString *walletName = [NSString stringWithFormat:@"%@-1",[CCDataManager coinKeyWithType:self.coin.coinType]];
            [self saveWalletWithAddress:address walletName:walletName importType:CCImportTypeWIF slot:0 completion:^(BOOL suc, CCWalletError error) {
                if (suc) {
                    completion(suc,error,privatekey);
                } else {
                    completion(suc,error,nil);
                }
            }];
        } else {
            completion(suc,error,nil);
        }
    }];
}

#pragma mark - HD钱包创建地址
- (void)createHDAddressWithWalletName:(NSString *)walletName
                             passWord:(NSString *)passWord
                           importType:(CCImportType)importType
                           completion:(void(^)(BOOL suc,CCWalletError error))completion {
    @weakify(self)
    [[CCDataManager dataManager] walletInfoWithAccountID:self.coin.accountID password:passWord completion:^(NSString *walletInfo) {
        @strongify(self)
        if (!walletInfo) {
            if (completion) {
                completion(NO,CCWalletErrorPWD);
            }
            return;
        }
        int slot = 0;
        if (self.wallets.count > 0) {
            CCWalletData *walletData = self.wallets.lastObject;
            slot = walletData.wallet.slot+1;
        }
        walletInfo = [walletInfo deleteSpace];
        
        NSString *address = [self createWalletByCoinTypeWithMnemonic:walletInfo slot:slot];
        [self saveWalletWithAddress:address walletName:walletName importType:importType slot:slot completion:completion];
    }];

}


#pragma mark - 存储钱包
- (void)saveWalletWithAddress:(NSString *)address
                   walletName:(NSString *)walletName
                   importType:(CCImportType)importType
                         slot:(int)slot
                   completion:(void(^)(BOOL suc,CCWalletError error))completion {
    CCWalletError walletError = CCWalletErrorMnemonicsValidPhrase;
    if (!address) {
        switch (importType) {
            case CCImportTypeSeed:
            case CCImportTypeMnemonic:
                walletError = CCWalletErrorMnemonicsValidPhrase;
                break;
            case CCImportTypePrivateKey:
                walletError = CCWalletImportPrivateKeyValidPhrase;
                break;
            case CCImportTypeWIF:
                walletError = CCWalletImportWIFValidPhrase;
                break;
            case CCImportTypeKeystore:
                walletError = CCWalletErrorKeyStoreValid;
                break;
            default:
                break;
        }
        if (completion) {
            completion(NO,walletError);
        }
        return;
    }

    NSInteger walletId = 1 + slot;

    //默认钱包名
    if (walletName.length == 0) {
        walletName = [NSString stringWithFormat:@"%@-%ld",[CCDataManager coinKeyWithType:self.coin.coinType],walletId];
    }
    NSInteger iconId = [CCRandomHelp randomIntegerBetween:0 and:100];
    
    //构造钱包的存储信息
    NSDictionary *walletDic = @{
                                @"address":address,
                                @"balance":@"0",
                                @"coinType":@(self.coin.coinType),
                                @"walletName":walletName,
                                @"isSelected":@(slot==0),
                                @"slot":@(slot),
                                @"iconId":@(iconId),
                                };
    CCWallet *wallet = [[CCCoreData coreData] saveWalletWithWallet:walletDic walletId:walletId accountID:self.coin.accountID completion:nil];
    CCWalletData *walletData = [CCWalletData walletDataWithWallet:wallet];
    if (!_wallets) {
        _wallets = [NSMutableArray array];
    }
    [_wallets addObject:walletData];
    if (slot == 0) {
        self.activeWallet = walletData;
    }
    
    switch (importType) {
        case CCImportTypeSeed:
        case CCImportTypeMnemonic:
            walletError = CCWalletImportMnemonicsSuc;
            break;
        case CCImportTypePrivateKey:
            walletError = CCWalletImportPrivateKeySuc;
            break;
        case CCImportTypeWIF:
            walletError = CCWalletImportWIFSuc;
            break;
        case CCImportTypeKeystore:
            walletError = CCWalletImportKeyStoreSuc;
            break;
        default:
            break;
    }
    if (completion) {
        completion(YES, walletError);
    }
    //保存
    [CCNotificationCenter postWalletAddressChange:self.coin.coinType];
}

#pragma mark - 助记词生成地址
- (NSString *)createWalletByCoinTypeWithMnemonic:(NSString *)mnemonic slot:(int)slot {
    mnemonic = [mnemonic deleteSpace];
    switch (self.coin.coinType) {
        case CCCoinTypeETH:
            return [CCWalletManager createETHAddressWithMnemonics:mnemonic slot:slot];
            break;
        case CCCoinTypeNEO:
            return [CCWalletManager createNEOAddressWithMnemonics:mnemonic slot:slot];
            break;
        case CCCoinTypeONT:
            return [CCWalletManager createONTAddressWithMnemonics:mnemonic slot:slot];
            break;
        default:
            break;
    }
    return nil;
}

#pragma mark - 私钥生成地址
- (NSString *)createWalletByCoinTypeWithPrivateKey:(NSString *)privateKey {
    privateKey = [privateKey deleteSpace];
    switch (self.coin.coinType) {
        case CCCoinTypeETH:
            return [CCWalletManager createETHAddressWithPrivateKey:privateKey];
            break;
        case CCCoinTypeNEO:
            return [CCWalletManager createNEOAddressWithPrivateKey:privateKey];
            break;
        case CCCoinTypeONT:
            return [CCWalletManager createONTAddressWithPrivateKey:privateKey];
            break;
        default:
            break;
    }
    return nil;
}

#pragma mark - WIF生成地址
- (NSString *)createWalletByCoinTypeWithWIF:(NSString *)wif {
    wif = [wif deleteSpace];
    switch (self.coin.coinType) {
        case CCCoinTypeNEO:
            return [CCWalletManager createNEOAddressWithWIF:wif];
            break;
        case CCCoinTypeONT:
            return [CCWalletManager createONTAddressWithWIF:wif];
            break;
        default:
            break;
    }
    return nil;
}


#pragma mark - 修改默认地址
- (void)changeActiveWallet:(CCWalletData *)walletData {
    if ([self.activeWallet.address compareWithString:walletData.address]) {
        return;
    }
    //修改
    self.activeWallet.wallet.isSelected = NO;
    walletData.wallet.isSelected = YES;
    [[CCCoreData coreData] saveDataCompletion:nil];
    //变更
    self.activeWallet = walletData;
    //发送通知
    [CCNotificationCenter postSelectWalletChange:self.coin.coinType accountID:self.coin.accountID];
}

#pragma mark - 默认新创建的名字
- (NSString *)createWalletName {
    NSInteger walletId = self.wallets.count + 1;
    return [NSString stringWithFormat:@"%@-%ld",[CCDataManager coinKeyWithType:self.coin.coinType],walletId];

}

#pragma mark - 地址得到钱包
- (CCWalletData *)walletDataWithAddress:(NSString *)address {
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"address CONTAINS[cd] %@",address];
    NSArray *result = [self.wallets filteredArrayUsingPredicate:pre];
    return result.firstObject;
}

#pragma mark - get
- (NSMutableArray<CCWalletData *> *)wallets {
    if (!_wallets) {
        _wallets = [NSMutableArray array];
        NSArray *requsetArray = [[CCCoreData coreData] requestWalletsWithCoinType:self.coin.coinType accountID:self.coin.accountID];
        CCWalletData *activeWallet;
        for (CCWallet *wallet in requsetArray) {
            CCWalletData *walletData = [CCWalletData walletDataWithWallet:wallet];
            if (wallet.isSelected) {
                activeWallet = walletData;
            }
            [_wallets addObject:walletData];
        }
        if (!activeWallet && _wallets.count) {
            activeWallet = _wallets.firstObject;
        }
        self.activeWallet = activeWallet;
    }
    return _wallets;
}


@end
