//
//  CCNEOApi.m
//  Karathen
//
//  Created by Karathen on 2018/9/3.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCNEOApi.h"
#import "YTKBatchRequest.h"
#import "CCNEOAccount.h"
#import <neoutils/neoutils.h>
#import "NSData+Extend.h"
#import "CCTokenInfoRequest.h"

static CCNEOApi *manager = nil;

@interface CCNEOApi ()

@property (nonatomic, strong) CCNEORequest *request;

@end

@implementation CCNEOApi

+ (instancetype)manager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[CCNEOApi alloc] init];
    });
    return manager;
}

#pragma mark - getBalance
- (void)getBalanceWithAddress:(NSString *)address
                       tokens:(NSArray *)tokens
                   completion:(void(^)(NSArray <NSDictionary *> *balance))completion {
    NSMutableArray *requestArray = [NSMutableArray array];
    for (NSString *token in tokens) {
        CCNEORequest *requset = [[CCNEORequest alloc] init];
        requset.parameter = @{
                              @"id":@"1",
                              @"method":@"getBalance",
                              @"jsonrpc":@"2.0",
                              @"params":@[address,token]
                              };
        [requestArray addObject:requset];
    }
    YTKBatchRequest *batchRequest = [[YTKBatchRequest alloc] initWithRequestArray:requestArray];
    [batchRequest startWithCompletionBlockWithSuccess:^(YTKBatchRequest * _Nonnull batchRequest) {
        NSMutableArray *balances = [NSMutableArray array];
        for (YTKRequest *request in batchRequest.requestArray) {
            NSArray *array = request.requestArgument[@"params"];
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setValue:array.lastObject forKey:@"tokenAddress"];
            [dic setValue:request.responseObject[@"result"]?:@"0" forKey:@"balance"];
            [balances addObject:dic];
        }
        if (completion) {
            completion(balances);
        }
    } failure:^(YTKBatchRequest * _Nonnull batchRequest) {
        if (completion) {
            completion(nil);
        }
    }];
}

#pragma mark - 获取地址下有余额的资产
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

#pragma mark - 转账
- (void)transferAccount:(CCNEOAccount *)account
            fromAddress:(NSString *)fromAddress
                  toAddress:(NSString *)toAddress
                     number:(NSString *)number
               tokenAddress:(NSString *)tokenAddress
                 completion:(void(^)(BOOL suc,NSString *txId))completion {
    CCNEORequest *transferRequest = [[CCNEORequest alloc] init];
    transferRequest.parameter = @{
                               @"id":@"1",
                               @"method":@"constructTx",
                               @"jsonrpc":@"2.0",
                               @"params":@[fromAddress,toAddress,number,tokenAddress]
                               };
    YTKChainRequest *chainReq = [[YTKChainRequest alloc] init];
    [chainReq addRequest:transferRequest callback:^(YTKChainRequest * _Nonnull chainRequest, YTKBaseRequest * _Nonnull baseRequest) {
        NSDictionary *responseObject = baseRequest.responseObject;
        if (responseObject[@"error"] || !responseObject[@"result"]) {
            completion(NO,nil);
        } else {
            responseObject = responseObject[@"result"];
            NSString *txDataString = responseObject[@"txData"];
            NSString *txId = responseObject[@"txid"];
            NSString *witness = responseObject[@"witness"];
            //签名
            NSData *txData = [NSData convertHexStrToData:txDataString];

            NSData *sig = NeoutilsSign(txData, account.privateKey.data.hexString, NULL);
            
            NSMutableString *witnessMul = [witness mutableCopy];
            NSRange signRange = [witnessMul rangeOfString:@"{signature}"];
            [witnessMul replaceCharactersInRange:signRange withString:sig.hexString];
            
            NSString *publicKey = account.publicKey.data.hexString;
            NSRange publicRange = [witnessMul rangeOfString:@"{pubkey}"];
            [witnessMul replaceCharactersInRange:publicRange withString:publicKey];
            NSString *sendRaw = [NSString stringWithFormat:@"%@%@",txDataString,witnessMul];
            
            DLog(@"公钥 - %@",publicKey);
            DLog(@"私钥 - %@",account.privateKey.data.hexString);
            DLog(@"地址 - %@",account.address.address);
            
            CCNEORequest *txRequest = [[CCNEORequest alloc] init];
            txRequest.parameter = @{
                                    @"id":@"1",
                                    @"method":@"sendRawTx",
                                    @"jsonrpc":@"2.0",
                                    @"params":@[sendRaw]
                                    };
            [chainRequest addRequest:txRequest callback:^(YTKChainRequest * _Nonnull chainRequest, YTKBaseRequest * _Nonnull baseRequest) {
                DLog(@"%@",baseRequest.responseObject);
                BOOL result = [baseRequest.responseObject[@"result"] boolValue];
                completion(result,txId);
            }];
        }
    }];
    chainReq.chainRequestFailed = ^(YTKChainRequest * _Nonnull chainRequest, YTKBaseRequest * _Nonnull failRequest) {
        completion(NO,nil);
    };
    [chainReq start];
}



