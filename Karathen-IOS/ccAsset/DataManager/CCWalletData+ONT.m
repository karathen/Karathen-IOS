//
//  CCWalletData+ONT.m
//  ccAsset
//
//  Created by SealWallet on 2018/9/19.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCWalletData+ONT.h"
#import "CCTradeRecordModel.h"
#import "CCCoreData+TradeRecord.h"
#import "CCONTApi.h"
#import "ONTAccount.h"

@implementation CCWalletData (ONT)

#pragma mark - 查询资产结束
- (void)queryONTBalancePriceCompletion:(void(^)(void))completion {
    [self queryONTAssets:self.assets priceCompletion:nil balanceCompletion:nil endCompletion:completion];
}

#pragma mark - 查询价格
- (void)queryONTBalancePriceAsset:(CCAsset *)asset completion:(void (^)(void))completion {
    [self queryONTAssets:@[asset] priceCompletion:nil balanceCompletion:nil endCompletion:completion];
}

#pragma mark - 查询余额和价格
- (void)queryONTAssets:(NSArray <CCAsset *> *)assets
       priceCompletion:(void(^)(void))priceCompletion
     balanceCompletion:(void(^)(NSDictionary *balance, BOOL suc, CCWalletError error))balanceCompletion
         endCompletion:(void(^)(void))endCompletion {
    dispatch_group_t downloadGroup = dispatch_group_create();
    
    dispatch_group_enter(downloadGroup);
    [self queryONTBalanceCompletion:^(NSDictionary *balance, BOOL suc, CCWalletError error) {
        dispatch_group_leave(downloadGroup);
        if (balanceCompletion) {
            balanceCompletion(balance,suc,error);
        }
    }];
    
    __block NSDictionary *pricesResult;
    dispatch_group_enter(downloadGroup);
    [self queryPriceSynbols:[self ontTokenSynbolsWithAsset:assets] completion:^(NSDictionary *result) {
        pricesResult = result;
        dispatch_group_leave(downloadGroup);
        if (priceCompletion) {
            priceCompletion();
        }
    }];
    
    @weakify(self)
    dispatch_group_notify(downloadGroup, dispatch_get_main_queue(), ^{
        @strongify(self)
        [self dealONTPriceWithData:pricesResult];
        if (endCompletion) {
            endCompletion();
        }
    });
}

#pragma mark - 请求余额
- (void)queryONTBalanceCompletion:(void(^)(NSDictionary *balance, BOOL suc, CCWalletError error))completion {
    [[CCONTApi manager] getBalanceWithAddress:self.address completion:^(NSDictionary *balance) {
        if (balance) {
            for (NSString *key in balance) {
                NSString *value = balance[key];
                CCAsset *asset = [self assetWithSymbol:key];
                if (asset) {
                    value = value?:@"0";
                    NSString *balanceString = [NSString valueString:value decimal:asset.tokenDecimal];
                    asset.balance = balanceString;
                }
            }
            if (completion) {
                completion(balance,YES,CCWalletGetBalanceSuc);
            }
        } else {
            if (completion) {
                completion(balance,NO,CCWalletErrorGetBalance);
            }
        }
    }];
}


- (NSArray *)ontTokenSynbolsWithAsset:(NSArray <CCAsset *> *)assets {
    NSMutableArray *synbols = [NSMutableArray array];
    for (CCAsset *asset in assets) {
        if (asset.tokenSynbol) {
            [synbols addObject:asset.tokenSynbol];
        }
    }
    return synbols;
}


- (NSArray *)ontTokensWithAssets:(NSArray <CCAsset *> *)assets {
    NSMutableArray *tokens = [NSMutableArray array];
    for (CCAsset *asset in assets) {
        if (asset.tokenAddress) {
            [tokens addObject:asset.tokenAddress];
        }
    }
    return tokens;
}

