//
//  CCWalletData.m
//  Karathen
//
//  Created by Karathen on 2018/7/19.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCWalletData.h"
#import "CCCoreData+Wallet.h"
#import "CCCoreData+Asset.h"
#import "CCCoreData+TradeRecord.h"
#import "CCTokenInfoRequest.h"
#import "CCWalletData+ETH.h"
#import "CCWalletData+NEO.h"
#import "CCWalletData+ONT.h"
#import "ONTAddress.h"

@interface CCWalletData ()

@property (nonatomic, strong) CCWallet *wallet;

@end

@implementation CCWalletData

+ (CCWalletData *)walletDataWithWallet:(CCWallet *)wallet {
    CCWalletData *data = [[CCWalletData alloc] init];
    data.wallet = wallet;
    return data;
}

#pragma mark - get
- (NSString *)address {
    return self.wallet.address;
}

- (NSString *)walletName {
    return self.wallet.walletName;
}

- (CCCoinType)type {
    return self.wallet.coinType;
}

- (NSString *)balance {
    return self.wallet.balance?:@"0";
}

- (CCAccountData *)accountData {
    return [[CCDataManager dataManager] accountWithAccountID:self.wallet.accountID];
}

- (CCImportType)importType {
    return self.accountData.account.importType;
}

- (BOOL)isSelected {
    return self.wallet.isSelected;
}

#pragma mark - 导出WIF
- (void)exportWIF:(NSString *)passWord
       completion:(void(^)(BOOL suc,NSString *wif,CCWalletError error))completion {
    @weakify(self)
    [[CCDataManager dataManager] walletInfoWithAccountID:self.wallet.accountID password:passWord completion:^(NSString *walletInfo) {
        @strongify(self)
        if (!walletInfo) {
            if (completion) {
                completion(NO,nil,CCWalletErrorPWD);
            }
            return;
        }
        switch (self.importType) {
            case CCImportTypeSeed:
            case CCImportTypeMnemonic:
            {
                int slot = self.wallet.slot;
                NSString *wif = [self exportWIFByMnemonic:walletInfo slot:slot];
                if (completion) {
                    completion(YES,wif,CCWalletExportWIFSuc);
                }
            }
                break;
            case CCImportTypeWIF:
            {
                if (completion) {
                    completion(YES,walletInfo,CCWalletExportWIFSuc);
                }
            }
                break;
            case CCImportTypePrivateKey:
            {
                NSString *wif = [self exportWIFByPrivatekey:walletInfo];
                if (completion) {
                    completion(YES,wif,CCWalletExportWIFSuc);
                }
            }
                break;
            default:
                break;
        }
    }];
}


#pragma mark - 导出私钥
- (void)exportPrivateKey:(NSString *)passWord
                    completion:(void(^)(BOOL suc,NSString *privateKey,CCWalletError error))completion {
    @weakify(self)
    [[CCDataManager dataManager] walletInfoWithAccountID:self.wallet.accountID password:passWord completion:^(NSString *walletInfo) {
        @strongify(self)
        if (!walletInfo) {
            if (completion) {
                completion(NO,nil,CCWalletErrorPWD);
            }
            return;
        }
        switch (self.importType) {
            case CCImportTypeSeed:
            case CCImportTypeMnemonic:
            {
                int slot = self.wallet.slot;
                NSString *privateKey = [self exportPrivateKeyByMnemonic:walletInfo slot:slot];
                if (completion) {
                    completion(YES,privateKey,CCWalletExportPrivateKeySuc);
                }
            }
                break;
            case CCImportTypePrivateKey:
            {
                if (completion) {
                    completion(YES,walletInfo,CCWalletExportPrivateKeySuc);
                }
            }
                break;
            case CCImportTypeWIF:
            {
                NSString *privateKey = [self exportPrivateKeyByWIF:walletInfo];
                if (completion) {
                    completion(YES,privateKey,CCWalletExportPrivateKeySuc);
                }
            }
                break;
            case CCImportTypeKeystore:
            {
                if (completion) {
                    completion(YES,walletInfo,CCWalletExportPrivateKeySuc);
                }
            }
                break;
            default:
                break;
        }
    }];
}