#pragma mark - 获取Gas
- (void)getGasWithAddress:(NSString *)address
               completion:(void(^)(BOOL suc,NSString *allGas,NSString *claimedGas,NSString *unClaimedGas))completion {
    //查询所有的
    CCNEOScanRequest *allRequest = [[CCNEOScanRequest alloc] init];
    allRequest.urlStr = [NSString stringWithFormat:@"get_unclaimed/%@",address];
    YTKChainRequest *chainReq = [[YTKChainRequest alloc] init];
    [chainReq addRequest:allRequest callback:^(YTKChainRequest * _Nonnull chainRequest, YTKBaseRequest * _Nonnull baseRequest) {
        NSNumber *allResult = baseRequest.responseObject[@"unclaimed"]?:@(0);
        NSDecimalNumber *allNum = [[NSDecimalNumber alloc] initWithDecimal:[allResult decimalValue]];
        DLog(@"所有gas = %@",allNum.stringValue);
        //查询可提取
        CCNEOScanRequest *claimableGas = [[CCNEOScanRequest alloc] init];
        claimableGas.urlStr = [NSString stringWithFormat:@"get_claimable/%@",address];
        [chainRequest addRequest:claimableGas callback:^(YTKChainRequest * _Nonnull chainRequest, YTKBaseRequest * _Nonnull baseRequest) {
            NSNumber *claimableResult = baseRequest.responseObject[@"unclaimed"]?:@(0);
            NSDecimalNumber *claimableNum = [[NSDecimalNumber alloc] initWithDecimal:[claimableResult decimalValue]];
            DLog(@"可提取gas = %@",claimableNum.stringValue);
            
            NSDecimalNumber *unClaimedGasNum = [allNum decimalNumberBySubtracting:claimableNum];
            DLog(@"不可提取gas = %@",unClaimedGasNum.stringValue);
            
            completion(YES,allNum.stringValue,claimableNum.stringValue,unClaimedGasNum.stringValue);
        }];
    }];
    chainReq.chainRequestFailed = ^(YTKChainRequest * _Nonnull chainRequest, YTKBaseRequest * _Nonnull failRequest) {
        completion(NO,@"0",@"0",@"0");
    };
    
    [chainReq start];
}

#pragma mark - 提取Gas
- (void)claimGasWalletData:(CCWalletData *)walletData
                  password:(NSString *)password
                completion:(void (^)(BOOL suc, CCWalletError error))completion {
    @weakify(self)
    [[CCDataManager dataManager] walletInfoWithAccountID:walletData.wallet.accountID password:password completion:^(NSString *walletInfo) {
        @strongify(self)
        [self claimGasWalletData:walletData walletInfo:walletInfo completion:completion];
    }];

}

