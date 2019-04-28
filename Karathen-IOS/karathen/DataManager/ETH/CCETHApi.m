//
//  CCETHApi.m
//  Karathen
//
//  Created by Karathen on 2018/9/10.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCETHApi.h"
#import "CCTokenInfoRequest.h"

static CCETHApi *manager = nil;

@interface CCETHApi ()

@property (nonatomic, strong) CCETHRequest *request;


@end

@implementation CCETHApi

+ (instancetype)manager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[CCETHApi alloc] init];
    });
    return manager;
}

#pragma mark - 获取交易记录
- (void)getTransationWithAddress:(NSString *)address
                    tokenAddress:(NSString *)tokenAddress
                            page:(NSInteger)page
                      completion:(void(^)(BOOL suc,NSArray *records))completion {
    self.request.parameter = @{
                               @"id":@"1",
                               @"method":@"getTransactionByAddress",
                               @"jsonrpc":@"2.0",
                               @"params":@[address,tokenAddress?:@"0x",@(page)]
                               };
    [self.request startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        NSDictionary *responseObject = request.responseObject;
        if (responseObject[@"error"] || !responseObject[@"result"]) {
            completion(NO,nil);
        } else {
            completion(YES,responseObject[@"result"]);
        }
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        completion(NO,nil);
    }];
}

#pragma mark - 查询721资产下的tokenid
- (void)getTokensOfOwner:(NSString *)ownerAddress
            tokenAddress:(NSString *)tokenAddress
                    page:(NSInteger)page
              completion:(void(^)(BOOL suc, NSArray *tokens))completion {
    self.request.parameter = @{
                               @"id":@"1",
                               @"method":@"tokensOfOwner",
                               @"jsonrpc":@"2.0",
                               @"params":@[tokenAddress,ownerAddress,@(page)]
                               };
    [self.request startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        NSDictionary *responseObject = request.responseObject;
        if (responseObject[@"error"] || !responseObject[@"result"]) {
            completion(NO,nil);
        } else {
            completion(YES,responseObject[@"result"]);
        }
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        completion(NO,nil);
    }];
}

#pragma mark - 获取地址下拥有的资产
- (void)getAssetHoldingWithAddress:(NSString *)address
                        completion:(void(^)(BOOL suc, NSArray <CCTokenInfoModel *> *assets))completion {
    self.request.parameter = @{
                               @"id":@"1",
                               @"method":@"getTokenHolding",
                               @"jsonrpc":@"2.0",
                               @"params":@[address]
                               };
    [self.request startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        NSArray *result = [CCTokenInfoModel mj_objectArrayWithKeyValuesArray:request.responseObject[@"result"]];
        if (result.count) {
            if (completion) {
                completion(YES, result);
            }
        } else {
            if (completion) {
                completion(NO, nil);
            }
        }
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        completion(NO,nil);
    }];
}