#pragma mark - 导出Keystore
- (void)exportKeystore:(NSString *)passWord
            completion:(void(^)(BOOL suc,NSString *keystore,CCWalletError error))completion {
    @weakify(self)
    [[CCDataManager dataManager] walletInfoWithAccountID:self.wallet.accountID password:passWord completion:^(NSString *walletInfo) {
        @strongify(self)
        if (!walletInfo) {
            if (completion) {
                completion(NO,nil,CCWalletErrorPWD);
            }
            return;
        }
        switch (self.importType) {
            case CCImportTypeSeed:
            case CCImportTypeMnemonic:
            {
                int slot = self.wallet.slot;
                [self exportKeystoreByMnemonic:walletInfo slot:slot password:passWord completion:^(BOOL suc, CCWalletError error, NSString *keystore) {
                    if (completion) {
                        completion(suc,keystore,error);
                    }
                }];
            }
                break;
            case CCImportTypePrivateKey:
            case CCImportTypeKeystore:
            {
                [self exportKeystoreByPrivatekey:walletInfo password:passWord completion:^(BOOL suc, CCWalletError error, NSString *keystore) {
                    if (completion) {
                        completion(suc,keystore,error);
                    }
                }];
            }
                break;
            default:
                break;
        }
    }];
}

- (NSString *)exportPrivateKeyByMnemonic:(NSString *)mnemonic slot:(int)slot {
    switch (self.type) {
        case CCCoinTypeETH:
            return [CCWalletManager exportETHPrivateKeyWithMnemonics:mnemonic slot:slot];
            break;
        case CCCoinTypeNEO:
            return [CCWalletManager exportNEOPrivateKeyWithMnemonics:mnemonic slot:slot];
            break;
        case CCCoinTypeONT:
            return [CCWalletManager exportONTPrivateKeyWithMnemonics:mnemonic slot:slot];
            break;
        default:
            break;
    }
    return nil;
}

- (NSString *)exportWIFByMnemonic:(NSString *)mnemonic slot:(int)slot {
    switch (self.type) {
        case CCCoinTypeNEO:
            return [CCWalletManager exportNEOWIFWithMnemonics:mnemonic slot:slot];
            break;
        case CCCoinTypeONT:
            return [CCWalletManager exportONTWIFWithMnemonics:mnemonic slot:slot];
            break;
        default:
            break;
    }
    return nil;
}

- (void)exportKeystoreByMnemonic:(NSString *)mnemonic slot:(int)slot password:(NSString *)password completion:(void(^)(BOOL suc, CCWalletError error,NSString *keystore))completion {
    switch (self.type) {
        case CCCoinTypeETH:
            [CCWalletManager exportETHKeystoreWithMnemonics:mnemonic slot:slot password:password completion:completion];
            break;
        default:
            break;
    }
}

- (void)exportKeystoreByPrivatekey:(NSString *)privateKey
                                password:(NSString *)password
                              completion:(void(^)(BOOL suc, CCWalletError error,NSString *keystore))completion {
    switch (self.type) {
        case CCCoinTypeETH:
            [CCWalletManager exportETHKeystoreWithPrivatekey:privateKey password:password completion:completion];
            break;
        default:
            break;
    }
}


- (NSString *)exportWIFByPrivatekey:(NSString *)privateKey {
    switch (self.type) {
        case CCCoinTypeNEO:
            return [CCWalletManager exportNEOWIFWithPrivateKey:privateKey];
            break;
        case CCCoinTypeONT:
            return [CCWalletManager exportONTWIFWithPrivateKey:privateKey];
            break;
        default:
            break;
    }
    return nil;
}