- (void)claimGasWalletData:(CCWalletData *)walletData
                walletInfo:(NSString *)walletInfo
                completion:(void (^)(BOOL suc, CCWalletError error))completion {
    if (!walletInfo) {
        if (completion) {
            completion(NO,CCWalletErrorPWD);
        }
        return;
    }
    CCNEOAccount *account;
    switch (walletData.importType) {
        case CCImportTypeSeed:
        case CCImportTypeMnemonic:
            account = [[CCNEOAccount alloc] initWithMnemonic:walletInfo slot:walletData.wallet.slot];
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
    
    CCNEORequest *claimRequest = [[CCNEORequest alloc] init];
    claimRequest.parameter = @{
                               @"id":@"1",
                               @"method":@"extractGas",
                               @"jsonrpc":@"2.0",
                               @"params":@[account.address.address]
                               };
    YTKChainRequest *chainReq = [[YTKChainRequest alloc] init];
    [chainReq addRequest:claimRequest callback:^(YTKChainRequest * _Nonnull chainRequest, YTKBaseRequest * _Nonnull baseRequest) {
        NSDictionary *responseObject = baseRequest.responseObject;
        if (responseObject[@"error"] || !responseObject[@"result"]) {
            completion(NO,CCWalletClaimGasFail);
        } else {
            DLog(@"提取GAS签名");
            responseObject = responseObject[@"result"];
            NSString *txDataString = responseObject[@"txData"];
            NSString *witness = responseObject[@"witness"];
            //签名
            NSData *txData = [NSData convertHexStrToData:txDataString];
            
            NSData *sig = NeoutilsSign(txData, account.privateKey.data.hexString, NULL);
            
            NSMutableString *witnessMul = [witness mutableCopy];
            NSRange signRange = [witnessMul rangeOfString:@"{signature}"];
            [witnessMul replaceCharactersInRange:signRange withString:sig.hexString];
            
            NSString *publicKey = account.publicKey.data.hexString;
            NSRange publicRange = [witnessMul rangeOfString:@"{pubkey}"];
            [witnessMul replaceCharactersInRange:publicRange withString:publicKey];
            NSString *sendRaw = [NSString stringWithFormat:@"%@%@",txDataString,witnessMul];
            
            
            CCNEORequest *txRequest = [[CCNEORequest alloc] init];
            txRequest.parameter = @{
                                    @"id":@"1",
                                    @"method":@"sendRawTx",
                                    @"jsonrpc":@"2.0",
                                    @"params":@[sendRaw]
                                    };
            [chainRequest addRequest:txRequest callback:^(YTKChainRequest * _Nonnull chainRequest, YTKBaseRequest * _Nonnull baseRequest) {
                DLog(@"%@",baseRequest.responseObject);
                BOOL result = [baseRequest.responseObject[@"result"] boolValue];
                completion(result,result?CCWalletClaimGasSuccess:CCWalletClaimGasFail);
            }];
        }
    }];
    chainReq.chainRequestFailed = ^(YTKChainRequest * _Nonnull chainRequest, YTKBaseRequest * _Nonnull failRequest) {
        completion(NO,CCWalletClaimGasFail);
    };
    [chainReq start];
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

#pragma mark - 获取交易详情
- (void)getNEOTransactionWithTxid:(NSString *)txId
                       completion:(void(^)(NSDictionary *info))completion {
    if ([txId hasPrefix:@"0x"]) {
        txId = [txId substringFromIndex:2];
    }
    CCNEOScanRequest *request = [[CCNEOScanRequest alloc] init];
    request.urlStr = [NSString stringWithFormat:@"get_transaction/%@",txId];
    [request startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        completion(request.responseObject);
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        completion(nil);
    }];
}

#pragma mark - 获取交易状态
- (void)getNEOTransactionStatusWithTxIds:(NSArray *)txIds
                              completion:(void(^)(NSDictionary *statusDic))completion {
    NSMutableArray *requestArray = [NSMutableArray array];
    for (NSString *txId in txIds) {
        CCNEORequest *requset = [[CCNEORequest alloc] init];
        requset.parameter = @{
                              @"id":@"1",
                              @"method":@"getApplicationLog",
                              @"jsonrpc":@"2.0",
                              @"params":@[[txId hasPrefix:@"0x"]?[txId substringFromIndex:2]:txId]
                              };
        [requestArray addObject:requset];
    }
    YTKBatchRequest *batchRequest = [[YTKBatchRequest alloc] initWithRequestArray:requestArray];
    [batchRequest startWithCompletionBlockWithSuccess:^(YTKBatchRequest * _Nonnull batchRequest) {
        NSMutableDictionary *statusDic = [NSMutableDictionary dictionary];
        for (YTKRequest *request in batchRequest.requestArray) {
            NSArray *array = request.requestArgument[@"params"];
            id result = request.responseObject[@"result"];
            if ([result respondsToSelector:@selector(boolValue)]) {
                NSString *txId = array.lastObject;
                [statusDic setValue:@([result boolValue]) forKey:[NSString stringWithFormat:@"0x%@",txId]];
            }
        }
        if (completion) {
            completion(statusDic);
        }
    } failure:^(YTKBatchRequest * _Nonnull batchRequest) {
        if (completion) {
            completion(nil);
        }
    }];
}

#pragma mark - get
- (CCNEORequest *)request {
    if (!_request) {
        _request = [[CCNEORequest alloc] init];
    }
    return _request;
}

@end


@implementation CCNEORequest

- (NSString *)baseUrl {
    return CC_NEO_BASEURL;
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


@implementation CCNEOScanRequest

- (NSString *)baseUrl {
    return CC_NEO_EXPLORER;
}

- (YTKRequestMethod)method {
    return YTKRequestMethodGET;
}

- (YTKRequestSerializerType)requestSerializerType {
    return YTKRequestSerializerTypeHTTP;
}

- (YTKResponseSerializerType)responseSerializerType {
    return YTKResponseSerializerTypeJSON;
}

@end