#pragma mark - 构造转账交易
+ (void)transferETHAsset:(CCAsset *)asset
             fromAddress:(NSString *)fromAddress
               toAddress:(NSString *)toAddress
                   money:(NSString *)money
                gasPrice:(NSString *)gasPrice
                gasLimit:(NSString *)gasLimit
         needEstimateGas:(BOOL)needEstimateGas
                  remark:(NSString *)remark
              completion:(void(^)(BOOL suc, CCWalletError error,Transaction *transaction))completion {
    //提供3种方式  1 以太坊官方限流配置   2 web3配置  3 infura配置  本方式使用以太坊官方限流配置291941a3f1d24fc3b20cd866ff417b88
    __block EtherscanProvider *e = [CCETHApi manager].ethProvider;
    
    __block Transaction *transaction = [Transaction transactionWithFromAddress:[Address addressWithString:fromAddress]];
    
    NSString *decimal = asset.tokenDecimal;
    NSString *tokenETH = [asset.tokenSynbol isEqualToString:@"ETH"]?nil:asset.tokenAddress;
    //是否是721
    BOOL isErc721 = [asset.tokenType compareWithString:CCAseet_ETH_ERC721];
    //
    NSString *customGasLimit = isErc721?@"450000":(tokenETH==nil?@"21000":@"60000");
    
    //是否是CK
    BOOL isCK = isErc721 && [CCWalletData checkIsCryptoKittiesAsset:asset];
    
    //1 account解密
    DLog(@"2 新建钱包成功 开始获取nonce");
    [[e getTransactionCount:transaction.fromAddress] onCompletion:^(IntegerPromise *pro) {
        if (pro.error != nil) {
            DLog(@"%@获取nonce失败",pro.error);
            completion(NO,CCWalletErrorSend,nil);
        }else{
            DLog(@"3 获取nonce成功 值为%ld",pro.value);
            transaction.nonce = pro.value;
            
            DLog(@"4 开始获取gasPrice");
            [self transactionWithGasPrice:gasPrice etherscanProvider:e completion:^(BigNumber *gasPriceNum, BOOL suc) {
                if (suc) {
                    transaction.gasPrice = gasPriceNum;
                    
                    transaction.chainId = e.chainId;
                    transaction.toAddress = [Address addressWithString:toAddress];
                    
                    //转账金额
                    NSDecimalNumber *valueNum = [NSDecimalNumber decimalNumberWithString:money];
                    NSDecimalNumber *decimalNum = [NSDecimalNumber decimalNumberWithMantissa:1 exponent:decimal.integerValue isNegative:NO];
                    NSDecimalNumber *result = [valueNum decimalNumberByMultiplyingBy:decimalNum];
                    BigNumber *b = [BigNumber bigNumberWithDecimalString:result.stringValue];
                    transaction.value = b;
                    
                    SecureData *data;
                    if (tokenETH == nil) {//默认eth
                        
                        if (gasLimit == nil) {
                            transaction.gasLimit = [BigNumber bigNumberWithDecimalString:customGasLimit];
                        }else{
                            DLog(@"手动设置了gasLimit = %@",gasLimit);
                            transaction.gasLimit = [BigNumber bigNumberWithDecimalString:gasLimit];
                        }
                        
                        if (remark) {
                            NSString *hexRemark = [NSString stringWithFormat:@"0x%@",[NSString hexStringFromString:remark]];
                            data = [SecureData secureDataWithHexString:hexRemark];
                        } else {
                            data = [SecureData secureDataWithCapacity:0];
                        }
                        transaction.data = data.data;
                    }else{
                        
                        if (gasLimit == nil) {
                            transaction.gasLimit = [BigNumber bigNumberWithDecimalString:customGasLimit];
                        }else{
                            DLog(@"手动设置了gasLimit = %@",gasLimit);
                            transaction.gasLimit = [BigNumber bigNumberWithDecimalString:gasLimit];
                        }
                        data = [SecureData secureData];
                        
                        if (isErc721 && !isCK) {
                            [data appendData:[SecureData hexStringToData:@"0x42842e0e"]];
                            NSData *dataFromAddress = transaction.fromAddress.data;//转出地址
                            for (int i=0; i < 32 - dataFromAddress.length; i++) {
                                [data appendByte:'\0'];
                            }
                            [data appendData:dataFromAddress];
                            
                            NSData *dataAddress = transaction.toAddress.data;//转入地址（真实代币转入地址添加到data里面）
                            for (int i=0; i < 32 - dataAddress.length; i++) {
                                [data appendByte:'\0'];
                            }
                            [data appendData:dataAddress];
                        } else {
                            [data appendData:[SecureData hexStringToData:@"0xa9059cbb"]];
                            
                            NSData *dataAddress = transaction.toAddress.data;//转入地址（真实代币转入地址添加到data里面）
                            for (int i=0; i < 32 - dataAddress.length; i++) {
                                [data appendByte:'\0'];
                            }
                            [data appendData:dataAddress];
                            
                        }
                        
                        NSData *valueData = transaction.value.data;//真实代币交易数量添加到data里面
                        for (int i=0; i < 32 - valueData.length; i++) {
                            [data appendByte:'\0'];
                        }
                        [data appendData:valueData];
                        
                        if (remark) {
                            NSString *hexRemark = [NSString stringWithFormat:@"0x%@",[NSString hexStringFromString:remark]];
                            NSData *remarkData = [SecureData hexStringToData:hexRemark];
                            [data appendData:remarkData];
                        }
                        
                        transaction.value = [BigNumber constantZero];
                        transaction.data = data.data;
                        transaction.toAddress = [Address addressWithString:tokenETH];//合约地址（代币交易 转入地址为合约地址）
                    }
                    
                    if (needEstimateGas) {
                        DLog(@"开始预估gas");
                        [[e estimateGas:transaction] onCompletion:^(BigNumberPromise *promise) {
                            DLog(@"预估gas - %@",promise.value.decimalString);
                            transaction.gasLimit = promise.value;;
                            completion(YES,CCWalletErrorSuccess,transaction);
                        }];
                    } else {
                        completion(YES,CCWalletErrorSuccess,transaction);
                    }
                } else {
                    completion(NO,CCWalletErrorNotGasPrice,nil);
                }
            }];
        }
    }];
}