- (void)exportPrivatekeyByKeystore:(NSString *)keystore
                          password:(NSString *)password
                        completion:(void(^)(BOOL suc, CCWalletError error,NSString *privatekey))completion {
    switch (self.type) {
        case CCCoinTypeETH:
        {
            [CCWalletManager createETHAddressWithKeystore:keystore password:password completion:^(BOOL suc, CCWalletError error, NSString *privatekey, NSString *address) {
                if (completion) {
                    if (suc) {
                        completion(suc,error,privatekey);
                    } else {
                        completion(suc,error,nil);
                    }
                }
            }];
        }
            break;
        default:
            break;
    }
}

- (NSString *)exportPrivateKeyByWIF:(NSString *)wif {
    switch (self.type) {
        case CCCoinTypeNEO:
            return [CCWalletManager exportNEOPrivateKeyWithWIF:wif];
            break;
        case CCCoinTypeONT:
            return [CCWalletManager exportONTPrivateKeyWithWIF:wif];
            break;
        default:
            break;
    }
    return nil;
}




#pragma mark - 导出助记词
- (void)exportMnemonic:(NSString *)passWord
                  completion:(void(^)(BOOL suc,NSString *mnemonic,CCWalletError error))completion {
    if (self.importType == CCImportTypeMnemonic || self.importType == CCImportTypeSeed) {
        [[CCDataManager dataManager] walletInfoWithAccountID:self.wallet.accountID password:passWord completion:^(NSString *walletInfo) {
            if (!walletInfo) {
                if (completion) {
                    completion(NO,nil,CCWalletErrorPWD);
                }
                return;
            }
            if (completion) {
                completion(YES,walletInfo,CCWalletExportMnemonicSuc);
            }
        }];
    }
}

#pragma mark - 更改筛选条件
- (void)changeFilterType:(NSString *)type {
    self.wallet.filterType = type;
    [[CCCoreData coreData] saveDataCompletion:nil];
    [CCNotificationCenter postWalletFilterChange:self.address];
}

- (void)changeHideNoBalance:(BOOL)hideNoBalance {
    self.wallet.isHideNoBalance = hideNoBalance;
    [[CCCoreData coreData] saveDataCompletion:nil];
    [CCNotificationCenter postWalletHideNoBalanceChange:self.address];
}

#pragma mark - 查询钱包余额&价格
- (void)queryAssetBalanceCompletion:(void(^)(void))completion {
    switch (self.type) {
        case CCCoinTypeETH:
        {
            [self queryETHBalancePriceCompletion:completion];
        }
            break;
        case CCCoinTypeNEO:
        {
            [self queryNEOBalancePriceCompletion:completion];
        }
            break;
        case CCCoinTypeONT:
        {
            [self queryONTBalancePriceCompletion:completion];
        }
            break;
        default:
            break;
    }
}

- (void)queryBalanceWithAsset:(NSArray *)assets completion:(void(^)(void))completion {
    switch (self.type) {
        case CCCoinTypeETH:
        {
            [self queryETHAssets:assets priceCompletion:nil balanceCompletion:nil endCompletion:completion];
        }
            break;
        case CCCoinTypeNEO:
        {
            [self queryNEOAssets:assets priceCompletion:nil balanceCompletion:nil endCompletion:completion];
        }
            break;
        case CCCoinTypeONT:
        {
            [self queryONTAssets:assets priceCompletion:nil balanceCompletion:nil endCompletion:completion];
        }
            break;
        default:
            break;
    }
}


#pragma mark - 查询钱包下有余额的资产
- (void)queryAssetHoldingCompletion:(void(^)(void))completion noContain:(void(^)(NSArray <CCAsset *> *assets))noContain {
    switch (self.type) {
        case CCCoinTypeETH:
        {
            [self queryETHAssetHoldingCompletion:completion noContain:noContain];
        }
            break;
        case CCCoinTypeNEO:
        {
            [self queryNEOAssetHoldingCompletion:completion noContain:noContain];
        }
            break;
        case CCCoinTypeONT:
        {
            completion();
            noContain(self.assets);
        }
            break;
        default:
            break;
    }
}