- (void)dealONTPriceWithData:(NSDictionary *)data {
    DLog(@"开始计算余额");
    NSDecimalNumber *allBalance = [NSDecimalNumber decimalNumberWithString:@"0"];
    for (CCAsset *asset in self.assets) {
        NSArray *priceArray = data[asset.tokenSynbol];
        if (priceArray.count > 0) {
            NSString *priceCNY = [NSString stringWithFormat:@"%@",priceArray[0]?:@"0"];
            asset.price = priceCNY;
        }
        if (priceArray.count > 1) {
            NSString *priceUSD = [NSString stringWithFormat:@"%@",priceArray[1]?:@"0"];
            asset.priceUSD = priceUSD;
        }
        
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

#pragma mark - 转账
- (void)transferONTAsset:(CCAsset *)asset
               toAddress:(NSString *)address
                  number:(NSString *)number
                password:(NSString *)password
              completion:(void(^)(BOOL suc,CCWalletError error,CCTradeRecordModel *tradeRecord))completion {
    @weakify(self)
    [[CCDataManager dataManager] walletInfoWithAccountID:self.wallet.accountID password:password completion:^(NSString *walletInfo) {
        @strongify(self)
        [self transferONTAsset:asset toAddress:address number:number walletInfo:walletInfo completion:completion];
    }];

}

- (void)transferONTAsset:(CCAsset *)asset
               toAddress:(NSString *)address
                  number:(NSString *)number
              walletInfo:(NSString *)walletInfo
              completion:(void(^)(BOOL suc,CCWalletError error,CCTradeRecordModel *tradeRecord))completion {
    address = [address deleteSpace];
    if (!walletInfo) {
        if (completion) {
            completion(NO,CCWalletErrorPWD,nil);
        }
        return;
    }
    ONTAccount *account;
    switch (self.importType) {
        case CCImportTypeSeed:
        case CCImportTypeMnemonic:
            account = [[ONTAccount alloc] initWithMnemonic:walletInfo slot:self.wallet.slot];
            break;
        case CCImportTypePrivateKey:
            account = [[ONTAccount alloc] initWithPrivateKey:walletInfo];
            break;
        case CCImportTypeWIF:
            account = [[ONTAccount alloc] initWithWIF:walletInfo];
            break;
        default:
            break;
    }
    NSString *tokenAddress = asset.tokenAddress;
    @weakify(self)
    [[CCONTApi manager] transferAccount:account asset:asset fromAddress:self.address toAddress:address number:number completion:^(BOOL suc, NSString *txId) {
        @strongify(self)
        if (suc) {
            CCTradeRecordModel *model = [self createONTHistoryWithTxId:txId toAddress:address tokenAddress:tokenAddress number:number];
            completion(suc,CCWalletSucSend,model);
        } else {
            completion(suc,CCWalletErrorSend,nil);
        }
    }];

}

#pragma mark - 转账成功构造历史记录信息
- (CCTradeRecordModel *)createONTHistoryWithTxId:(NSString *)txId
                                       toAddress:(NSString *)address
                                    tokenAddress:(NSString *)tokenAddress
                                          number:(NSString *)number {
    CCTradeRecordModel *model = [[CCTradeRecordModel alloc] init];
    model.addressTo = address;
    model.addressFrom = self.address;
    model.blockTime = [[NSDate date] timeIntervalSince1970];
    model.txId = txId;
    model.value = number;
    model.coinType = CCCoinTypeONT;
    return model;
}


#pragma mark - 地址区块浏览器网址
- (NSString *)addressONTExplorer {
    return [NSString stringWithFormat:@"%@%@",CC_ONT_ADDRESS_URL,self.address];
}

#pragma mark -  交易记录详情Url
- (NSString *)ontTradeDetailUrlWithTxId:(NSString *)txId {
    if ([txId hasPrefix:@"0x"]) {
        txId = [txId substringFromIndex:2];
    }
    return [NSString stringWithFormat:@"%@%@",CC_ONT_TX_URL,txId];
}

@end