#pragma mark - 转账
+ (void)transferETHAccount:(Account *)account
                     asset:(CCAsset *)asset
               fromAddress:(NSString *)fromAddress
                 toAddress:(NSString *)toAddress
                     money:(NSString *)money
                  gasPrice:(NSString *)gasPrice
                  gasLimit:(NSString *)gasLimit
           needEstimateGas:(BOOL)needEstimateGas
                    remark:(NSString *)remark
                completion:(void(^)(NSString *hashStr,NSString *gasPrice,NSString *gasLimit,NSString *data,BOOL suc,CCWalletError error))completion {
    __block EtherscanProvider *e = [CCETHApi manager].ethProvider;
    [CCETHApi transferETHAsset:asset fromAddress:fromAddress toAddress:toAddress money:money gasPrice:gasPrice gasLimit:gasLimit needEstimateGas:needEstimateGas remark:remark completion:^(BOOL suc, CCWalletError error, Transaction *transaction) {
        
        NSString *dataHexString = [SecureData secureDataWithData:transaction.data].hexString;
        //签名
        [account sign:transaction];
        NSData *signedTransaction = [transaction serialize];
        //发送
        DLog(@"6 开始转账");
        [[e sendTransaction:signedTransaction] onCompletion:^(HashPromise *pro) {
            if (pro.error == nil){
                DLog(@"\n---------------【生成转账交易成功！！！！】--------------\n哈希值 = %@\n",transaction.transactionHash.hexString);
                DLog(@" 7成功 哈希值 =  %@",pro.value.hexString); completion(pro.value.hexString,transaction.gasPrice.decimalString,transaction.gasLimit.decimalString,dataHexString,YES,CCWalletSucSend);
            }else{
                completion(@"",transaction.gasPrice.decimalString,transaction.gasLimit.decimalString,dataHexString,NO,CCWalletErrorSend);
            }
        }];
    }];
}


+ (void)transferETHardwareWallet:(CCHardwareWallet *)hardware
                            slot:(int)slot
                        verifyFp:(BOOL)verifyFp
                        password:(NSString *)password
                           asset:(CCAsset *)asset
                     fromAddress:(NSString *)fromAddress
                       toAddress:(NSString *)toAddress
                           money:(NSString *)money
                        gasPrice:(NSString *)gasPrice
                        gasLimit:(NSString *)gasLimit
                 needEstimateGas:(BOOL)needEstimateGas
                          remark:(NSString *)remark
                         process:(void(^)(NSString *message))process
                      completion:(void(^)(NSString *hashStr,NSString *gasPrice,NSString *gasLimit,NSString *data,BOOL suc,CCWalletError error))completion {
    __block EtherscanProvider *e = [CCETHApi manager].ethProvider;
    [CCETHApi transferETHAsset:asset fromAddress:fromAddress toAddress:toAddress money:money gasPrice:gasPrice gasLimit:gasLimit needEstimateGas:needEstimateGas remark:remark completion:^(BOOL suc, CCWalletError error, Transaction *transaction) {
        if (suc && transaction.data) {
            NSString *dataHexString = [SecureData secureDataWithData:transaction.data].hexString;
            [hardware signETHTransaction:[transaction serialize] slot:slot asset:asset verifyFp:verifyFp password:password deviceWaiting:^{
                if (process) {
                    process(Localized(@"Please press the button after confirming the information"));
                }
            } completion:^(BOOL suc, int errorCode, NSData *signData) {
                if (suc) {
                    if (process) {
                        process(Localized(@"Sending raw transaction"));
                    }
                    [transaction signHardwareData:signData];
                    NSData *signedTransaction = [transaction serialize];
                    //发送
                    DLog(@"6 开始转账");
                    [[e sendTransaction:signedTransaction] onCompletion:^(HashPromise *pro) {
                        if (pro.error == nil){
                            DLog(@" 7成功 哈希值 =  %@",pro.value.hexString); completion(pro.value.hexString,transaction.gasPrice.decimalString,transaction.gasLimit.decimalString,dataHexString,YES,CCWalletSucSend);
                        } else {
                            DLog(@"转账失败: %@",pro.error); completion(@"",transaction.gasPrice.decimalString,transaction.gasLimit.decimalString,dataHexString,NO,CCWalletErrorSend);
                        }
                    }];
                } else {
                    completion(nil,nil,nil,nil,NO,errorCode);
                }
            }];
        } else {
            completion(@"",transaction.gasPrice.decimalString,transaction.gasLimit.decimalString,nil,NO,CCWalletErrorSend);
        }
    }];
}