#pragma mark - 查询单个
- (void)queryAssetBalance:(CCAsset *)asset completion:(void(^)(void))completion {
    switch (self.type) {
        case CCCoinTypeETH:
        {
            [self queryETHBalancePriceAsset:asset completion:completion];
        }
            break;
        case CCCoinTypeNEO:
        {
            [self queryNEOBalancePriceAsset:asset completion:completion];
        }
            break;
        case CCCoinTypeONT:
        {
            [self queryONTBalancePriceAsset:asset completion:completion];
        }
            break;
        default:
            break;
    }
}

#pragma mark - 切换币种单位
- (void)changeCurrencyUnit {
    NSDecimalNumber *allBalance = [NSDecimalNumber decimalNumberWithString:@"0"];
    for (CCAsset *asset in self.assets) {
        NSDecimalNumber *priceNumber;
        if ([[CCCurrencyUnit currentCurrencyUnit] isEqualToString:CCCurrencyUnitCNY]) {
            priceNumber = [NSDecimalNumber decimalNumberWithString:asset.price?:@"0"];
        } else {
            priceNumber = [NSDecimalNumber decimalNumberWithString:asset.priceUSD?:@"0"];
        }
        
        NSDecimalNumber *balance = [NSDecimalNumber decimalNumberWithString:asset.balance?:@"0"];
        NSDecimalNumber *priceNum = [priceNumber decimalNumberByMultiplyingBy:balance];
        allBalance = [allBalance decimalNumberByAdding:priceNum];;
    }
    
    NSString *balance = allBalance.stringValue;
    [self changeWalletBalance:balance];
}

#pragma mark - 钱包的地址的区块浏览器地址
- (NSString *)addressExplorer {
    switch (self.type) {
        case CCCoinTypeETH:
        {
            return [self addressETHExplorer];
        }
            break;
        case CCCoinTypeNEO:
        {
            return [self addressNEOExplorer];
        }
            break;
        case CCCoinTypeONT:
        {
            return [self addressONTExplorer];
        }
            break;
        default:
            break;
    }
    return nil;
}


#pragma mark - 交易记录详情Url
- (NSString *)tradeDetailUrlWithTxId:(NSString *)txId {
    switch (self.type) {
        case CCCoinTypeETH:
        {
            return [self ethTradeDetailUrlWithTxId:txId];
        }
            break;
        case CCCoinTypeNEO:
        {
            return [self neoTradeDetailUrlWithTxId:txId];
        }
            break;
        case CCCoinTypeONT:
        {
            return [self ontTradeDetailUrlWithTxId:txId];
        }
            break;
        default:
            break;
    }
    return nil;
}

#pragma mark - 删除资产
- (void)deleteAsset:(CCAsset *)asset {
    NSString *tokenAddress = asset.tokenAddress;

    asset.isDelete = YES;
    [self.assets removeObject:asset];
    
    //删除交易记录
    [[CCCoreData coreData] deleteTradeRecordWalletAddress:self.address tokenAddress:tokenAddress coinType:self.type accountID:self.wallet.accountID completion:nil];
    //重新计算
    [self calculateBalance];
    //通知
    [CCNotificationCenter postAssetChangeWithWalletAddress:self.address];
}


#pragma mark - 添加资产
- (void)addAsset:(CCTokenInfoModel *)asset {
    if (!asset) {
        return;
    }
    if (!asset.tokenDecimal || !asset.tokenSynbol) {
        return;
    }
    asset.tokenType = asset.tokenType?:CCAseet_ETH_ERC20;
    //最后一个
    CCAsset *lasetAsset = self.assets.lastObject;
    //
    NSMutableDictionary *assetDic = [asset.mj_keyValues mutableCopy];
    
    [assetDic setValue:@(lasetAsset.asset_id+1) forKey:@"asset_id"];
    [assetDic setValue:@(self.type) forKey:@"coinType"];

    CCAsset *resAsset = [[CCCoreData coreData] saveAssetWithAsset:assetDic walletAddress:self.wallet.address coinType:self.type accountID:self.wallet.accountID completion:nil];
    [self.assets addObject:resAsset];
    
    @weakify(self)
    [self queryAssetBalance:resAsset completion:^{
        @strongify(self)
        [CCNotificationCenter postWalletBalanceChangeWithWalletAddress:self.address];
    }];

    //通知
    [CCNotificationCenter postAssetChangeWithWalletAddress:self.address];
}

