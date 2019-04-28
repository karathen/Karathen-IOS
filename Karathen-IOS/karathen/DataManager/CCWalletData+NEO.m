//
//  CCWalletData+NEO.m
//  Karathen
//
//  Created by Karathen on 2018/9/4.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCWalletData+NEO.h"
#import "CCNEOApi.h"
#import "NSData+Extend.h"
#import "CCNEOAccount.h"
#import "CCTradeRecordModel.h"
#import "CCCoreData+TradeRecord.h"

@implementation CCWalletData (NEO)

#pragma mark - 查询资产结束
- (void)queryNEOBalancePriceCompletion:(void(^)(void))completion {
    [self queryNEOAssets:self.assets priceCompletion:nil balanceCompletion:nil endCompletion:completion];
}


- (void)queryNEOAssetHoldingCompletion:(void(^)(void))completion
                             noContain:(void(^)(NSArray <CCAsset *> *assets))noContain {
    @weakify(self)
    [[CCNEOApi manager] getAssetHoldingWithAddress:self.address completion:^(BOOL suc, NSArray<CCTokenInfoModel *> *assets) {
        @strongify(self)
        [self addAssetArray:assets noContains:^(NSArray<CCAsset *> *noContains) {
            if (noContain) {
                noContain(noContains);
            }
        } completion:^{
            completion();
        }];
    }];
}


#pragma mark - 查询价格
- (void)queryNEOBalancePriceAsset:(CCAsset *)asset completion:(void (^)(void))completion {
    [self queryNEOAssets:@[asset] priceCompletion:nil balanceCompletion:nil endCompletion:completion];
}

#pragma mark - 查询余额和价格
- (void)queryNEOAssets:(NSArray <CCAsset *> *)assets
       priceCompletion:(void(^)(void))priceCompletion
           balanceCompletion:(void(^)(NSArray<NSDictionary *> *balance, BOOL suc, CCWalletError error))balanceCompletion
               endCompletion:(void(^)(void))endCompletion {
    dispatch_group_t downloadGroup = dispatch_group_create();
    
    dispatch_group_enter(downloadGroup);
    [self queryNEOBalanceTokens:[self neoTokensWithAssets:assets] completion:^(NSArray<NSDictionary *> *balance, BOOL suc, CCWalletError error) {
        dispatch_group_leave(downloadGroup);
        if (balanceCompletion) {
            balanceCompletion(balance,suc,error);
        }
    }];
    
    __block NSDictionary *pricesResult;
    dispatch_group_enter(downloadGroup);
    [self queryPriceSynbols:[self neoTokenSynbolsWithAsset:assets] completion:^(NSDictionary *result) {
        pricesResult = result;
        dispatch_group_leave(downloadGroup);
        if (priceCompletion) {
            priceCompletion();
        }
    }];
    
    @weakify(self)
    dispatch_group_notify(downloadGroup, dispatch_get_main_queue(), ^{
        @strongify(self)
        [self dealNEOPriceWithData:pricesResult];
        if (endCompletion) {
            endCompletion();
        }
    });
}

#pragma mark - 请求余额
- (void)queryNEOBalanceTokens:(NSArray *)tokens completion:(void(^)(NSArray<NSDictionary *> *balance, BOOL suc, CCWalletError error))completion {
    @weakify(self)
    [[CCNEOApi manager] getBalanceWithAddress:self.address tokens:tokens completion:^(NSArray<NSDictionary *> *balance) {
        @strongify(self)
        DLog(@"请求余额结束");
        if (balance) {
            for (NSDictionary *dic in balance) {
                NSString *tokenAddress = dic[@"tokenAddress"];
                NSString *value = dic[@"balance"];
                CCAsset *asset = [self assetWithToken:tokenAddress];
                asset.balance = [NSString valueString:value decimal:asset.tokenDecimal];
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

- (NSArray *)neoTokenSynbolsWithAsset:(NSArray <CCAsset *> *)assets {
    NSMutableArray *synbols = [NSMutableArray array];
    for (CCAsset *asset in assets) {
        if (asset.tokenSynbol) {
            [synbols addObject:asset.tokenSynbol];
        }
    }
    return synbols;
}

- (NSArray *)neoTokensWithAssets:(NSArray <CCAsset *> *)assets {
    NSMutableArray *tokens = [NSMutableArray array];
    for (CCAsset *asset in assets) {
        if (asset.tokenAddress) {
            [tokens addObject:asset.tokenAddress];
        }
    }
    return tokens;
}

- (void)dealNEOPriceWithData:(NSDictionary *)data {
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
- (void)transferNEOAsset:(CCAsset *)asset
               toAddress:(NSString *)address
                  number:(NSString *)number
                password:(NSString *)password
              completion:(void(^)(BOOL suc,CCWalletError error,CCTradeRecordModel *tradeRecord))completion {
    @weakify(self)
    [[CCDataManager dataManager] walletInfoWithAccountID:self.wallet.accountID password:password completion:^(NSString *walletInfo) {
        @strongify(self)
        [self transferNEOAsset:asset toAddress:address number:number walletInfo:walletInfo completion:completion];
    }];
 
}

- (void)transferNEOAsset:(CCAsset *)asset
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
    CCNEOAccount *account;
    switch (self.importType) {
        case CCImportTypeSeed:
        case CCImportTypeMnemonic:
        {
            account = [[CCNEOAccount alloc] initWithMnemonic:walletInfo slot:self.wallet.slot];
        }
            break;
        case CCImportTypePrivateKey:
            account = [[CCNEOAccount alloc] initWithPrivateKey:walletInfo];
            break;
        case CCImportTypeWIF:
            account = [[CCNEOAccount alloc] initWithWIF:walletInfo];
            break;
        default:
            break;
    }
    
    NSString *tokenAddress = asset.tokenAddress;
    @weakify(self)
    [[CCNEOApi manager] transferAccount:account fromAddress:self.address toAddress:address number:number tokenAddress:tokenAddress completion:^(BOOL suc, NSString *txId) {
        @strongify(self)
        if (suc) {
            CCTradeRecordModel *tradeRecord = [self createNEOHistoryWithTxId:txId toAddress:address tokenAddress:tokenAddress number:number];
            completion(suc,CCWalletSucSend,tradeRecord);
        } else {
            completion(suc,CCWalletErrorSend,nil);
        }
        
    }];
}

#pragma mark - 转账成功构造历史记录信息
- (CCTradeRecordModel *)createNEOHistoryWithTxId:(NSString *)txId
                    toAddress:(NSString *)address
                 tokenAddress:(NSString *)tokenAddress
                       number:(NSString *)number {
    CCTradeRecordModel *model = [[CCTradeRecordModel alloc] init];
    model.addressTo = address;
    model.addressFrom = self.address;
    model.blockTime = [[NSDate date] timeIntervalSince1970];
    model.txId = txId;
    model.value = number;
    model.coinType = CCCoinTypeNEO;
    return model;
}


#pragma mark - 地址区块浏览器网址
- (NSString *)addressNEOExplorer {
    return [NSString stringWithFormat:@"%@%@",CC_NEO_ADDRESS_URL,self.address];
}

#pragma mark -  交易记录详情Url
- (NSString *)neoTradeDetailUrlWithTxId:(NSString *)txId {
    if ([txId hasPrefix:@"0x"]) {
        txId = [txId substringFromIndex:2];
    }
    return [NSString stringWithFormat:@"%@%@",CC_NEO_TX_URL,txId];
}
@end