#pragma mark - 签名交易广播
+ (void)transferWalletData:(CCWalletData *)walletData
                  passWord:(NSString *)passWord
                 toAddress:(NSString *)toAddress
                  gasPrice:(NSString *)gasPrice
                  gasLimit:(NSString *)gasLimit
                     value:(NSString *)value
                 transdata:(NSData *)transdata
                completion:(void(^)(NSString *hashStr,NSString *gasPrice,NSString *gasLimit,NSString *data,BOOL suc,CCWalletError error))completion {
    [[CCDataManager dataManager] walletInfoWithAccountID:walletData.wallet.accountID password:passWord completion:^(NSString *walletInfo) {
        [CCETHApi transferWalletData:walletData walletInfo:walletInfo toAddress:toAddress gasPrice:gasPrice gasLimit:gasLimit value:value transdata:transdata completion:completion];
    }];

}

+ (void)transferWalletData:(CCWalletData *)walletData
                walletInfo:(NSString *)walletInfo
                 toAddress:(NSString *)toAddress
                  gasPrice:(NSString *)gasPrice
                  gasLimit:(NSString *)gasLimit
                     value:(NSString *)value
                 transdata:(NSData *)transdata
                completion:(void(^)(NSString *hashStr,NSString *gasPrice,NSString *gasLimit,NSString *data,BOOL suc,CCWalletError error))completion {
    if (!walletInfo) {
        if (completion) {
            completion(@"",@"",@"",@"",NO,CCWalletErrorPWD);
        }
        return;
    }
    Account *account;
    if (walletData.importType == CCImportTypeMnemonic || walletData.importType == CCImportTypeSeed) {
        account = [[Account alloc] initWithMnemonicPhrase:walletInfo coinType:60 account:0 external:0 slot:walletData.wallet.slot];
    } else {
        account = [Account accountWithPrivateKey:[SecureData hexStringToData:[walletInfo hasPrefix:@"0x"]?walletInfo:[@"0x" stringByAppendingString:walletInfo]]];
    }
    
    __block EtherscanProvider *e = [CCETHApi manager].ethProvider;
    
    __block Transaction *transaction = [Transaction transactionWithFromAddress:[Address addressWithString:walletData.address]];
    
    [[e getTransactionCount:transaction.fromAddress] onCompletion:^(IntegerPromise *pro) {
        if (pro.error != nil) {
            DLog(@"%@获取nonce失败",pro.error);
            completion(@"",@"",@"",@"",NO,CCWalletErrorSend);
        }else{
            DLog(@"3 获取nonce成功 值为%ld",pro.value);
            transaction.nonce = pro.value;
            
            DLog(@"4 开始获取gasPrice");
            [self transactionWithGasPrice:gasPrice etherscanProvider:e completion:^(BigNumber *gasPriceNum, BOOL suc) {
                if (suc) {
                    transaction.gasPrice = gasPriceNum;
                    transaction.chainId = e.chainId;
                    transaction.toAddress = [Address addressWithString:toAddress];
                    
                    BigNumber *b = [BigNumber bigNumberWithDecimalString:value];
                    transaction.value = b;
                    
                    SecureData *data = [SecureData secureDataWithData:transdata];
                    transaction.data = data.data;
                    transaction.gasLimit = [BigNumber bigNumberWithDecimalString:gasLimit?:@"450000"];
                    transaction.toAddress = [Address addressWithString:toAddress];
                    
                    //签名
                    [account sign:transaction];
                    NSData *signedTransaction = [transaction serialize];
                    
                    NSString *dataHexString = data.hexString;
                    //发送
                    DLog(@"6 开始转账");
                    [[e sendTransaction:signedTransaction] onCompletion:^(HashPromise *pro) {
                        if (pro.error == nil){
                            DLog(@"\n---------------【生成转账交易成功！！！！】--------------\n哈希值 = %@\n",transaction.transactionHash.hexString);
                            DLog(@" 7成功 哈希值 =  %@",pro.value.hexString); completion(pro.value.hexString,transaction.gasPrice.decimalString,transaction.gasLimit.decimalString,dataHexString,YES,CCWalletSucSend);
                        }else{
                            completion(@"",transaction.gasPrice.decimalString,transaction.gasLimit.decimalString,dataHexString,NO,CCWalletErrorSend);
                        }
                    }];
                } else {
                    completion(@"",@"",@"",@"",NO,CCWalletErrorNotGasPrice);
                }
            }];
        }
    }];
}