- (void)addAssetArray:(NSArray <CCTokenInfoModel *> *)assets
           noContains:(void(^)(NSArray <CCAsset *>*))noContains
           completion:(void(^)(void))completion {
    if (assets.count == 0) {
        //返回没有在其中包含的资产
        if (noContains) {
            noContains(self.assets);
        }
        return;
    }
    //最后一个
    CCAsset *lasetAsset = self.assets.lastObject;
    NSInteger assetId = lasetAsset.asset_id;
    
    NSMutableArray *allAssets = [self.assets mutableCopy];
    
    NSMutableDictionary *assetsDic = [NSMutableDictionary dictionary];
    for (CCTokenInfoModel *assetInfo in assets) {
        if (!assetInfo.tokenSynbol) {
            continue;
        }
        CCAsset *asset = [self assetWithToken:assetInfo.tokenAddress];
        if (asset) {
            [allAssets removeObject:asset];
        }
        
        assetInfo.tokenType = assetInfo.tokenType?:CCAseet_ETH_ERC20;
        assetId += 1;
        NSMutableDictionary *assetDic = [assetInfo.mj_keyValues mutableCopy];
        [assetDic setValue:@(assetId) forKey:@"asset_id"];
        [assetDic setValue:@(self.type) forKey:@"coinType"];
        if (!assetInfo.tokenIcon || assetInfo.tokenIcon.length == 0) {
            if (asset.tokenIcon && asset.tokenIcon.length != 0) {
                [assetDic setValue:asset.tokenIcon forKey:@"tokenIcon"];
            } else if (asset.isDefault && self.wallet.coinType == CCCoinTypeETH) {//这个是为了替换现在eth图标不正确添加的
                [assetDic setValue:@"cc_asset_eth" forKey:@"tokenIcon"];
            }
        }
        NSString *balanceString = [NSString valueString:assetDic[@"balance"]?:@"0" decimal:assetInfo.tokenDecimal];
        [assetDic setValue:balanceString forKey:@"balance"];
        [assetsDic setValue:assetDic forKey:assetInfo.tokenAddress];
        
    }
    
    //返回没有在其中包含的资产
    if (noContains) {
        noContains(allAssets);
    }

    NSArray *assetArray = [[CCCoreData coreData] saveAssetWithAssets:assetsDic walletAddress:self.address coinType:self.type accountID:self.wallet.accountID completion:^(BOOL suc, NSError *error) {
        if (completion) {
            completion();
        }
    }];
    self.assets = [assetArray mutableCopy];
    
    @weakify(self)
    [self queryAssetBalanceCompletion:^{
        @strongify(self)
        [CCNotificationCenter postWalletBalanceChangeWithWalletAddress:self.address];
    }];
    
    [self calculateBalance];
    
    //通知
    [CCNotificationCenter postAssetChangeWithWalletAddress:self.address];
}



//重新计算余额
- (void)calculateBalance {
    NSDecimalNumber *allBalance = [NSDecimalNumber decimalNumberWithString:@"0"];
    for (CCAsset *asset in self.assets) {
        //相乘
        NSDecimalNumber *priceNumber;
        if ([[CCCurrencyUnit currentCurrencyUnit] isEqualToString:CCCurrencyUnitCNY]) {
            priceNumber = [NSDecimalNumber decimalNumberWithString:asset.price?:@"0"];
        } else {
            priceNumber = [NSDecimalNumber decimalNumberWithString:asset.priceUSD?:@"0"];
        }
        
        NSDecimalNumber *balance = [NSDecimalNumber decimalNumberWithString:asset.balance?:@"0"];
        NSDecimalNumber *priceNum = [priceNumber decimalNumberByMultiplyingBy:balance];
        allBalance = [allBalance decimalNumberByAdding:priceNum];;
    }
    NSString *balance = allBalance.stringValue;
    
    [self changeWalletBalance:balance];
}


