//
//  CCWalletData+ETH.m
//  Karathen
//
//  Created by Karathen on 2018/9/4.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCWalletData+ETH.h"
#import "CCCoreData+Asset.h"
#import "CCCoreData+Wallet.h"
#import "CCTradeRecordModel.h"
#import "CCCoreData+TradeRecord.h"

@implementation CCWalletData (ETH)

#pragma mark - 查询资产结束
- (void)queryETHBalancePriceCompletion:(void(^)(void))completion {
    [self queryETHAssets:self.assets priceCompletion:nil balanceCompletion:nil endCompletion:completion];
}

- (void)queryETHAssetHoldingCompletion:(void(^)(void))completion
                             noContain:(void(^)(NSArray <CCAsset *> *assets))noContain {
    @weakify(self)
    [[CCETHApi manager] getAssetHoldingWithAddress:self.address completion:^(BOOL suc, NSArray<CCTokenInfoModel *> *assets) {
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

#pragma mark - 查询单个价格
- (void)queryETHBalancePriceAsset:(CCAsset *)asset completion:(void (^)(void))completion {
    [self queryETHAssets:@[asset] priceCompletion:nil balanceCompletion:nil endCompletion:completion];
}

#pragma mark - 查询余额和价格
- (void)queryETHAssets:(NSArray <CCAsset *> *)assets
       priceCompletion:(void(^)(void))priceCompletion
              balanceCompletion:(void(^)(NSDictionary *balances, BOOL suc, CCWalletError error))balanceCompletion
                  endCompletion:(void(^)(void))endCompletion {
    dispatch_group_t requestGroup = dispatch_group_create();
    
    dispatch_group_enter(requestGroup);
    [self queryETHBalanceTokens:[self ethTokensWithAssets:assets] completion:^(NSDictionary *balances, BOOL suc, CCWalletError error) {
        dispatch_group_leave(requestGroup);
        if (balanceCompletion) {
            balanceCompletion(balances,suc,error);
        }
    }];
    
    __block NSDictionary *pricesResult;
    dispatch_group_enter(requestGroup);
    [self queryPriceSynbols:[self ethTokenSynbolsWithAsset:assets] completion:^(NSDictionary *result) {
        pricesResult = result;
        dispatch_group_leave(requestGroup);
        if (priceCompletion) {
            priceCompletion();
        }
    }];
    
    @weakify(self)
    dispatch_group_notify(requestGroup, dispatch_get_main_queue(), ^{
        @strongify(self)
        [self dealETHPriceWithData:pricesResult];
        if (endCompletion) {
            endCompletion();
        }
    });
}


#pragma mark - 请求余额
- (void)queryETHBalanceTokens:(NSArray *)tokens completion:(void(^)(NSDictionary *balances, BOOL suc, CCWalletError error))completion {
    @weakify(self)
    [CCETHApi getETHBalanceWithTokens:tokens withAddress:self.address completion:^(NSDictionary *balances, BOOL suc, CCWalletError error) {
        @strongify(self)
        for (NSString *key in balances) {
            CCAsset *asset = [self ethAssetWithToken:key];
            if (asset) {
                NSString *balanceString = [NSString valueString:balances[key] decimal:asset.tokenDecimal];
                asset.balance = balanceString;
            }
        }
        DLog(@"请求余额结束");
        if (completion) {
            completion(balances,suc,error);
        }
    }];
}


- (CCAsset *)ethAssetWithToken:(NSString *)token {
    for (CCAsset * asset in self.assets) {
        if ([asset.tokenSynbol isEqualToString:@"ETH"]) {
            if ([asset.walletAddress compareWithString:token]) {
                return asset;
            }
        } else {
            if ([asset.tokenAddress compareWithString:token]) {
                return asset;
            }
        }
    }
    return nil;
}


- (NSArray *)ethTokenSynbolsWithAsset:(NSArray <CCAsset *> *)assets {
    NSMutableArray *synbols = [NSMutableArray array];
    for (NSInteger i = 0; i < assets.count; i ++) {
        CCAsset *asset = assets[i];
        if (![asset.tokenType compareWithString:CCAseet_ETH_ERC721] && asset.tokenSynbol) {
            if (asset.tokenSynbol) {
                [synbols addObject:asset.tokenSynbol];
            }
        }
    }
    return synbols;
}

- (NSArray *)ethTokensWithAssets:(NSArray <CCAsset *> *)assets {
    NSMutableArray *tokens = [NSMutableArray array];
    for (NSInteger i = 0; i < assets.count; i ++) {
        CCAsset *asset = assets[i];
        if (![asset.tokenSynbol isEqualToString:@"ETH"]) {
            if (asset.tokenAddress) {
                [tokens addObject:asset.tokenAddress];
            }
        }
    }
    return tokens;
}


- (void)dealETHPriceWithData:(NSDictionary *)data {
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
- (void)transferETHAsset:(CCAsset *)asset
               toAddress:(NSString *)address
                  number:(NSString *)number
                password:(NSString *)password
                gasPrice:(NSString *)gasPrice
                gasLimit:(NSString *)gasLimit
              completion:(void(^)(BOOL suc,CCWalletError error,CCTradeRecordModel *tradeRecord))completion {
    @weakify(self)
    [[CCDataManager dataManager] walletInfoWithAccountID:self.wallet.accountID password:password completion:^(NSString *walletInfo) {
        @strongify(self)
        [self transferETHAsset:asset toAddress:address number:number walletInfo:walletInfo gasPrice:gasPrice gasLimit:gasLimit completion:completion];
    }];
}

- (void)transferHardwareETHAsset:(CCAsset *)asset
                       toAddress:(NSString *)address
                          number:(NSString *)number
                        password:(NSString *)password
                        gasPrice:(NSString *)gasPrice
                        gasLimit:(NSString *)gasLimit
                         process:(void(^)(NSString *message))process
                      completion:(void(^)(BOOL suc,CCWalletError error,CCTradeRecordModel *tradeRecord))completion {
    @weakify(self)
    [CCETHApi transferETHardwareWallet:[CCHardwareWallet hardwareWallet]
                                  slot:self.wallet.slot
                              verifyFp:NO
                              password:password
                                 asset:asset
                           fromAddress:self.address
                             toAddress:address
                                 money:number
                              gasPrice:gasPrice
                              gasLimit:nil
                       needEstimateGas:NO
                                remark:nil
                               process:process
                            completion:^(NSString *hashStr, NSString *gasPrice, NSString *gasLimit, NSString *data, BOOL suc, CCWalletError error) {
                                CCTradeRecordModel *tradeRecord;
                                if (suc) {
                                    @strongify(self)
                                    tradeRecord = [self createEHTHistoryWithTxId:hashStr toAddress:address tokenAddress:asset.tokenAddress number:number gasPrice:gasPrice gasLimit:gasLimit data:data];
                                }
                                if (completion) {
                                    completion(suc,error,tradeRecord);
                                }
                            }];
}

- (void)transferETHAsset:(CCAsset *)asset
               toAddress:(NSString *)address
                  number:(NSString *)number
              walletInfo:(NSString *)walletInfo
                gasPrice:(NSString *)gasPrice
                gasLimit:(NSString *)gasLimit
              completion:(void(^)(BOOL suc,CCWalletError error,CCTradeRecordModel *tradeRecord))completion {
    address = [address deleteSpace];
    if (!walletInfo) {
        if (completion) {
            completion(NO,CCWalletErrorPWD,nil);
        }
        return;
    }
    
    Account *account;
    if (self.importType == CCImportTypeMnemonic || self.importType == CCImportTypeSeed) {
        account = [[Account alloc] initWithMnemonicPhrase:walletInfo coinType:60 account:0 external:0 slot:self.wallet.slot];
    } else {
        account = [Account accountWithPrivateKey:[SecureData hexStringToData:[walletInfo hasPrefix:@"0x"]?walletInfo:[@"0x" stringByAppendingString:walletInfo]]];
    }
    
    @weakify(self)
    [CCETHApi transferETHAccount:account
                           asset:asset
                     fromAddress:self.address
                       toAddress:address
                           money:number
                        gasPrice:gasPrice
                        gasLimit:nil
                 needEstimateGas:NO
                          remark:nil
                      completion:^(NSString *hashStr, NSString *gasPrice, NSString *gasLimit, NSString *data, BOOL suc, CCWalletError error) {
                          CCTradeRecordModel *tradeRecord;
                          if (suc) {
                              @strongify(self)
                              tradeRecord = [self createEHTHistoryWithTxId:hashStr toAddress:address tokenAddress:asset.tokenAddress number:number gasPrice:gasPrice gasLimit:gasLimit data:data];
                          }
                          if (completion) {
                              completion(suc,error,tradeRecord);
                          }
                          
                      }];
}

#pragma mark - 转账成功构造历史记录信息
- (CCTradeRecordModel *)createEHTHistoryWithTxId:(NSString *)txId
                    toAddress:(NSString *)address
                 tokenAddress:(NSString *)tokenAddress
                       number:(NSString *)number
                     gasPrice:(NSString *)gasPrice
                     gasLimit:(NSString *)gasLimit
                         data:(NSString *)data {
    CCTradeRecordModel *model = [[CCTradeRecordModel alloc] init];
    model.addressTo = address;
    model.addressFrom = self.address;
    model.blockTime = [[NSDate date] timeIntervalSince1970];
    model.txId = txId;
    model.gas = gasLimit;
    model.gasPrice = gasPrice;
    model.value = number;
    model.data = data;
    model.coinType = CCCoinTypeETH;
    return model;
}


#pragma mark - 地址区块浏览器网址
- (NSString *)addressETHExplorer {
    return [NSString stringWithFormat:@"%@%@",CC_ETH_ADDRESS_URL,self.address];
}


#pragma mark -  交易记录详情Url
- (NSString *)ethTradeDetailUrlWithTxId:(NSString *)txId {
    return [NSString stringWithFormat:@"%@%@",CC_ETH_TX_URL,txId];
}

@end