#pragma mark - 设置GasPrice和GasLimit
+ (void)transactionWithGasPrice:(NSString *)gasPrice etherscanProvider:(EtherscanProvider *)e completion:(void(^)(BigNumber *gasPriceNum,BOOL suc))completion {
    if (gasPrice) {
        DLog(@"手动设置了gasPrice = %@GWei",gasPrice);
        BigNumber *gasPriceNum = [[BigNumber bigNumberWithDecimalString:gasPrice] mul:[BigNumber bigNumberWithDecimalString:@"1000000000"]];
        if (completion) {
            completion(gasPriceNum,YES);
        }
    } else {
        [[e getGasPrice] onCompletion:^(BigNumberPromise *proGasPrice) {
            if (proGasPrice.error == nil) {
                DLog(@"5 获取gasPrice成功 值为%@Wei",proGasPrice.value.decimalString);
                if (completion) {
                    completion(proGasPrice.value,YES);
                }
            } else {
                if (completion) {
                    completion(nil,NO);
                }
            }
        }];
    }
}

#pragma mark - 交易记录
+ (void)getETHTransactionWithTxid:(NSString *)txId
                       completion:(void(^)(TransactionInfoPromise *info))completion {
    if (!txId) {
        if (completion) {
            completion(nil);
        }
        return;
    }
    EtherscanProvider *e = [CCETHApi manager].ethProvider;
    Hash *hash = [Hash hashWithHexString:txId];
    [[e getTransaction:hash] onCompletion:^(TransactionInfoPromise *info) {
        if (completion) {
            completion(info);
        }
    }];
}

#pragma mark - 交易记录
+ (void)getETHTransactionReceiptWithTxid:(NSString *)txId
                               completion:(void(^)(TransactionInfoPromise *info))completion {
    EtherscanProvider *e = [CCETHApi manager].ethProvider;
    Hash *hash = [Hash hashWithHexString:txId];
    [[e getTransactionReceipt:hash] onCompletion:^(TransactionInfoPromise *info) {
        if (completion) {
            completion(info);
        }
    }];
}