#pragma mark - 修改名称
- (void)changeWalletName:(NSString *)walletName {
    self.wallet.walletName = walletName;
    [[CCCoreData coreData] saveDataCompletion:nil];
    [CCNotificationCenter postWalletNameChangeWithWalletAddress:self.address];
}

#pragma mark - 修改余额
- (void)changeWalletBalance:(NSString *)balance {
    self.wallet.balance = balance;
    [[CCCoreData coreData] saveDataCompletion:nil];
    [CCNotificationCenter postWalletBalanceChangeWithWalletAddress:self.address];
}


#pragma mark - 自查是否被添加过
- (CCAsset *)hadAddAsset:(CCTokenInfoModel *)asset {
    return [self assetWithToken:asset.tokenAddress];
}

#pragma mark - 获取资产
- (CCAsset *)assetWithToken:(NSString *)token {
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"tokenAddress CONTAINS[cd] %@",token];
    NSArray *result = [self.assets filteredArrayUsingPredicate:pre];
    if (result.count > 0) {
        return result.firstObject;
    }
    return nil;
}

- (CCAsset *)assetWithSymbol:(NSString *)symbol {
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"tokenSynbol CONTAINS[cd] %@",symbol];
    NSArray *result = [self.assets filteredArrayUsingPredicate:pre];
    if (result.count > 0) {
        return result.firstObject;
    }
    return nil;
}

#pragma mark - 默认图标
- (NSString *)defaultIcon {
    switch (self.type) {
        case CCCoinTypeETH:
            return @"cc_asset_default";
            break;
        case CCCoinTypeNEO:
            return @"cc_neoasset_default";
            break;
        case CCCoinTypeONT:
            return @"cc_ontasset_default";
            break;
        default:
            break;
    }
    return nil;
}

#pragma mark - 对应资产加载对应图片
- (void)bindImageView:(UIImageView *)imageView asset:(CCAsset *)asset {
    NSString *defaultIcon = [self defaultIcon];
    if (asset.isDefault) {
        if (asset.tokenIcon.length) {
            [imageView setImage:[UIImage imageNamed:asset.tokenIcon]];
        } else {
            [imageView setImage:[UIImage imageNamed:defaultIcon]];
        }
    } else {
        [imageView sd_setImageWithURL:[NSURL URLWithString:asset.tokenIcon] placeholderImage:[UIImage imageNamed:defaultIcon]];
    }
}

#pragma mark - 提取的币种
- (NSString *)claimSymbol {
    NSString *symbol = @"";
    switch (self.type) {
        case CCCoinTypeNEO:
            symbol = @"GAS";
            break;
        case CCCoinTypeONT:
            symbol = @"ONG";
            break;
        default:
            break;
    }
    return symbol;
}

#pragma mark - 资产余额
+ (NSString *)balanceStringWithAsset:(CCAsset *)asset {
    NSDecimalNumber *balance = [NSDecimalNumber decimalNumberWithString:asset.balance?:@"0"];
    return [NSString formatDecimalNum:balance roundMode:NSRoundDown afterPoint:8];
}

#pragma mark - 计算价格
+ (NSString *)priceBalanceStringWithAsset:(CCAsset *)asset {
    NSDecimalNumber *priceNumber;
    if ([[CCCurrencyUnit currentCurrencyUnit] isEqualToString:CCCurrencyUnitCNY]) {
        priceNumber = [NSDecimalNumber decimalNumberWithString:asset.price?:@"0"];
    } else {
        priceNumber = [NSDecimalNumber decimalNumberWithString:asset.priceUSD?:@"0"];
    }
    NSDecimalNumber *balance = [NSDecimalNumber decimalNumberWithString:asset.balance?:@"0"];
    NSDecimalNumber *priceBalance = [balance decimalNumberByMultiplyingBy:priceNumber];
    return [NSString formatDecimalNum:priceBalance roundMode:NSRoundDown afterPoint:2];
}

#pragma mark - 检查地址是否符合规则
+ (BOOL)checkAddress:(NSString *)address coinType:(CCCoinType)coinType {
    address = [address deleteSpace];
    if ([address hasPrefix:@"0x"]) {
        address = [address substringFromIndex:2];
    }
    switch (coinType) {
        case CCCoinTypeETH:
        {
            if (address.length == 40) {
                Address *ethAddress = [Address addressWithString:address];
                if (ethAddress) {
                    return YES;
                } else {
                    return NO;
                }
            } else {
                return NO;
            }
        }
            break;
        case CCCoinTypeNEO:
        {
            if (address.length == 34) {
                ONTAddress *ontAddress = [[ONTAddress alloc] initWithAddressString:address];
                if (ontAddress) {
                    return YES;
                } else {
                    return NO;
                }
            } else {
                return NO;
            }
        }
            break;
        case CCCoinTypeONT:
        {
            if (address.length == 34) {
                ONTAddress *ontAddress = [[ONTAddress alloc] initWithAddressString:address];
                if (ontAddress) {
                    return YES;
                } else {
                    return NO;
                }
            } else {
                return NO;
            }
        }
            break;
        default:
            break;
    }
    return NO;
}

#pragma mark - 查询价格
- (void)queryPriceSynbols:(NSArray *)synbols completion:(void(^)(NSDictionary *result))completion {
    CCRequest *request = [[CCRequest alloc] init];
    request.parameter = @{
                          @"id":@"1",
                          @"method":@"getPrice_2",
                          @"jsonrpc":@"2.0",
                          @"params":@[synbols]
                          };
    [request startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        NSMutableDictionary *prices = [NSMutableDictionary dictionary];
        NSArray *array = request.responseObject[@"result"];
        for (NSDictionary *dic in array) {
            NSArray *price = dic[@"price"];
            NSString *symbol = dic[@"symbol"];
            if (price && symbol) {
                [prices setValue:price forKey:symbol];
            }
        }
        if (completion) {
            completion(prices);
        }
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        if (completion) {
            completion(nil);
        }
    }];

}


#pragma mark - 检验是否是CK猫
+ (BOOL)checkIsCryptoKittiesAsset:(CCAsset *)asset {
    return [asset.tokenAddress compareWithString:@"0x06012c8cf97bead5deae237070f9587f8e7a266d"];
}

#pragma mark - 检验交易记录是不是NEO或者NEO gas的
+ (BOOL)isNEOOrNEOGas:(NSString *)tokenAddress {
    return [tokenAddress compareWithString:@"0xc56f33fc6ecfcd0c225c4ab356fee59390af8560be0e930faebe74a6daff7c9b"] || [tokenAddress compareWithString:@"0x602c79718b16e442de58778e148d0b1084e3b2dffd5de6b7b16cee7969282de7"];
}

#pragma mark - get
- (NSMutableArray<CCAsset *> *)assets {
    if (!_assets) {
        _assets = [NSMutableArray array];
        
        //查询对应账户 钱包下的资产
        NSArray *assets = [[CCCoreData coreData] requestAssetWithWalletAddress:self.address coinType:self.type accountID:self.wallet.accountID];
        if (assets.count == 0) {
            //默认的资产
            NSDictionary *defaultAssets = [CCDefaultAsset simpleAssetWithCoinType:self.type];
            assets = [[CCCoreData coreData] saveAssetWithAssets:defaultAssets walletAddress:self.address coinType:self.type accountID:self.wallet.accountID completion:nil];
        }
        [_assets addObjectsFromArray:assets];
    }
    return _assets;
}

- (NSString *)balanceString {
    NSDecimalNumber *balance = [NSDecimalNumber decimalNumberWithString:self.balance];
    return [NSString formatDecimalNum:balance roundMode:NSRoundDown afterPoint:2];
}


@end