#pragma mark - 查询余额
+ (void)getETHBalanceWithTokens:(NSArray<NSString *> *)arrayToken
                    withAddress:(NSString *)address
                     completion:(void(^)(NSDictionary *balances,BOOL suc,CCWalletError error))completion {
    NSMutableArray *requestArray = [NSMutableArray array];
    
    CCETHScanRequest *addressRequest = [[CCETHScanRequest alloc] init];
    addressRequest.parameter = @{
                          @"action":@"balance",
                          @"address":address,
                          @"tag":@"latest"
                          };
    [requestArray addObject:addressRequest];
    
    for (NSString *tokenAddress in arrayToken) {
        CCETHScanRequest *requset = [[CCETHScanRequest alloc] init];
        requset.parameter = @{
                              @"action":@"tokenbalance",
                              @"address":address,
                              @"contractaddress":tokenAddress,
                              @"tag":@"latest"
                              };
        [requestArray addObject:requset];
    }
    
    YTKBatchRequest *batchRequest = [[YTKBatchRequest alloc] initWithRequestArray:requestArray];
    [batchRequest startWithCompletionBlockWithSuccess:^(YTKBatchRequest * _Nonnull batchRequest) {
        NSMutableDictionary *balanceDic = [NSMutableDictionary dictionary];
        for (YTKRequest *request in batchRequest.requestArray) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:request.responseData options:NSJSONReadingMutableContainers error:NULL];
            NSString *status = dic[@"status"];
            if (status.integerValue != 1) {
                continue;
            }
            if ([request.requestArgument[@"action"] compareWithString:@"tokenbalance"]) {
                NSString *contractaddress = request.requestArgument[@"contractaddress"];
                if (contractaddress) {
                    [balanceDic setValue:dic[@"result"]?:@"0" forKey:contractaddress.lowercaseString];
                }
            } else {
                [balanceDic setValue:dic[@"result"]?:@"0" forKey:address.lowercaseString];
            }
        }
        completion(balanceDic,YES,CCWalletGetBalanceSuc);
    } failure:^(YTKBatchRequest * _Nonnull batchRequest) {
        completion(nil,YES,CCWalletErrorGetBalance);
    }];
}


#pragma mark - 获取GasPrice
+ (void)getETHGasPriceCompletion:(void(^)(NSString *gasPrice))completion {
    EtherscanProvider *e = [CCETHApi manager].ethProvider;
    [[e getGasPrice] onCompletion:^(BigNumberPromise *proGasPrice) {
        if (completion && proGasPrice.error == nil) {
            completion(proGasPrice.value.decimalString);
        }
    }];
}


#pragma mark - 查询块高
+ (void)getETHBlockNumCompletion:(void (^)(NSInteger))completion {
    EtherscanProvider *e = [CCETHApi manager].ethProvider;
    [[e getBlockNumber] onCompletion:^(IntegerPromise *promise) {
        if (completion) {
            completion(promise.value);
        }
    }];
}

#pragma mark - 网络类型
+ (ChainId)chainId {
    return ChainIdHomestead;
}

#pragma mark - apiKey
+ (NSString *)apiKey {
    return CC_ETH_APIKEY;
}


#pragma mark - get
- (CCETHRequest *)request {
    if (!_request) {
        _request = [[CCETHRequest alloc] init];
    }
    return _request;
}

- (EtherscanProvider *)ethProvider {
    if (!_ethProvider) {
        _ethProvider = [[EtherscanProvider alloc] initWithChainId:[CCETHApi chainId] apiKey:[CCETHApi apiKey]];
    }
    return _ethProvider;
}

@end


@implementation CCETHRequest


- (NSString *)baseUrl {
    return CC_ETH_BASEURL;
}

- (NSString *)requestUrl {
    return @"";
}

- (YTKRequestSerializerType)requestSerializerType {
    return YTKRequestSerializerTypeJSON;
}

- (YTKResponseSerializerType)responseSerializerType {
    return YTKResponseSerializerTypeJSON;
}

@end


@implementation CCETHScanRequest

- (NSString *)baseUrl {
    return CC_ETH_EXPLORER;
}

- (NSString *)requestUrl {
    return @"api?module=account";
}

- (BOOL)statusCodeValidator {
    return YES;
}

- (YTKRequestMethod)method {
    return YTKRequestMethodGET;
}

- (YTKRequestSerializerType)requestSerializerType {
    return YTKRequestSerializerTypeJSON;
}

- (YTKResponseSerializerType)responseSerializerType {
    return YTKResponseSerializerTypeHTTP;
}

@end
